@isTest
public with sharing class SaddleRockSyncAsLoggedInTest {
    @isTest
    public static void test_syncAsLoggedIn_OK() {
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
                        '}' +
                    '}';

        Map<string,string> payLoad = new Map<String,string>();
        payLoad.put('data', s);
        payLoad.put('vendorIntegrationId', '123');

        req.requestBody = Blob.valueOf(JSON.serialize(payLoad));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockSyncAsLoggedIn.doPost();

        Test.stopTest();
        System.debug(res.responseBody.toString());
        System.assertEquals(200, res.statusCode);
    }

    @isTest
    public static void test_syncAsLoggedIn_InvalidField() {
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

        Map<string,string> payLoad = new Map<String,string>();
        payLoad.put('data', s);
        payLoad.put('vendorIntegrationId', '123');

        req.requestBody = Blob.valueOf(JSON.serialize(payLoad));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockSyncAsLoggedIn.doPost();

        Test.stopTest();
        System.debug(res.responseBody.toString());
        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_syncAsLoggedIn_InvalidJSON() {
        RestRequest req = new RestRequest();
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        String s = '{' +
                        '"id": "' + intake.Id + '",' +
                        '"description": "Test API Custom",' +
                        '"client": [{' +
                            '"clientFirstName": "Jane",' +
                            '"clientLastName": "Doe",' +
                            '"clientPhoneHome": "1111111111",' +
                            '"clientCountry": "USA",' +
                            '"clientEmail": "doej@email.com",' +
                            '"clientDateOfBirth": "07/31/1990"' +
                        '},' +
                    '}';

        Map<string,string> payLoad = new Map<String,string>();
        payLoad.put('data', s);
        payLoad.put('vendorIntegrationId', '123');

        req.requestBody = Blob.valueOf(JSON.serialize(payLoad));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockSyncAsLoggedIn.doPost();

        Test.stopTest();
        System.debug(res.responseBody.toString());
        System.assertEquals(500, res.statusCode);
    }
}