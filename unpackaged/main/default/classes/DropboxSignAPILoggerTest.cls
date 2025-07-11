@isTest
public with sharing class DropboxSignAPILoggerTest {
    private static Dropbox_Sign_API_Settings__c createTestDropboxSignAPISettings(){
        Dropbox_Sign_API_Settings__c setting = new Dropbox_Sign_API_Settings__c();
        setting.Debugging__c = true;
        setting.Log_Days_to_Keep__c = 90;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Base_URL__c = 'https://api.hellosign.com/v3';
        setting.API_Key__c = '123';
        insert setting;
        return setting;
    }
    @IsTest static void testLog() {
        createTestDropboxSignAPISettings();
        Test.startTest();
            // default settings
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // nothing to write
            DropboxSignAPILogger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new DropboxSignAPILogger.Log(null, 'none1');
            DropboxSignAPILogger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new DropboxSignAPILogger.Log(LoggingLevel.FINE, 'fine1');
            DropboxSignAPILogger.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // REST log
            new DropboxSignAPILogger.Log(LoggingLevel.DEBUG, 'debug1');
            DropboxSignAPILogger.Log l = new DropboxSignAPILogger.Log(LoggingLevel.ERROR, 'error1', 'sum1');
            l.setRequest(null);
            l.setResponse(null);
            l.start();
            l.stop();
            DropboxSignAPILogger.writeLogs();
            System.assertEquals(2, [SELECT Count() FROM Integration_Log__c]);
            System.assertEquals(1, [SELECT Count() FROM Integration_Log__c WHERE Name = 'error1'
                AND Level__c = 'ERROR' AND Start__c != null AND Stop__c != null AND Duration__c != null]);

            new DropboxSignAPILogger.Log(LoggingLevel.DEBUG, null).toString();
            new DropboxSignAPILogger.Log(LoggingLevel.DEBUG, null).getElapsed();
        Test.stopTest();
    }
}