@isTest
public with sharing class SaddleRockIntakeFileWebhookEndpointTest {
    @isTest
    public static void test_SaddleRockFileHandler() {
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        Test.startTest();
        SaddleRockFileHandler fileHandler = new SaddleRockFileHandler();
        docriosdk.Models.FilesPostResponse resp = fileHandler.saveFileToDocrio(intake.Id, 'Test', 'Test.pdf', 'Test', 'test', 'test');
        Test.stopTest();
        System.assertEquals(null, resp);
    }
    @isTest
    public static void test_SaddleRockFileHandler_ExistingFile() {
        litify_docs__File_Info__c testFileInfo = SaddleRockTestDataFactory.createTestFileInfo();
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        Test.startTest();
        SaddleRockFileHandler fileHandler = new SaddleRockFileHandler();
        docriosdk.Models.FilesPostResponse resp = fileHandler.saveFileToDocrio(intake.Id, testFileInfo.litify_docs__External_ID__c, testFileInfo.Name, 'Test', 'application/pdf', 'https://www.salesforce.com');
        Test.stopTest();
        System.assertEquals(null, resp);
    }

    @isTest
    public static void test_fileWebhook() {
        RestRequest req = new RestRequest();
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        String s = '{' +
                        '"id": "' + intake.Id + '",' +
                        '"documents": [' +
                            '{' +
                                '"externalId": "abc123-filesfdcid",' +
                                '"name": "Test.pdf",' +
                                '"description": "Test file uploaded from vendor",' +
                                '"documentType": "application/pdf",' +
                                '"signedUrl": "https://resources.docs.salesforce.com/latest/latest/en-us/sfdc/pdf/basics.pdf"' +
                            '}' +
                        ']' +
                    '}';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockIntakeFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_MissingId() {
        RestRequest req = new RestRequest();
        String s = '{' +
                        '"id": null,' +
                        '"documents": [' +
                            '{' +
                                '"externalId": "abc123-filesfdcid",' +
                                '"name": "Test.pdf",' +
                                '"description": "Test file uploaded from vendor",' +
                                '"documentType": "application/pdf",' +
                                '"signedUrl": "https://resources.docs.salesforce.com/latest/latest/en-us/sfdc/pdf/basics.pdf"' +
                            '}' +
                        ']' +
                    '}';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockIntakeFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_BadRequest() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockIntakeFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_500() {
        RestRequest req = new RestRequest();
        String s = '{' +
                        '"id": null,' +
                        '"document": null';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockIntakeFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(500, res.statusCode);
    }
}