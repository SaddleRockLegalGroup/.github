@isTest
public with sharing class SC_BatchUploadFileTest {
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
    public static void test_ExecBatch() {
        litify_pm__Intake__c testIntake = SC_TestDataFactory.createTestIntake();
        litify_docs__File_Info__c testFile = SC_TestDataFactory.createTestFileInfo();

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = SC_TestDataFactory.createTestDocrioSetting();
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string uploadFileUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/documents';
        System.debug(uploadFileUrl);

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
                                        '"message": "Document Uploaded"' +
                                    '}';
        
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', uploadFileRespStr, null);
        SaddleRockCalloutMock fileContent1Resp = new SaddleRockCalloutMock(200, 'OK', fileContentRespStr, null);
        

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);

        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(uploadFileUrl, uploadFileResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);



        Test.startTest();
        SC_BatchUploadFile batchJob = new SC_BatchUploadFile('Test Client', caseId, testFile.Id, 'retainer');
        Database.executeBatch(batchJob);
        Test.stopTest();
    }
}