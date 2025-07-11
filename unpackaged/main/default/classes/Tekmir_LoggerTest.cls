@isTest
public with sharing class Tekmir_LoggerTest {
    @IsTest static void testLog() {
        Tekmir_TestDataFactory.createTestTekmirAPISetting(true);
        Test.startTest();
            // default settings
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // nothing to write
            Tekmir_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new Tekmir_Logger.Log(null, 'none1');
            Tekmir_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new Tekmir_Logger.Log(LoggingLevel.FINE, 'fine1');
            Tekmir_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // REST log
            new Tekmir_Logger.Log(LoggingLevel.DEBUG, 'debug1');
            Tekmir_Logger.Log l = new Tekmir_Logger.Log(LoggingLevel.ERROR, 'error1', 'sum1');
            l.setRequest(null);
            l.setResponse(null);
            l.start();
            l.stop();
            Tekmir_Logger.writeLogs();
            System.assertEquals(2, [SELECT Count() FROM Integration_Log__c]);
            System.assertEquals(1, [SELECT Count() FROM Integration_Log__c WHERE Name = 'error1'
                AND Level__c = 'ERROR' AND Start__c != null AND Stop__c != null AND Duration__c != null]);

            new Tekmir_Logger.Log(LoggingLevel.DEBUG, null).toString();
            new Tekmir_Logger.Log(LoggingLevel.DEBUG, null).getElapsed();
        Test.stopTest();
    }
}