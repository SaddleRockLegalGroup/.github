public with sharing class SC_FileUploadHandler {
    public static void submitFiles(string clientName, string caseId, string fileInfoId, List<string> otherFileInfoIds) {
        System.debug('###SC_FileUploadHandler.submitFiles###');
        List<string> fileIds = new List<string>();
        // Map<string,string> fileMap = new Map<string,string>();
        fileIds.add(fileInfoId);
        fileIds.addAll(otherFileInfoIds);
        List<litify_docs__File_Info__c> files = [SELECT Id, Name
                                                FROM litify_docs__File_Info__c
                                                WHERE litify_docs__Complete__c = true
                                                AND litify_docs__Delete__c = false
                                                AND Id IN :fileIds];
        try{
            if(files != null && files.size() > 0){
                for(litify_docs__File_Info__c doc : files){
                    if(doc.Id == fileInfoId){
                        System.debug('Uploading retainer: ' + doc.Name);
                        SC_SchedulerUploadFile.schedule(clientName, caseId, doc.Id, 'retainer');
                    }
                    else{
                        System.debug('Uploading ' + doc.Name);
                        SC_SchedulerUploadFile.schedule(clientName, caseId, doc.Id, 'other');
                    }
                }


                // for(litify_docs__File_Info__c doc : files){
                //     fileMap.put(doc.Id, doc.Name);
                // }
                // System.debug('###SC_FileUploadHandler.fileMap: ' + fileMap + '###');
                // SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
                // SaddleRockDocrioAPIModels.FilesGetResponse fileResp = docrioService.getDownloadUrls(fileIds);
                // if(fileResp != null && fileResp.Records != null && fileResp.Records.size()>0){
                //     List<SaddleRockDocrioAPIModels.SignedUrlObject> fileList = fileResp.Records;
                //     for(SaddleRockDocrioAPIModels.SignedUrlObject urlObj : fileList){
                //         if(urlObj.Id == fileInfoId){
                //             Map<string,string> fileMetaObj = new Map<string,string>{
                //                 'filename' => clientName + '_' + fileMap.get(urlObj.Id),
                //                 'status' => 'completed',
                //                 'type' => 'retainer'
                //             };
                //             Map<string,object> resp = getFileContentAndUpload(caseId, JSON.serialize(fileMetaObj), fileMap.get(urlObj.Id), urlObj.SignedUrl);
                //             result.add(resp);
                //         }
                //         else {
                //             // Upload Single Document
                //             Map<string,string> fileMetaObj = new Map<string,string>{
                //                 'filename' => fileMap.get(urlObj.Id),
                //                 'status' => 'completed',
                //                 'type' => 'other'
                //             };
                //             Map<string,object> resp = getFileContentAndUpload(caseId, JSON.serialize(fileMetaObj), fileMap.get(urlObj.Id), urlObj.SignedUrl);
                //             result.add(resp);
                //         }
                //     }
                // }
                // else {
                //     result.add(new Map<string,object>{
                //         'success' => false,
                //         'data' => 'Failed to get Docrio Signed URLs'
                //     });
                // }
            }
        }
        catch(Exception e){
            throw e;
        }
    }

    // private static Map<string,object> getFileContentAndUpload(string caseId, string fileMeta, string fileName, string fileUrl){
    //     Map<string,object> result = new Map<string,object>();
    //     HttpRequest req = new HttpRequest();
    //     System.debug(fileUrl);
    //     req.setEndpoint(fileUrl);
    //     req.setMethod('GET');
    //     req.setTimeout(120000);
    //     SC_Logger.Log l = new SC_Logger.Log(LoggingLevel.INFO, 'SC_FileUploadHandler', 'Making callout to [GET] ' + fileUrl);
    //     HttpRequest tempToLog = new HttpRequest();
    //     l.setRequest(req);
    //     HttpResponse resp;
    //     try {
    //         Http http = new Http();
    //         resp = http.send(req);
    //         l.setResponse(resp);

    //         if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
    //             SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
    //             System.debug(fileMeta);
    //             System.debug(resp.getBodyAsBlob());
    //             result = restApi.uploadDocument(caseId, fileMeta, fileName, resp.getBodyAsBlob());
    //             return result;
    //         }
    //     }
    //     catch(Exception e) {
    //         System.debug('Failed to make callout to ' + fileUrl + '. Error: ' + e.getMessage());
    //         new SC_Logger.Log(LoggingLevel.ERROR, 'SC_FileUploadHandler', e.getMessage() + '\n\n' + e.getStackTraceString());
    //         result.put('success', false);
    //         result.put('data', e.getMessage() + '\n\n' + e.getStackTraceString());
    //     }
    //     return result;
    // }
}