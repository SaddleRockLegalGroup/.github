public with sharing class SaddleRockAuthenticate {
    public string authenticateAsAPIUser() {
        List<Integration_Setting__mdt> settings = new List<Integration_Setting__mdt>();
        if(!Test.isRunningTest()){
            settings = [SELECT Client_ID__c, Client_Secret__c 
                        FROM Integration_Setting__mdt 
                        WHERE DeveloperName = 'Custom_Intake_API' 
                        LIMIT 1];
        }
        else {
            settings = SaddleRockTestDataFactory.generateTestIntegrationSetting();
        }

        Map<string,string> bodyMap = new Map<string,string>();
        string clientId = settings[0].Client_ID__c;
        string clientSecret = settings[0].Client_Secret__c;
        string endpoint = URL.getOrgDomainUrl().toExternalForm() + '/services/oauth2/token';
        String payLoad = 'grant_type=client_credentials' 
        + '&client_id=' + EncodingUtil.urlEncode(clientId,'UTF-8') 
        + '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(payLoad);
        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
            System.debug(httpResponse.getBody());
            Map<string,object> resp = (Map<string,object>) JSON.deserializeUntyped(httpResponse.getBody());
            return String.valueOf(resp.get('access_token'));
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            throw e;
        }
    }
}