public class BridgeLegalAPI_CreateMatterInvocable {
    public class FlowInputs {
        @InvocableVariable(label='Intake Record ID' required=true) public string intakeId;
        @InvocableVariable(label='External Sharing Link') public string externalSharingLink;
        @InvocableVariable(label='Signed Retainer Record ID') public string selectedRetainerId;
    }

    @InvocableMethod(label='BRIDGE LEGAL API: CREATE MATTER')
    public static void submitToBridgeLegal(List<FlowInputs> request){
        System.debug('### BridgeLegalAPI_CreateMatterInvocable ###');
        string intakeId = request[0].intakeId;
        string externalSharingLink = request[0].externalSharingLink;
        string selectedRetainerId = request[0].selectedRetainerId;
        submitAsync(intakeId, externalSharingLink, selectedRetainerId);
    }

    @future(callout=true)
    private static void submitAsync(string intakeId, string externalSharingLink, string selectedRetainerId){
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                              , litify_pm__Client__r.Name
                                              , litify_pm__Client__r.litify_pm__First_Name__c
                                              , litify_pm__Client__r.litify_pm__Last_Name__c
                                              , litify_pm__Client__r.Phone
                                              , litify_pm__Client__r.litify_pm__Email__c
                                              , litify_pm__Client__r.BillingStreet
                                              , litify_pm__Client__r.BillingCity
                                              , litify_pm__Client__r.BillingState
                                              , litify_pm__Client__r.BillingPostalCode
                                              , litify_pm__Client__r.litify_pm__Social_Security_Number__c
                                              , litify_pm__Client__r.Date_of_Death__c
                                              , litify_pm__Client__r.Cause_of_Death__c
                                              , Camp_Lejuene__r.Branch_of_Service__c
                                              , Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c
                                              , Camp_Lejuene__r.Military_Personnel_Place_of_Birth__c
                                              , Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c
                                              , Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c
                                              , Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c
                                              , Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c
                                              , Campaign_Partner__r.API_Integration_Description__c
                                              , FX_Id__c
                                              , What_is_your_relation_to_this_individual__c
                                              , Confirm_if_caller_is_next_of_kin__c
                                              , litify_pm__Description__c
                                              , Referral_Partner_API_Description__c
                                              , litify_pm__Status__c
                                              FROM litify_pm__Intake__c
                                              WHERE Id = :intakeId
                                              LIMIT 1];
        if(intakes != null && intakes.size() > 0){
            Map<string,string> paramMap = new Map<string,string>{
                'firstName' => intakes[0].litify_pm__Client__r.litify_pm__First_Name__c,
                'lastName' => intakes[0].litify_pm__Client__r.litify_pm__Last_Name__c,
                'phone' => intakes[0].litify_pm__Client__r.Phone,
                'email' => intakes[0].litify_pm__Client__r.litify_pm__Email__c,
                'address' => intakes[0].litify_pm__Client__r.BillingStreet,
                'city' => intakes[0].litify_pm__Client__r.BillingCity,
                'state' => intakes[0].litify_pm__Client__r.BillingState,
                'zipCode' => intakes[0].litify_pm__Client__r.BillingPostalCode,
                'matterType' => 'Camp Lejeune',
                'source' => 'Saddle Rock Legal Group',
                'ssnLast4' => intakes[0].litify_pm__Client__r.litify_pm__Social_Security_Number__c
            };
            Map<string,object> requestPayload = new Map<string,object>{
                'behalfOf' => intakes[0].litify_pm__Client__r.Name,
                'behalfRelation' => intakes[0].What_is_your_relation_to_this_individual__c,
                'behalfLegalRelation' => intakes[0].Confirm_if_caller_is_next_of_kin__c,
                'whyPointOfContact' => '',
                'causeOfDeath' => intakes[0].litify_pm__Client__r.Cause_of_Death__c,
                'birthLocationCity' => intakes[0].Camp_Lejuene__r.Military_Personnel_Place_of_Birth__c,
                'birthLocationState' => '',
                'deathDate' => intakes[0].litify_pm__Client__r.Date_of_Death__c,
                'deathOccurState' => '',
                'startDateAtCampLejeune' => intakes[0].Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c != null ? string.valueOf(intakes[0].Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c) : '',
                'endingDateAtCampLejeune' => intakes[0].Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c != null ? string.valueOf(intakes[0].Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c) : '',
                'civilianServiceMemberOrVeteran' => intakes[0].Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c,
                'locationLivedworkedAtCamp' => intakes[0].Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c,
                'branchServedMilitary' => intakes[0].Camp_Lejuene__r.Branch_of_Service__c,
                'serviceStartingDate' => '',
                'serviceEndingDate' => '',
                'caseSummary' => intakes[0].litify_pm__Description__c,
                'documentUrl' => externalSharingLink,
                'externalId2' => intakes[0].Id
            };
            List<Map<string,string>> cancerDigs = new List<Map<string,string>>();
            string cancerIssue = intakes[0].Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c;
            if(!string.isBlank(cancerIssue) && !string.isEmpty(cancerIssue)){
                List<string> issues = cancerIssue.split(';');
                for(string i : issues){
                    String cIssue = BridgeLegalAPI_JSONValueMap.mapCancerDiagnosed(i);
                    if(cIssue != null){
                        if(cIssue != 'adultLeukemia; childhoodLeukemia'){
                            Map<string,string> tempMap = new Map<string,string>{
                                'value' => cIssue
                            };
                            cancerDigs.add(tempMap);
                        }
                        else {
                            Map<string,string> tempMap = new Map<string,string>{
                                'value' => 'adultLeukemia'
                            };
                            cancerDigs.add(tempMap);
                            Map<string,string> tempMap1 = new Map<string,string>{
                                'value' => 'childhoodLeukemia'
                            };
                            cancerDigs.add(tempMap1);
                        }
                    }
                }
            }
            if(cancerDigs != null && cancerDigs.size() > 0){
                requestPayload.put('cancerDiagnosed', cancerDigs);
            }
            
            try {
                // Set intake to Referred Out
                intakes[0].Referral_Partner_API_Description__c = intakes[0].Campaign_Partner__r.API_Integration_Description__c;
                intakes[0].litify_pm__Status__c = 'Referred Out';

                // Submit data to create matter in Bridge Legal API
                BridgeLegalAPI_RestAPIWrapper restApi = new BridgeLegalAPI_RestAPIWrapper();
                Map<string,object> resp = restApi.createMatter(paramMap, requestPayload);
                if(resp != null && resp.get('success') != null && Boolean.valueOf(resp.get('success'))){
                    Map<string,object> dataParsed = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(resp.get('data')));
                    string bridgifyMatterID = string.valueOf(dataParsed.get('id'));
                    
                    intakes[0].Referral_Partner_API_External_ID__c = bridgifyMatterID;
     
                    // Submit signed retainer documents to Bridge Legal API
                    if(string.isNotEmpty(selectedRetainerId) && string.isNotBlank(selectedRetainerId)){
                        Map<string,object> docResp = BridgeLegalAPI_FileUploadHandler.uploadFiles(bridgifyMatterID, selectedRetainerId);                    
                        if(docResp.get('success') != null && Boolean.valueOf(docResp.get('success'))){
                            intakes[0].Referral_Partner_API_Error__c = '';
                            update intakes[0];
                        }
                        else {
                            intakes[0].Referral_Partner_API_Error__c = string.valueOf(docResp.get('data'));
                            update intakes[0];
                        }
                    }
                    else {
                        intakes[0].Referral_Partner_API_Error__c = '';
                        update intakes[0];
                    }
                }
                else {
                    intakes[0].Referral_Partner_API_Error__c = string.valueOf(resp.get('data'));
                    update intakes[0];
                }

                BridgeLegalAPI_Logger.writeLogs();
            }
            catch(Exception e){
                System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
                new BridgeLegalAPI_Logger.Log(LoggingLevel.ERROR, 'BridgeLegalAPI_CreateMatterInvocable', e.getMessage() + '\n\n' + e.getStackTraceString());
                BridgeLegalAPI_Logger.writeLogs();
            }
        }
    }
}