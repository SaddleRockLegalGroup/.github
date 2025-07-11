@isTest
public with sharing class SaddlerockGetDocrioDownloadUrlTest {
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
        System.debug('### Creating test Docrio Setting ###');
        SaddleRockTestDataFactory.createTestDocrioSetting();

        docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();

        System.debug('### Creating test account ###');
        Account testAcct = new Account();
        testAcct.litify_pm__First_Name__c = 'John';
        testAcct.litify_pm__Last_Name__c = 'Doe';
        testAcct.litify_pm__Phone_Mobile__c = '1111111111';
        testAcct.Name = 'John Doe';
        insert testAcct;

        System.debug('### Creating test intake ###');
        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Client__c = testAcct.Id;
        insert testIntake;

        System.debug('### Creating test files ###');
        litify_docs__File_Info__c testFile = new litify_docs__File_Info__c();
        testFile.Name = 'Test.pdf';
        testFile.litify_docs__Related_To__c = testIntake.Id;
        testFile.litify_docs__Complete__c = true;
        insert testFile;
        litify_docs__File_Info__c testFile1 = new litify_docs__File_Info__c();
        testFile1.Name = 'Test1.pdf';
        testFile1.litify_docs__Related_To__c = testIntake.Id;
        testFile1.litify_docs__Complete__c = true;
        insert testFile1;

        //Set up mock
        System.debug('### Creating mock requests ###');
        
        string docrioSignedUrlRespStr = '{' +
                                    '"Records": [' +
                                        '{' +
                                            '"Id": "' + testFile.Id + '",' +
                                            '"SignedUrl": "https://Test.pdf"' +
                                        '},' +
                                        '{' +
                                            '"Id": "' + testFile1.Id + '",' +
                                            '"SignedUrl": "https://Test1.pdf"' +
                                        '}' +
                                    ']' +
                                '}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        
        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint,oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id + ',' + testFile1.Id, docrioSignedUrlResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs input = new SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs();
        input.fileInfoIds = new List<string>();
        input.fileInfoIds.add(testFile.Id);
        input.fileInfoIds.add(testFile1.Id);
        List<SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs> request = new List<SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs>();
        request.add(input);

        List<SaddlerockGetDocrioDownloadUrlInvocable.FlowOutputs> result = SaddlerockGetDocrioDownloadUrlInvocable.getSignedUrl(request);

        Test.stopTest();
        System.assertEquals(true, result[0].success);
        System.assertEquals(2, result[0].data.size());
    }

    @isTest
    public static void test_OK_RelatedFiles() {
        System.debug('### Creating test Docrio Setting ###');
        SaddleRockTestDataFactory.createTestDocrioSetting();

        docriosdk__Docrio_Tool_Setting__c  docrioSetting = docriosdk__Docrio_Tool_Setting__c.getOrgDefaults();

        System.debug('### Creating test account ###');
        Account testAcct = new Account();
        testAcct.litify_pm__First_Name__c = 'John';
        testAcct.litify_pm__Last_Name__c = 'Doe';
        testAcct.litify_pm__Phone_Mobile__c = '1111111111';
        testAcct.Name = 'John Doe';
        insert testAcct;

        System.debug('### Creating test intake ###');
        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Client__c = testAcct.Id;
        insert testIntake;

        System.debug('### Creating test files ###');
        litify_docs__File_Info__c testFile = new litify_docs__File_Info__c();
        testFile.Name = 'Test.pdf';
        testFile.litify_docs__Related_To__c = testIntake.Id;
        testFile.litify_docs__Complete__c = true;
        insert testFile;
        litify_docs__File_Info__c testFile1 = new litify_docs__File_Info__c();
        testFile1.Name = 'Test1.pdf';
        testFile1.litify_docs__Related_To__c = testIntake.Id;
        testFile1.litify_docs__Complete__c = true;
        insert testFile1;

        //Set up mock
        System.debug('### Creating mock requests ###');
        
        string docrioSignedUrlRespStr = '{' +
                                    '"Records": [' +
                                        '{' +
                                            '"Id": "' + testFile.Id + '",' +
                                            '"SignedUrl": "https://Test.pdf"' +
                                        '},' +
                                        '{' +
                                            '"Id": "' + testFile1.Id + '",' +
                                            '"SignedUrl": "https://Test1.pdf"' +
                                        '}' +
                                    ']' +
                                '}';

        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        
        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint,oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id + ',' + testFile1.Id, docrioSignedUrlResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs input = new SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs();
        input.recordId = testIntake.Id;
        List<SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs> request = new List<SaddlerockGetDocrioDownloadUrlInvocable.FlowInputs>();
        request.add(input);

        List<SaddlerockGetDocrioDownloadUrlInvocable.FlowOutputs> result = SaddlerockGetDocrioDownloadUrlInvocable.getSignedUrl(request);

        Test.stopTest();
        System.assertEquals(true, result[0].success);
        System.assertEquals(2, result[0].data.size());
    }
}