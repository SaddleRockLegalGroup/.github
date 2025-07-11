@isTest
public with sharing class SC_LoggerTest {
    @IsTest static void testLog() {
        SC_TestDataFactory.createTestSimplyConvertSetting();
        Test.startTest();
            // default settings
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // nothing to write
            SC_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new SC_Logger.Log(null, 'none1');
            SC_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new SC_Logger.Log(LoggingLevel.FINE, 'fine1');
            SC_Logger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // REST log
            new SC_Logger.Log(LoggingLevel.DEBUG, 'debug1');
            SC_Logger.Log l = new SC_Logger.Log(LoggingLevel.ERROR, 'error1', 'sum1');
            l.setRequest(null);
            l.setResponse(null);
            l.start();
            l.stop();
            SC_Logger.writeLogs();
            System.assertEquals(2, [SELECT Count() FROM Integration_Log__c]);
            System.assertEquals(1, [SELECT Count() FROM Integration_Log__c WHERE Name = 'error1'
                AND Level__c = 'ERROR' AND Start__c != null AND Stop__c != null AND Duration__c != null]);

            new SC_Logger.Log(LoggingLevel.DEBUG, null).toString();
            new SC_Logger.Log(LoggingLevel.DEBUG, null).getElapsed();
        Test.stopTest();
    }
}