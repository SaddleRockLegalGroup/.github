public with sharing class BridgeLegalAPI_FileUploadHandler {
    public static Map<string,object> uploadFiles(string bridgifyMatterId, string retainerId) {
        Map<string,string> fileIdNameMap = new Map<string,string>();
        List<litify_docs__File_Info__c> files = [SELECT Id, Name
                                                FROM litify_docs__File_Info__c
                                                WHERE litify_docs__Complete__c = true
                                                AND litify_docs__Delete__c = false
                                                AND Id = :retainerId LIMIT 1];
        if(files != null && files.size() > 0){
            SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
            SaddleRockDocrioAPIModels.FilesGetResponse fileResp = docrioService.getDownloadUrls(new List<string>{files[0].Id});
            if(fileResp != null && fileResp.Records != null && fileResp.Records.size()>0){
                Map<string,object> docUploadResp = uploadToBridgeLegalAPI(bridgifyMatterId, files[0].Name, fileResp.Records[0].SignedUrl);
                return docUploadResp;
            }
        }
        
        return new Map<string,object>{
            'success' => false,
            'data' => 'Internal Server Error'
        };
    }

    private static Map<string,object> uploadToBridgeLegalAPI(string matterId, string fileName, string fileUrl){
        Map<string,object> result = new Map<string,object>();
        HttpRequest req = new HttpRequest();
        System.debug(fileUrl);
        req.setEndpoint(fileUrl);
        req.setMethod('GET');
        req.setTimeout(120000);
        BridgeLegalAPI_Logger.Log l = new BridgeLegalAPI_Logger.Log(LoggingLevel.INFO, 'BridgeLegalAPI_FileUploadHandler', 'Making callout to [GET] ' + fileUrl);
        l.setRequest(req);
        HttpResponse resp;
        try {
            Http http = new Http();
            resp = http.send(req);
            l.setResponse(resp);

            if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
                BridgeLegalAPI_RestAPIWrapper restApi = new BridgeLegalAPI_RestAPIWrapper();
                result = restApi.uploadDocument(matterId, fileName, resp.getBodyAsBlob());
                return result;
            }
        }
        catch(Exception e) {
            System.debug('Failed to make callout to ' + fileUrl + '. Error: ' + e.getMessage());
            new BridgeLegalAPI_Logger.Log(LoggingLevel.ERROR, 'BridgeLegalAPI_FileUploadHandler', e.getMessage() + '\n\n' + e.getStackTraceString());
            result.put('success', false);
            result.put('data', e.getMessage() + '\n\n' + e.getStackTraceString());
        }
        return result;
    }
}