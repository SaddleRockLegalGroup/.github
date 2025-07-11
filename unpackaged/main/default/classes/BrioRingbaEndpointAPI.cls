@RestResource(urlMapping='/ringbacall')
global with sharing class BrioRingbaEndpointAPI {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // {
        //     "ringbaid": "abc",
        //     "callstartime": "12/18/2024 3:38:31 PM",
        //     "dnis": "+18339663885",
        //     "ani": "+16106133512"
        // }

        try {
            Map<String, Object> parsedPayload = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            String ringbaId = String.valueOf(parsedPayload.get('ringbaid'));
            String callstartTimeStr = String.valueOf(parsedPayload.get('callstarttime'));
            String campaignName = String.valueOf(parsedPayload.get('campaignname'));
            String DNIS = String.valueOf(parsedPayload.get('dnis'));
            String ANI = String.valueOf(parsedPayload.get('ani'));
            String marketingSource = String.valueOf(parsedPayload.get('marketingsource'));
            String referralPartnerAPIExternalId = String.valueOf(parsedPayload.get('referralpartnerapiexternalid'));

            System.debug('Parsed Payload: ' + parsedPayload);
            System.debug('ringbaId: ' + ringbaId);
            System.debug('callStartTimeStr: ' + callstartTimeStr);
            System.debug('campaignName: ' + campaignName);
            System.debug('dnis: ' + DNIS);
            System.debug('ani: ' + ANI);
            System.debug('marketingSource: ' + marketingSource);
            System.debug('referralPartnerAPIExternalId: ' + referralPartnerAPIExternalId);

            // Create a new Call record (assuming you have a custom object named Call__c)
            Ringba_Call__c newCall = new Ringba_Call__c();
            newCall.Ringba_Id__c = ringbaId;
            newCall.Campaign__c = campaignName;
            newCall.DNIS__c = DNIS;
            newCall.ANI__c = ANI;
            newCall.Marketing_Source__c = marketingSource;
            newCall.Referral_Partner_API_External_Id__c = referralPartnerAPIExternalId;

            // Check CRUD permissions before inserting
            if (Schema.sObjectType.Ringba_Call__c.isCreateable()) {
                insert newCall;
                System.debug('Record inserted successfully: ' + newCall);
                res.statusCode = 201; // HTTP status code for created
                res.responseBody = Blob.valueOf('{"message": "Call record created successfully", "success": true}');
            } else {
                res.responseBody = Blob.valueOf('{"error": "Insufficient permissions to create Ringba_Call__c record."}');
                return;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            res.responseBody = Blob.valueOf('{"error": "An error occurred while creating the call record."}');
        }
    }
}