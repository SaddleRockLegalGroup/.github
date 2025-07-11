public with sharing class BridgeLegalAPI_RestAPIWrapper {
    public static final Bridge_Legal_API_Settings__c API_SETTING { 
        get {
            Bridge_Legal_API_Settings__c API_SETTING = Bridge_Legal_API_Settings__c.getOrgDefaults();
            return API_SETTING;
        }
    }
    public Map<string,object> createMatter(Map<string,string> paramMap, Map<string,object> requestPayload) {
        Map<string,object> result = new Map<string,object>();
        string params = '';
        for(string key : paramMap.keySet()){
            if(paramMap.get(key) != null){
                params += key + '=' + EncodingUtil.urlEncode(paramMap.get(key), 'UTF-8') + '&';
            }
        }
        string endpoint = API_SETTING.Base_URL__c + '/matter?' + params.substringBeforeLast('&');
        HttpResponse resp = makeCallout(endpoint, 'POST', JSON.serialize(requestPayload));
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if(respParsed.get('message') != null 
                && string.valueOf(respParsed.get('message')) == 'Succeeded'
                && respParsed.get('data') != null){
                    Map<string,object> dataParsed = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(respParsed.get('data')));
                    result.put('success', true);
                    result.put('data', dataParsed);
                }
                else if(respParsed.get('data') == null && respParsed.get('msg') != null){
                    result.put('success', false);
                    result.put('data', respParsed.get('msg'));
                }
                else {
                    result.put('success', false);
                    result.put('data', resp.getBody());
                }
            }
            catch(System.Exception e) {
                System.debug(e.getMessage() + e.getStackTraceString());
                result.put('success', false);
                result.put('data', e.getMessage() + '\n\n' + e.getStackTraceString());
            }
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
            result.put('success', false);
            result.put('data', resp.getStatusCode() + ' - ' + resp.getStatus() + '\n\n' + resp.getBody());
        }

        return result;
    }

    public Map<string,object> uploadDocument(string bridgeLegalMatterId, string fileName, Blob fileContent) {
        Map<string,object> result = new Map<string,object>();

        string endpoint = API_SETTING.Base_URL__c + '/document/upload';

        try {
            string body = '';
            body += BridgeLegalAPI_HttpFormBuilder.WriteBoundary();
            body += BridgeLegalAPI_HttpFormBuilder.WriteBodyParameter('matterId', bridgeLegalMatterId);
            body += BridgeLegalAPI_HttpFormBuilder.WriteBoundary();
            body += BridgeLegalAPI_HttpFormBuilder.WriteBlobBodyParameter('files', EncodingUtil.base64Encode(fileContent), fileName);
            body += BridgeLegalAPI_HttpFormBuilder.WriteBoundary(BridgeLegalAPI_HttpFormBuilder.EndingType.CrLf);
            
            // String formBody = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n'
            //                     + 'Content-Disposition: form-data; name="matterId"\r\n\r\n'
            //                     + bridgeLegalMatterId + '\r\n'
            //                     + '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n'
            //                     + 'Content-Disposition: form-data; name="files"; filename="' + fileName + '"\r\n'
            //                     + 'Content-Type: application/pdf\r\n\r\n'
            //                     + EncodingUtil.base64Encode(fileContent) + '\r\n'
            //                     + '------WebKitFormBoundary7MA4YWxkTrZu0gW--';

            BridgeLegalAPI_Logger.Log l = new BridgeLegalAPI_Logger.Log(LoggingLevel.INFO, 'BridgeLegalAPI_RestAPIWrapper.uploadDocument', 'Making callout to [POST] ' + endpoint);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setHeader('Authorization', API_SETTING.API_Key__c);
            request.setHeader('Content-Type', BridgeLegalAPI_HttpFormBuilder.GetContentType());
            request.setMethod('POST');
            request.setBodyAsBlob(EncodingUtil.base64Decode(body));
            // request.setBody(formBody);
            request.setTimeout(120000);

            HttpRequest tempToLog = new HttpRequest();
            tempToLog.setEndpoint(endpoint);
            tempToLog.setHeader('Authorization', API_SETTING.API_Key__c);
            tempToLog.setHeader('Content-Type', BridgeLegalAPI_HttpFormBuilder.GetContentType());
            tempToLog.setMethod('POST');
            tempToLog.setBody('Blob (data) from uploadToBridgeLegalAPI\'s GET response');
            l.setRequest(tempToLog);

            HttpResponse resp;
            Http http = new Http();
            resp = http.send(request);
            l.setResponse(resp);
            if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if((respParsed.get('successResult') != null && Boolean.valueOf(respParsed.get('successResult')))
                || (respParsed.get('msg') != null && string.valueOf(respParsed.get('msg')) == 'Succeeded')){
                    result.put('success', true);
                    result.put('data', 'Succeeded');
                }
                else if(respParsed.get('successResult') != null && !Boolean.valueOf(respParsed.get('successResult')) 
                && respParsed.get('msg') != null){
                    result.put('success', false);
                    result.put('data', string.valueOf(respParsed.get('msg')));
                }
                else {
                    result.put('success', false);
                    result.put('data', resp.getBody());
                }
            }
            else{
                System.debug(resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
                result.put('success', false);
                result.put('data', resp.getStatusCode() + ' - ' + resp.getStatus() + ' | ' + resp.getBody());
            }
        }
        catch(Exception e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage() + e.getStackTraceString());
            result.put('success', false);
            result.put('data', e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return result;
    }

    public static HttpResponse makeCallout(String endpoint, String method, String body) {
        System.debug('###BridgeLegalAPI_RestAPIWrapper: makeCallout###');
        System.debug('###BridgeLegalAPI_RestAPIWrapper: method | ' + method + '-' + endpoint + '###');
        System.debug('###BridgeLegalAPI_RestAPIWrapper: body | ' + body + '###');
        BridgeLegalAPI_Logger.Log l = new BridgeLegalAPI_Logger.Log(LoggingLevel.INFO, 'BridgeLegalAPI_RestAPIWrapper.makeCallout', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', API_SETTING.API_Key__c);
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
            new BridgeLegalAPI_Logger.Log(LoggingLevel.ERROR, 'BridgeLegalAPI_RestAPIWrapper.makeCallout', 'Failed to make callout to ' + endpoint + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return httpResponse;
    }
}