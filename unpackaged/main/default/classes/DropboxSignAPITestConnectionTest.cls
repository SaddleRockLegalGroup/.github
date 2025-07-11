@isTest
public with sharing class DropboxSignAPITestConnectionTest {
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

    private static litify_pm__Role__c createTestIntakeRole(){
        Account acct = new Account();
        acct.litify_pm__First_Name__c = 'John';
        acct.litify_pm__Last_Name__c = 'Doe';
        acct.litify_pm__Email__c = 'doe@email.com';
        insert acct;
        
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acct.Id;
        insert intake;

        litify_pm__Role__c role = new litify_pm__Role__c();
        role.litify_pm__Party__c = acct.Id;
        role.litify_pm__Intake__c = intake.Id;
        insert role;
        return role;
    }
    private static litify_docs__File_Info__c createTestFileInfo(){
        litify_docs__File_Info__c fileInfo = new litify_docs__File_Info__c();
        fileInfo.Name = 'Test document';
        fileInfo.litify_docs__Description__c = 'This is a test';
        fileInfo.litify_docs__Author__c = 'Test User';
        insert fileInfo;
        return fileInfo;
    }

    
    public static docriosdk__Docrio_Tool_Setting__c createTestDocrioSetting(){
        docriosdk__Docrio_Tool_Setting__c setting = new docriosdk__Docrio_Tool_Setting__c();
        setting.docriosdk__Connected_App_Consumer_Key__c = 'TEST-DOCRIO-KEY';
        setting.docriosdk__Connected_App_Consumer_Secret__c = 'TEST-DOCRIO-SECRET';
        setting.docriosdk__API_Endpoint__c = 'https://api.123.genesisapi.com/v1';
        setting.docriosdk__Bucket_Name__c = 'https://456-us-east-2-documents.s3.us-east-2.amazonaws.com';
        insert setting;
        return setting;
    }

    @isTest
    public static void test_TestConnection_OK() {
        // Set up mock
        createTestDocrioSetting();
        string s = '{' +
                        '"list_info": {' +
                            '"page": 1,' +
                            '"num_pages": 0,' +
                            '"num_results": 0,' +
                            '"page_size": 20' +
                        '},' +
                        '"templates": []' +
                    '}';
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock dbTemplateRespStr = new SaddleRockCalloutMock(200, 'OK', s, null);

        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock('https://api.hellosign.com/v3/template/list?test_mode=true', dbTemplateRespStr);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        List<DropboxSignAPITestConnection.FlowOutputs> result = DropboxSignAPITestConnection.testDropboxConnection();
        Test.stopTest();

        System.assertEquals(true, result[0].success);

    }

    @isTest
    public static void test_TestConnection_Failed() {
        // Set up mock
        createTestDocrioSetting();
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        
        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        List<DropboxSignAPITestConnection.FlowOutputs> result = DropboxSignAPITestConnection.testDropboxConnection();
        Test.stopTest();

        System.assertEquals(false, result[0].success);

    }
}