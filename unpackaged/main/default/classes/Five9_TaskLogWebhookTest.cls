@isTest
public with sharing class Five9_TaskLogWebhookTest {
    @isTest
    public static void test_doPost() {
        RestRequest req = new RestRequest();
        req.addHeader('Origin', 'https://app.five9.com');

        req.addParameter('disposition_id', '221');
        req.addParameter('campaign_id', '173');
        req.addParameter('ANI', '8554841883');
        req.addParameter('hold_time', '0');
        req.addParameter('litify_pm__intake__c.Id', '');
        req.addParameter('session_id', '8F37A714310445CEB1A52C68FA847BD0');
        req.addParameter('length', '4747');
        req.addParameter('disposition_name', 'Test - System Dispo Logging');
        req.addParameter('end_timestamp', '20240409170230458');
        req.addParameter('DNIS', '2673371300');
        req.addParameter('number', '2673371300');
        req.addParameter('handle_time', '');
        req.addParameter('sfWebhookKey', 'test123');

        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        createTestAPISettings();

        Test.startTest();
        Five9_TaskLogWebhook.doPost();
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(1, tasks.size());
    }

    @isTest
    public static void test_doPost_InvalidId() {
        RestRequest req = new RestRequest();
        req.addHeader('Origin', 'https://app.five9.com');

        req.addParameter('disposition_id', '221');
        req.addParameter('campaign_id', '173');
        req.addParameter('ANI', '8554841883');
        req.addParameter('hold_time', '0');
        req.addParameter('litify_pm__intake__c.Id', '123456');
        req.addParameter('session_id', '8F37A714310445CEB1A52C68FA847BD0');
        req.addParameter('length', '4747');
        req.addParameter('disposition_name', 'Test - System Dispo Logging');
        req.addParameter('end_timestamp', '20240409170230458');
        req.addParameter('DNIS', '2673371300');
        req.addParameter('number', '2673371300');
        req.addParameter('handle_time', '');
        req.addParameter('sfWebhookKey', 'test123');

        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        createTestAPISettings();

        Test.startTest();
        Five9_TaskLogWebhook.doPost();
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(0, tasks.size());
    }

    @isTest
    public static void test_doPost_UNAUTHORIZED() {
        RestRequest req = new RestRequest();
        req.addParameter('disposition_id', '221');
        req.addParameter('campaign_id', '173');
        req.addParameter('ANI', '8554841883');
        req.addParameter('hold_time', '0');
        req.addParameter('litify_pm__intake__c.Id', '123456');
        req.addParameter('session_id', '8F37A714310445CEB1A52C68FA847BD0');
        req.addParameter('length', '4747');
        req.addParameter('disposition_name', 'Test - System Dispo Logging');
        req.addParameter('end_timestamp', '20240409170230458');
        req.addParameter('DNIS', '2673371300');
        req.addParameter('number', '2673371300');
        req.addParameter('handle_time', '');

        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        Five9_TaskLogWebhook.doPost();
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(0, tasks.size());
    }

    private static Five9_Webhook_Setting__c createTestAPISettings(){
        Five9_Webhook_Setting__c setting = new Five9_Webhook_Setting__c();
        setting.API_Key__c = 'test123';
        insert setting;
        return setting;
    }
}