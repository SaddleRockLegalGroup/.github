@isTest
private class TriggerAttatchFiletoSignEventTest {

    @isTest
    static void testTriggerAttatchFiletoSignEvent() {
        Test.enableChangeDataCapture();
        // Create and insert a record that will trigger the trigger
        Dropbox_Sign_API_Settings__c API_SETTING = new Dropbox_Sign_API_Settings__c();
        API_SETTING.api_key__c = '123';
        API_SETTING.Base_URL__c = 'https://api.hellosign.com/v3'; 
        insert API_SETTING;
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(API_SETTING.API_Key__c + ':'));
        Account acc = new Account();
        acc.litify_pm__first_name__c = 'test';
        acc.litify_pm__last_name__c = 'test';
        acc.litify_pm__Phone_Mobile__c = '1111111111';
        insert acc;
        litify_pm__intake__c intake = new litify_pm__intake__c();
        intake.litify_pm__client__c = acc.id;
        insert intake;
        Dropbox_Sign_Event__c signEvent = new Dropbox_Sign_Event__c(
            Files_Url__c = 'https://api.hellosign.com/v3/signature_request/files/test_signature_request_id',
            Event_Type__c = 'signature_request_all_signed',
            Get_File__c = true,
            Intake__c = intake.Id,
            Title__c = 'Test Agreement'
        );
        insert signEvent;
        Test.getEventBus().deliver();

        /*System.assertNotEquals(0, debugLogs.size(), 'Debug log not generated');

        // Check the debug logs for relevant information
        String debugLog = [SELECT Body FROM DebugLog WHERE Id = :debugLogs[0].Id].Body;
        System.assert(debugLog.contains('Your expected debug statement'),
                      'Expected debug statement not found in debug logs');

        // Additional assertions based on your specific logic*/
    }
}