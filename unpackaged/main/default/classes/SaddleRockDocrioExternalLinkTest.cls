@isTest
public with sharing class SaddleRockDocrioExternalLinkTest {
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
    public static void test_createSharingLink_OK() {
        System.debug('### Creating test Docrio Setting ###');
        SaddleRockTestDataFactory.createTestDocrioSetting();

        docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();

        System.debug('### Creating test account ###');
        Account testAcct = new Account();
        testAcct.litify_pm__First_Name__c = 'John';
        testAcct.litify_pm__Last_Name__c = 'Doe';
        testAcct.Name = 'John Doe';
        insert testAcct;

        System.debug('### Creating test intake ###');
        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Client__c = testAcct.Id;
        insert testIntake;

        System.debug('### Creating test files ###');
        litify_docs__File_Info__c testFile = new litify_docs__File_Info__c();
        testFile.Name = 'Test.docx';
        testFile.litify_docs__Related_To__c = testIntake.Id;
        insert testFile;
        litify_docs__File_Info__c testFile1 = new litify_docs__File_Info__c();
        testFile1.Name = 'Test1.docx';
        testFile1.litify_docs__Related_To__c = testIntake.Id;
        insert testFile1;

        //Set up mock
        System.debug('### Creating mock requests ###');
        
        string externalLinkRespStr = '{' +
                                        '"CreatedByName": "Test User",' +
                                        '"OrganizationName": "Test Inc.",' +
                                        '"Records": [' +
                                            '{' +
                                                '"litify_docs__Unique_Id__c": "-LXd2we2BasKYB8lGwKWILlrRL-TCWnWNSpEChhvczM",' +
                                                '"litify_docs__Password__c": false,' +
                                                '"litify_docs__Expiration_Date__c": "2023-03-02",' +
                                                '"Id": "a1D5c00000AvbgHEAR"' +
                                            '}' +
                                        ']' +
                                    '}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock externalLinkResp = new SaddleRockCalloutMock(200, 'OK', externalLinkRespStr, null);

        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint,oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/externallink/create', externalLinkResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        SaddleRockDocrioExternalLink.FlowInputs input = new SaddleRockDocrioExternalLink.FlowInputs();
        input.fileInfoIds = new List<string>();
        input.fileInfoIds.add(testFile.Id);
        input.fileInfoIds.add(testFile1.Id);
        input.sharingPassword = 'test123';
        List<SaddleRockDocrioExternalLink.FlowInputs> request = new List<SaddleRockDocrioExternalLink.FlowInputs>();
        request.add(input);

        SaddleRockDocrioExternalLink.createExternalLink(request);

        Test.stopTest();
    }

    @isTest
    public static void test_createSharingLink_500() {
        System.debug('### Creating test Docrio Setting ###');
        SaddleRockTestDataFactory.createTestDocrioSetting();

        docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();

        System.debug('### Creating test account ###');
        Account testAcct = new Account();
        testAcct.litify_pm__First_Name__c = 'John';
        testAcct.litify_pm__Last_Name__c = 'Doe';
        testAcct.Name = 'John Doe';
        insert testAcct;

        System.debug('### Creating test intake ###');
        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Client__c = testAcct.Id;
        insert testIntake;

        System.debug('### Creating test files ###');
        litify_docs__File_Info__c testFile = new litify_docs__File_Info__c();
        testFile.Name = 'Test.docx';
        testFile.litify_docs__Related_To__c = testIntake.Id;
        insert testFile;
        litify_docs__File_Info__c testFile1 = new litify_docs__File_Info__c();
        testFile1.Name = 'Test1.docx';
        testFile1.litify_docs__Related_To__c = testIntake.Id;
        insert testFile1;

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);

        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint,oAuthResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        SaddleRockDocrioExternalLink.FlowInputs input = new SaddleRockDocrioExternalLink.FlowInputs();
        input.fileInfoIds = new List<string>();
        input.fileInfoIds.add(testFile.Id);
        input.fileInfoIds.add(testFile1.Id);
        input.sharingPassword = 'test123';
        List<SaddleRockDocrioExternalLink.FlowInputs> request = new List<SaddleRockDocrioExternalLink.FlowInputs>();
        request.add(input);

        SaddleRockDocrioExternalLink.createExternalLink(request);

        Test.stopTest();
    }
}