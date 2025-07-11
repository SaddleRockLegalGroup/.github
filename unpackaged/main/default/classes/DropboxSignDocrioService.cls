public with sharing class DropboxSignDocrioService {
    public class SignedUrlObject {
        public String SignedUrl {get;set;}
        public String Id {get;set;}
    }
    public class FilesGetResponse {
        public List<SignedUrlObject> Records {get;set;}
    }

    public static final Endpoints ENDPOINTS { 
        get {
        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        
        if (isSandbox || Test.isRunningTest()) {
            return new Endpoints(
                'https://test.salesforce.com/services/oauth2/authorize',
                'https://test.salesforce.com/services/oauth2/token'
            );
        }
        
        return new Endpoints(
            'https://login.salesforce.com/services/oauth2/authorize',
            'https://login.salesforce.com/services/oauth2/token'
        );
        }
    }

    public class Endpoints {
        String oAuthEndpoint;
        String tokenEndpoint;
        
        public Endpoints(String oAuthEndpoint, String tokenEndpoint) {
            this.oAuthEndpoint = oAuthEndpoint;
            this.tokenEndpoint = tokenEndpoint;
        }
    }
    
    public static final docriosdk__Docrio_Tool_Setting__c  SETTING = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();

    // GET DOCRIO ACCESS TOKEN
    public string refreshDocrioToken() {
        if (SETTING == null ) {
            return null;
        }
        
        String body = 'grant_type=refresh_token&client_id=' + SETTING.docriosdk__Connected_App_Consumer_Key__c
            + '&client_secret=' + SETTING.docriosdk__Connected_App_Consumer_Secret__c + '&refresh_token='
            + SETTING.docriosdk__Refresh_Token__c;
        
        HttpRequest request = new HttpRequest();
        request.setBody(body);
        request.setMethod('POST');
        request.setEndpoint(ENDPOINTS.tokenEndpoint);
        request.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        Map<String, String> responseBody = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
        String accessToken = responseBody.get('access_token');
        return accessToken;
    }

    public FilesGetResponse getDownloadUrls(string token, List<string> fileInfoIds){
        // GET DOCRIO ACCESS TOKEN
        System.debug('### Getting Docrio Token ###');
        string accessToken = token != '' ? token : refreshDocrioToken();

        if(accessToken == null){
            return null;
        }

        String ids = String.join(fileInfoIds, ',');
        String path = SETTING.docriosdk__API_Endpoint__c + '/files?Ids=' + ids;

        try {
            HttpResponse resp = makeCallout(path, 'GET', accessToken, null);
            if(resp.getStatusCode() == 200 || resp.getStatus() == 'OK'){
                FilesGetResponse respData = (FilesGetResponse)JSON.deserialize(resp.getBody(), FilesGetResponse.class);
                return respData;
            }
            else {
                return null;
            }
        }
        catch (Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }

    //MAKE CALLOUT
    public static HttpResponse makeCallout(String endpoint, String method, String token, String body) {
        System.debug('###DropboxSignDocrioService: makeCallout###');
        System.debug('###DropboxSignDocrioService: method | ' + method + '-' + endpoint + '###');
        System.debug('###DropboxSignDocrioService: body | ' + body + '###');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(method);
        request.setTimeout(120000);

        if(method == 'POST' && string.isNotEmpty(body)){
            request.setBody(body);
        }
        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            throw e;
        }
        return httpResponse;
    }
}