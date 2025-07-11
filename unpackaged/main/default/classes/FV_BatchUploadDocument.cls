global class FV_BatchUploadDocument implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    private List<string> fileIds;
    private string projectId;

    public FV_BatchUploadDocument(List<string> fileIdsParam, string projectIdParam) {
        fileIds = fileIdsParam;
        projectId = projectIdParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, litify_docs__File_Size__c
                                        FROM litify_docs__File_Info__c
                                        WHERE Id IN :fileIds]) ;   
    }
    global void execute(Database.BatchableContext BC, List<litify_docs__File_Info__c> scope){
        System.debug('###FV_BatchUploadDocument is running###');
        FV_RestAPIWrapper restApi = new FV_RestAPIWrapper();
        FV_Models.HttpResponseWrapper loginInfoResp = FV_RestAPIWrapper.createSession();
        if(!loginInfoResp.success){
            new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUploadDocument', loginInfoResp.data);
        }
        else {
            FV_Models.LoginRespModel loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(loginInfoResp.data, FV_Models.LoginRespModel.class);

            Map<string,litify_docs__File_Info__c> fileMap = new Map<string,litify_docs__File_Info__c>();
            List<string> fileIdList = new List<string>();
            for(litify_docs__File_Info__c file : scope){
                fileMap.put(file.Id, file);
                fileIdList.add(file.Id);
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
                    FV_Logger.Log l = new FV_Logger.Log(LoggingLevel.INFO, 'FV_BatchUploadDocument', 'Making callout to [GET] ' + fileUrl);
                    HttpRequest tempToLog = new HttpRequest();
                    l.setRequest(req);
                    HttpResponse resp;
                    Http http = new Http();
                    resp = http.send(req);
                    // l.setResponse(resp);
            
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
                            new FV_Logger.Log(LoggingLevel.INFO, 'FV_BatchUploadDocument', 'Document uploaded successfully');
                        } else {
                            new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUploadDocument', result.data);
                        }
                    }
                }
            } catch(Exception e) {
                new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUploadDocument', e.getMessage() + '\n\n' + e.getStackTraceString());
            }
        }
        FV_Logger.writeLogs();
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.abortJob(a.id);
    }
}