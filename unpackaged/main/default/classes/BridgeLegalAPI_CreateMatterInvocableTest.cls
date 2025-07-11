@isTest
public with sharing class BridgeLegalAPI_CreateMatterInvocableTest {
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
        // Create test flow inputs
        litify_pm__Intake__c testIntake = createTestIntake();
        litify_docs__File_Info__c testFile = createTestFileInfo();

        List<BridgeLegalAPI_CreateMatterInvocable.FlowInputs> request = new List<BridgeLegalAPI_CreateMatterInvocable.FlowInputs>();
        BridgeLegalAPI_CreateMatterInvocable.FlowInputs input = new BridgeLegalAPI_CreateMatterInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.externalSharingLink = 'https://www.salesforce.com';
        input.selectedRetainerId = testFile.Id;
        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = createTestDocrioSetting();
        Bridge_Legal_API_Settings__c bridgifySetting = createTestBridgeLegalSettings();

        Map<string,string> testParamMap = new Map<string,string>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'phone' => '1111111111',
            'email' => 'doej@email.com',
            'address' => '111 Test Street',
            'city' => 'Test City',
            'state' => 'PA',
            'zipCode' => '11111',
            'matterType' => 'Camp Lejeune',
            'source' => 'Saddle Rock Legal Group',
            'ssnLast4' => '111111111'
        };
        
        string params = '';
        for(string key : testParamMap.keySet()){
            if(testParamMap.get(key) != null){
                params += key + '=' + EncodingUtil.urlEncode(testParamMap.get(key), 'UTF-8') + '&';
            }
        }
        string createMatterUrl = bridgifySetting.Base_URL__c + '/matter?' + params.substringBeforeLast('&');
        string uploadFileUrl = bridgifySetting.Base_URL__c + '/document/upload';
        System.debug(createMatterUrl);
        System.debug(uploadFileUrl);
        string createMatterRespStr = '{' +
                                        '"code": 0,' +
                                        '"message": "Succeeded",' +
                                        '"data": {' +
                                            '"id": 407330' +
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
        string fileContentRespStr = 'a'.repeat(100);
        string uploadFileRespStr = '{' +
                                        '"code":0,' +
                                        '"msg":"Succeeded",' +
                                        '"data":null,' +
                                        '"successResult":true,' +
                                        '"successDataResult":false' +
                                    '}';
        
        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', createMatterRespStr, null);
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', uploadFileRespStr, null);
        

        Map<String, HttpCalloutMock> bridgeLegalResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(bridgeLegalResp);
        multiCalloutMock.addRequestMock(createMatterUrl, createMatterResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        BridgeLegalAPI_CreateMatterInvocable.submitToBridgeLegal(request);
        Test.stopTest();
        List<litify_pm__Intake__c> validatedIntake = [SELECT Id FROM litify_pm__Intake__c WHERE Referral_Partner_API_External_ID__c = '407330'];
        System.assertEquals(1, validatedIntake.size());
    }

    @isTest
    public static void test_OK_NoRetainer() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = createTestIntake();
        litify_docs__File_Info__c testFile = createTestFileInfo();

        List<BridgeLegalAPI_CreateMatterInvocable.FlowInputs> request = new List<BridgeLegalAPI_CreateMatterInvocable.FlowInputs>();
        BridgeLegalAPI_CreateMatterInvocable.FlowInputs input = new BridgeLegalAPI_CreateMatterInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.externalSharingLink = 'https://www.salesforce.com';
        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = createTestDocrioSetting();
        Bridge_Legal_API_Settings__c bridgifySetting = createTestBridgeLegalSettings();

        Map<string,string> testParamMap = new Map<string,string>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'phone' => '1111111111',
            'email' => 'doej@email.com',
            'address' => '111 Test Street',
            'city' => 'Test City',
            'state' => 'PA',
            'zipCode' => '11111',
            'matterType' => 'Camp Lejeune',
            'source' => 'Saddle Rock Legal Group',
            'ssnLast4' => '111111111'
        };
        
        string params = '';
        for(string key : testParamMap.keySet()){
            if(testParamMap.get(key) != null){
                params += key + '=' + EncodingUtil.urlEncode(testParamMap.get(key), 'UTF-8') + '&';
            }
        }
        string createMatterUrl = bridgifySetting.Base_URL__c + '/matter?' + params.substringBeforeLast('&');

        string createMatterRespStr = '{' +
                                        '"code": 0,' +
                                        '"message": "Succeeded",' +
                                        '"data": {' +
                                            '"id": 407330' +
                                        '}' +
                                    '}';
        
        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', createMatterRespStr, null);

        Map<String, HttpCalloutMock> bridgeLegalResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(bridgeLegalResp);
        multiCalloutMock.addRequestMock(createMatterUrl, createMatterResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        BridgeLegalAPI_CreateMatterInvocable.submitToBridgeLegal(request);
        Test.stopTest();
        List<litify_pm__Intake__c> validatedIntake = [SELECT Id FROM litify_pm__Intake__c WHERE Referral_Partner_API_External_ID__c = '407330'];
        System.assertEquals(1, validatedIntake.size());
    }

    @isTest
    public static void test_Error_MissingPayload() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = createTestIntake();
        litify_docs__File_Info__c testFile = createTestFileInfo();

        List<BridgeLegalAPI_CreateMatterInvocable.FlowInputs> request = new List<BridgeLegalAPI_CreateMatterInvocable.FlowInputs>();
        BridgeLegalAPI_CreateMatterInvocable.FlowInputs input = new BridgeLegalAPI_CreateMatterInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.externalSharingLink = 'https://www.salesforce.com';
        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = createTestDocrioSetting();
        Bridge_Legal_API_Settings__c bridgifySetting = createTestBridgeLegalSettings();

        Map<string,string> testParamMap = new Map<string,string>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'phone' => '1111111111',
            'email' => 'doej@email.com',
            'address' => '111 Test Street',
            'city' => 'Test City',
            'state' => 'PA',
            'zipCode' => '11111',
            'matterType' => 'Camp Lejeune',
            'source' => 'Saddle Rock Legal Group',
            'ssnLast4' => '111111111'
        };
        
        string params = '';
        for(string key : testParamMap.keySet()){
            if(testParamMap.get(key) != null){
                params += key + '=' + EncodingUtil.urlEncode(testParamMap.get(key), 'UTF-8') + '&';
            }
        }
        string createMatterUrl = bridgifySetting.Base_URL__c + '/matter?' + params.substringBeforeLast('&');

        string createMatterRespStr = '{' + 
                                        '"code":500,' +
                                        '"message":"Internal Server Error",' +
                                        '"data":null' +
                                    '}';
        
        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(500, 'Internal Server Error', createMatterRespStr, null);

        Map<String, HttpCalloutMock> bridgeLegalResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(bridgeLegalResp);
        multiCalloutMock.addRequestMock(createMatterUrl, createMatterResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        BridgeLegalAPI_CreateMatterInvocable.submitToBridgeLegal(request);
        Test.stopTest();
        List<litify_pm__Intake__c> validatedIntake = [SELECT Id, Referral_Partner_API_Error__c FROM litify_pm__Intake__c WHERE Id = :testIntake.Id];
        System.assertEquals('500 - Internal Server Error\n\n{"code":500,"message":"Internal Server Error","data":null}', validatedIntake[0].Referral_Partner_API_Error__c);
    }

    // CREATE TEST DATA
    private static litify_pm__Intake__c createTestIntake(){
        Account newAcct = new Account();
        newAcct.litify_pm__First_Name__c = 'John';
        newAcct.litify_pm__Last_Name__c = 'Doe';
        newAcct.Phone = '1111111111';
        newAcct.litify_pm__Phone_Mobile__c = '1111111111';
        newAcct.litify_pm__Email__c = 'doej@email.com';
        newAcct.BillingStreet = '111 Test Street';
        newAcct.BillingCity = 'Test City';
        newAcct.BillingState = 'PA';
        newAcct.BillingPostalCode = '11111';
        newAcct.litify_pm__Social_Security_Number__c = '111111111';

        insert newAcct;
        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        insert newIntake;
        return newIntake;
    }
    private static litify_docs__File_Info__c createTestFileInfo(){
        litify_docs__File_Info__c fileInfo = new litify_docs__File_Info__c();
        fileInfo.Name = 'Test document';
        fileInfo.litify_docs__Description__c = 'This is a test';
        fileInfo.litify_docs__Author__c = 'Test User';
        fileInfo.litify_docs__Delete__c = false;
        fileInfo.litify_docs__Complete__c = true;
        insert fileInfo;
        return fileInfo;
    }
    private static docriosdk__Docrio_Tool_Setting__c createTestDocrioSetting(){
        docriosdk__Docrio_Tool_Setting__c setting = new docriosdk__Docrio_Tool_Setting__c();
        setting.docriosdk__Connected_App_Consumer_Key__c = 'TEST-DOCRIO-KEY';
        setting.docriosdk__Connected_App_Consumer_Secret__c = 'TEST-DOCRIO-SECRET';
        setting.docriosdk__API_Endpoint__c = 'https://api.123.genesisapi.com/v1';
        setting.docriosdk__Bucket_Name__c = 'https://456-us-east-2-documents.s3.us-east-2.amazonaws.com';
        insert setting;
        return setting;
    }
    private static Bridge_Legal_API_Settings__c createTestBridgeLegalSettings(){
        Bridge_Legal_API_Settings__c setting = new Bridge_Legal_API_Settings__c();
        setting.Debugging__c = true;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Base_URL__c = 'https://api.bridgify.com/venture/openapi/v1';
        setting.API_Key__c = '123';
        insert setting;
        return setting;
    }
}