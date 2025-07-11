global class SC_BatchUploadFile implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    private string clientName;
    private string caseId;
    private string fileInfoId;
    private string type;

    public SC_BatchUploadFile(string clientNameParam, string caseIdParam, string fileInfoIdParam, string typeParam) {
        clientName = clientNameParam;
        caseId = caseIdParam;
        fileInfoId = fileInfoIdParam;
        type = typeParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name FROM litify_docs__File_Info__c
                                        WHERE Id = :fileInfoId LIMIT 1]) ;   
    }
    global void execute(Database.BatchableContext BC, List<litify_docs__File_Info__c> scope){
        System.debug('###SC_BatchUploadFile is running###');
        litify_docs__File_Info__c file = scope[0];
        SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
        SaddleRockDocrioAPIModels.FilesGetResponse fileResp = docrioService.getDownloadUrls(new List<string>{file.Id});
        
        string fileName = type == 'retainer' ? clientName + '_' + file.Name : file.Name;
        Map<string,string> fileMetaObj = new Map<string,string>{
            'filename' => fileName,
            'status' => 'completed',
            'type' => type
        };
        Map<string,object> resp = getFileContentAndUpload(caseId, JSON.serialize(fileMetaObj), fileName, fileResp.Records[0].SignedUrl);
        SC_Logger.writeLogs();
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.abortJob(a.id);
    }

    private static Map<string,object> getFileContentAndUpload(string caseId, string fileMeta, string fileName, string fileUrl){
        Map<string,object> result = new Map<string,object>();
        HttpRequest req = new HttpRequest();
        System.debug(fileUrl);
        req.setEndpoint(fileUrl);
        req.setMethod('GET');
        req.setTimeout(120000);
        SC_Logger.Log l = new SC_Logger.Log(LoggingLevel.INFO, 'SC_BatchUploadFile', 'Making callout to [GET] ' + fileUrl);
        HttpRequest tempToLog = new HttpRequest();
        l.setRequest(req);
        HttpResponse resp;
        try {
            Http http = new Http();
            resp = http.send(req);
            // l.setResponse(resp);
    
            if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
                SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
                // System.debug(fileMeta);
                // System.debug(resp.getBodyAsBlob());
                result = restApi.uploadDocument(caseId, fileMeta, fileName, resp.getBodyAsBlob());
                return result;
            }
        }
        catch(Exception e) {
            System.debug('Failed to make callout to ' + fileUrl + '. Error: ' + e.getMessage());
            new SC_Logger.Log(LoggingLevel.ERROR, 'SC_BatchUploadFile', e.getMessage() + '\n\n' + e.getStackTraceString());
            result.put('success', false);
            result.put('data', e.getMessage() + '\n\n' + e.getStackTraceString());
        }
        return result;
    }
}