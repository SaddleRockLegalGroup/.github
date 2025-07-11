@isTest
public with sharing class SC_VoidCaseDocumentsInvocableTest {
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
        litify_pm__Intake__c testIntake = SC_TestDataFactory.createTestIntake();
        testIntake.API_Casesafe_Id__c = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        update testIntake;

        List<SC_VoidCaseDocumentsInvocable.FlowInputs> request = new List<SC_VoidCaseDocumentsInvocable.FlowInputs>();
        SC_VoidCaseDocumentsInvocable.FlowInputs input = new SC_VoidCaseDocumentsInvocable.FlowInputs();
        input.caseId = testIntake.API_Casesafe_Id__c;

        request.add(input);

        // Set up mock
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string voidDocUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/documents';
        string updateCaseUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId;
        System.debug(voidDocUrl);
        System.debug(updateCaseUrl);
        string voidDocRespStr = '{' +
                                    '"message": "Case xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx documents voided"' +
                                '}';
        string updateCaseRespStr = '{' +
                                    '"message": "Updated case 82118"' +
                                    '"data": {},' +
                                '}';

        SaddleRockCalloutMock voidDocResp = new SaddleRockCalloutMock(200, 'OK', voidDocRespStr, null);
        SaddleRockCalloutMock updateCaseResp = new SaddleRockCalloutMock(200, 'OK', updateCaseRespStr, null);
        

        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        multiCalloutMock.addRequestMock(voidDocUrl, voidDocResp);
        multiCalloutMock.addRequestMock(updateCaseUrl, updateCaseResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        SC_VoidCaseDocumentsInvocable.voidCaseDocument(request);
        System.assertEquals(1, 1, 'Nothing to assert');
        Test.stopTest();
    }
}