@IsTest
public class Dial800WebhookHandler_Test {
    
    @IsTest
    static void testHandleCreateRecordWebhook() {
        // Simulate a POST request with a JSON payload
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"eventType": "create_record","ANI": "1234567890","Station": "station","Call Start": "2023-01-01T12:34:56","DNIS": "9876543210","Call Id": "ABCD1234","City": "San Francisco","State": "CA","Postal Code": 94105,"Status": "Connected","Target": "Target Name","Media Agency": "Agency Name","Campaign": "Campaign Name","Duration": 300,"Connected Duration": 200}');
        // Call the webhook handler
        Dial800WebhookHandler.handleWebhook();
        
        // Verify the response
        System.assertEquals(200, res.statusCode, 'Response status should be 200');
        System.assert(res.responseBody.toString().contains('"status": "success"'), 'Response should indicate success');
        
        // Verify that the Contact was created
        List<Dial800__c>dial800 = [SELECT Name, ANI__c,Call_Id__c FROM Dial800__c WHERE ANI__c = '1234567890'];
        System.assertEquals(1, dial800.size(), 'One Dial800 record should have been created');
        System.assertEquals('1234567890', dial800[0].ANI__c, 'ANI should match');
        System.assertEquals('ABCD1234', dial800[0].Call_Id__c, 'Call ID should match');
    }
   
    
    @IsTest
    static void testHandleUnknownEventType() {
        // Simulate a POST request with an unknown event type
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"event_type": "unknown_event"}');
        
        // Call the webhook handler
        Dial800WebhookHandler.handleWebhook();
        
        // Verify the response
        System.assertEquals(200, res.statusCode, 'Response status should be 200');
        System.assert(res.responseBody.toString().contains('"status": "success"'), 'Response should indicate success');
        
        // Verify no records were created or updated
        Contact[] contacts = [SELECT Id FROM Contact];
        System.assertEquals(0, contacts.size(), 'No Dial800 record should be created or updated');
    }
    
}