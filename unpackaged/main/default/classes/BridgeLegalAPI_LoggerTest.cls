@isTest
public with sharing class BridgeLegalAPI_LoggerTest {
    private static Bridge_Legal_API_Settings__c createTestBridgeLegalSettings(){
        Bridge_Legal_API_Settings__c setting = new Bridge_Legal_API_Settings__c();
        setting.Debugging__c = true;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Base_URL__c = 'https://api.bridgify.com/venture/openapi/v1';
        setting.API_Key__c = '123';
        insert setting;
        return setting;
    }
    @IsTest static void testLog() {
        createTestBridgeLegalSettings();
        Test.startTest();
            // default settings
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // nothing to write
            BridgeLegalAPI_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new BridgeLegalAPI_Logger.Log(null, 'none1');
            BridgeLegalAPI_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new BridgeLegalAPI_Logger.Log(LoggingLevel.FINE, 'fine1');
            BridgeLegalAPI_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // REST log
            new BridgeLegalAPI_Logger.Log(LoggingLevel.DEBUG, 'debug1');
            BridgeLegalAPI_Logger.Log l = new BridgeLegalAPI_Logger.Log(LoggingLevel.ERROR, 'error1', 'sum1');
            l.setRequest(null);
            l.setResponse(null);
            l.start();
            l.stop();
            BridgeLegalAPI_Logger.writeLogs();
            System.assertEquals(2, [SELECT Count() FROM Integration_Log__c]);
            System.assertEquals(1, [SELECT Count() FROM Integration_Log__c WHERE Name = 'error1'
                AND Level__c = 'ERROR' AND Start__c != null AND Stop__c != null AND Duration__c != null]);

            new BridgeLegalAPI_Logger.Log(LoggingLevel.DEBUG, null).toString();
            new BridgeLegalAPI_Logger.Log(LoggingLevel.DEBUG, null).getElapsed();
        Test.stopTest();
    }
}