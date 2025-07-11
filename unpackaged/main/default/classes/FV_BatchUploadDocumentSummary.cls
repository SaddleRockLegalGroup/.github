global class FV_BatchUploadDocumentSummary implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    private string intakeId;
    private string projectId;
    private string retainerFileId;
    private string questionnaireFileId;
    private string callerFVId;
    private string clientFVId;

    public FV_BatchUploadDocumentSummary(string intakeIdParam, string projectIdParam, string retainerFileIdParam, string questionnaireFileIdParam
    , string callerFVIdParam, string clientFVIdParam) {
        intakeId = intakeIdParam;
        projectId = projectIdParam;
        retainerFileId = retainerFileIdParam;
        questionnaireFileId = questionnaireFileIdParam;
        callerFVId = callerFVIdParam;
        clientFVId = clientFVIdParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        if(retainerFileId == null && questionnaireFileId == null){
            return Database.getQueryLocator([SELECT Id, Name, litify_docs__File_Size__c
                                        FROM litify_docs__File_Info__c
                                        LIMIT 1]);
        }
        return Database.getQueryLocator([SELECT Id, Name, litify_docs__File_Size__c
                                        FROM litify_docs__File_Info__c
                                        WHERE Id = :retainerFileId OR Id = :questionnaireFileId]);   
    }
    global void execute(Database.BatchableContext BC, List<litify_docs__File_Info__c> scope){
        System.debug('###FV_BatchUploadDocumentSummary is running###');
        string fvRetainerDocId = '';
        string fvQuestionnaireDocId = '';
        FV_RestAPIWrapper restApi = new FV_RestAPIWrapper();
        List<string> fileIdList = new List<string>();
        if(retainerFileId != null){
            fileIdList.add(retainerFileId);
        }
        if(questionnaireFileId != null){
            fileIdList.add(questionnaireFileId);
        }
        
        FV_Models.HttpResponseWrapper loginInfoResp = FV_RestAPIWrapper.createSession();
        if(!loginInfoResp.success){
            new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUploadDocumentSummary', loginInfoResp.data);
        }
        else {
            FV_Models.LoginRespModel loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(loginInfoResp.data, FV_Models.LoginRespModel.class);
            if(!fileIdList.isEmpty()){
                Map<string,litify_docs__File_Info__c> fileMap = new Map<string,litify_docs__File_Info__c>();
                for(litify_docs__File_Info__c file : scope){
                    fileMap.put(file.Id, file);
                }
                
                SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
                
                try {
                    SaddleRockDocrioAPIModels.FilesGetResponse fileResp = docrioService.getDownloadUrls(fileIdList);
                    for(SaddleRockDocrioAPIModels.SignedUrlObject file : fileResp.Records){
                        string fileUrl = file.SignedUrl;
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint(fileUrl);
                        req.setMethod('GET');
                        req.setTimeout(120000);
                        FV_Logger.Log l = new FV_Logger.Log(LoggingLevel.INFO, 'FV_BatchUploadDocumentSummary', 'Making callout to [GET] ' + fileUrl);
                        HttpRequest tempToLog = new HttpRequest();
                        l.setRequest(req);
                        HttpResponse resp;
                        Http http = new Http();
                        resp = http.send(req);
                        l.setResponse(resp);
                
                        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
                            Map<string,object> fileMetaPayload = new Map<string,object>{
                                'documentId' => new Map<string,string>{
                                    'partner' => file.Id + '-' + String.valueOfGmt(Datetime.now())
                                },
                                'filename' => fileMap.get(file.Id).Name,
                                'size' => fileMap.get(file.Id).litify_docs__File_Size__c
                            };
                            
                            FV_Models.HttpResponseWrapper result = restApi.uploadDocument(fileMetaPayload, resp.getBodyAsBlob(), projectId, loginInfo);
                            if(result.success){
                                System.debug('###Document uploaded successfully###');
                                new FV_Logger.Log(LoggingLevel.INFO, 'FV_BatchUploadDocumentSummary', 'Document uploaded successfully');
                                FV_Models.Document documentResParsed = (FV_Models.Document) JSON.deserialize(result.data, FV_Models.Document.class);
                                if(file.Id == retainerFileId){
                                    fvRetainerDocId = documentResParsed.documentId.native;
                                }
                                if(file.Id == questionnaireFileId){
                                    fvQuestionnaireDocId = documentResParsed.documentId.native;
                                }
                            } else {
                                new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUploadDocumentSummary', result.data);
                            }
                        }
                    }
                } catch(Exception e) {
                    new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUploadDocumentSummary', e.getMessage() + '\n\n' + e.getStackTraceString());
                }
            }
            
            // 10. PROJECT: Update project form - Case Summary (include client above if not same as caller, include retainer and questionnaire doc IDs if applicable)
            List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , litify_pm__Case_Type__r.Name 
                                                , Caller__c
                                                , litify_pm__Client__c
                                                , Is_your_loved_one_still_living__c
                                                , What_is_your_relation_to_this_individual__c
                                                FROM litify_pm__Intake__c WHERE Id = :intakeId LIMIT 1];
            Map<string,object> caseSummary = FV_PayloadBuilder.buildCaseSummaryPayload(intakes[0], projectId, callerFVId, clientFVId, fvRetainerDocId, fvQuestionnaireDocId);
            FV_Models.HttpResponseWrapper caseSummaryResp = restApi.updateProjectForm(projectId, 'casesummary', caseSummary, loginInfo);   
        }
        
        FV_Logger.writeLogs();
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.abortJob(a.id);
    }
}