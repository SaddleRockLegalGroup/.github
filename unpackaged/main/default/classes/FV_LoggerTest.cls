@isTest
public with sharing class FV_LoggerTest {
    @IsTest static void testLog() {
        FV_TestDataFactory.createTestFilevineAPISetting();
        Test.startTest();
            // default settings
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // nothing to write
            FV_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new FV_Logger.Log(null, 'none1');
            FV_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new FV_Logger.Log(LoggingLevel.FINE, 'fine1');
            FV_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // REST log
            new FV_Logger.Log(LoggingLevel.DEBUG, 'debug1');
            FV_Logger.Log l = new FV_Logger.Log(LoggingLevel.ERROR, 'error1', 'sum1');
            l.setRequest(null);
            l.setResponse(null);
            l.start();
            l.stop();
            FV_Logger.writeLogs();
            System.assertEquals(2, [SELECT Count() FROM Integration_Log__c]);
            System.assertEquals(1, [SELECT Count() FROM Integration_Log__c WHERE Name = 'error1'
                AND Level__c = 'ERROR' AND Start__c != null AND Stop__c != null AND Duration__c != null]);

            new FV_Logger.Log(LoggingLevel.DEBUG, null).toString();
            new FV_Logger.Log(LoggingLevel.DEBUG, null).getElapsed();
        Test.stopTest();
    }
}