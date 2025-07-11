public with sharing class Etech_InvocableSendToEtech {
    public class FlowInputs {
        @InvocableVariable(label='Intake Record Id' required=true) public string intakeId;
    }

    @InvocableMethod(label='ETECH API: Send to Etech Dialer')
    public static void submitToEtech(List<FlowInputs> requests){
        List<string> intakeIds = new List<string>();
        for(FlowInputs request : requests){
           intakeIds.add(request.intakeId);
        }
            
        asyncSubmit(intakeIds);
    }
    
    @future (callout=true)
    private static void asyncSubmit(List<string> intakeIds){
        List<litify_pm__Intake__c> intakes = [SELECT Id, Name 
                                            , Telephony_API_Description__c, Telephony_API_Error__c, Telephony_API_External_ID__c
                                            , litify_pm__Client__c, litify_pm__Client__r.litify_pm__First_Name__c, litify_pm__Client__r.litify_pm__Last_Name__c
                                            , litify_pm__Client__r.Phone, litify_pm__Client__r.litify_pm__Email__c
                                            , litify_pm__Client__r.BillingPostalCode
                                            , litify_pm__Case_Type__r.Name, Campaign__r.Name
                                            FROM litify_pm__Intake__c 
                                            WHERE Id IN :intakeIds];
        for(litify_pm__Intake__c intake : intakes){
            // Call the Etech API here using the provided intakeId
            System.debug('Submitting to Etech for Intake ID: ' + intake.Id);
            Etech_RestAPIWrapper apiWrapper = new Etech_RestAPIWrapper();
            Etech_Models.RequestModel request = new Etech_Models.RequestModel();
            request.IntakeExternalId = intake.Id;
            request.CampaignCaseExternalId = ''; // IGNORE/EXCLUDE
            request.ClientExternalId = intake.litify_pm__Client__c;
            request.First_Name = intake.litify_pm__Client__r.litify_pm__First_Name__c;
            request.Last_Name = intake.litify_pm__Client__r.litify_pm__Last_Name__c;
            request.Phone_Number = intake.litify_pm__Client__r.Phone;
            request.Email_Address = intake.litify_pm__Client__r.litify_pm__Email__c;
            //Updated CS 06-18-2025 Postal_Code to send as blank string if null
            request.Postal_Code = String.isNotBlank(intake.litify_pm__Client__r.BillingPostalCode)
				? intake.litify_pm__Client__r.BillingPostalCode
				: '';
            request.Case_Type = intake.litify_pm__Case_Type__r.Name;
            request.Campaign_Name = intake.Campaign__r.Name;

            intake.Telephony_API_Description__c = 'Etech';
            try {
                Etech_Models.ResponseWrapperModel response = apiWrapper.sendToEtech(request, intake.Id);
                if(response.success) {
                    Etech_Models.ResponseModel responseData = (Etech_Models.ResponseModel) JSON.deserialize(response.data, Etech_Models.ResponseModel.class);

                    if(responseData.RecordId == null || (responseData.Errors != null && !responseData.Errors.isEmpty())){
                        intake.Telephony_API_Error__c = 'Etech API Error: ' + (responseData.Errors != null ? String.join(responseData.Errors, ', ') : 'Unknown error');
                    }
                    else{
                        intake.Telephony_API_External_ID__c = responseData.RecordId;
                    }
                }
                else {
                    intake.Telephony_API_Error__c = 'Etech API Error: ' + response.data;
                }
            }
            catch(Exception e) {
                System.debug('Error while submitting to Etech: ' + e.getMessage());
                intake.Telephony_API_Error__c = 'Etech API Error: ' + e.getMessage();
            }
        }

        update intakes;
        Etech_Logger.writeLogs();
    }    
}