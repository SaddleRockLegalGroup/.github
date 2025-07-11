public class FV_CreateProjectInvocable {
    public class FlowInputs {
        @InvocableVariable(label='Intake Record ID' required=true) public string intakeId;
        @InvocableVariable(label='Retainer Record ID') public string retainerFileId;
        @InvocableVariable(label='Questionnaire Record ID') public string questionnaireFileId;
        @InvocableVariable(label='List of other file info Ids') public List<string> fileInfoIds;
    }

    @InvocableMethod(label='FILEVINE API: CREATE PROJECT')
    public static void submitToFilevineAPI(List<FlowInputs> request){
        System.debug('### FV_CreateProjectInvocable ###');
        string intakeId = request[0].intakeId;
        string retainerFileId = request[0].retainerFileId;
        string questionnaireFileId = request[0].questionnaireFileId;
        List<string> fileInfoIds = request[0].fileInfoIds;
        submitAsync(intakeId, retainerFileId, questionnaireFileId, fileInfoIds);
    }

    @future(callout=true)
    private static void submitAsync(string intakeId, string retainerFileId, string questionnaireFileId, List<string> fileInfoIds){
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                            , Campaign_Partner__c
                                            , Campaign_Partner__r.API_Integration_Description__c
                                            , Caller__c
                                            , Caller__r.Emergency_Contact_Name__c
                                            , Caller__r.Emergency_Contact_Relationship__c
                                            , Caller__r.Emergency_Contact_Phone__c
                                            , Caller__r.Date_of_Death__c
                                            , Caller__r.litify_pm__First_Name__c
                                            , Caller__r.Middle_Name__c
                                            , Caller__r.litify_pm__Last_Name__c
                                            , Caller__r.litify_pm__Email__c
                                            , Caller__r.Secondary_Email__c
                                            , Caller__r.litify_pm__Phone_Mobile__c
                                            , Caller__r.litify_pm__Phone_Home__c
                                            , Caller__r.litify_pm__Phone_Work__c
                                            , Caller__r.BillingStreet
                                            , Caller__r.BillingCity
                                            , Caller__r.BillingState
                                            , Caller__r.BillingPostalCode
                                            , Caller__r.Best_time_to_reach_client__c
                                            , Caller__r.litify_pm__Date_of_birth__c
                                            , Caller__r.litify_pm__Social_Security_Number__c
                                            , Preferred_Method_of_Contact__c
                                            , litify_pm__Client__c
                                            , litify_pm__Client__r.Date_of_Death__c
                                            , litify_pm__Client__r.litify_pm__First_Name__c
                                            , litify_pm__Client__r.Middle_Name__c
                                            , litify_pm__Client__r.litify_pm__Last_Name__c
                                            , litify_pm__Client__r.litify_pm__Email__c
                                            , litify_pm__Client__r.Secondary_Email__c
                                            , litify_pm__Client__r.litify_pm__Phone_Mobile__c
                                            , litify_pm__Client__r.litify_pm__Phone_Home__c
                                            , litify_pm__Client__r.litify_pm__Phone_Work__c
                                            , litify_pm__Client__r.BillingStreet
                                            , litify_pm__Client__r.BillingCity
                                            , litify_pm__Client__r.BillingState
                                            , litify_pm__Client__r.BillingPostalCode
                                            , litify_pm__Client__r.Best_time_to_reach_client__c
                                            , litify_pm__Client__r.litify_pm__Date_of_birth__c
                                            , litify_pm__Client__r.litify_pm__Social_Security_Number__c
                                            , litify_pm__Client__r.Name
                                            , Referral_Partner_API_Error__c
                                            , Referral_Partner_API_External_ID__c
                                              FROM litify_pm__Intake__c
                                              WHERE Id = :intakeId
                                              LIMIT 1];
        if(intakes != null && intakes.size() > 0){
            try {
                //////////////////////////////////////////////
                // 0. Authenticate
                // 1. CUSTOM CONTACT: Create emergency contact (if applicable)
                // 2. CUSTOM CONTACT: Create caller (include emergency contact above if applicable)
                // 3. CUSTOM CONTACT: Create client (if not same as caller)
                // 4. PROJECT: Create project (include caller above)
                // ---------
                // 5. PROJECT: Update project form - Initial Intake
                // 6. PROJECT: Update project form - Mass Tort Info
                // ---------
                // 7. DOCUMENTS: Create URL for document upload (One callout for each document)
                // 8. DOCUMENTS: Upload document (One callout for each document)
                // 9. DOCUMENTS: Link document to project (One callout for each document)
                // ---------
                // 5 or 10. PROJECT: Update project form - Case Summary (include client above if not same as caller, include retainer and questionnaire doc IDs)
                //////////////////////////////////////////////

                // Set intake to Referred Out
                intakes[0].Referral_Partner_API_Description__c = intakes[0].Campaign_Partner__c != null ? intakes[0].Campaign_Partner__r.API_Integration_Description__c : '';
                intakes[0].litify_pm__Status__c = 'Referred Out';

                FV_RestAPIWrapper restApi = new FV_RestAPIWrapper();
                // 0. Authenticate
                FV_Models.HttpResponseWrapper loginInfoResp = FV_RestAPIWrapper.createSession();
                if(loginInfoResp.success){
                    string fvEmergencyContactId = '';
                    FV_Models.LoginRespModel loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(loginInfoResp.data, FV_Models.LoginRespModel.class);
                    // 1. CUSTOM CONTACT: Create emergency contact (if applicable)
                    if(!string.isBlank(intakes[0].Caller__r.Emergency_Contact_Name__c) && string.isNotEmpty(intakes[0].Caller__r.Emergency_Contact_Name__c)
                    && ((!string.isBlank(intakes[0].Caller__r.Emergency_Contact_Phone__c) && string.isNotEmpty(intakes[0].Caller__r.Emergency_Contact_Phone__c))
                        || (!string.isBlank(intakes[0].Caller__r.Emergency_Contact_Relationship__c) && string.isNotEmpty(intakes[0].Caller__r.Emergency_Contact_Relationship__c)))){
                        List<Map<string,object>> emergencyContact = FV_PayloadBuilder.buildEmergencyContactPayload(intakes[0]);
                        FV_Models.HttpResponseWrapper emergencyContactResp = restApi.createCustomContact(emergencyContact, loginInfo);
                        if(emergencyContactResp.success){
                            FV_Models.Contact emergencyContactParsed = (FV_Models.Contact) JSON.deserialize(emergencyContactResp.data, FV_Models.Contact.class);
                            fvEmergencyContactId = emergencyContactParsed.personId.native;
                        }
                    }
                    // 2. CUSTOM CONTACT: Create caller (include emergency contact above if applicable)
                    List<Map<string,object>> caller = FV_PayloadBuilder.buildCallerPayload(intakes[0], fvEmergencyContactId);
                    FV_Models.HttpResponseWrapper callerResp = restApi.createCustomContact(caller, loginInfo);
                    if(callerResp.success){
                        FV_Models.Contact callerParsed = (FV_Models.Contact) JSON.deserialize(callerResp.data, FV_Models.Contact.class);
                        
                        // 4. PROJECT: Create project (include caller above) - Client same as caller (SKIP 3.)
                        if(intakes[0].Caller__c == intakes[0].litify_pm__Client__c){
                            Map<string,object> project = FV_PayloadBuilder.buildProjectPayload(intakes[0], callerParsed.personId.native);
                            FV_Models.HttpResponseWrapper projectResp = restApi.createProject(project, loginInfo);
                            if(projectResp.success){
                                FV_Models.Project projectParsed = (FV_Models.Project) JSON.deserialize(projectResp.data, FV_Models.Project.class);
                                
                                // 5. PROJECT: Update project form - Initial Intake
                                // 6. PROJECT: Update project form - Mass Tort Info
                                // Schedule FV_BatchUpdateProjectForm batch to handle 5, 6
                                intakes[0].Referral_Partner_API_External_ID__c = projectParsed.projectId.native;
                                intakes[0].Referral_Partner_API_Error__c = '';
                                update intakes[0];

                                FV_SchBatchUpdateProjectForm.schedule(intakes[0].Id, projectParsed.projectId.native);

                                // 7. DOCUMENTS: Create URL for document upload
                                // 8. DOCUMENTS: Upload document
                                // 9. DOCUMENTS: Link document to project
                                // Schedule FV_UploadDocument batch to handle 7, 8, 9
                                if(fileInfoIds != null && fileInfoIds.size() > 0){
                                    FV_SchBatchUploadDocument.schedule(fileInfoIds, projectParsed.projectId.native);
                                }
                                
                                // 10. PROJECT: Update project form - Case Summary (include client above if not same as caller)
                                FV_SchBatchUploadDocumentSummary.schedule(intakes[0].Id, projectParsed.projectId.native, retainerFileId, questionnaireFileId, callerParsed.personId.native, callerParsed.personId.native);
                            }
                            else {
                                intakes[0].Referral_Partner_API_Error__c = projectResp.data;
                                update intakes[0];
                            }
                        }
                        else {
                            // 3. CUSTOM CONTACT: Create client (if not same as caller)
                            List<Map<string,object>> client = FV_PayloadBuilder.buildClientPayload(intakes[0]);
                            FV_Models.HttpResponseWrapper clientResp = restApi.createCustomContact(client, loginInfo);
                            if(clientResp.success){
                                FV_Models.Contact clientParsed = (FV_Models.Contact) JSON.deserialize(clientResp.data, FV_Models.Contact.class);
                                // 4. PROJECT: Create project (include caller above)
                                Map<string,object> project = FV_PayloadBuilder.buildProjectPayload(intakes[0], callerParsed.personId.native);
                                FV_Models.HttpResponseWrapper projectResp = restApi.createProject(project, loginInfo);
                                if(projectResp.success){
                                    FV_Models.Project projectParsed = (FV_Models.Project) JSON.deserialize(projectResp.data, FV_Models.Project.class);
                                    
                                    // 5. PROJECT: Update project form - Initial Intake
                                    // 6. PROJECT: Update project form - Mass Tort Info
                                    // Schedule FV_BatchUpdateProjectForm batch to handle 5, 6
                                    intakes[0].Referral_Partner_API_External_ID__c = projectParsed.projectId.native;
                                    intakes[0].Referral_Partner_API_Error__c = '';
                                    update intakes[0];

                                    FV_SchBatchUpdateProjectForm.schedule(intakes[0].Id, projectParsed.projectId.native);

                                    // 7. DOCUMENTS: Create URL for document upload
                                    // 8. DOCUMENTS: Upload document
                                    // 9. DOCUMENTS: Link document to project
                                    // Schedule FV_UploadDocument batch to handle 7, 8, 9
                                    if(fileInfoIds != null && fileInfoIds.size() > 0){
                                        FV_SchBatchUploadDocument.schedule(fileInfoIds, projectParsed.projectId.native);
                                    }

                                    // 10. PROJECT: Update project form - Case Summary (include client above if not same as caller)
                                    FV_SchBatchUploadDocumentSummary.schedule(intakes[0].Id, projectParsed.projectId.native, retainerFileId, questionnaireFileId, callerParsed.personId.native, clientParsed.personId.native);
                                }
                                else {
                                    intakes[0].Referral_Partner_API_Error__c = projectResp.data;
                                    update intakes[0];
                                }
                            }
                            else {
                                intakes[0].Referral_Partner_API_Error__c = clientResp.data;
                                update intakes[0];
                            }
                        }
                    }
                    else {
                        intakes[0].Referral_Partner_API_Error__c = callerResp.data;
                        update intakes[0];
                    }
                }
                else {
                    intakes[0].Referral_Partner_API_Error__c = loginInfoResp.data;
                    update intakes[0];
                }
                FV_Logger.writeLogs();
            }
            catch(Exception e){
                System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
                new FV_Logger.Log(LoggingLevel.ERROR, 'FV_CreateProjectInvocable', e.getMessage() + '\n\n' + e.getStackTraceString());
                FV_Logger.writeLogs();
            }
        }
    }
}