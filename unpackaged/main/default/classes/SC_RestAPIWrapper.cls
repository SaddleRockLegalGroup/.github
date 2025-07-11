public with sharing class SC_RestAPIWrapper {
    public static final Simply_Convert_API_Setting__c API_SETTING { 
        get {
            Simply_Convert_API_Setting__c API_SETTING = Simply_Convert_API_Setting__c.getOrgDefaults();
            return API_SETTING;
        }
    }
    public Map<string,object> createCase(SC_APIModels.CaseResource caseRequest) {
        Map<string,object> result = new Map<string,object>();
        string endpoint = API_SETTING.Base_URL__c + '/cases';
        HttpResponse resp = makeCallout(endpoint, 'POST', JSON.serialize(caseRequest));
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if(respParsed.get('data') != null){
                    Map<string,object> dataParsed = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(respParsed.get('data')));
                    result.put('success', true);
                    result.put('data', dataParsed.get('uuid'));
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
    public Map<string,object> updateCase(SC_APIModels.CaseResource caseRequest, string api_casesafe_id) {
        Map<string,object> result = new Map<string,object>();
        string endpoint = API_SETTING.Base_URL__c + '/cases/' + api_casesafe_id;
        HttpResponse resp = makeCallout(endpoint, 'PUT', JSON.serialize(caseRequest));
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if(respParsed.get('message') != null){
                    //Map<string,object> dataParsed = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(respParsed.get('data')));
                    result.put('success', true);
                    result.put('data', respParsed.get('message'));
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

    public Map<string,object> updateCaseReferrall(SC_APIModels.CaseResource caseRequest, string api_casesafe_id) {
        Map<string,object> result = new Map<string,object>();
        string endpoint = API_SETTING.Base_URL__c + '/cases/' + api_casesafe_id + '/referral';
        string putBody = '{"referred_from_company_uuid" : "' + caseRequest.referred_from_company_uuid + '", "referred_to_company_uuid" : "' + caseRequest.referred_to_company_uuid + '"}';
        HttpResponse resp = makeCallout(endpoint, 'PUT', putBody );
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if(respParsed.get('message') != null){
                    //Map<string,object> dataParsed = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(respParsed.get('data')));
                    result.put('success', true);
                    result.put('data', respParsed.get('message'));
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

    public Map<string,object> uploadDocument(string caseId, string fileMeta, string fileName, Blob fileContent) {
        Map<string,object> result = new Map<string,object>();

        string endpoint = API_SETTING.Base_URL__c + '/cases/' + caseId + '/documents';

        try {
            string body = '';
            body += SC_HttpFormBuilder.WriteBoundary();
            body += SC_HttpFormBuilder.WriteBodyParameter('file_meta', fileMeta);
            body += SC_HttpFormBuilder.WriteBoundary();
            body += SC_HttpFormBuilder.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(fileContent), fileName);
            body += SC_HttpFormBuilder.WriteBoundary(SC_HttpFormBuilder.EndingType.CrLf);
            
            // String formBody = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n'
            //                     + 'Content-Disposition: form-data; name="matterId"\r\n\r\n'
            //                     + bridgeLegalMatterId + '\r\n'
            //                     + '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\n'
            //                     + 'Content-Disposition: form-data; name="files"; filename="' + fileName + '"\r\n'
            //                     + 'Content-Type: application/pdf\r\n\r\n'
            //                     + EncodingUtil.base64Encode(fileContent) + '\r\n'
            //                     + '------WebKitFormBoundary7MA4YWxkTrZu0gW--';

            SC_Logger.Log l = new SC_Logger.Log(LoggingLevel.INFO, 'SC_RestAPIWrapper.uploadDocument', 'Making callout to [POST] ' + endpoint);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setHeader('API-Key', API_SETTING.API_Key__c);
            request.setHeader('Content-Type', SC_HttpFormBuilder.GetContentType());
            request.setMethod('POST');
            request.setBodyAsBlob(EncodingUtil.base64Decode(body));
            // request.setBody(formBody);
            request.setTimeout(120000);

            // l.setRequest(request);

            HttpResponse resp;
            Http http = new Http();
            resp = http.send(request);
            l.setResponse(resp);
            if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if(respParsed.get('message') != null && string.valueOf(respParsed.get('message')) == 'Document Uploaded'){
                    result.put('success', true);
                    result.put('data', 'Document Uploaded: ' + fileName);
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
        // SC_Logger.writeLogs();
        return result;
    }

    public Map<string,object> voidDocument(string caseId) {
        Map<string,object> result = new Map<string,object>();

        string endpoint = API_SETTING.Base_URL__c + '/cases/' + caseId + '/documents';

        try {
            HttpResponse resp = makeCallout(endpoint, 'DELETE', null);
            if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
                result.put('success', true);
                result.put('data', resp.getBody());
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
        // SC_Logger.writeLogs();
        return result;
    }
    public Map<string,object> updateCaseUsingMap(Map<string,object> caseRequest, string api_casesafe_id) {
        Map<string,object> result = new Map<string,object>();
        string endpoint = API_SETTING.Base_URL__c + '/cases/' + api_casesafe_id;
        HttpResponse resp = makeCallout(endpoint, 'PUT', JSON.serialize(caseRequest));
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                Map<string,object> respParsed = (Map<string,object>) JSON.deserializeUntyped(resp.getBody());

                if(respParsed.get('message') != null){
                    //Map<string,object> dataParsed = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(respParsed.get('data')));
                    result.put('success', true);
                    result.put('data', respParsed.get('message'));
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

    public static HttpResponse makeCallout(String endpoint, String method, String body) {
        System.debug('###SC_RestAPIWrapper: makeCallout###');
        System.debug('###SC_RestAPIWrapper: method | ' + method + '-' + endpoint + '###');
        System.debug('###SC_RestAPIWrapper: body | ' + body + '###');
        SC_Logger.Log l = new SC_Logger.Log(LoggingLevel.INFO, 'SC_RestAPIWrapper.makeCallout', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('API-Key', API_SETTING.API_Key__c);
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
            new SC_Logger.Log(LoggingLevel.ERROR, 'SC_RestAPIWrapper.makeCallout', 'Failed to make callout to ' + endpoint + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return httpResponse;
    }
}