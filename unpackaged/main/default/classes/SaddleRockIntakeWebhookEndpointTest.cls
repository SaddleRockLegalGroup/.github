@isTest
public with sharing class SaddleRockIntakeWebhookEndpointTest {
    @isTest
    public static void test_intakeWebhook_OK() {
        RestRequest req = new RestRequest();
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        String s = '{' +
                        '"id": "' + intake.Id + '",' +
                        '"description": "Test API Custom",' +
                        '"client": {' +
                            '"clientFirstName": "Jane",' +
                            '"clientLastName": "Doe",' +
                            '"clientPhoneHome": "1111111111",' +
                            '"clientPhoneMobile": "222222222",' +
                            '"clientPhoneWork": "3333333333",' +
                            '"clientStreetAddr": "111 Test St",' +
                            '"clientCity": "Conshohocken",' +
                            '"clientState": "PA",' +
                            '"clientZip": "19428",' +
                            '"clientCounty": "NA",' +
                            '"clientCountry": "USA",' +
                            '"clientEmail": "doej@email.com",' +
                            '"clientDateOfBirth": "1990-07-31"' +
                        '},' +
                        '"campLejeune": {' +
                            '"campLejeuneFirstDateAtCL": "1953-08-01",' +
                            '"campLejeuneLastDateAtCL": "1987-12-13"' +
                        '}' +
                    '}';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Mock
        string oAuthRespStr = '{"access_token": "token123"}';
        string syncAsLoggedInRespStr = '{"status": "Received"}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', oAuthRespStr, null);
        SaddleRockCalloutMock syncAsLoggedInResp = new SaddleRockCalloutMock(200, 'OK', syncAsLoggedInRespStr, null);

        Map<String, HttpCalloutMock> mockResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(mockResp);
        multiCalloutMock.addRequestMock(URL.getOrgDomainUrl().toExternalForm() + '/services/oauth2/token', oAuthResp);
        multiCalloutMock.addRequestMock(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/SaddleRockSyncAsLoggedIn', syncAsLoggedInResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        SaddleRockIntakeWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(200, res.statusCode);
    }

    @isTest
    public static void test_intakeWebhook_NoPayload() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockIntakeWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_intakeWebhook_InvalidField() {
        RestRequest req = new RestRequest();
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        String s = '{' +
                        '"id": "' + intake.Id + '",' +
                        '"description": "Test API Custom",' +
                        '"client": {' +
                            '"clientFirstName": "Jane",' +
                            '"clientLastName": "Doe",' +
                            '"clientPhoneHome": "1111111111",' +
                            '"clientPhoneMobile": "222222222",' +
                            '"clientPhoneWork": "3333333333",' +
                            '"clientStreetAddr": "111 Test St",' +
                            '"clientCity": "Conshohocken",' +
                            '"clientState": "PA",' +
                            '"clientZip": "19428",' +
                            '"clientCounty": "NA",' +
                            '"clientCountry": "USA",' +
                            '"clientEmail": "doej@email.com",' +
                            '"clientDateOfBirth": "07/31/1990"' +
                        '},' +
                        '"campLejeune": {' +
                            '"campLejeuneFirstDateAtCL": "1953-08-01",' +
                            '"campLejeuneLastDateAtCL": "1987-12-13"' +
                        '}' +
                    '}';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Mock
        string oAuthRespStr = '{"access_token": "token123"}';
        string syncAsLoggedInRespStr = '{"status": "Received"}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', oAuthRespStr, null);
        SaddleRockCalloutMock syncAsLoggedInResp = new SaddleRockCalloutMock(400, '{"success": false, "data": "Invalid date clientDateOfBirth"}', syncAsLoggedInRespStr, null);

        Map<String, HttpCalloutMock> mockResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(mockResp);
        multiCalloutMock.addRequestMock(URL.getOrgDomainUrl().toExternalForm() + '/services/oauth2/token', oAuthResp);
        multiCalloutMock.addRequestMock(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/SaddleRockSyncAsLoggedIn', syncAsLoggedInResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        SaddleRockIntakeWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_intakeWebhook_500() {
        RestRequest req = new RestRequest();
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        String s = '{' +
                        '"id": "' + intake.Id + '",' +
                        '"description": null';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockIntakeWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(500, res.statusCode);
    }
}