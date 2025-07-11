@isTest
private class BrioRingbaEndpointAPITest {

    @isTest
    static void testCreateCall() {
        // Set up test data
        String ringbaId = '12345';
        String callStartTimeStr = '12/06/2024 08:43:58 AM';
        String campaignName = 'Test Campaign';
        String dnis = '+1234567890';
        String ani = '+0987654321';
        String marketingSource = 'Test Marketing Source';
        String referralPartnerAPIExternalId = 'Test Referral Partner API External Id';

        // Create a JSON string to simulate the request body
        String requestBody = '{"ringbaid": "' + ringbaId + '", "callstarttime": "' + callStartTimeStr + '", "campaignname": "' + campaignName + '", "dnis": "' + dnis + '", "ani": "' + ani + '" , "marketingsource": "' + marketingSource + '", "referralpartnerapiexternalid": "' + referralPartnerAPIExternalId + '"}';
        System.debug('Request Body: ' + requestBody);

        // Create a RestRequest and RestResponse
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        BrioRingbaEndpointAPI.doPost();

        // Verify that the Call__c record was created
        Ringba_Call__c[] calls = [SELECT Ringba_Id__c, Call_Start__c, Campaign__c, DNIS__c, ANI__c, Marketing_Source__c, Referral_Partner_API_External_Id__c FROM Ringba_Call__c WHERE Ringba_Id__c = :ringbaId];
        
        System.assertEquals(campaignName, calls[0].Campaign__c);
        System.assertEquals(dnis, calls[0].DNIS__c);
        System.assertEquals(ani, calls[0].ANI__c);
        System.assertEquals(marketingSource, calls[0].Marketing_Source__c);
        System.assertEquals(referralPartnerAPIExternalId, calls[0].Referral_Partner_API_External_Id__c);
    }
}