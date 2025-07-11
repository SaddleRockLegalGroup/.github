@RestResource(urlMapping='/SaddleRockIntakeFileWebhook/*')
global without sharing class SaddleRockIntakeFileWebhookEndpoint {
    @HttpPost
    global static void doPost() {
        System.debug('### SaddleRockIntakeFileWebhook ###');
        Map<String, Object> inboundIntakeDataMap = new Map<String, Object>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string intakeId = '';
        String data = '';
        Boolean hasError = false;

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

            if(req.requestBody == null || req.requestBody.toString() == ''){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Request body is empty", "success": false}');
                return;
            }

            data = req.requestBody.toString();
            Map<String, Object> dataMap = (Map<string, Object>) JSON.deserializeUntyped(data);
            intakeId = string.valueOf(dataMap.get('id'));

            SaddleRockUtils.integrationId = vendors[0].Integration__c;
            SaddleRockUtils.intakeRecId = intakeId;
            SaddleRockUtils.transName = 'SaddleRockIntakeFileWebhook';
            SaddleRockUtils.transRequest = data;
            SaddleRockUtils.transVendor = vendors[0].Label;

            if(intakeId == null || intakeId == ''){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Intake ID is missing", "success": false}');
                
                SaddleRockUtils.transResponse = '{"error": "Intake ID is missing", "success": false}';
                SaddleRockUtils.transStatus = 'Error';
                return;
            }

            List<Object> fileList = (List<Object>) dataMap.get('documents');
            List<Map<string,object>> fileRespWrapper = new List<Map<string,object>>();
            for(Object fileObj : fileList){
                Map<string,string> file = (Map<string,string>) JSON.deserialize(JSON.serialize(fileObj), Map<string,string>.class);
                string combinedExternalId = vendors[0].OrgID__c + '-' + file.get('externalId');

                SaddleRockFileHandler fileHandler = new SaddleRockFileHandler();
                docriosdk.Models.FilesPostResponse docrioResponse = !Test.isRunningTest() ? fileHandler.saveFileToDocrio(intakeId, combinedExternalId, file.get('name'), file.get('description'), file.get('documentType'), file.get('signedUrl')) : null;
                Map<string,object> resp = new Map<string,object>();
                if(docrioResponse != null && docrioResponse.Successes != null && docrioResponse.Successes.size() > 0){
                    resp.put('success', true);
                    resp.put('fileName', file.get('name'));
                    resp.put('externalId', combinedExternalId);
        
                    resp.put('id', docrioResponse.Successes[0].Id);
                    resp.put('message', docrioResponse.Message);
                }
                else {
                    hasError = true;
                    resp.put('success', false);
                    resp.put('id', docrioResponse != null ? docrioResponse.Failures[0] : null);
                    resp.put('fileName', file.get('name'));
                    resp.put('externalId', combinedExternalId);
                }

                fileRespWrapper.add(new Map<string,object>{
                    'success' => resp.get('success'),
                    'id' => resp.get('id'),
                    'fileName' => resp.get('fileName'),
                    'externalId' => resp.get('externalId'),
                    'message' => resp.get('message')
                });
            }

            if(hasError){
                res.statusCode = 400;
                SaddleRockUtils.transStatus = 'Error';
            }
            else {
                res.statusCode = 200;
                SaddleRockUtils.transStatus = 'Success';
            }
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"result": '  + JSON.serialize(fileRespWrapper) + '}');

            SaddleRockUtils.transResponse = '{"result": '  + JSON.serialize(fileRespWrapper) + '}';
            SaddleRockUtils.writeLogs();
            return;

        }
        catch(Exception e){
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '", "success": false}');

            SaddleRockUtils.transResponse = e.getMessage() + '\n\n' +  e.getStackTraceString();
            SaddleRockUtils.transStatus = 'Error';

            SaddleRockUtils.writeLogs();
            return;
        }
    }
}