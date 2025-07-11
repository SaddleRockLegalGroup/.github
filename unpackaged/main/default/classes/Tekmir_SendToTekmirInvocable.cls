public class Tekmir_SendToTekmirInvocable {
    public class FlowInputs {
        @InvocableVariable(label='Intake Record Id' required=true) public string intakeId;
        @InvocableVariable(label='Retainer File Info Id(s)') public List<string> fileIds;
    }

    @InvocableMethod(label='TEKMIR API: NEW MATTER')
    public static void submitToTekmir(List<FlowInputs> requests){
        System.debug('### Tekmir_SendToTekmirInvocable ###');
        
        for(FlowInputs request : requests){
            string intakeId = request.intakeId;
            List<string> fileIds = request.fileIds;
            
            asyncSubmit(intakeId, fileIds);
        }
    }
    
    @future (callout=true)
    private static void asyncSubmit(string intakeId, List<string> fileIds){
        try {
            Tekmir_API_Settings__c apiSetting = Tekmir_API_Settings__c.getOrgDefaults();
            Tekmir_Logger.relatedRecId = intakeId;
            List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Referral_Partner_API_External_ID__c
                                                , Referral_Partner_API_Description__c
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :intakeId
                                                LIMIT 1];

            Tekmir_RestAPIWrapper restApi = new Tekmir_RestAPIWrapper();
            Tekmir_DataHandler dataMapper = new Tekmir_DataHandler();
            Integer saltIdTestmode = Crypto.getRandomInteger();
            Tekmir_Models.NewMatterRequest matterReq = dataMapper.buildJsonPayload(intakeId, saltIdTestmode, apiSetting.Test_mode__c);
            Tekmir_Models.HttpResponseWrapper matterResp = restApi.sendNewMatterRequest(matterReq);
            if(matterResp.success){
                Tekmir_FileHandler fileHandler = new Tekmir_FileHandler();
                Map<string,object> parsedMatResp = (Map<string,object>) JSON.deserializeUntyped(matterResp.data);
                string tekmirMatterId = String.valueOf(parsedMatResp.get('matterId'));
                
                intakes[0].Referral_Partner_API_External_ID__c = tekmirMatterId;

                if(fileIds != null && fileIds.size() > 0) {
                    Tekmir_FileHandler fileMapper = new Tekmir_FileHandler();
                    List<Tekmir_Models.NewDocument> docReqList = fileMapper.buildJsonPayload(intakeId, fileIds, saltIdTestmode, apiSetting.Test_mode__c);
                    if(docReqList != null && docReqList.size() > 0) {
                        Boolean fileUploadSuccess = true;
                        string fileUploadError = '';
                        for(Tekmir_Models.NewDocument docReq : docReqList) {
                            Tekmir_Models.HttpResponseWrapper docResp = restApi.sendNewDocumentRequest(docReq);
                            if(docResp.success) {
                                Map<string,object> parsedDocResp = (Map<string,object>) JSON.deserializeUntyped(docResp.data);
                                string logMsg = 'Document successfully uploaded for matter: ' + tekmirMatterId + ' with Document ID: ' + String.valueOf(parsedDocResp.get('integratorDocumentId'));
                                System.debug(logMsg);
                                new Tekmir_Logger.Log(LoggingLevel.DEBUG, 'Tekmir Callout Log: Document Upload', logMsg);
                            } else {
                                fileUploadSuccess = false;
                                string logMsg = 'Failed to upload document: ' + docResp.data + '\n';
                                fileUploadError += logMsg;
                                System.debug(logMsg);
                                new Tekmir_Logger.Log(LoggingLevel.ERROR, 'Tekmir Callout Error: Document Upload', logMsg);
                            }
                        }
                        if(fileUploadSuccess) {
                            // Update intake
                            intakes[0].Referral_Partner_API_Error__c = '';
                            update intakes[0];
                        }
                        else {
                            // Update intake
                            intakes[0].Referral_Partner_API_Error__c = fileUploadError;
                            update intakes[0];
                        }
                    }                    
                }
                else {
                    // Update intake
                    intakes[0].Referral_Partner_API_Error__c = '';
                    update intakes[0];
                }
            }
            else {
                System.debug('Failed to create new matter: ' + matterResp.data);
                // Update intake
                intakes[0].Referral_Partner_API_Error__c = matterResp.data;
                update intakes[0];
            }
            Tekmir_Logger.writeLogs();
        }
        catch(Exception e){
            System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
            new Tekmir_Logger.Log(LoggingLevel.ERROR, 'Tekmir Callout Exception',
                e.getMessage() + '\n\n' + e.getStackTraceString()); 
            Tekmir_Logger.writeLogs();
        }
    }
}