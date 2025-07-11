public with sharing class SaddlerockGetDocrioDownloadUrlInvocable {
    public class FlowInputs {
        @InvocableVariable(label='Record ID (If record ID is set, downloading urls will be generated for all related files)') public string recordId;
        @InvocableVariable(label='List of File Info IDs (Specify the file record Ids if you want to generate downloading url(s) specific file(s), not all related files)') public List<Id> fileInfoIds;
    }
    public class FlowOutputs {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public List<SaddlerockDocrioSignedUrlModel> data;
    }

    @InvocableMethod(label='Get Docrio Download URL')
    public static List<FlowOutputs> getSignedUrl(List<FlowInputs> request){
        List<FlowOutputs> result = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        output.data = new List<SaddlerockDocrioSignedUrlModel>();

        string recordId = request[0].recordId;
        List<Id> fileInfoIds = request[0].fileInfoIds != null ? request[0].fileInfoIds : new List<Id>();

        SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
        try {
            if(recordId != null && recordId != ''){
                List<litify_docs__File_Info__c> files = [SELECT Id, litify_docs__Related_To__c
                                FROM litify_docs__File_Info__c 
                                WHERE litify_docs__Related_To__c = :recordId 
                                AND litify_docs__Delete__c = false
                                AND litify_docs__Complete__c = true];
                for(litify_docs__File_Info__c f : files){
                    fileInfoIds.add(f.Id);
                }
            }

            if(fileInfoIds != null && fileInfoIds.size() > 0){
                SaddleRockDocrioAPIModels.FilesGetResponse docrioFileResp = docrioService.getDownloadUrls(fileInfoIds);
                if(docrioFileResp != null && docrioFileResp.Records != null && docrioFileResp.Records.size() > 0){
                    for(SaddleRockDocrioAPIModels.SignedUrlObject signedObj : docrioFileResp.Records){
                        SaddlerockDocrioSignedUrlModel fileObj = new SaddlerockDocrioSignedUrlModel();
                        fileObj.SignedUrl = signedObj.SignedUrl;
                        fileObj.Id = signedObj.Id;
                        output.data.add(fileObj);
                    }

                    output.success = true;
                }
                else {
                    output.success = false;
                    output.message = JSON.serialize(docrioFileResp);
                }
            }
            else {
                output.success = false;
                output.message = 'No file is available to download';
            }
            
        }
        catch(Exception e){
            output.success = false;
            output.message = e.getMessage() + e.getStackTraceString();
        }
        
        result.add(output);
        return result;
    }
}