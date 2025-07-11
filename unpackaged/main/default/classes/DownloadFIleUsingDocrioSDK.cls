public with sharing class DownloadFIleUsingDocrioSDK {
    
    public static final Dropbox_Sign_API_Settings__c API_SETTING { 
        get {
            Dropbox_Sign_API_Settings__c API_SETTING = Dropbox_Sign_API_Settings__c.getOrgDefaults();
            return API_SETTING;
        }
    }
    @Future(callout=true)
    public static void getFileForDocrio(String filesUrl, String title, String externalFileId, String intakeId){
        System.debug('DownloadFIleUsingDocrioSDK.getFileForDocrio triggered');
        HttpRequest req = new HttpRequest();
        // string baseUrl = API_SETTING.Base_URL__c;
        // string endpoint = baseUrl.replace('/v3','') + filesUrl;
        string endpoint = filesUrl; //Updated on 3/15/2024
        req.setEndpoint(endpoint);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(API_SETTING.API_Key__c + ':'));
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');
        
        String externalId = 'DB_' + externalFileId;
        String fileName = title + '.pdf';
        
        List<litify_docs__File_Info__c> existingFiles = [
            SELECT 
            Id 
            FROM litify_docs__File_Info__c 
            WHERE litify_docs__External_ID__c = :externalId 
            AND litify_docs__Delete__c = false];
        
        docriosdk.Models.FilesPostResponse docrioResponse;
        docriosdk.DocrioService.Files filesApi = new docriosdk.DocrioService.Files();
        
        try {
            if (existingFiles.size() > 0) {
                // If file exists, upload to Docrio as new version
                System.debug('File already exists. Uploading new version...');
                litify_docs__File_Info__c existingFile = existingFiles[0];
                docriosdk.Models.FilesPutRequest docrioRequest = new docriosdk.Models.FilesPutRequest(existingFile.Id, req.getEndpoint(), req.getHeader('Authorization'));
                docrioResponse = filesApi.Put(docrioRequest);
                System.debug(string.valueOf(docrioResponse));
                new DropboxSignAPILogger.Log(LoggingLevel.DEBUG, 'DownloadFileUsingDocrioSDK',
                                             string.valueOf(docrioResponse));
                DropboxSignAPILogger.writeLogs();
            } 
            else {
                // If file doesn't exist, upload to Docrio as new file
                System.debug('File is new. Uploading to Docrio...');
                docriosdk.Models.FilesPostRequest docrioRequest = new docriosdk.Models.FilesPostRequest(fileName, req.getEndpoint(), req.getHeader('Authorization'), 'litify_pm__Intake__c', intakeId);
                docrioRequest.SetProperty('litify_docs__External_ID__c', externalId);
                docrioRequest.DocumentCategory = 'API Documents';
                docrioRequest.ContentType = 'application/pdf';
                docrioRequest.DocumentDescription = 'Downloaded from API';
                docrioResponse = filesApi.Post(docrioRequest);
                System.debug(string.valueOf(docrioResponse));
                new DropboxSignAPILogger.Log(LoggingLevel.DEBUG, 'DownloadFileUsingDocrioSDK',
                                             string.valueOf(docrioResponse));
                DropboxSignAPILogger.writeLogs();
            }
        }
        catch(Exception e){
            System.debug(e.getMessage() + '. ' + e.getStackTraceString());
            new DropboxSignAPILogger.Log(LoggingLevel.ERROR, 'DownloadFileUsingDocrioSDK exception',
                                         e.getMessage() + '. ' + e.getStackTraceString());
            DropboxSignAPILogger.writeLogs();
        }
    }
    
}