public with sharing class Tekmir_RestAPIWrapper {    
    public static final string TEKMIR_NAMEDCREDENTIAL { 
        get {
            Tekmir_API_Settings__c API_SETTING = Tekmir_API_Settings__c.getOrgDefaults();
            if( API_SETTING == null || (API_SETTING != null && API_SETTING.Test_mode__c == null) ) {
                return 'TekmirNamedCredStaging';
            }
            return API_SETTING.Test_mode__c ? API_SETTING.Named_Credentials_Staging__c : API_SETTING.Named_Credentials_Prod__c;
        }
    }

    public Tekmir_Models.HttpResponseWrapper sendNewMatterRequest(Tekmir_Models.NewMatterRequest request){
        System.debug('### Tekmir_RestAPIWrapper: sendNewMatterRequest ###');
        Tekmir_Models.HttpResponseWrapper respWrapper = new Tekmir_Models.HttpResponseWrapper();
        string endpoint = 'callout:' + TEKMIR_NAMEDCREDENTIAL + '/newmatter';
        string method = 'POST';
        
        // Submit new matter
        HttpResponse resp = makeCallout(endpoint, method, JSON.serialize(request));

        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
            respWrapper.success = true;
            respWrapper.data = resp.getBody();
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
            respWrapper.success = false;
            respWrapper.data = resp.getStatusCode() + ' - ' + resp.getStatus() + '\n\n' + resp.getBody();
        }
        return respWrapper;
    }
    
    public Tekmir_Models.HttpResponseWrapper sendNewDocumentRequest(Tekmir_Models.NewDocument request){
        System.debug('### Tekmir_RestAPIWrapper: sendNewDocumentRequest ###');
        Tekmir_Models.HttpResponseWrapper respWrapper = new Tekmir_Models.HttpResponseWrapper();
        string endpoint = 'callout:' + TEKMIR_NAMEDCREDENTIAL + '/newdocument';
        string method = 'POST';
        
        // Submit new document
        HttpResponse resp = makeCallout(endpoint, method, JSON.serialize(request));

        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
            respWrapper.success = true;
            respWrapper.data = resp.getBody();
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
            respWrapper.success = false;
            respWrapper.data = resp.getStatusCode() + ' - ' + resp.getStatus() + '\n\n' + resp.getBody();
        }
        return respWrapper;
    }
    
    public static HttpResponse makeCallout(String endpoint, String method, String body) {
        System.debug('###Tekmir_RestAPIWrapper: makeCallout###');
        System.debug('###Tekmir_RestAPIWrapper: method | ' + method + '-' + endpoint + '###');
        System.debug('###Tekmir_RestAPIWrapper: body | ' + body + '###');

        Tekmir_Logger.Log l = new Tekmir_Logger.Log(LoggingLevel.INFO, 'Tekmir Callout Log', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(method);
        request.setTimeout(120000);

        if((method == 'POST' || method == 'PUT' || method == 'PATCH') && string.isNotEmpty(body)){
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
            new Tekmir_Logger.Log(LoggingLevel.ERROR, 'Tekmir Callout Log Exception',
                'Failed to make callout to ' + endpoint + '\n\n body ' + body + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString());
            throw e;
        }

        return httpResponse;
    }
}