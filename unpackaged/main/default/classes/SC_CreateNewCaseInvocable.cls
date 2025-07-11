public with sharing class SC_CreateNewCaseInvocable {
    private static SC_APIModels.Constant CONSTANT = new SC_APIModels.Constant();

    public class FlowInputs {
        @InvocableVariable(label='Intake Record ID' required=true) public string intakeId;
        @InvocableVariable(label='Required Main File Info Record Id' required=true) public string requiredFileId;
        @InvocableVariable(label='Other File Info Record Ids') public List<string> otherFileIds;
    }

    @InvocableMethod(label='SIMPLY CONVERT API: CREATE NEW CASE')
    public static void createNewCase(List<FlowInputs> request){
        string intakeId = request[0].intakeId;
        string requiredFileId = request[0].requiredFileId;
        List<string> otherFileIds = request[0].otherFileIds;
        submitAsync(intakeId, requiredFileId, otherFileIds);
    }

    @future(callout=true)
    private static void submitAsync(string intakeId, string requiredFileId, List<string> otherFileIds){
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Caller__r.BillingCity
                                                , Caller__r.BillingPostalCode
                                                , Caller__r.BillingState
                                                , Caller__r.BillingStreet
                                                , Caller__r.Emergency_Contact_Name__c
                                                , Caller__r.Emergency_Contact_Phone__c
                                                , Caller__r.litify_pm__Email__c
                                                , Caller__r.litify_pm__First_Name__c
                                                , Caller__r.litify_pm__Last_Name__c
                                                , Caller__r.litify_pm__Phone_Home__c
                                                , Caller__r.litify_pm__Phone_Mobile__c
                                                , Caller__r.litify_pm__Phone_Other__c
                                                , Caller__r.litify_pm__Social_Security_Number__c
                                                , Caller__r.Marital_Status__c
                                                , Caller__r.Middle_Name__c
                                                , Caller__r.Secondary_Email__c
                                                , Caller__r.Suffix__c
                                                , litify_pm__Client__r.Name
                                                , litify_pm__Client__r.BillingPostalCode
                                                , litify_pm__Client__r.BillingState
                                                , litify_pm__Client__r.BillingStreet
                                                , litify_pm__Client__r.Date_of_Death__c
                                                , litify_pm__Client__r.litify_pm__Date_of_birth__c
                                                , litify_pm__Client__r.litify_pm__Email__c
                                                , litify_pm__Client__r.litify_pm__First_Name__c
                                                , litify_pm__Client__r.litify_pm__Last_Name__c
                                                , litify_pm__Client__r.litify_pm__Phone_Mobile__c
                                                , litify_pm__Client__r.litify_pm__Social_Security_Number__c
                                                , litify_pm__Client__r.Middle_Name__c
                                                , litify_pm__Client__r.Suffix__c
                                                , litify_pm__Client__r.BillingCity
                                                , Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c
                                                , Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c
                                                , Camp_Lejuene__r.How_long_did_you_stay_at_Camp_Lejuene__c
                                                , Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c
                                                , Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c
                                                , Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c
                                                , Camp_Lejuene__r.Estimate_Dates_at_Camp_Lejuene__c
                                                , Camp_Lejuene__r.NE_NPD_Details__c
                                                , Campaign_Partner__r.API_Integration_Description__c
                                                , What_is_your_relation_to_this_individual__c
                                                , State__c
                                                , litify_pm__Description__c
                                                , litify_pm__Statute_of_Limitations_Date__c
                                                , Signing_authority_as__c
                                                , litify_pm__Status__c
                                                , Referral_Partner_API_External_ID__c
                                                , Referral_Partner_API_Description__c
                                                , Referral_Partner_API_Error__c
                                                , Calling_on_behalf_of_you_or_loved_one__c
                                                , Confirm_if_caller_is_next_of_kin__c
                                                , Does_caller_have_authority_to_sign__c
                                              FROM litify_pm__Intake__c
                                              WHERE Id = :intakeId
                                              LIMIT 1];
        try{
            if(intakes != null && intakes.size() > 0){
                SC_APIModels.CaseResource newCaseRequest = BuildNewCaseRequest(intakes[0]);
                Map<string,object> caseResp = restApi.createCase(newCaseRequest);
                if(caseResp != null && Boolean.valueOf(caseResp.get('success'))){
                    string simpleConvertCaseId = string.valueOf(caseResp.get('data'));
    
                    // List<Map<string,object>> uploadResp = SC_FileUploadHandler.submitFiles(intakes[0].litify_pm__Client__r.Name, simpleConvertCaseId, requiredFileId, otherFileIds);
                    // new SC_Logger.Log(LoggingLevel.DEBUG, 'SC_CreateNewCaseInvocable: Document Uploaded', uploadResp);

                    SC_FileUploadHandler.submitFiles(intakes[0].litify_pm__Client__r.Name, simpleConvertCaseId, requiredFileId, otherFileIds);
                  
                    intakes[0].Referral_Partner_API_External_ID__c = simpleConvertCaseId;
                    intakes[0].Referral_Partner_API_Error__c = '';
                    intakes[0].Referral_Partner_API_Description__c = intakes[0].Campaign_Partner__c != null ? intakes[0].Campaign_Partner__r.API_Integration_Description__c : '';
                    intakes[0].litify_pm__Status__c = 'Referred Out'; // Set intake to Referred Out
                    update intakes[0];
                }
                else {
                    intakes[0].Referral_Partner_API_Error__c = string.valueOf(caseResp.get('data'));
                    intakes[0].Referral_Partner_API_Description__c = intakes[0].Campaign_Partner__c != null ? intakes[0].Campaign_Partner__r.API_Integration_Description__c : '';
                    update intakes[0];
                }
            }
            SC_Logger.writeLogs();
        }
        catch(Exception e){
            System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
            new SC_Logger.Log(LoggingLevel.ERROR, 'SC_CreateNewCaseInvocable', e.getMessage() + '\n\n' + e.getStackTraceString());
            SC_Logger.writeLogs();
        }
    }

    private static SC_APIModels.CaseResource BuildNewCaseRequest(litify_pm__Intake__c intake){
        SC_APIModels.CaseResource newCaseRequest = new SC_APIModels.CaseResource();
        newCaseRequest.referred_from_company_uuid = 'bc006f4c46e12c2f83268977b065f27476248b6b';
        newCaseRequest.referred_to_company_uuid = 'fc9d1751c6a1256a2ba8822ddb3437e6f1a01731';
        newCaseRequest.litigation_id = 116;
        newCaseRequest.status_id = 8;
        newCaseRequest.bot_language = 'en-US';
        newCaseRequest.tags = new List<string>{'f784cb45db2960bd856995ac392f83393dff4ff4'};
        
        newCaseRequest.birthday_injured = SC_Helper.formatDateToString(intake.litify_pm__Client__r.litify_pm__Date_of_birth__c);
        newCaseRequest.city = intake.Caller__r.BillingCity;
        newCaseRequest.city_address_injured = intake.litify_pm__Client__r.BillingCity;
        newCaseRequest.death_date = SC_Helper.formatDateToString(intake.litify_pm__Client__r.Date_of_Death__c);
        newCaseRequest.email = intake.Caller__r.litify_pm__Email__c;
        newCaseRequest.email2 = intake.Caller__r.Secondary_Email__c;
        newCaseRequest.email_injured = intake.litify_pm__Client__r.litify_pm__Email__c;
        newCaseRequest.fname = intake.Caller__r.litify_pm__First_Name__c;
        newCaseRequest.fname_injured = intake.litify_pm__Client__r.litify_pm__First_Name__c;
        newCaseRequest.lname = intake.Caller__r.litify_pm__Last_Name__c;
        newCaseRequest.lname_injured = intake.litify_pm__Client__r.litify_pm__Last_Name__c;
        newCaseRequest.marital_status = intake.Caller__r.Marital_Status__c;
        newCaseRequest.mname = intake.Caller__r.Middle_Name__c;
        newCaseRequest.mname_injured = intake.litify_pm__Client__r.Middle_Name__c;
        newCaseRequest.phone = intake.Caller__r.litify_pm__Phone_Mobile__c;
        newCaseRequest.phone2 = intake.Caller__r.litify_pm__Phone_Home__c;
        newCaseRequest.phone3 = intake.Caller__r.litify_pm__Phone_Other__c;
        newCaseRequest.phone_injured = intake.litify_pm__Client__r.litify_pm__Phone_Mobile__c;
        newCaseRequest.ssn = intake.Caller__r.litify_pm__Social_Security_Number__c;
        newCaseRequest.ssn_injured = intake.litify_pm__Client__r.litify_pm__Social_Security_Number__c;
        newCaseRequest.state = intake.Caller__r.BillingState;
        newCaseRequest.state_address_injured = intake.litify_pm__Client__r.BillingState;
        newCaseRequest.street1 = intake.Caller__r.BillingStreet;
        newCaseRequest.street1_address_injured = intake.litify_pm__Client__r.BillingStreet;
        newCaseRequest.suffix = intake.Caller__r.Suffix__c;
        newCaseRequest.suffix_injured = intake.litify_pm__Client__r.Suffix__c;
        newCaseRequest.zip = intake.Caller__r.BillingPostalCode;
        newCaseRequest.zip_address_injured = intake.litify_pm__Client__r.BillingPostalCode;

        newCaseRequest.relation = intake.Calling_on_behalf_of_you_or_loved_one__c == 'Self' ? 'myself' : intake.What_is_your_relation_to_this_individual__c;
        newCaseRequest.state_injured = intake.State__c;
        newCaseRequest.details = intake.litify_pm__Description__c + '\n' + intake.Camp_Lejuene__r.NE_NPD_Details__c;
        newCaseRequest.sol_trigger_date = SC_Helper.formatDateToString(intake.litify_pm__Statute_of_Limitations_Date__c);
        
        newCaseRequest.conditions = new List<Integer>();
        string issue = intake.Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c;
        if(!string.isBlank(issue) && !string.isEmpty(issue)){
            List<string> issues = issue.split(';');
            for(string i : issues){
                Integer cvIssue = SC_JSONValueMap.mapCondition(i);
                if(cvIssue != null){
                    newCaseRequest.conditions.add(cvIssue);
                }
            }
        }

        newCaseRequest.information = new List<Integer>();
        Integer info1 = SC_JSONValueMap.mapInformation(intake.Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c);
        Integer info2 = SC_JSONValueMap.mapInformation(intake.Camp_Lejuene__r.How_long_did_you_stay_at_Camp_Lejuene__c);
        Integer info3 = (newCaseRequest.relation == 'myself' 
        || intake.Does_caller_have_authority_to_sign__c == 'Yes'
        || intake.Confirm_if_caller_is_next_of_kin__c == 'The caller is the formal next of kin (when through all levels and they are the next in line)')
        ? 1056 : null;
        Integer info4 = SC_JSONValueMap.mapInformation(intake.Camp_Lejuene__r.Estimate_Dates_at_Camp_Lejuene__c);
        if(info1 != null){
            newCaseRequest.information.add(info1);
        }
        if(info2 != null){
            newCaseRequest.information.add(info2);
        }
        if(info3 != null){
            newCaseRequest.information.add(info3);
        }
        if(info4 != null){
            newCaseRequest.information.add(info4);
        }

        newCaseRequest.meta = new SC_APIModels.Meta();
        newCaseRequest.meta.emergencyContactName = intake.Caller__r.Emergency_Contact_Name__c;
        newCaseRequest.meta.emergencyContactPhone = intake.Caller__r.Emergency_Contact_Phone__c;
        newCaseRequest.meta.agentCapacity = SC_JSONValueMap.mapAgentCapacity(intake.Signing_authority_as__c);
        newCaseRequest.meta.campDates = new List<Map<string,object>>();
        Map<string,object> campDate = new Map<string,object>{
            'dateTime' => intake.Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c,
            'dateTime1' => intake.Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c
        };
        newCaseRequest.meta.campDates.add(campDate);

        newCaseRequest.meta.campLocations = new Map<string,object>();
        string campLoc = intake.Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c;
        if(!string.isBlank(campLoc) && !string.isEmpty(campLoc)){
            List<string> campLocs = campLoc.split(';');
            List<string> convertedLocs = new List<string>();
            for(string l : campLocs){
                string cvLoc = SC_JSONValueMap.mapLocation(l);
                if(cvLoc != null){
                    convertedLocs.add(cvLoc);
                }
            }
            for(string loc : CONSTANT.campLocationList){
                if(convertedLocs != null && convertedLocs.contains(loc)){
                    newCaseRequest.meta.campLocations.put(loc, 'true');
                }
                else {
                    newCaseRequest.meta.campLocations.put(loc, 'false');
                }
            }
        }

        newCaseRequest.external_data = new Map<string,object>();
        newCaseRequest.external_data.put('litify_1519', new Map<string,string>{
            'id' => intake.Id
        });

        return newCaseRequest;
    }
}