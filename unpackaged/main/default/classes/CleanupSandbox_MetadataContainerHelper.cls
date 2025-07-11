public class CleanupSandbox_MetadataContainerHelper {
    public static void toggleTrigger(String triggerName, string triggerStatus) {
        try {
            List<ApexTrigger> tgrs = [SELECT Id, Body, ApiVersion FROM ApexTrigger WHERE Name = :triggerName LIMIT 1];
            if(tgrs != null && tgrs.size() > 0){
                ApexTrigger tgr = tgrs[0];
                decimal apiVer = tgr.ApiVersion.setScale(1);
                String baseUrl = URL.getOrgDomainURL().toExternalForm() + '/services/data/v' + apiVer + '/';
                String token = 'Bearer ' + UserInfo.getSessionId();
                
                HttpResponse triggerInfoResp = sendRequest(baseUrl + 'tooling/sobjects/ApexTrigger/' + tgr.Id, 'GET', token, null);
                
                Map<String, Object> triggerInfo = (Map<String, Object>)JSON.deserializeUntyped(triggerInfoResp.getBody());
                
                String containerName = 'CleanSB-' + System.now();
                String containerJson = '{"Name":"' + containerName + '"}';
                HttpResponse containerResponse = sendRequest(baseUrl + 'tooling/sobjects/MetadataContainer/', 'POST', token, containerJson);
                System.debug(containerResponse.getBody());
                String containerId = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(containerResponse.getBody())).get('id'));
                
                
                Map<string,object> updateTriggerMap = new Map<string,object>{
                    'MetadataContainerId' => containerId,
                        'ContentEntityId' => tgr.Id,
                        'Body' => triggerInfo.get('Body'),
                        'Metadata' => new Map<string,object>{
                            'apiVersion' => apiVer,
                                'status' => triggerStatus
                                }
                };
                    
                HttpResponse updateTriggerResponse = sendRequest(baseUrl + 'tooling/sobjects/ApexTriggerMember/', 'POST', token, JSON.serialize(updateTriggerMap));
                System.debug(updateTriggerResponse.getBody());
                
                String asyncRequestJson = '{"MetadataContainerId" : "' + containerId + '", "isCheckOnly": "false"}';
                HttpResponse asyncRequestResponse = sendRequest(baseUrl + 'tooling/sobjects/ContainerAsyncRequest/', 'POST', token, asyncRequestJson);
                String asyncRequestId = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(asyncRequestResponse.getBody())).get('id'));
                
                HttpResponse asyncStatusResponse = sendRequest(baseUrl + 'tooling/sobjects/ContainerAsyncRequest/' + asyncRequestId, 'GET', token, null);
                System.debug('Deployment Response: ' + asyncStatusResponse.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }
    
    private static HttpResponse sendRequest(String endpoint, String method, String token, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        if (body != null) {
            req.setBody(body);
        }
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }
}