@RestResource(urlMapping='/SaddleRockIntakeSingleFileWebhook/*')
global without sharing class SaddleRockSingleFileWebhookEndpoint {
    @HttpPost
    global static void doPost() {
        System.debug('### SaddleRockIntakeSingleFileWebhook ###');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{
            string oAuthOrgId = req.headers.get('sforgid');
            string oAuthAPIKey = req.headers.get('apikey');
            List<Integration_Vendor__mdt> vendors = new List<Integration_Vendor__mdt>();
            if(!Test.isRunningTest()){
                vendors = [SELECT Label, OrgID__c, API_Key__c, Integration__c, Active__c 
                                                        FROM Integration_Vendor__mdt
                                                        WHERE OrgID__c = :oAuthOrgId AND API_Key__c = :oAuthAPIKey AND Active__c = true
                                                        LIMIT 1];
            }
            else {
                Integration_Vendor__mdt test = SaddleRockTestDataFactory.generateTestVendor();
                vendors.add(test);
            }

            if(vendors == null || vendors.size() < 1){
                res.statusCode = 401;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Unauthorized", "success": false}');
                return;
            }

            if(req.requestBody == null){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Request body is empty", "success": false}');
                return;
            }

            string integrationId = vendors[0].Integration__c;
            Integer MAX_FILE_SIZE = 11 * 1024 * 1024;

            Blob fileContent = req.requestBody;
            
            if(fileContent.size() >= MAX_FILE_SIZE){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Exceeded max size limit of 12000000", "success": false}');
                return;
            }

            string intakeId = req.params.get('id');
            string fileName = req.params.get('fileName');
            string combinedExternalId = oAuthOrgId + '-' + req.params.get('externalId');
            SaddleRockUtils.integrationId = integrationId;
            SaddleRockUtils.intakeRecId = intakeId;
            SaddleRockUtils.transName = 'SaddleRockIntakeSingleFileWebhook';
            SaddleRockUtils.transRequest = fileName + ' (data)';
            SaddleRockUtils.transVendor = vendors[0].Label;

            if(intakeId == null || intakeId == ''){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Intake ID is missing", "success": false}');
 
                SaddleRockUtils.transResponse = '{"error": "Intake ID is missing", "success": false}';
                SaddleRockUtils.transStatus = 'Error';
                SaddleRockUtils.writeLogs();
                return;
            }
            if(fileName == null || fileName == ''){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "File name is missing", "success": false}');
                
                SaddleRockUtils.intakeRecId = intakeId;
                SaddleRockUtils.transResponse = '{"error": "File name is missing is missing", "success": false}';
                SaddleRockUtils.transStatus = 'Error';
                SaddleRockUtils.writeLogs();
                return;
            }

            Map<string,object> result = DownloadIntakeFile(intakeId, combinedExternalId, fileName, fileContent, oAuthOrgId, integrationId);

            if(Boolean.valueOf(result.get('success'))){
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"id": "' + intakeId + '", "fileName": "' + fileName + '", "success": true}');
                
                SaddleRockUtils.transResponse = '{"id": "' + intakeId + '", "fileName": "' + fileName + '", "success": true}';
                SaddleRockUtils.transStatus = 'Success';
            }
            else {
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "' + string.valueOf(result.get('data')) + '", "success": false}');
                
                SaddleRockUtils.transResponse = '{"error": "' + string.valueOf(result.get('data')) + '", "success": false}';
                SaddleRockUtils.transStatus = 'Error';
            }

            SaddleRockUtils.writeLogs();
            return;

        }
        catch(Exception e){
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '", "success": false}');
            return;
        }
    }

    private static Map<string,object> DownloadIntakeFile(string intakeId, string combinedExternalId, string fileName, Blob fileContent, string oAuthOrgId, string integrationId) {
        Map<string,object> result = new Map<string,object>();
        SaddleRockUtils.integrationId = integrationId;

        List<Map<String, String>> filesMap = new List<Map<String, String>>();
        Map<String, String> fileInfoMap = new Map<String, String>();
        try {
            new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockIntakeSingleFileWebhook', 'File is being uploaded for intake id: ' + intakeId);
            

            fileInfoMap.put('Name', fileName);
            fileInfoMap.put('litify_docs__Author__c', '');
            fileInfoMap.put('litify_docs__Description__c', 'Uploaded by vendor: ' + oAuthOrgId);
            fileInfoMap.put('litify_docs__External_ID__c', combinedExternalId);
            fileInfoMap.put('litify_docs__Folder_Path__c', '');
            fileInfoMap.put('litify_docs__From__c', '');
            fileInfoMap.put('litify_docs__To__c', '');
            fileInfoMap.put('litify_docs__Related_To_Api_Name__c', 'litify_pm__Intake__c');
            fileInfoMap.put('litify_docs__Related_To__c', intakeId);
            fileInfoMap.put('litify_docs__File_Type__c', 'application/pdf');
            filesMap.add(fileInfoMap);
            

            SaddleRockDocrioService docrioService = new SaddleRockDocrioService();
            string token = docrioService.refreshDocrioToken();
            if(!string.isBlank(token) && !string.isEmpty(token)){
                Map<string,object> fileInfoResp = docrioService.createFileInfo(token, filesMap);
                if(Boolean.valueOf(fileInfoResp.get('success'))){
                    string signedUrl = String.valueOf(fileInfoResp.get('SignedUrl'));
                    string fileId = String.valueOf(fileInfoResp.get('Id'));
                    new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockIntakeSingleFileWebhook', 'signedUrl: ' + signedUrl);
                    if(signedUrl != null && signedUrl != ''){
                        Map<string,object> uploadResult = docrioService.uploadFile(token, signedURL, fileContent);
                        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockIntakeSingleFileWebhook', 'uploadResult: ' + uploadResult.get('message'));
        
                        if(Boolean.valueOf(uploadResult.get('success'))){
                            Map<string,object> completeResp = docrioService.completeUpload(token, new List<string>{fileId});
                            result.put('success', completeResp.get('success'));
                            result.put('data', completeResp.get('message'));
                        }
                        else {
                            result.put('success', false);
                            result.put('data', 'Failed to upload to Docrio');
                        }
                    }
                    else {
                        result.put('success', false);
                        result.put('data', 'Not able to get signedUrl');
                    }
                }
                else {
                    result.put('success', false);
                    result.put('data', 'Not able to create docrio file info');
                }
            }
            else {
                new SaddleRockUtils.Log(LoggingLevel.ERROR, 'SaddleRockIntakeSingleFileWebhook.DownloadIntakeFile', 'Failed to authenticate Docrio API');
                result.put('success', false);
                result.put('data', 'Failed to authenticate Docrio API');
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            new SaddleRockUtils.Log(LoggingLevel.ERROR, 'SaddleRockIntakeSingleFileWebhook.DownloadIntakeFile', ex.getMessage() + ' ' +  ex.getStackTraceString());
            result.put('success', false);
            result.put('data', ex.getMessage());
        }
        return result;
    }
}