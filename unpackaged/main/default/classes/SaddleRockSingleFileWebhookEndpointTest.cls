@isTest
public with sharing class SaddleRockSingleFileWebhookEndpointTest {
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
    public static void test_fileWebhook_OK() {
        RestRequest req = new RestRequest();
        
        System.debug('### Creating test Docrio Setting ###');
        SaddleRockTestDataFactory.createTestDocrioSetting();
        docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();
        System.debug('### Creating test intake ###');
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        System.debug('### Creating test files ###');
        litify_docs__File_Info__c testFile = new litify_docs__File_Info__c();
        testFile.Name = 'Test.pdf';
        testFile.litify_docs__Related_To__c = intake.Id;
        insert testFile;

        req.addParameter('id', intake.Id);
        req.addParameter('fileName', 'Test.pdf');
        req.addParameter('externalId', 'abc123-filesfdcid');
        req.requestBody = Blob.valueOf('a'.repeat(5242880));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        string fileInfoRespStr = '{' +
                                    '"' + testFile.Name + '": {' +
                                        '"SignedUrl": "https://6a7e6e6a-9fcd-4207-8962-839b9d81b49b-us-east-2-documents.s3.us-east-2.amazonaws.com/",' +
                                        '"Expires": "2023-07-31T21:18:46.765Z",' +
                                        '"Id": "' + testFile.Id + '"' +
                                    '}' +
                                '}';
        string fileCompleteRespStr = '{' +
                                    '"Message": "Files successfully uploaded.",' +
                                    '"Successes": [' +
                                        '{' +
                                            '"litify_docs__Version_Id__c": "3TkP_tMHXsVYL59w6.E7TMtX6gzkDRIj",' +
                                            '"litify_docs__Source__c": "Docrio Api",' +
                                            '"litify_docs__File_Size__c": 25667,' +
                                            '"litify_docs__Delete__c": false,' +
                                            '"litify_docs__Updated_By_Name__c": "Brio Services",' +
                                            '"litify_docs__Updated_On__c": "2023-07-31T22:56:16.194Z",' +
                                            '"litify_docs__Updated_By__c": "005Dn0000066Va8IAE",' +
                                            '"litify_docs__Folder_Path_Last_255__c": "[]",' +
                                            '"litify_docs__Folder_Path_First_255__c": "[]",' +
                                            '"litify_docs__Latest_Version__c": 0,' +
                                            '"litify_docs__Related_To__c": "' + intake.Id + '",' +
                                            '"litify_docs__Related_To_Api_Name__c": "litify_pm__Intake__c",' +
                                            '"litify_docs__OCR_Compatible__c": true,' +
                                            '"litify_docs__Latest_Version_Formula__c": 0,' +
                                            '"litify_docs__Folder_Path__c": "[]",' +
                                            '"litify_docs__File_Type__c": "application/pdf",' +
                                            '"litify_docs__File_Link__c": "/lightning/r/litify_docs__File_Info__c/' + testFile.Id + '/view",' +
                                            '"litify_docs__Description__c": "Uploaded by vendor: abc123",' +
                                            '"litify_docs__Complete__c": true,' +
                                            '"SystemModstamp": "2023-07-31T22:55:52.000Z",' +
                                            '"LastModifiedById": "005Dn0000066Va8IAE",' +
                                            '"LastModifiedDate": "2023-07-31T22:55:52.000Z",' +
                                            '"CreatedById": "005Dn0000066Va8IAE",' +
                                            '"CreatedDate": "2023-07-31T22:55:52.000Z",' +
                                            '"Name": "' + testFile.Name + '",' +
                                            '"IsDeleted": false,' +
                                            '"OwnerId": "005Dn0000066Va8IAE",' +
                                            '"Id": "' + testFile.Id + '"' +
                                        '}' +
                                    '],' +
                                    '"Failures": []' +
                                '}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock fileInfoResp = new SaddleRockCalloutMock(200, 'OK', fileInfoRespStr, null);
        SaddleRockCalloutMock fileUploadResp = new SaddleRockCalloutMock(200, 'OK', '', null);
        SaddleRockCalloutMock fileCompleteResp = new SaddleRockCalloutMock(200, 'OK', fileCompleteRespStr, null);

        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint,oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files', fileInfoResp);
        multiCalloutMock.addRequestMock('https://6a7e6e6a-9fcd-4207-8962-839b9d81b49b-us-east-2-documents.s3.us-east-2.amazonaws.com/', fileUploadResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files/complete', fileCompleteResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);


        Test.startTest();

        SaddleRockSingleFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(200, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_InvalidBucketUrl() {
        RestRequest req = new RestRequest();
        
        System.debug('### Creating test Docrio Setting ###');
        SaddleRockTestDataFactory.createTestDocrioSetting();
        docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();
        System.debug('### Creating test intake ###');
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        System.debug('### Creating test files ###');
        litify_docs__File_Info__c testFile = new litify_docs__File_Info__c();
        testFile.Name = 'Test.pdf';
        testFile.litify_docs__Related_To__c = intake.Id;
        insert testFile;

        req.addParameter('id', intake.Id);
        req.addParameter('fileName', 'Test.pdf');
        req.addParameter('externalId', 'abc123-filesfdcid');
        req.requestBody = Blob.valueOf('a'.repeat(5242880));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        string fileInfoRespStr = '{' +
                                    '"' + testFile.Name + '": {' +
                                        '"SignedUrl": "https://6a7e6e6a-9fcd-4207-8962-839b9d81b49b-us-east-2-documents.s3.us-east-2.amazonaws.com/",' +
                                        '"Expires": "2023-07-31T21:18:46.765Z",' +
                                        '"Id": "' + testFile.Id + '"' +
                                    '}' +
                                '}';
        string fileCompleteRespStr = '{}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock fileInfoResp = new SaddleRockCalloutMock(200, 'OK', fileInfoRespStr, null);
        SaddleRockCalloutMock fileUploadResp = new SaddleRockCalloutMock(200, 'OK', '', null);
        SaddleRockCalloutMock fileCompleteResp = new SaddleRockCalloutMock(400, 'Bad Request', fileCompleteRespStr, null);

        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint,oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files', fileInfoResp);
        multiCalloutMock.addRequestMock('https://6a7e6e6a-9fcd-4207-8962-839b9d81b49b-us-east-2-documents.s3.us-east-2.amazonaws.com/', fileUploadResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files/complete', fileCompleteResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);


        Test.startTest();

        SaddleRockSingleFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_NoPayload() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockSingleFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_MissingParams() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('a'.repeat(5242880));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockSingleFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    public static void test_fileWebhook_MissingFileName() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('a'.repeat(5242880));
        RestContext.request = req;
        System.debug('### Creating test intake ###');
        litify_pm__Intake__c intake = SaddleRockTestDataFactory.createTestIntake('John', 'Doe');
        req.addParameter('id', intake.Id);
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        SaddleRockSingleFileWebhookEndpoint.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }
}