public with sharing class FV_RestAPIWrapper {
    public static final Filevine_API_Settings__c API_SETTING { 
        get {
            Filevine_API_Settings__c API_SETTING = Filevine_API_Settings__c.getOrgDefaults();
            return API_SETTING;
        }
    }
    
    public static FV_Models.HttpResponseWrapper createSession(){
        FV_Models.HttpResponseWrapper result = new FV_Models.HttpResponseWrapper();
        string apiKey = API_SETTING.API_Key__c;
        string apiSecret = API_SETTING.API_Secret__c;
        string method = 'POST';
        string timestampNow = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        string endpoint = API_SETTING.Base_URL__c + '/session';

        FV_Models.LoginModel payload = new FV_Models.LoginModel();
        payload.mode = 'key';
        payload.apiKey = apiKey;
        Blob targetBlob = Blob.valueOf(apiKey + '/' + timestampNow + '/' + apiSecret);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        payload.apiHash = EncodingUtil.convertToHex(hash);
        payload.apiTimestamp = timestampNow;

        HttpResponse resp = authCallout(endpoint, method, JSON.serialize(payload));
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            result.success = true;
            result.data = resp.getBody();
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus());
            result.success = false;
            result.data = resp.getStatusCode() + ' - ' + resp.getStatus();
        }
        return result;
    }

    public FV_Models.HttpResponseWrapper createCustomContact(List<Map<string,object>> requestPayload, FV_Models.LoginRespModel loginInfo) {
        FV_Models.HttpResponseWrapper result = new FV_Models.HttpResponseWrapper();
        if(loginInfo == null){
            FV_Models.HttpResponseWrapper sessionResp = createSession();
            if(sessionResp.success == false){
                result.success = false;
                result.data = sessionResp.data;
                return result;
            }
            loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(sessionResp.data, FV_Models.LoginRespModel.class);
        }
        
        string endpoint = API_SETTING.Base_URL__c + '/core/custom-contacts';
        HttpResponse resp = makeCallout(endpoint, 'POST', JSON.serialize(requestPayload), loginInfo);
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            result.success = true;
            result.data = resp.getBody();
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus());
            result.success = false;
            result.data = resp.getStatusCode() + ' - ' + resp.getStatus();
        }
        return result;
    }

    public FV_Models.HttpResponseWrapper createProject(Map<string,object> requestPayload, FV_Models.LoginRespModel loginInfo){
        FV_Models.HttpResponseWrapper result = new FV_Models.HttpResponseWrapper();
        if(loginInfo == null){
            FV_Models.HttpResponseWrapper sessionResp = createSession();
            if(sessionResp.success == false){
                result.success = false;
                result.data = sessionResp.data;
                return result;
            }
            loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(sessionResp.data, FV_Models.LoginRespModel.class);
        }
        
        string endpoint = API_SETTING.Base_URL__c + '/core/projects';
        HttpResponse resp = makeCallout(endpoint, 'POST', JSON.serialize(requestPayload), loginInfo);
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            result.success = true;
            result.data = resp.getBody();
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus());
            result.success = false;
            result.data = resp.getStatusCode() + ' - ' + resp.getStatus();
        }
        return result;
    }

    public FV_Models.HttpResponseWrapper updateProjectForm(string projectId, string formName, Map<string,object> requestPayload, FV_Models.LoginRespModel loginInfo){
        FV_Models.HttpResponseWrapper result = new FV_Models.HttpResponseWrapper();
        if(loginInfo == null){
            FV_Models.HttpResponseWrapper sessionResp = createSession();
            if(sessionResp.success == false){
                result.success = false;
                result.data = sessionResp.data;
                return result;
            }
            loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(sessionResp.data, FV_Models.LoginRespModel.class);
        }
        
        string endpoint = API_SETTING.Base_URL__c + '/core/projects/' + projectId + '/forms/' + formName;
        HttpResponse resp = makeCallout(endpoint, 'PATCH', JSON.serialize(requestPayload), loginInfo);
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            result.success = true;
            result.data = resp.getBody();
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus());
            result.success = false;
            result.data = resp.getStatusCode() + ' - ' + resp.getStatus();
        }
        return result;
    }

    public FV_Models.HttpResponseWrapper uploadDocument(Map<string,object> fileMetaPayload, Blob fileContent, string projectId, FV_Models.LoginRespModel loginInfo){
        FV_Models.HttpResponseWrapper result = new FV_Models.HttpResponseWrapper();
        if(loginInfo == null){
            FV_Models.HttpResponseWrapper sessionResp = createSession();
            if(sessionResp.success == false){
                result.success = false;
                result.data = sessionResp.data;
                return result;
            }
            loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(sessionResp.data, FV_Models.LoginRespModel.class);
        }
        string method = 'POST';
        string endpoint = API_SETTING.Base_URL__c + '/core/documents';
        HttpResponse resp = makeCallout(endpoint, method, JSON.serialize(fileMetaPayload), loginInfo);
        if(resp.getStatus().equalsIgnoreCase('OK') || resp.getStatusCode() == 200){
            try{
                FV_Models.DocumentURLResp doc = (FV_Models.DocumentURLResp) JSON.deserialize(resp.getBody(), FV_Models.DocumentURLResp.class);
                string uploadUrl = doc.url;
                string contentType = doc.contentType;
                string documentId = doc.documentId.native;
                FV_Logger.Log l = new FV_Logger.Log(LoggingLevel.INFO, 'FV_RestAPIWrapper.uploadDocument', 'Making callout to [PUT] ' + uploadUrl);

                HttpRequest request = new HttpRequest();
                request.setEndpoint(uploadUrl);
                request.setMethod('PUT');
                request.setTimeout(120000);
                request.setBodyAsBlob(fileContent);
                request.setHeader('Content-Type', contentType);
                
                // l.setRequest(request);
                HttpRequest tempToLog = new HttpRequest();
                tempToLog.setEndpoint(uploadUrl);
                tempToLog.setHeader('Content-Type', contentType);
                tempToLog.setMethod('PUT');
                tempToLog.setBody('Blob (data) from GET response');
                l.setRequest(tempToLog);
                
                HttpResponse httpResponse;
                Http http = new Http();
                httpResponse = http.send(request);
                l.setResponse(httpResponse);

                if(httpResponse.getStatus().equalsIgnoreCase('OK') || httpResponse.getStatusCode() == 200){
                    string addDocToProjectEndpoint = API_SETTING.Base_URL__c + '/core/projects/' + projectId + '/documents/' + documentId;
                    HttpResponse addDocToProjectResp = makeCallout(addDocToProjectEndpoint, 'POST', null, loginInfo);
                    if(addDocToProjectResp.getStatus().equalsIgnoreCase('OK') || addDocToProjectResp.getStatusCode() == 200){
                        result.success = true;
                        result.data = addDocToProjectResp.getBody();
                    }
                    else{
                        System.debug(addDocToProjectResp.getStatusCode() + ' - ' + addDocToProjectResp.getStatus());
                        result.success = false;
                        result.data = addDocToProjectResp.getStatusCode() + ' - ' + addDocToProjectResp.getStatus();
                    }
                }
                else{
                    System.debug(httpResponse.getStatusCode() + ' - ' + httpResponse.getStatus());
                    result.success = false;
                    result.data = httpResponse.getStatusCode() + ' - ' + httpResponse.getStatus();
                }
            }
            catch(System.Exception e) {
                System.debug(e.getMessage());
                result.success = false;
                result.data = e.getMessage();
            
            }
        }
        else{
            System.debug(resp.getStatusCode() + ' - ' + resp.getStatus());
            result.success = false;
            result.data = resp.getStatusCode() + ' - ' + resp.getStatus();
        }
        return result;
    }

    public static HttpResponse makeCallout(String endpoint, String method, String body, FV_Models.LoginRespModel loginInfo){
        System.debug('###FV_RestAPIWrapper: makeCallout###');
        System.debug('###FV_RestAPIWrapper: method | ' + method + '-' + endpoint + '###');
        System.debug('###FV_RestAPIWrapper: body | ' + body + '###');
        FV_Logger.Log l = new FV_Logger.Log(LoggingLevel.INFO, 'FV_RestAPIWrapper.makeCallout', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setTimeout(120000);

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + loginInfo.accessToken);
        request.setHeader('x-fv-orgid', loginInfo.orgId);
        request.setHeader('x-fv-userid', loginInfo.userId);
        request.setHeader('x-fv-sessionid', loginInfo.refreshToken);

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
            new FV_Logger.Log(LoggingLevel.ERROR, 'FV_RestAPIWrapper.makeCallout', 'Failed to make callout to ' + endpoint + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return httpResponse;
    }

    public static HttpResponse authCallout(String endpoint, String method, String body) {
        System.debug('###FV_RestAPIWrapper: authCallout###');
        System.debug('###FV_RestAPIWrapper: method | ' + method + '-' + endpoint + '###');
        System.debug('###FV_RestAPIWrapper: body | ' + body + '###');
        FV_Logger.Log l = new FV_Logger.Log(LoggingLevel.INFO, 'FV_RestAPIWrapper.authCallout', 'Making callout to [' + method + '] ' + endpoint);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setTimeout(120000);
        request.setBody(body);
        request.setHeader('Content-Type', 'application/json');
        
        l.setRequest(request);
        
        HttpResponse httpResponse;
        try {
            Http http = new Http();
            httpResponse = http.send(request);
            l.setResponse(httpResponse);
        }
        catch(System.CalloutException e) {
            System.debug('Failed to make callout to ' + endpoint + '. Error: ' + e.getMessage());
            new FV_Logger.Log(LoggingLevel.ERROR, 'FV_RestAPIWrapper.authCallout', 'Failed to make callout to ' + endpoint + '\n\n' + e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return httpResponse;
    }
}