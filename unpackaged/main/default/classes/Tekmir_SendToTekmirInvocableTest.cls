@isTest
public with sharing class Tekmir_SendToTekmirInvocableTest {
    public static final Endpoints ENDPOINTS { get {
        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        
        if (isSandbox || Test.isRunningTest()) {
            return new Endpoints(
                'https://test.salesforce.com/services/oauth2/authorize',
                'https://test.salesforce.com/services/oauth2/token'
            );
        }
        
        return new Endpoints(
            'https://login.salesforce.com/services/oauth2/authorize',
            'https://login.salesforce.com/services/oauth2/token'
        );
    }}
    public class Endpoints {
        String oAuthEndpoint;
        String tokenEndpoint;
        
        public Endpoints(String oAuthEndpoint, String tokenEndpoint) {
            this.oAuthEndpoint = oAuthEndpoint;
            this.tokenEndpoint = tokenEndpoint;
        }
    }

    @isTest
    public static void test_OK() {
        BRIO_BypassApexTriggerWhileTesting.setDoNotRunTrigger();
        // Create test flow inputs
        litify_pm__Intake__c testIntake = Tekmir_TestDataFactory.createTestIntake();
        litify_pm__Intake__c createdIntake = [SELECT Id, FX_Id__c FROM litify_pm__Intake__c WHERE Id = :testIntake.Id LIMIT 1];
        litify_docs__File_Info__c testFile = Tekmir_TestDataFactory.createTestFileInfo();

        List<Tekmir_SendToTekmirInvocable.FlowInputs> request = new List<Tekmir_SendToTekmirInvocable.FlowInputs>();
        Tekmir_SendToTekmirInvocable.FlowInputs input = new Tekmir_SendToTekmirInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.fileIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = Tekmir_TestDataFactory.createTestDocrioSetting();
        Tekmir_API_Settings__c tekmirSetting = Tekmir_TestDataFactory.createTestTekmirAPISetting(true);
        string newMatterUrl = 'callout:' + tekmirSetting.Named_Credentials_Staging__c + '/newmatter';
        string newdocumentUrl = 'callout:' + tekmirSetting.Named_Credentials_Staging__c + '/newdocument';
        System.debug(newMatterUrl);
        System.debug(newdocumentUrl);
        string newMatRespStr = '{' +
                                    '"integratorMatterId": "' + createdIntake.FX_Id__c + '",' +
                                    '"matterId": "abcdef123",' +
                                    '"campaign": "Test"' +
                                    '}';
        string docrioSignedUrlRespStr = '{' +
                                        '"Records": [' +
                                            '{' +
                                                '"Id": "' + testFile.Id + '",' +
                                                '"SignedUrl": "https://test.pdf"' +
                                            '}' +
                                        ']' +
                                    '}';

        String uploadFileRespStr = '{' +
                                        '"relatedIntegratorMatterId": "' + testIntake.Id + '",' +
                                        '"integratorDocumentId": "' + testFile.Id + '",' +
                                        '"tekmirDocumentId": "string"' +
                                    '}';

        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', newMatRespStr, null);
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', uploadFileRespStr, null);

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(newMatterUrl, createMatterResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock(newdocumentUrl, uploadFileResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        Tekmir_SendToTekmirInvocable.submitToTekmir(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Referral_Partner_API_External_ID__c
                                                , Referral_Partner_API_Description__c
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id
                                                LIMIT 1];
        System.assertEquals(1, intakes.size());
        System.assertEquals('abcdef123', intakes[0].Referral_Partner_API_External_ID__c);
    }

    @isTest
    public static void test_NoFile_OK() {
        BRIO_BypassApexTriggerWhileTesting.setDoNotRunTrigger();
        // Create test flow inputs
        litify_pm__Intake__c testIntake = Tekmir_TestDataFactory.createTestIntake();
        litify_pm__Intake__c createdIntake = [SELECT Id, FX_Id__c FROM litify_pm__Intake__c WHERE Id = :testIntake.Id LIMIT 1];

        List<Tekmir_SendToTekmirInvocable.FlowInputs> request = new List<Tekmir_SendToTekmirInvocable.FlowInputs>();
        Tekmir_SendToTekmirInvocable.FlowInputs input = new Tekmir_SendToTekmirInvocable.FlowInputs();
        input.intakeId = testIntake.Id;

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = Tekmir_TestDataFactory.createTestDocrioSetting();
        Tekmir_API_Settings__c tekmirSetting = Tekmir_TestDataFactory.createTestTekmirAPISetting(true);
        string newMatterUrl = 'callout:' + tekmirSetting.Named_Credentials_Staging__c + '/newmatter';
        System.debug(newMatterUrl);
        string newMatRespStr = '{' +
                                    '"integratorMatterId": "' + createdIntake.FX_Id__c + '",' +
                                    '"matterId": "abcdef123",' +
                                    '"campaign": "Test"' +
                                    '}';

        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', newMatRespStr, null);

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(newMatterUrl, createMatterResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        Tekmir_SendToTekmirInvocable.submitToTekmir(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Referral_Partner_API_External_ID__c
                                                , Referral_Partner_API_Description__c
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id
                                                LIMIT 1];
        System.assertEquals(1, intakes.size());
        System.assertEquals('abcdef123', intakes[0].Referral_Partner_API_External_ID__c);
    }

    @isTest
    public static void test_FileUpload_Error() {
        BRIO_BypassApexTriggerWhileTesting.setDoNotRunTrigger();
        // Create test flow inputs
        litify_pm__Intake__c testIntake = Tekmir_TestDataFactory.createTestIntake();
        litify_pm__Intake__c createdIntake = [SELECT Id, FX_Id__c FROM litify_pm__Intake__c WHERE Id = :testIntake.Id LIMIT 1];
        litify_docs__File_Info__c testFile = Tekmir_TestDataFactory.createTestFileInfo();

        List<Tekmir_SendToTekmirInvocable.FlowInputs> request = new List<Tekmir_SendToTekmirInvocable.FlowInputs>();
        Tekmir_SendToTekmirInvocable.FlowInputs input = new Tekmir_SendToTekmirInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.fileIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = Tekmir_TestDataFactory.createTestDocrioSetting();
        Tekmir_API_Settings__c tekmirSetting = Tekmir_TestDataFactory.createTestTekmirAPISetting(true);
        string newMatterUrl = 'callout:' + tekmirSetting.Named_Credentials_Staging__c + '/newmatter';
        string newdocumentUrl = 'callout:' + tekmirSetting.Named_Credentials_Staging__c + '/newdocument';
        System.debug(newMatterUrl);
        System.debug(newdocumentUrl);
        string newMatRespStr = '{' +
                                    '"integratorMatterId": "' + createdIntake.FX_Id__c + '",' +
                                    '"matterId": "abcdef123",' +
                                    '"campaign": "Test"' +
                                    '}';
        string docrioSignedUrlRespStr = '{' +
                                        '"Records": [' +
                                            '{' +
                                                '"Id": "' + testFile.Id + '",' +
                                                '"SignedUrl": "https://test.pdf"' +
                                            '}' +
                                        ']' +
                                    '}';

        String uploadFileRespStr = '{' +
                                    '"detail": [' +
                                            '{' +
                                            '"loc": [' +
                                                '"string",' +
                                                '0' +
                                            '],' +
                                            '"msg": "string",' +
                                            '"type": "string"' +
                                            '}' +
                                        ']' +
                                    '}';

        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', newMatRespStr, null);
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(422, 'Validation Error', uploadFileRespStr, null);

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(newMatterUrl, createMatterResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock(newdocumentUrl, uploadFileResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        Tekmir_SendToTekmirInvocable.submitToTekmir(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id
                                                , Referral_Partner_API_External_ID__c
                                                , Referral_Partner_API_Description__c
                                                , Referral_Partner_API_Error__c
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id
                                                LIMIT 1];
        System.assertEquals(1, intakes.size());
        System.assertEquals('abcdef123', intakes[0].Referral_Partner_API_External_ID__c);
        System.assertNotEquals('', intakes[0].Referral_Partner_API_Error__c);
    }
}