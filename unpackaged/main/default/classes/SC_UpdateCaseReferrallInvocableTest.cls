@isTest
public with sharing class SC_UpdateCaseReferrallInvocableTest {
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

        List<SC_UpdateCaseReferrallInvocable.FlowInputs> request = new List<SC_UpdateCaseReferrallInvocable.FlowInputs>();
        SC_UpdateCaseReferrallInvocable.FlowInputs input = new SC_UpdateCaseReferrallInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.requiredFileId = testFile.Id;
        input.otherFileIds = new List<string>{testFile1.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = SC_TestDataFactory.createTestDocrioSetting();
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string UpdateCaseReferrallUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/referral';
        string uploadFileUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/documents';
        System.debug(UpdateCaseReferrallUrl);
        System.debug(uploadFileUrl);
        string UpdateCaseReferrallRespStr = '{' +
                                        '"message": "Created case 118114",' +
                                        '"success": true,' +
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
        
        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', UpdateCaseReferrallRespStr, null);
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', uploadFileRespStr, null);
        SaddleRockCalloutMock docrioSignedUrl1Resp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlResp1Str, null);
        SaddleRockCalloutMock fileContent1Resp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(200, 'OK', '{"invalid_json":}', null);
        SaddleRockCalloutMock mockResponseFail = new SaddleRockCalloutMock(404, 'OK', '{"invalid_json":}', null);

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(UpdateCaseReferrallUrl, createMatterResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile1.Id, docrioSignedUrl1Resp);
        multiCalloutMock.addRequestMock('https://test1.pdf', fileContent1Resp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);
        multiCalloutMock.addRequestMock(UpdateCaseReferrallUrl, mockResponse);
        multiCalloutMock.addRequestMock(UpdateCaseReferrallUrl, mockResponseFail);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        SC_UpdateCaseReferrallInvocable.UpdateCaseReferrall(request);
        Test.stopTest();
    }
    /*
    @isTest
    static void testUpdateCase_CatchBlock() {
        // Create a mock CaseResource object
        SC_APIModels.CaseResource caseRequest = new SC_APIModels.CaseResource();
        caseRequest.api_casesafe_id = 'test_api_casesafe_id';
        
        // Create a mock callout response
        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(200, 'OK', '{"invalid_json":}', null);

        // Set the mock callout response
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string UpdateCaseReferrallUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/referral';
        multiCalloutMock.addRequestMock(UpdateCaseReferrallUrl, mockResponse);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Call the method under test
        SC_UpdateCaseReferrallInvocable.updateCaseReferrall(caseRequest);
        
        // Assert the result
        System.assertEquals(false, result.get('success'), 'Success should be false');
        // Add assertions for other fields in the result map if needed
        
        // Verify that the catch block was executed and the exception was caught
        String errorMessage = (String) result.get('data');
        System.assert(errorMessage.contains('Invalid JSON'), 'Expected error message not found');
    }
    */
    // CREATE TEST DATA
    
}