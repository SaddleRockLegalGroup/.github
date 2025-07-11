public with sharing class DropboxSignAPIRestAPI {
    public static final Dropbox_Sign_API_Settings__c API_SETTING { 
        get {
            Dropbox_Sign_API_Settings__c API_SETTING = Dropbox_Sign_API_Settings__c.getOrgDefaults();
            return API_SETTING;
        }
    }

    public DropboxSignAPIModels.HttpResponseWrapper testConnection(){
        DropboxSignAPIModels.HttpResponseWrapper respWrapper = new DropboxSignAPIModels.HttpResponseWrapper();
        string method = 'GET';
        string endpoint = API_SETTING.Base_URL__c;
        if(Test.isRunningTest()) {
            endpoint = 'https://api.hellosign.com/v3';
        }
        endpoint = endpoint + '/template/list?test_mode=true';

        HttpResponse resp = makeCallout(endpoint, method, null);
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                Map<string,object> parsedData = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
                respWrapper.success = true;
                respWrapper.message = JSON.serialize(parsedData);
            }
            catch(System.Exception e) {
                System.debug(e.getMessage());
                respWrapper.success = false;
                respWrapper.message = e.getMessage() + ' - ' + e.getStackTraceString();
            }
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
            respWrapper.success = false;
            respWrapper.message = resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody();
        }
        return respWrapper;
    }

    public DropboxSignAPIModels.SignatureRequestRespWrapper sendSignatureRequest(DropboxSignAPIModels.SignatureRequest request){
        DropboxSignAPIModels.SignatureRequestRespWrapper respWrapper = new DropboxSignAPIModels.SignatureRequestRespWrapper();
        string method = 'POST';
        string endpoint = API_SETTING.Base_URL__c;
        if(Test.isRunningTest()) {
            endpoint = 'https://api.hellosign.com/v3';
        }
        endpoint = endpoint + '/signature_request/send';
        HttpResponse resp = makeCallout(endpoint, method, JSON.serialize(request));
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                DropboxSignAPIModels.SignatureRequestResp parsedData = (DropboxSignAPIModels.SignatureRequestResp) JSON.deserialize(resp.getBody(), DropboxSignAPIModels.SignatureRequestResp.class);
                respWrapper.success = true;
                respWrapper.data = parsedData;
            }
            catch(System.Exception e) {
                System.debug(e.getMessage());
                respWrapper.success = false;
                respWrapper.message = e.getMessage() + ' - ' + e.getStackTraceString();
            }
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
            respWrapper.success = false;
            respWrapper.message = resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody();
        }
        return respWrapper;
    }

    public static HttpResponse makeCallout(String endpoint, String method, String body) {
        System.debug('###DropboxSignAPIRestAPI: makeCallout###');
        System.debug('###DropboxSignAPIRestAPI: method | ' + method + '-' + endpoint + '###');
        System.debug('###DropboxSignAPIRestAPI: body | ' + body + '###');

        DropboxSignAPILogger.Log l = new DropboxSignAPILogger.Log(LoggingLevel.INFO, 'DropboxSignAPIRestAPI.makeCallout', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(API_SETTING.API_Key__c + ':'));
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(method);
        request.setTimeout(120000);

        if((method == 'POST' || method == 'PUT') && string.isNotEmpty(body)){
            request.setBody(body);
        }
        l.setRequest(request);
        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
            l.setResponse(httpResponse);
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            new DropboxSignAPILogger.Log(LoggingLevel.ERROR, 'DropboxSignAPIRestAPI.makeCallout exception',
                'Failed to make callout to ' + endpoint + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString());
            throw e;
        }

        return httpResponse;
    }
}