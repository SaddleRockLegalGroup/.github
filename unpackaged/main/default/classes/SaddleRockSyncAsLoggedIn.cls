@RestResource(urlMapping='/SaddleRockSyncAsLoggedIn/*')
global without sharing class SaddleRockSyncAsLoggedIn {
    @HttpPost
    global static void doPost(){
        RestResponse res = RestContext.response;
        String vendorName = '';
        String vendorIntegrationId = '';
        string intakeId = '';

        RestRequest req = RestContext.request;
        String rawData = req.requestBody.toString();

        try {
            Map<String, Object> dataParsed = (Map<string, Object>) JSON.deserializeUntyped(rawData);
            vendorIntegrationId = String.valueOf(dataParsed.get('vendorIntegrationId'));
            vendorName = String.valueOf(dataParsed.get('vendorName'));
            String data = String.valueOf(dataParsed.get('data'));
            Map<String, Object> inboundIntakeDataMap = new Map<String, Object>();
            Map<String, Object> dataMap = (Map<string, Object>) JSON.deserializeUntyped(data);
            intakeId = string.valueOf(dataMap.get('id'));

            for(string k : dataMap.keyset()){
                string firstLevelVal = string.valueOf(dataMap.get(k));
                inboundIntakeDataMap.put(k, firstLevelVal);

                // new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockSyncAsLoggedIn', 'JSON Key: ' + k + ', JSON Value: ' + firstLevelVal);
                
                if(firstLevelVal.startsWith('{')){
                    // the value can be parsed 1 more time
                    Map<String, Object> subObjectMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(dataMap.get(k)));
                    for(string i : subObjectMap.keyset()){
                        string secondLevelVal = string.valueOf(subObjectMap.get(i));
                        inboundIntakeDataMap.put(i, secondLevelVal);

                        // new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockSyncAsLoggedIn', 'JSON Key: ' + i + ', JSON Value: ' + secondLevelVal);
                    }
                }
            }

            List<Map<String, Object>> intakeToUpsert = new List<Map<String, Object>>();
            intakeToUpsert.add(inboundIntakeDataMap);

            SaddleRockSyncHandler intakeHandler = new SaddleRockSyncHandler();
            Map<string,object> handlerResp = intakeHandler.SaddleRockSyncHandler(vendorIntegrationId, intakeToUpsert);

            System.debug('SaddleRockSyncHandler stopped');

            if(Boolean.valueOf(handlerResp.get('success'))){
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(string.valueOf(handlerResp.get('data')));

                
                SaddleRockUtils.intakeRecId = intakeId;
                SaddleRockUtils.transName = 'SaddleRockIntakeWebhook';
                SaddleRockUtils.transRequest = data;
                SaddleRockUtils.transResponse = '{"data": ' + data + ', "success": true}';
                SaddleRockUtils.transStatus = 'Success';
                SaddleRockUtils.transVendor = vendorName;
            }
            else {
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(string.valueOf(handlerResp.get('data')));

                SaddleRockUtils.intakeRecId = intakeId;
                SaddleRockUtils.transName = 'SaddleRockIntakeWebhook';
                SaddleRockUtils.transRequest = data;
                SaddleRockUtils.transResponse = string.valueOf(handlerResp.get('data'));
                SaddleRockUtils.transStatus = 'Error';
                SaddleRockUtils.transVendor = vendorName;
            }

            SaddleRockUtils.writeLogs();
            return;
        }
        catch (Exception ex) {
            System.debug(ex);
            String stackTraceString = ex.getStackTraceString();            
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = 500;

            SaddleRockUtils.intakeRecId = intakeId;
            SaddleRockUtils.transName = 'SaddleRockIntakeWebhook';
            SaddleRockUtils.transRequest = rawData;
            SaddleRockUtils.transResponse = ex.getMessage() + '\n\n' + ex.getStackTraceString();
            SaddleRockUtils.transStatus = 'Error';
            SaddleRockUtils.transVendor = vendorName;
            SaddleRockUtils.integrationId = vendorIntegrationId;
            SaddleRockUtils.writeLogs();
            return;
        }
    }
}