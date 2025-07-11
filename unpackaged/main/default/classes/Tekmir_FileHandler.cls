public with sharing class Tekmir_FileHandler {
    public List<Tekmir_Models.NewDocument> buildJsonPayload(string intakeId, List<string> fileIds, Integer saltIdTestmode, Boolean testMode) {
        List<Tekmir_Models.NewDocument> result = new List<Tekmir_Models.NewDocument>();

        Map<Id, litify_docs__File_Info__c> fileMap = new Map<Id, litify_docs__File_Info__c>([SELECT Id, Name
                                                                                        , litify_docs__File_Type__c, FX_Is_Signed_Retainer__c
                                                                                        FROM litify_docs__File_Info__c
                                                                                        WHERE litify_docs__Complete__c = true
                                                                                        AND litify_docs__Delete__c = false
                                                                                        AND Id IN :fileIds]);

        if(fileMap != null && fileMap.size() > 0){
            SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
            SaddleRockDocrioAPIModels.FilesGetResponse fileResp = docrioService.getDownloadUrls(fileIds);
            if(fileResp != null && fileResp.Records != null && fileResp.Records.size() > 0){
                for(SaddleRockDocrioAPIModels.SignedUrlObject signedUrlObj : fileResp.Records) {
                    Tekmir_Models.NewDocument newDoc = new Tekmir_Models.NewDocument();
                    litify_docs__File_Info__c file = fileMap.get(signedUrlObj.Id);
                    newDoc.integratorDocumentId = signedUrlObj.Id;
                    newDoc.relatedIntegratorMatterId = testMode ? intakeId + '-' + String.valueOf(saltIdTestmode) : intakeId;
                    newDoc.fileType = getFileType(file.Name, file.FX_Is_Signed_Retainer__c);
                    newDoc.fileName = file.Name;
                    newDoc.contentType = file.litify_docs__File_Type__c;
                    newDoc.fileUrl = signedUrlObj.SignedUrl;
                    newDoc.fileUrlExpirationTimestamp = Datetime.now().addMinutes(4).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    newDoc.clientCompletedAtDate = Datetime.now().formatGMT('yyyy-MM-dd');
                    result.add(newDoc);                    
                }
            }

            return result;
        }

        return null;
    }

    private static string getFileType(String fileName, Boolean isSignedRetainer) {
        if( String.isBlank(fileName) ) {
            return 'Unknown';
        }

        if (fileName.toLowerCase().contains('retainer')) {
            return 'Retainer';
        } else if( isSignedRetainer) {
            return 'Retainer';
        } else if (fileName.toLowerCase().contains('intake')) {
            return 'IntakePacket';
        }  else {
            return 'Unknown';
        }
    }
}