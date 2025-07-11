@isTest
private class BRIOWebhookVFPage_ControllerTest {

    @isTest
    static void testInitMethod() {
        // Create test data
        String jsonPayload = '{"event":{"event_type":"signature_request_signed","event_time":"9876543210","event_hash":"9337217ae0f38090ed9ecb3ec93196c6153ef8513f55ce5a31aaf5e3250a1690","event_metadata":{"related_signature_id":null,"reported_for_account_id":"another_random_account_id","reported_for_app_id":null,"integration_identifier":null}},"account_guid":"another_random_account_guid","client_id":null,"signature_request":{"signature_request_id":"another_random_signature_request_id","test_mode":false,"title":"Another Random Agreement","original_title":"Another Random Agreement","subject":"Another Random Agreement","message":"Please review and sign the attached contract.","metadata":{},"created_at":1234567890,"expires_at":null,"is_complete":true,"is_declined":false,"has_error":false,"custom_fields":[],"response_data":[{"name":"Signature Date1","type":"date_signed","required":false,"api_id":"random_6","value":"02 / 15 / 2024","signature_id":"another_random_signature_1"},' +
                     '{"name":"Signature2","type":"signature","required":true,"api_id":"random_7","value":null,"signature_id":"another_random_signature_2"},' +
                     '{"name":"Signature Date3","type":"date_signed","required":false,"api_id":"random_8","value":"02 / 15 / 2024","signature_id":"another_random_signature_3"},' +
                     '{"name":"Signature Date4","type":"date_signed","required":false,"api_id":"random_9","value":"02 / 15 / 2024","signature_id":"another_random_signature_4"},' +
                     '{"name":"Signature3","type":"signature","required":true,"api_id":"random_10","value":null,"signature_id":"another_random_signature_5"}],"signing_url":"https://app.hellosign.com/sign/another_random_signature_request_id","signing_redirect_url":null,"final_copy_uri":"/v3/signature_request/final_copy/another_random_signature_request_id","files_url":"https://api.hellosign.com/v3/signature_request/files/another_random_signature_request_id","details_url":"https://app.hellosign.com/home/manage?guid=another_random_signature_request_id","requester_email_address":"random_email@gobrio.com","signatures":[{"signature_id":"another_random_signature_1","has_pin":false,"has_sms_auth":false,"has_sms_delivery":false,"sms_phone_number":null,"signer_email_address":"another_random_signer@gobrio.com","signer_name":"Another Random Signer","signer_role":null,"order":null,"status_code":"signed","signed_at":9876543210,"last_viewed_at":9876543210,"last_reminded_at":null,"error":null}],' +
                     '"cc_email_addresses":["random_cc_email@example.com","random_email@gobrio.com"],"template_ids":null}}';
        Dropbox_Sign_API_Settings__c customSetting = new Dropbox_Sign_API_Settings__c();
        customSetting.API_Key__c = '61bbe8f75acf1978d8b41d776b1bb809486628e9f2bdb13e66bbeb28564b58e9';
        insert customSetting;


        
        // Set up test page and controller
        PageReference pageRef = Page.DropBoxSignEndpoint; // Replace with your actual Visualforce page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('json', jsonPayload);

        BRIOWebhookVFPage_Controller controller = new BRIOWebhookVFPage_Controller();

        // Test the init method
        Test.startTest();
        PageReference result = controller.init();
        Test.stopTest();
        String expectedExceptionMessage = 'List index out of bounds: 0'; 
        System.assertEquals(expectedExceptionMessage, controller.outputText);
    }
}