@RestResource(urlMapping='/SaddleRockIntakeWebhook/*')
global without sharing class SaddleRockIntakeWebhookEndpoint {
    @HttpPost
    global static void doPost() {
        Map<String, Object> inboundIntakeDataMap = new Map<String, Object>();
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

            if(req.requestBody == null || req.requestBody.toString() == ''){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "Request body is empty", "success": false}');
                return;
            }

            String data = req.requestBody.toString();

            SaddleRockAuthenticate loginAs = new SaddleRockAuthenticate();
            string accessToken = loginAs.authenticateAsAPIUser();

            HttpResponse httpResponse = runSync(accessToken, data, vendors[0].Integration__c, vendors[0].Label);
            
            System.debug('runSync stopped');

            res.statusCode = httpResponse.getStatusCode();
            res.addHeader('Content-Type', 'application/json');
            if(httpResponse.getStatusCode() == 200){
                res.responseBody = Blob.valueOf('{"data": ' + data + ', "success": true}');
            }
            else {
                res.responseBody = Blob.valueOf('{"error": "' + httpResponse.getBody() + '", "success": false}');
            }
            return;
        }
        catch(Exception e){
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '", "success": false}');
            return;
        }
    }

    private static HttpResponse runSync(string token, string data, Id vendorIntegrationId, string vendorName){
        System.debug('runSync started');

        Map<string,string> payLoad = new Map<String,string>();
        payLoad.put('data', data);
        payLoad.put('vendorIntegrationId', vendorIntegrationId);
        payLoad.put('vendorName', vendorName);

        string internalEndpoint = URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/SaddleRockSyncAsLoggedIn';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(internalEndpoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(payLoad));

        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
            System.debug(httpResponse.getBody());
            return httpResponse;
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + internalEndpoint + '. Error: ' + e.getMessage());
            throw e;
        }            
    }
    
}