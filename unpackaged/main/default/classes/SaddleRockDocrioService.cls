public with sharing virtual class SaddleRockDocrioService {
    public static final Endpoints ENDPOINTS { get {
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
    }}
    public class Endpoints {
        String oAuthEndpoint;
        String tokenEndpoint;
        
        public Endpoints(String oAuthEndpoint, String tokenEndpoint) {
            this.oAuthEndpoint = oAuthEndpoint;
            this.tokenEndpoint = tokenEndpoint;
        }
    }
    public static final docriosdk__Docrio_Tool_Setting__c  SETTING = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();

    //GET DOCRIO ACCESS TOKEN
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
        
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.refreshDocrioToken', accessToken);
        return accessToken;
    }
    

    //CREATE EXTERNAL LINK
    public SaddleRockDocrioAPIModels.ExternalLinkPostResponseWrapper createExternalLink(string token, SaddleRockDocrioAPIModels.ExternalLinkPostRequest request){
        SaddleRockDocrioAPIModels.ExternalLinkPostResponseWrapper externalLinkRespWrapper = new SaddleRockDocrioAPIModels.ExternalLinkPostResponseWrapper();

        //Get Docrio Access Token
        System.debug('### Getting Docrio Token ###');
        string accessToken = token != '' ? token : refreshDocrioToken();

        if(accessToken == null){
            externalLinkRespWrapper.success = false;
            externalLinkRespWrapper.message = 'Failed to get Docrio Access Token';
            return externalLinkRespWrapper;
        }

        System.debug('### Creating external link ###');
        String path = SETTING.docriosdk__API_Endpoint__c + '/externallink/create';

        try {
            HttpResponse resp = makeCallout(path, 'POST', accessToken, JSON.serialize(request));
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201 || resp.getStatus() == 'OK'){
                Map<string,object> externalLinkResp = (Map<string,object>)JSON.deserializeUntyped(resp.getBody());
                externalLinkRespWrapper.success = true;
                externalLinkRespWrapper.message = 'External link has been successfully created.';
                externalLinkRespWrapper.data = externalLinkResp;
                return externalLinkRespWrapper;
            }
            else {
                externalLinkRespWrapper.success = false;
                externalLinkRespWrapper.message = resp.getStatusCode() + ' - ' + resp.getStatus() + ': ' + resp.getBody();
                return externalLinkRespWrapper;
            }
        }
        catch (Exception e){
            System.debug(e.getMessage());
            externalLinkRespWrapper.success = false;
            externalLinkRespWrapper.message = e.getMessage();
            return externalLinkRespWrapper;
        }
    }

    //MAKE CALLOUT
    public static HttpResponse makeCallout(String endpoint, String method, String token, String body) {
        System.debug('###SaddleRockDocrioService: makeCallout###');
        System.debug('###SaddleRockDocrioService: method | ' + method + '-' + endpoint + '###');
        System.debug('###SaddleRockDocrioService: body | ' + body + '###');
        
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.makeCallout', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(method);
        request.setTimeout(120000);

        if((method == 'POST' || method == 'PUT') && string.isNotEmpty(body)){
            request.setBody(body);
            new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.makeCallout', method + ' Payload ' + endpoint + ': ' + body);
        }
        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            
            new SaddleRockUtils.Log(LoggingLevel.ERROR, 'SaddleRockDocrioService.makeCallout', 'Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            throw e;
        }

        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.makeCallout', 'Resp ' + endpoint + ': ' + httpResponse.getStatusCode() + ' | ' + httpResponse.getBody());
        return httpResponse;
    }

    //MAKE CALLOUT BLOB
    public static HttpResponse makeCalloutBlob(String endpoint, String method, String token, Blob body) {
        System.debug('###SaddleRockDocrioService: makeCalloutBlob###');
        System.debug('###SaddleRockDocrioService: method | ' + method + '-' + endpoint + '###');
        System.debug('###SaddleRockDocrioService: body | ' + body + '###');
        
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.makeCalloutBlob', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(method);
        request.setTimeout(120000);

        if((method == 'POST' || method == 'PUT') && body != null){
            request.setBodyAsBlob(body);
            new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.makeCalloutBlob', method + ' Payload ' + endpoint + ': ' + body);
        }
        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            
            new SaddleRockUtils.Log(LoggingLevel.ERROR, 'SaddleRockDocrioService.makeCalloutBlob', 'Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            throw e;
        }

        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'SaddleRockDocrioService.makeCalloutBlob', 'Resp ' + endpoint + ': ' + httpResponse.getStatusCode() + ' | ' + httpResponse.getBody());
        return httpResponse;
    }

    //DOCRIO - Create file info
    public Map<string,object> createFileInfo(string token, List<Map<String, String>> filesMap){
        Map<string,object> result = new Map<string,object>();
        //Get Docrio Access Token
        System.debug('### Getting Docrio Token ###');
        string accessToken = token != '' ? token : refreshDocrioToken();

        if(accessToken == null){
            result.put('success', false);
            result.put('message', 'Authentication failed');
            return result;
        }

        System.debug('### Creating file info ###');
        String path = SETTING.docriosdk__API_Endpoint__c + '/files';

        try {
            HttpResponse resp = makeCallout(path, 'POST', accessToken, JSON.serialize(filesMap));
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201 || resp.getStatus() == 'OK'){
                Map<string,object> respMap = (Map<string,object>)JSON.deserializeUntyped(resp.getBody());
                Map<string,object> fileParsed = (Map<string,object>)JSON.deserializeUntyped(JSON.serialize(respMap.values()[0]));

                result.put('success', true);
                result.put('message', 'OK');
                result.put('SignedUrl', String.valueOf(fileParsed.get('SignedUrl')));
                result.put('Id', String.valueOf(fileParsed.get('Id')));
            }
        }
        catch (Exception e){
            System.debug(e.getMessage());
            result.put('success', false);
            result.put('message', e.getMessage());
        }
        return result;
    }

    //DOCRIO - Upload file
    public Map<string,object> uploadFile(string token, string signedURL, Blob file){
        Map<string,object> result = new Map<string,object>();
        //Get Docrio Access Token
        System.debug('### Getting Docrio Token ###');
        string accessToken = token != '' ? token : refreshDocrioToken();

        if(accessToken == null){
            result.put('success', false);
            result.put('message', 'Authentication failed');
            return result;
        }

        System.debug('### Uploading file ###');
        String path = signedURL;

        try {
            HttpResponse resp = makeCalloutBlob(path, 'PUT', accessToken, file);
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201 || resp.getStatus() == 'OK'){
                result.put('success', true);
                result.put('message', 'OK');
            }
            else {
                result.put('success', false);
                result.put('message', resp.getStatusCode() + ' - ' + resp.getBody());
            }
        }
        catch (Exception e){
            System.debug(e.getMessage());
            result.put('success', false);
            result.put('message', e.getMessage());
        }
        
        return result;
    }

    //DOCRIO - Complete uploading
    public Map<string,object> completeUpload(string token, List<string> ids){
        Map<string,object> result = new Map<string,object>();
        //Get Docrio Access Token
        System.debug('### Getting Docrio Token ###');
        string accessToken = token != '' ? token : refreshDocrioToken();

        if(accessToken == null){
            result.put('success', false);
            result.put('message', 'Authentication failed');
            return result;
        }

        System.debug('### Completing file upload ###');
        String path = SETTING.docriosdk__API_Endpoint__c + '/files/complete';
        Map<string,List<string>> payload = new Map<string,List<string>>();
        payload.put('Ids', ids);

        try {
            HttpResponse resp = makeCallout(path, 'POST', accessToken, JSON.serialize(payload));
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201 || resp.getStatus() == 'OK'){
                result.put('success', true);
                result.put('message', 'OK');
            }
            else {
                result.put('success', false);
                result.put('message', resp.getStatusCode() + ' - ' + resp.getBody());
            }
        }
        catch (Exception e){
            System.debug(e.getMessage());
            result.put('success', false);
            result.put('message', e.getMessage());
        }
        
        return result;
    }

    //DOCRIO - GET SIGNED URLS
    public SaddleRockDocrioAPIModels.FilesGetResponse getDownloadUrls(List<Id> fileInfoIds){
        String ids = String.join((List<String>)fileInfoIds, ',');
        String path = SETTING.docriosdk__API_Endpoint__c + '/files?Ids=' + ids;

        try {
            string accessToken = refreshDocrioToken();
            HttpResponse resp = makeCallout(path, 'GET', accessToken, null);
            if(resp.getStatusCode() == 200 || resp.getStatus() == 'OK'){
                SaddleRockDocrioAPIModels.FilesGetResponse respData = (SaddleRockDocrioAPIModels.FilesGetResponse)JSON.deserialize(resp.getBody(), SaddleRockDocrioAPIModels.FilesGetResponse.class);
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
}