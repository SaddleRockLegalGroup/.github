@isTest
public with sharing class SC_CreateNewCaseInvocableTest {
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
        litify_pm__Intake__c testIntake = SC_TestDataFactory.createTestIntake();
        litify_docs__File_Info__c testFile = SC_TestDataFactory.createTestFileInfo();
        litify_docs__File_Info__c testFile1 = SC_TestDataFactory.createTestFileInfo();

        List<SC_CreateNewCaseInvocable.FlowInputs> request = new List<SC_CreateNewCaseInvocable.FlowInputs>();
        SC_CreateNewCaseInvocable.FlowInputs input = new SC_CreateNewCaseInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.requiredFileId = testFile.Id;
        input.otherFileIds = new List<string>{testFile1.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = SC_TestDataFactory.createTestDocrioSetting();
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string createCaseUrl = simplyConvertSetting.Base_URL__c + '/cases';
        string uploadFileUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/documents';
        System.debug(createCaseUrl);
        System.debug(uploadFileUrl);
        string createCaseRespStr = '{' +
                                        '"message": "Created case 118114",' +
                                        '"data": {' +
                                            '"uuid": "' + caseId + '"' +
                                        '}' +
                                    '}';
        string docrioSignedUrlRespStr = '{' +
                                        '"Records": [' +
                                            '{' +
                                                '"Id": "' + testFile.Id + '",' +
                                                '"SignedUrl": "https://test.pdf"' +
                                            '}' +
                                        ']' +
                                    '}';
        string docrioSignedUrlResp1Str = '{' +
                                        '"Records": [' +
                                            '{' +
                                                '"Id": "' + testFile1.Id + '",' +
                                                '"SignedUrl": "https://test1.pdf"' +
                                            '}' +
                                        ']' +
                                    '}';
        string fileContentRespStr = 'a'.repeat(100);
        string uploadFileRespStr = '{' +
                                        '"message": "Document Uploaded"' +
                                    '}';
        
        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', createCaseRespStr, null);
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', uploadFileRespStr, null);
        SaddleRockCalloutMock docrioSignedUrl1Resp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlResp1Str, null);
        SaddleRockCalloutMock fileContent1Resp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(createCaseUrl, createMatterResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile1.Id, docrioSignedUrl1Resp);
        multiCalloutMock.addRequestMock('https://test1.pdf', fileContent1Resp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        SC_CreateNewCaseInvocable.createNewCase(request);
        Test.stopTest();
    }

    // @isTest
    // public static void test_OK_NoRetainer() {
    //     // Create test flow inputs
    //     litify_pm__Intake__c testIntake = createTestIntake();
    //     litify_docs__File_Info__c testFile = createTestFileInfo();

    //     List<SC_CreateNewCaseInvocable.FlowInputs> request = new List<SC_CreateNewCaseInvocable.FlowInputs>();
    //     SC_CreateNewCaseInvocable.FlowInputs input = new SC_CreateNewCaseInvocable.FlowInputs();
    //     input.intakeId = testIntake.Id;
    //     input.externalSharingLink = 'https://www.salesforce.com';
    //     request.add(input);

    //     // Set up mock
    //     docriosdk__Docrio_Tool_Setting__c docrioSetting = createTestDocrioSetting();
    //     Simply_Convert_API_Setting__c simplyConvertSetting = createTestSimplyConvertSetting();

    //     Map<string,string> testParamMap = new Map<string,string>{
    //         'firstName' => 'John',
    //         'lastName' => 'Doe',
    //         'externalId' => testIntake.Id,
    //         'phone' => '1111111111',
    //         'email' => 'doej@email.com',
    //         'address' => '111 Test Street',
    //         'city' => 'Test City',
    //         'state' => 'PA',
    //         'zipCode' => '11111',
    //         'matterType' => 'Camp Lejeune',
    //         'source' => 'Saddle Rock Legal Group',
    //         'ssnLast4' => '111111111'
    //     };
        
    //     string params = '';
    //     for(string key : testParamMap.keySet()){
    //         if(testParamMap.get(key) != null){
    //             params += key + '=' + EncodingUtil.urlEncode(testParamMap.get(key), 'UTF-8') + '&';
    //         }
    //     }
    //     string createCaseUrl = simplyConvertSetting.Base_URL__c + '/matter?' + params.substringBeforeLast('&');

    //     string createCaseRespStr = '{' +
    //                                     '"code": 0,' +
    //                                     '"message": "Succeeded",' +
    //                                     '"data": {' +
    //                                         '"id": 407330' +
    //                                     '}' +
    //                                 '}';
        
    //     SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', createCaseRespStr, null);

    //     Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
    //     SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
    //     multiCalloutMock.addRequestMock(createCaseUrl, createMatterResp);

    //     Test.setMock(HttpCalloutMock.class, multiCalloutMock);

    //     // Start test
    //     Test.startTest();
    //     SC_CreateNewCaseInvocable.submitToBridgeLegal(request);
    //     Test.stopTest();
    //     List<litify_pm__Intake__c> validatedIntake = [SELECT Id FROM litify_pm__Intake__c WHERE Referral_Partner_API_External_ID__c = '407330'];
    //     System.assertEquals(1, validatedIntake.size());
    // }

    // @isTest
    // public static void test_Error_MissingPayload() {
    //     // Create test flow inputs
    //     litify_pm__Intake__c testIntake = createTestIntake();
    //     litify_docs__File_Info__c testFile = createTestFileInfo();

    //     List<SC_CreateNewCaseInvocable.FlowInputs> request = new List<SC_CreateNewCaseInvocable.FlowInputs>();
    //     SC_CreateNewCaseInvocable.FlowInputs input = new SC_CreateNewCaseInvocable.FlowInputs();
    //     input.intakeId = testIntake.Id;
    //     input.externalSharingLink = 'https://www.salesforce.com';
    //     request.add(input);

    //     // Set up mock
    //     docriosdk__Docrio_Tool_Setting__c docrioSetting = createTestDocrioSetting();
    //     Simply_Convert_API_Setting__c simplyConvertSetting = createTestSimplyConvertSetting();

    //     Map<string,string> testParamMap = new Map<string,string>{
    //         'firstName' => 'John',
    //         'lastName' => 'Doe',
    //         'externalId' => testIntake.Id,
    //         'phone' => '1111111111',
    //         'email' => 'doej@email.com',
    //         'address' => '111 Test Street',
    //         'city' => 'Test City',
    //         'state' => 'PA',
    //         'zipCode' => '11111',
    //         'matterType' => 'Camp Lejeune',
    //         'source' => 'Saddle Rock Legal Group',
    //         'ssnLast4' => '111111111'
    //     };
        
    //     string params = '';
    //     for(string key : testParamMap.keySet()){
    //         if(testParamMap.get(key) != null){
    //             params += key + '=' + EncodingUtil.urlEncode(testParamMap.get(key), 'UTF-8') + '&';
    //         }
    //     }
    //     string createCaseUrl = simplyConvertSetting.Base_URL__c + '/matter?' + params.substringBeforeLast('&');

    //     string createCaseRespStr = '{' + 
    //                                     '"code":500,' +
    //                                     '"message":"Internal Server Error",' +
    //                                     '"data":null' +
    //                                 '}';
        
    //     SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(500, 'Internal Server Error', createCaseRespStr, null);

    //     Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
    //     SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
    //     multiCalloutMock.addRequestMock(createCaseUrl, createMatterResp);

    //     Test.setMock(HttpCalloutMock.class, multiCalloutMock);

    //     // Start test
    //     Test.startTest();
    //     SC_CreateNewCaseInvocable.submitToBridgeLegal(request);
    //     Test.stopTest();
    //     List<litify_pm__Intake__c> validatedIntake = [SELECT Id, Referral_Partner_API_Error__c FROM litify_pm__Intake__c WHERE Id = :testIntake.Id];
    //     System.assertEquals('500 - Internal Server Error\n\n{"code":500,"message":"Internal Server Error","data":null}', validatedIntake[0].Referral_Partner_API_Error__c);
    // }

    // CREATE TEST DATA
    
}