public with sharing class SaddleRockFileHandler {
    public docriosdk.Models.FilesPostResponse saveFileToDocrio(string intakeId, string externalId, string name, string description, string type, string signedUrl) {
        List<litify_docs__File_Info__c> existingFiles = [SELECT Id FROM litify_docs__File_Info__c 
                                                    WHERE litify_docs__External_ID__c = :externalId
                                                    AND litify_docs__Complete__c = true
                                                    AND litify_docs__Delete__c = false];
        docriosdk.Models.FilesPostResponse docrioResponse;
        docriosdk.DocrioService.Files filesApi = new docriosdk.DocrioService.Files();
        if (existingFiles.size() > 0) {
            litify_docs__File_Info__c existingFile = existingFiles[0];
            docriosdk.Models.FilesPutRequest docrioRequest = new docriosdk.Models.FilesPutRequest(existingFile.Id, signedUrl, null);
            docrioResponse = !Test.isRunningTest() ? filesApi.Put(docrioRequest) : null;
        } 
        else {
            docriosdk.Models.FilesPostRequest docrioRequest = new docriosdk.Models.FilesPostRequest(name, signedUrl, null, SObjectType.litify_pm__Intake__c.sObjectType.getDescribe().getName(), intakeId);
            docrioRequest.SetProperty('litify_docs__External_ID__c', externalId);
            docrioRequest.ContentType = type;
            docrioRequest.DocumentDescription = description;
            docrioResponse = !Test.isRunningTest() ? filesApi.Post(docrioRequest) : null;
        }

        return docrioResponse;
    }
}