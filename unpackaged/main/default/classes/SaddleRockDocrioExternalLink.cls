public with sharing class SaddleRockDocrioExternalLink {
    public class FlowInputs {
        @InvocableVariable(label='Record ID (If record ID is set, all related files will be shared)') public string recordId;
        @InvocableVariable(label='List of File Info IDs (If you want to only share some files, not all related files)') public List<String> fileInfoIds;
        @InvocableVariable(label='Expiration Date' required=true) public Date expirationDate;
        @InvocableVariable(label='Sharing Password') public string sharingPassword;
    }
    public class FlowOutputs {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }
    @InvocableMethod(label='Get Docrio External Link')
    public static List<FlowOutputs> createExternalLink(List<FlowInputs> request){
        List<FlowOutputs> result = new List<FlowOutputs>();
        string recordId = request[0].recordId;
        List<String> fileInfoIds = request[0].fileInfoIds != null ? request[0].fileInfoIds : new List<String>();
        Date expirationDate = request[0].expirationDate;
        string sharingPassword = request[0].sharingPassword;

        SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
        try {
            string accessToken = docrioService.refreshDocrioToken();
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
                SaddleRockDocrioAPIModels.ExternalLinkPostRequest externalLinkRequest = BuildExternalLinkRequest(fileInfoIds, expirationDate, sharingPassword);
                SaddleRockDocrioAPIModels.ExternalLinkPostResponseWrapper resp = docrioService.createExternalLink(accessToken, externalLinkRequest);
        
                if(resp.success){
                    List<Object> linkRecords = (List<Object>)resp.data.get('Records');
                    Map<String, Object> linkRecordObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(linkRecords[0]));
                    docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();
                    String sharingLink = docrioSetting.docriosdk__API_Endpoint__c + '/share/s/' + linkRecordObj.get('litify_docs__Unique_Id__c');
                    
                    System.debug('### External link: ' + sharingLink + ' ###');
        
                    result = GetFlowOutput(resp.success, sharingLink);
                }
                else {
                    result = GetFlowOutput(resp.success, resp.message);
                }
            }
            else {
                result = GetFlowOutput(false, 'No file is available to share');
            }
            
        }
        catch(Exception e){
            result = GetFlowOutput(false, e.getMessage() + e.getStackTraceString());
        }
        
        return result;
    }

    private static SaddleRockDocrioAPIModels.ExternalLinkPostRequest BuildExternalLinkRequest(List<String> fileInfoIds, Date expirationDate, String sharingPassword){
        SaddleRockDocrioAPIModels.ExternalLinkPostRequest request = new SaddleRockDocrioAPIModels.ExternalLinkPostRequest();
        request.FileInfoRecords = new List<Map<String,Object>>();
        request.FileLinkRecord = new Map<String,Object>();

        Integer fileSize = 0;
        String fileType = '';

        List<litify_docs__File_Info__c> pdfFiles = [SELECT OwnerId, IsDeleted, Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById
                                                            , litify_docs__Author__c, litify_docs__Description__c
                                                            , litify_docs__External_File_Path__c, litify_docs__External_ID__c, litify_docs__Folder_Path__c
                                                            , litify_docs__From__c, litify_docs__To__c, litify_docs__Latest_Version__c, litify_docs__Complete__c
                                                            , litify_docs__File_Link__c, litify_docs__Related_To_Api_Name__c, litify_docs__File_Type__c
                                                            , litify_docs__File_Size__c, litify_docs__Related_To__c
                                                        FROM litify_docs__File_Info__c 
                                                        WHERE Id IN :fileInfoIds];
        
        
        if(pdfFiles != null && pdfFiles.size() > 0){
            for(litify_docs__File_Info__c pdfFile : pdfFiles){
                Map<String,Object> fileInfoRecordObj = new Map<String,Object>();
                fileSize = Integer.valueOf(pdfFile.litify_docs__File_Size__c) != null || Integer.valueOf(pdfFile.litify_docs__File_Size__c) == 0 ? Integer.valueOf(pdfFile.litify_docs__File_Size__c) : 1;
                fileType = String.valueOf(pdfFile.litify_docs__File_Type__c);
    
                fileInfoRecordObj.put('OwnerId', pdfFile.OwnerId);
                fileInfoRecordObj.put('IsDeleted', pdfFile.IsDeleted);
                fileInfoRecordObj.put('Id', pdfFile.Id);
                fileInfoRecordObj.put('Name', pdfFile.Name);
                fileInfoRecordObj.put('CreatedDate', pdfFile.CreatedDate);
                fileInfoRecordObj.put('CreatedById', pdfFile.CreatedById);
                fileInfoRecordObj.put('LastModifiedDate', pdfFile.LastModifiedDate);
                fileInfoRecordObj.put('LastModifiedById', pdfFile.LastModifiedById);
                fileInfoRecordObj.put('LastReferencedDate', pdfFile.LastModifiedDate);
                fileInfoRecordObj.put('LastViewedDate', pdfFile.LastModifiedDate);
                fileInfoRecordObj.put('SystemModstamp', pdfFile.LastModifiedDate);
                fileInfoRecordObj.put('litify_docs__Author__c', pdfFile.litify_docs__Author__c);
                fileInfoRecordObj.put('litify_docs__Description__c', pdfFile.litify_docs__Description__c);
                fileInfoRecordObj.put('litify_docs__External_File_Path__c', pdfFile.litify_docs__External_File_Path__c);
                fileInfoRecordObj.put('litify_docs__External_ID__c', pdfFile.litify_docs__External_ID__c);
                fileInfoRecordObj.put('litify_docs__Folder_Path__c', pdfFile.litify_docs__Folder_Path__c);
                fileInfoRecordObj.put('litify_docs__From__c', pdfFile.litify_docs__From__c);
                fileInfoRecordObj.put('litify_docs__To__c', pdfFile.litify_docs__To__c);
                fileInfoRecordObj.put('litify_docs__Latest_Version__c', pdfFile.litify_docs__Latest_Version__c);
                fileInfoRecordObj.put('litify_docs__Complete__c', true);
                fileInfoRecordObj.put('litify_docs__File_Link__c', pdfFile.litify_docs__File_Link__c);
                fileInfoRecordObj.put('litify_docs__Related_To_Api_Name__c', pdfFile.litify_docs__Related_To_Api_Name__c);
                fileInfoRecordObj.put('litify_docs__Related_To__c', pdfFile.litify_docs__Related_To__c);
                fileInfoRecordObj.put('litify_docs__File_Type__c', pdfFile.litify_docs__File_Type__c);
                fileInfoRecordObj.put('litify_docs__File_Size__c', fileSize);
    
                request.FileInfoRecords.add(fileInfoRecordObj);
            }
            
        }
        
        request.FileLinkRecord.put('litify_docs__Expiration_Date__c', expirationDate);
        //request.FileLinkRecord.put('litify_docs__File_Size__c', fileSize);
        //request.FileLinkRecord.put('litify_docs__File_Type__c', fileType);
        request.FileLinkRecord.put('litify_docs__Password__c', sharingPassword);
        request.FileLinkRecord.put('litify_docs__Unique_Id__c', null);

        return request;
    }

    private static List<FlowOutputs> GetFlowOutput(Boolean success, string message){
      List<FlowOutputs> result = new List<FlowOutputs>();
      FlowOutputs output = new FlowOutputs();
      output.success = success;
      output.message = message;
      result.add(output);
      return result;
    }
}