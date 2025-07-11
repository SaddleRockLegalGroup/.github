public with sharing class Etech_RestAPIWrapper {
    public static final Etech_API_Setting__c API_SETTING { 
        get {
            Etech_API_Setting__c API_SETTING = Etech_API_Setting__c.getOrgDefaults();
            return API_SETTING;
        }
    }
    public Etech_Models.ResponseWrapperModel sendToEtech(Etech_Models.RequestModel request, string relatedRecId) {
        System.debug('### Etech_InvocableSendToEtech: sendToEtech ###');
        Etech_Models.ResponseWrapperModel respWrapper = new Etech_Models.ResponseWrapperModel();
        string endpoint = API_SETTING == null || API_SETTING.Test_mode__c ? API_SETTING.API_URL_Staging__c : API_SETTING.API_URL_Prod__c;
        string method = 'POST';
        
        // Submit to Etech Dialer
        HttpResponse resp = makeCallout(endpoint, method, JSON.serialize(request), relatedRecId);

        if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
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
    public static HttpResponse makeCallout(String endpoint, String method, String body, string relatedRecId) {
        System.debug('###Etech_InvocableSendToEtech: makeCallout###');
        System.debug('###Etech_InvocableSendToEtech: method | ' + method + '-' + endpoint + '###');
        System.debug('###Etech_InvocableSendToEtech: body | ' + body + '###');

        Etech_Logger.Log l = new Etech_Logger.Log(LoggingLevel.INFO, 'Etech Callout Log', 'Making callout to [' + method + '] ' + endpoint, relatedRecId);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' + API_SETTING.Token__c);
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
            new Etech_Logger.Log(LoggingLevel.ERROR, 'Etech Callout Log Exception',
                'Failed to make callout to ' + endpoint + '\n\n body ' + body + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString(), relatedRecId);
            throw e;
        }

        return httpResponse;
    }
}