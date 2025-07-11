@RestResource(urlMapping='/Dial800Intake/*')
global class Dial800WebhookHandler {
//use to test in scottv1 sandbox: https://saddlerock--scottsv1.sandbox.my.salesforce-sites.com/Dial800/services/apexrest/Dial800Intake
//use to test in prod: https://saddlerock.my.salesforce-sites.com/Dial800/services/apexrest/Dial800Intake
    @HttpPost
    global static void handleWebhook() {
        try {
            // Parse the incoming request
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            // Log the request body for debugging
            String requestBody = req.requestBody.toString();
            System.debug('Webhook Payload: ' + requestBody);

            // Parse JSON payload
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            String eventType = (String) payload.get('eventType');
            System.debug('Event Type: ' + eventType);
    
            // Perform actions based on event type
            if (eventType == 'create_record') {
                createRecord(payload);
            } else {
                System.debug('Unknown event type: ' + eventType);
            }
               
            // Set response status
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"status": "success"}');
        } catch (Exception ex) {
            // Handle any errors
            System.debug('Error in WebhookHandler: ' + ex.getMessage());
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('{"status": "error", "message": "' + ex.getMessage() + '"}');
        }
    }

    // Helper method to create a record
    private static void createRecord(Map<String, Object> payload) {
        try {
            //Create a Dial800__c record
            Dial800__c  newDetails = new Dial800__c ();
            newDetails.ANI__c = (String) payload.get('ANI');
            newDetails.Station__c = (String) payload.get('Station');
            newDetails.Call_Start__c  = (String) payload.get('Call Start');
            newDetails.DNIS__c = (String) payload.get('DNIS');
            newDetails.Call_Id__c = (String) payload.get('Call Id');
            newDetails.City__c = (String) payload.get('City');
            newDetails.State__c = (String) payload.get('State');
            newDetails.Postal_Code__c = Integer.valueof(payload.get('Postal Code'));
            newDetails.Status__c = (String) payload.get('Status');
            newDetails.Target__c = (String) payload.get('Target');
            newDetails.Media_Agency__c = (String) payload.get('Media Agency');
            newDetails.Campaign__c = (String) payload.get('Campaign');
            newDetails.Duration__c = Integer.valueof(payload.get('Duration'));
            newDetails.Connected_Duration__c = Integer.valueof(payload.get('Connected Duration'));
            insert newDetails;
            System.debug('newDetails created: ' + newDetails);
        } catch (Exception ex) {
            System.debug('Error creating record: ' + ex.getMessage());
            throw ex;
        }
    }
}