@isTest
public with sharing class Etech_InvocableSendToEtechTest {
    @isTest
    public static void test_OK() {
        BRIO_BypassApexTriggerWhileTesting.setDoNotRunTrigger();
        // Create test setting
        Etech_API_Setting__c setting = new Etech_API_Setting__c();
        setting.Test_mode__c = true;
        setting.Debugging__c = true;
        setting.API_URL_Staging__c = 'https://TekmirAPIStaging.com/api/v2';
        setting.API_URL_Prod__c = 'https://TekmirAPIProd.com/api/v2';
        setting.Token__c = 'abcdef1234';
        insert setting;

        // Create test client
        Account newAcct = new Account();
        newAcct.litify_pm__First_Name__c = 'John';
        newAcct.litify_pm__Last_Name__c = 'Doe';
        newAcct.Phone = '1111111111';
        newAcct.litify_pm__Phone_Mobile__c   = '1111111111';
        newAcct.litify_pm__Email__c = 'doej@email.com';
        newAcct.BillingStreet = '111 Test Street';
        newAcct.BillingCity = 'Test City';
        newAcct.BillingState = 'Pennsylvania';
        newAcct.BillingPostalCode = '11111';
        insert newAcct;

        // Create test case type
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c();
        caseType.Name = 'Test Case Type';
        insert caseType;

        // Create test campaign
        Campaign__c newCampaign = new Campaign__c();
        newCampaign.Name = 'Test Campaign';
        newCampaign.Case_Type__c = caseType.Id;
        insert newCampaign;

        // Create test intake
        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        newIntake.litify_pm__Case_Type__c = caseType.Id;
        newIntake.Campaign__c = newCampaign.Id;
        insert newIntake;

        List<Etech_InvocableSendToEtech.FlowInputs> request = new List<Etech_InvocableSendToEtech.FlowInputs>();
        Etech_InvocableSendToEtech.FlowInputs input = new Etech_InvocableSendToEtech.FlowInputs();
        input.intakeId = newIntake.Id;

        request.add(input);

        // Set up mock
        string respStr = '{' +
                            '"Message": "Record is created",' +
                            '"RecordId": "13055",' +
                            '"Errors": []' +
                        '}';

        SaddleRockCalloutMock etechResp = new SaddleRockCalloutMock(201, 'Created', respStr, null);

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(setting.API_URL_Staging__c, etechResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        Etech_InvocableSendToEtech.submitToEtech(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Telephony_API_External_ID__c
                                                , Telephony_API_Error__c
                                                , Telephony_API_Description__c
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :newIntake.Id
                                                LIMIT 1];
        System.assertEquals(1, intakes.size());
        System.assertEquals('13055', intakes[0].Telephony_API_External_ID__c);
        System.assertEquals(null, intakes[0].Telephony_API_Error__c);
        System.assertEquals('Etech', intakes[0].Telephony_API_Description__c);
    }
    @isTest
    public static void test_Error() {
        BRIO_BypassApexTriggerWhileTesting.setDoNotRunTrigger();
        // Create test setting
        Etech_API_Setting__c setting = new Etech_API_Setting__c();
        setting.Test_mode__c = true;
        setting.Debugging__c = true;
        setting.API_URL_Staging__c = 'https://TekmirAPIStaging.com/api/v2';
        setting.API_URL_Prod__c = 'https://TekmirAPIProd.com/api/v2';
        setting.Token__c = 'abcdef1234';
        insert setting;

        // Create test client
        Account newAcct = new Account();
        newAcct.litify_pm__First_Name__c = 'John';
        newAcct.litify_pm__Last_Name__c = 'Doe';
        newAcct.Phone = '1111111111';
        newAcct.litify_pm__Phone_Mobile__c   = '1111111111';
        newAcct.litify_pm__Email__c = 'doej@email.com';
        newAcct.BillingStreet = '111 Test Street';
        newAcct.BillingCity = 'Test City';
        newAcct.BillingState = 'Pennsylvania';
        newAcct.BillingPostalCode = '11111';
        insert newAcct;

        // Create test case type
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c();
        caseType.Name = 'Test Case Type';
        insert caseType;

        // Create test campaign
        Campaign__c newCampaign = new Campaign__c();
        newCampaign.Name = 'Test Campaign';
        newCampaign.Case_Type__c = caseType.Id;
        insert newCampaign;

        // Create test intake
        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        newIntake.litify_pm__Case_Type__c = caseType.Id;
        newIntake.Campaign__c = newCampaign.Id;
        insert newIntake;

        List<Etech_InvocableSendToEtech.FlowInputs> request = new List<Etech_InvocableSendToEtech.FlowInputs>();
        Etech_InvocableSendToEtech.FlowInputs input = new Etech_InvocableSendToEtech.FlowInputs();
        input.intakeId = newIntake.Id;

        request.add(input);

        // Set up mock
        string respStr = '{' +
                            '"Message": "Validation failed",' +
                            '"RecordId": null,' +
                            '"Errors": [' +
                                '"First Name is required.",' +
                                '"Last Name is required.",' +
                                '"Phone Number is required.",' +
                                '"Email is required.",' +
                                '"IntakeExternalId is required.",' +
                                '"Case Type is required.",' +
                                '"Campaign Name is required."' +
                            ']' +
                        '}';

        SaddleRockCalloutMock etechResp = new SaddleRockCalloutMock(400, 'Bad Request', respStr, null);

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(setting.API_URL_Staging__c, etechResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        Etech_InvocableSendToEtech.submitToEtech(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Telephony_API_External_ID__c
                                                , Telephony_API_Error__c
                                                , Telephony_API_Description__c
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :newIntake.Id
                                                LIMIT 1];
        System.assertEquals(1, intakes.size());
        System.assertEquals(null, intakes[0].Telephony_API_External_ID__c);
        System.assertNotEquals(null, intakes[0].Telephony_API_Error__c);
        System.assertEquals('Etech', intakes[0].Telephony_API_Description__c);
    }
}