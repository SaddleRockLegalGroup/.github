@RestResource(urlMapping='/intakeDesk/newmatter/*')
global without sharing class IntakeDesk_NewMatterWebhook {
    @HttpPost
    global static void doPost() {
        Map<String, Object> inboundIntakeDataMap = new Map<String, Object>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String data = req.requestBody.toString();

        string oAuthOrgId = req.headers.get('sforgid');
        string oAuthAPIKey = req.headers.get('apikey');
        List<brioapi__Integration_Vendor__mdt> vendors = new List<brioapi__Integration_Vendor__mdt>();

        if(!Test.isRunningTest()){
            vendors = [SELECT Label, brioapi__OrgID__c, brioapi__API_Key__c, brioapi__Integration__c, brioapi__Active__c 
                        FROM brioapi__Integration_Vendor__mdt
                        WHERE brioapi__OrgID__c = 'intakeDesk' AND brioapi__API_Key__c = :oAuthAPIKey AND brioapi__Active__c = true
                        LIMIT 1];
        }
        else {
            brioapi__Integration_Vendor__mdt test = new brioapi__Integration_Vendor__mdt();
            test.brioapi__OrgID__c = 'intakeDesk';
            test.brioapi__API_Key__c = 'testapi123';
            test.brioapi__Active__c = true;
            test.Label = 'Test Vendor';
            vendors.add(test);
        }

        try{
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

            HttpResponse httpResponse = runSync(data, vendors[0].brioapi__Integration__c);
        
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = httpResponse.getStatusCode();
            res.responseBody = Blob.valueOf(httpResponse.getBody());
            return;
        }
        catch(Exception e){
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '-' + e.getStackTraceString().replaceAll('\n', '-') + '", "success": false}');

            return;
        }
    }

    private static HttpResponse runSync(string dataString, string integrationId){
        string internalEndpoint = '';
        if(!Test.isRunningTest()){
            internalEndpoint = 'callout:Custom_API/services/apexrest/intakedesksync';
        }
        else {
            internalEndpoint = URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/intakedesksync';
        }
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(internalEndpoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/json');
        
        Map<string,object> payLoad = new Map<String,object>();        
        Map<String, Object> dataParsed = (Map<string, Object>) JSON.deserializeUntyped(dataString);
        payLoad.put('data', dataParsed);
        payLoad.put('integrationId', integrationId);
        request.setBody(JSON.serialize(payLoad));

        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
            System.debug(httpResponse.getBody());
            return httpResponse;
        }
        catch(System.CalloutException e) {
            throw e;
        }
    }
}