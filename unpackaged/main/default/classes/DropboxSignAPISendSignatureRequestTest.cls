@isTest
public with sharing class DropboxSignAPISendSignatureRequestTest {
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

    private static List<DropboxSignAPISigner> buildTestSigners(){
        Account newAcct = new Account();
        newAcct.litify_pm__First_Name__c = 'John';
        newAcct.litify_pm__Last_Name__c = 'Doe';
        insert newAcct;
        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        insert newIntake;
        litify_pm__Role__c newRole = new litify_pm__Role__c();
        newRole.litify_pm__Intake__c = newIntake.Id;
        newRole.litify_pm__Party__c = newAcct.Id;
        insert newRole;

        DropboxSignAPISigner signer = new DropboxSignAPISigner();
        signer.roleId = newRole.Id;
        signer.partyId = newAcct.Id;
        signer.name = 'John Doe';
        signer.phone = '1111111111';
        signer.email = 'doej@email.com';
        signer.signingOrder = 1;
        List<DropboxSignAPISigner> result = new List<DropboxSignAPISigner>();
        result.add(signer);
        return result;
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

    private static Dropbox_Sign_API_Settings__c createTestDropboxSignAPISettings(){
        Dropbox_Sign_API_Settings__c setting = new Dropbox_Sign_API_Settings__c();
        setting.Debugging__c = true;
        setting.Log_Days_to_Keep__c = 90;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Base_URL__c = 'https://api.hellosign.com/v3';
        setting.API_Key__c = '123';
        insert setting;
        return setting;
    }

    @isTest
    public static void test_SendSignatureRequest_OK() {
        // Create test flow inputs
        litify_docs__File_Info__c testFile = createTestFileInfo();
        List<litify_docs__File_Info__c> files = new List<litify_docs__File_Info__c>();
        files.add(testFile);

        List<DropboxSignAPISendSignatureRequest.FlowInputs> request = new List<DropboxSignAPISendSignatureRequest.FlowInputs>();
        DropboxSignAPISendSignatureRequest.FlowInputs input = new DropboxSignAPISendSignatureRequest.FlowInputs();
        input.title = 'Test Dropbox Email';
        input.subject = 'Test Dropbox Email';
        input.message = 'Test Dropbox Email';
        input.signers = buildTestSigners();
        input.documents = files;
        input.testMode = true;
        input.sendViaSMS = true;
        input.ccEmailAddresses = new List<string> {'johndoe@email.com'};
        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = createTestDocrioSetting();
        string dropboxSigRespstr = '{' +
                        '"signature_request": {' +
                        '"signature_request_id": "2b388914e3ae3b738bd4e2ee2850c677e6dc53d2",' +
                        '"title": "NDA with Acme Co.",' +
                        '"original_title": "The NDA we talked about",' +
                        '"subject": "The NDA we talked about",' +
                        '"message": "Please sign this NDA and then we can discuss more. Let me know if you have any questions.",' +
                        '"test_mode": true,' +
                        '"metadata": {' +
                            '"custom_id": "1234",' +
                            '"custom_text": "NDA #9"' +
                        '},' +
                        '"created_at": 1570471067,' +
                        '"is_complete": false,' +
                        '"is_declined": false,' +
                        '"has_error": false,' +
                        '"custom_fields": [],' +
                        '"response_data": [],' +
                        '"signing_url": "https://app.hellosign.com/sign/2b388914e3ae3b738bd4e2ee2850c677e6dc53d2",' +
                        '"signing_redirect_url": null,' +
                        '"files_url": "https://api.hellosign.com/v3/signature_request/files/2b388914e3ae3b738bd4e2ee2850c677e6dc53d2",' +
                        '"details_url": "https://app.hellosign.com/home/manage?guid=2b388914e3ae3b738bd4e2ee2850c677e6dc53d2",' +
                        '"requester_email_address": "me@dropboxsign.com",' +
                        '"signatures": [' +
                            '{' +
                            '"signature_id": "78caf2a1d01cd39cea2bc1cbb340dac3",' +
                            '"signer_email_address": "jack@example.com",' +
                            '"signer_name": "Jack",' +
                            '"signer_role": null,' +
                            '"order": 0,' +
                            '"status_code": "awaiting_signature",' +
                            '"signed_at": null,' +
                            '"last_viewed_at": null,' +
                            '"last_reminded_at": null,' +
                            '"has_pin": false,' +
                            '"has_sms_auth": false' +
                            '},' +
                            '{' +
                            '"signature_id": "616629ed37f8588d28600be17ab5d6b7",' +
                            '"signer_email_address": "jill@example.com",' +
                            '"signer_name": "Jill",' +
                            '"signer_role": null,' +
                            '"order": 1,' +
                            '"status_code": "awaiting_signature",' +
                            '"signed_at": null,' +
                            '"last_viewed_at": null,' +
                            '"last_reminded_at": null,' +
                            '"has_pin": false,' +
                            '"has_sms_auth": false' +
                            '}' +
                        '],' +
                        '"cc_email_addresses": [' +
                            '"lawyer1@dropboxsign.com",' +
                            '"lawyer2@example.com"' +
                        '],' +
                        '"attachments": [' +
                            '{' +
                            '"id": "id_1",' +
                            '"signer": "1",' +
                            '"name": "Attachment #1",' +
                            '"required": true,' +
                            '"instructions": "Instructions #1",' +
                            '"uploaded_at": 1650398513' +
                            '},' +
                            '{' +
                            '"id": "id_2",' +
                            '"signer": "2",' +
                            '"name": "Attachment #2",' +
                            '"required": true,' +
                            '"instructions": null,' +
                            '"uploaded_at": null' +
                            '}' +
                        '],' +
                        '"template_ids": null' +
                        '}' +
                    '}';
        
        string docrioSignedUrlRespStr = '{' +
                                    '"Records": [' +
                                        '{' +
                                            '"Id": "' + testFile.Id + '",' +
                                            '"SignedUrl": "https://test.pdf"' +
                                        '}' +
                                    ']' +
                                '}';
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock dropboxSigResp = new SaddleRockCalloutMock(200, 'OK', dropboxSigRespstr, null);
        

        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://api.hellosign.com/v3/signature_request/send', dropboxSigResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        List<DropboxSignAPISendSignatureRequest.FlowOutputs> result = DropboxSignAPISendSignatureRequest.submitSignatureRequest(request);
        Test.stopTest();

        System.assertEquals(true, result[0].success);
    }

    @isTest
    public static void test_SendSignatureRequest_Failed() {
        // Create test flow inputs
        litify_docs__File_Info__c testFile = createTestFileInfo();
        List<litify_docs__File_Info__c> files = new List<litify_docs__File_Info__c>();
        files.add(testFile);

        List<DropboxSignAPISendSignatureRequest.FlowInputs> request = new List<DropboxSignAPISendSignatureRequest.FlowInputs>();
        DropboxSignAPISendSignatureRequest.FlowInputs input = new DropboxSignAPISendSignatureRequest.FlowInputs();
        input.title = 'Test Dropbox Email';
        input.subject = 'Test Dropbox Email';
        input.message = 'Test Dropbox Email';
        input.signers = buildTestSigners();
        input.documents = files;
        input.testMode = true;
        input.sendViaSMS = true;
        request.add(input);

        // Set up mock
        SaddleRockCalloutMock oAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        Map<String, HttpCalloutMock> docrioResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(docrioResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, oAuthResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        List<DropboxSignAPISendSignatureRequest.FlowOutputs> result = DropboxSignAPISendSignatureRequest.submitSignatureRequest(request);
        Test.stopTest();

        System.assertEquals(false, result[0].success);
    }
}