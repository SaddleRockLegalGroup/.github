@isTest
public with sharing class SC_UpdateCaseInvocableTest {
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

        List<SC_UpdateCaseInvocable.FlowInputs> request = new List<SC_UpdateCaseInvocable.FlowInputs>();
        SC_UpdateCaseInvocable.FlowInputs input = new SC_UpdateCaseInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.requiredFileId = testFile.Id;
        input.otherFileIds = new List<string>{testFile1.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = SC_TestDataFactory.createTestDocrioSetting();
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string UpdateCaseUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId;
        string uploadFileUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/documents';
        System.debug(UpdateCaseUrl);
        System.debug(uploadFileUrl);
        string UpdateCaseRespStr = '{' +
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
        
        SaddleRockCalloutMock createMatterResp = new SaddleRockCalloutMock(200, 'OK', UpdateCaseRespStr, null);
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
        multiCalloutMock.addRequestMock(UpdateCaseUrl, createMatterResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile1.Id, docrioSignedUrl1Resp);
        multiCalloutMock.addRequestMock('https://test1.pdf', fileContent1Resp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);
        multiCalloutMock.addRequestMock(UpdateCaseUrl, mockResponse);
        multiCalloutMock.addRequestMock(UpdateCaseUrl, mockResponseFail);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        SC_UpdateCaseInvocable.UpdateCase(request);
        Test.stopTest();
    }

    // CREATE TEST DATA
    
}