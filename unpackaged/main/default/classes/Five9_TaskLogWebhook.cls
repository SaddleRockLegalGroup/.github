@RestResource(urlMapping='/TaskLogWebhook/*')
global without sharing class Five9_TaskLogWebhook {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{
            Map<string,string> requestParams = req.params;
            Map<string,string> headers = req.headers;
            System.debug(JSON.serialize(headers));
            System.debug(JSON.serialize(requestParams));

            Five9_Webhook_Setting__c setting = Five9_Webhook_Setting__c.getOrgDefaults();

            if(requestParams.get('sfWebhookKey') == setting.API_Key__c){
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"success": true}');
    
                Task t = new Task();
                string tz = UserInfo.getTimeZone().getDisplayName().substringBefore(' ');
                Datetime curDatetime = Datetime.now();
                t.Subject = 'Call ' + curDatetime.format('MM/dd/yyyy hh:mm') + ' ' + tz + ' - ' + requestParams.get('disposition_name');
                t.Five9Campaign__c = requestParams.get('campaign_name');
                t.Five9ANI__c = requestParams.get('ANI');
                t.Five9DNIS__c = requestParams.get('DNIS');
                t.Five9HandleTime__c = requestParams.get('handle_time');
                t.Five9__Five9TaskType__c = 'Call';
                t.Five9__Five9SessionId__c = requestParams.get('session_id');
                t.WhatId = String.isBlank(requestParams.get('litify_pm__intake__c.Id')) || String.isEmpty(requestParams.get('litify_pm__intake__c.Id')) ? null : requestParams.get('litify_pm__intake__c.Id');
                t.Description = 'Number: ' + requestParams.get('number');
                t.TaskSubtype = 'Call';
                t.Status = 'Completed';
                t.Five9Agent__c = requestParams.get('full_name');
                t.CallDisposition = requestParams.get('disposition_name');
                t.ActivityDate = Date.today();
                insert t;
            }
            else {
                res.statusCode = 401;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf('{"error": "UNAUTHORIZED", "success": false}');
            }

            return;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '", "success": false}');

            logFive9('ERROR', 'Five9 TaskLogWebhook.doPost Exception', 'Log :' + '\n' + JSON.serialize(req.params) + '\n\n' + e.getMessage() + '\n\n' +  e.getStackTraceString());
            return;
        }
    }

    private static void logFive9(string level, string name, string details){
        Integration_Log__c log = new Integration_Log__c();
        log.Name = name;
        log.Level__c = level;
        log.Log__c = details;
        insert log;
    }
}