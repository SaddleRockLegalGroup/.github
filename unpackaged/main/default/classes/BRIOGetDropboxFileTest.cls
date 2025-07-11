@isTest
private class BRIOGetDropboxFileTest {

    private class DropboxCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HttpRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/pdf');
            res.setBody('Mock PDF Content'); // You can replace this with your mock PDF content
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDBFile() {
        // Set up test data
        Test.startTest();
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new DropboxCalloutMock());

        // Create a test signEventId, filesUrl, and title
        Account acc = new Account();
        acc.litify_pm__first_name__c = 'test';
        acc.litify_pm__last_name__c = 'test';
        insert acc;
        litify_pm__intake__c intake = new litify_pm__intake__c();
        intake.litify_pm__client__c = acc.id;
        insert intake;
        Dropbox_Sign_Event__c signEvent = new Dropbox_Sign_Event__c(
            Final_Copy_URI__c = '/v3/signature_request/final_copy/test_signature_request_id',
            Event_Type__c = 'signature_request_all_signed',
            Get_File__c = true,
            Intake__c = intake.Id,
            Title__c = 'Test Agreement'
        );
        insert signEvent;
        String signEventId = signEvent.id;
        String filesUrl = signEvent.Final_Copy_URI__c;
        String title = signEvent.Title__c;

        // Call the method to be tested
        BRIOGetDropboxFile.getDBFile(filesUrl, title, signEventId);

        Test.stopTest();

        // Add assertions based on your requirements
        // Example: Verify that a ContentVersion record was inserted
        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title = :title LIMIT 1];
        System.assertEquals(1, cvList.size(), 'ContentVersion record should be inserted');
    }
}