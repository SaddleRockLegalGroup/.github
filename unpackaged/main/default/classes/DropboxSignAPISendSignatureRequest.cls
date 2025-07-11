public with sharing class DropboxSignAPISendSignatureRequest {
    public class FlowInputs {
        @InvocableVariable(label='Intake') public string intakeId;
        @InvocableVariable(label='Title (up to 255 characters)' required=true) public string title;
        @InvocableVariable(label='Subject (up to 255 characters)' required=true) public string subject;
        @InvocableVariable(label='Message (up to 5000 characters)' required=true) public string message;
        @InvocableVariable(label='Signers' required=true) public List<DropboxSignAPISigner> signers;
        @InvocableVariable(label='List of Documents' required=true) public List<litify_docs__File_Info__c> documents;
        @InvocableVariable(label='Is running test?' required=true) public Boolean testMode;
        @InvocableVariable(label='Send via SMS? (SMS will not work when running in test mode)' required=true) public Boolean sendViaSMS;
        @InvocableVariable(label='CC Email Addresses' required=false) public List<string> ccEmailAddresses;
    }
    public class FlowOutputs {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='DROPBOX SIGN: Submit Signature Request')
    public static List<FlowOutputs> submitSignatureRequest(List<FlowInputs> request){
        Map<string,DropboxSignAPISigner> signerMap = new Map<string,DropboxSignAPISigner>();
        DropboxSignAPIModels.SignatureRequest signatureReq = new DropboxSignAPIModels.SignatureRequest();
        try {
            signatureReq.title = request[0].title;
            signatureReq.subject = request[0].subject;
            signatureReq.message = request[0].message;
            signatureReq.test_mode = request[0].testMode;
            signatureReq.use_text_tags = true;
            signatureReq.file_urls = new List<string>();

            if(request[0].ccEmailAddresses != null && request[0].ccEmailAddresses.size() > 0){
                signatureReq.cc_email_addresses = request[0].ccEmailAddresses;
            }

            List<string> fileIds = new List<string>();
            if(request[0].documents != null){
                for(litify_docs__File_Info__c fileInfo : request[0].documents){
                    fileIds.add(fileInfo.Id);
                }
                if(fileIds != null && fileIds.size() > 0){
                    DropboxSignDocrioService docrioService = new DropboxSignDocrioService();
                    string accessToken = docrioService.refreshDocrioToken();
                    DropboxSignDocrioService.FilesGetResponse docrioFileResp = docrioService.getDownloadUrls(accessToken, fileIds);
                    if(docrioFileResp != null && docrioFileResp.Records != null && docrioFileResp.Records.size() > 0){
                        for(DropboxSignDocrioService.SignedUrlObject signedObj : docrioFileResp.Records){
                            signatureReq.file_urls.add(signedObj.SignedUrl);
                        }
                    }
                }
            }

            signatureReq.signers = new List<DropboxSignAPIModels.Signer>();
            List<DropboxSignAPISigner> signers = request[0].signers;

            if(signers != null && signers.size() > 0){
                for(DropboxSignAPISigner signer : signers){
                    DropboxSignAPIModels.Signer dbSigner = new DropboxSignAPIModels.Signer();
                    string customSignerId = signer.name + signer.email + signer.signingOrder;
                    signerMap.put(customSignerId.toLowerCase(), signer);
                    dbSigner.name = signer.name;
                    dbSigner.email_address = signer.email;
                    dbSigner.order = signer.signingOrder;
                    if(request[0].sendViaSMS){
                        string formattedPhone = formatMobilePhone(signer.phone);
                        if(formattedPhone == 'Invalid'){
                            return returnResult(false, 'Error: Mobile phone ' + signer.phone + ' is invalid');
                        }
                        else if(formattedPhone == ''){
                            return returnResult(false, 'Error: Mobile phone is empty');
                        }
                        dbSigner.sms_phone_number = formattedPhone;
                        dbSigner.sms_phone_number_type = 'delivery';
                    }
                    signatureReq.signers.add(dbSigner);
                }
                

                DropboxSignAPIRestAPI restApi = new DropboxSignAPIRestAPI();
                DropboxSignAPIModels.SignatureRequestRespWrapper respWrapper = restApi.sendSignatureRequest(signatureReq);
                if(respWrapper != null){
                    DropboxSignAPILogger.writeLogs();
                    if(respWrapper.success && respWrapper.data != null && respWrapper.data.signature_request != null){
                        // Create Dropbox Sign Request record
                        Dropbox_Sign_Request__c sfNewSigReq = new Dropbox_Sign_Request__c();
                        sfNewSigReq.Signature_Request_ID__c = respWrapper.data.signature_request.signature_request_id;
                        sfNewSigReq.Status__c = 'created';
                        sfNewSigReq.Title__c = respWrapper.data.signature_request.title;
                        sfNewSigReq.API_Response__c = JSON.serialize(respWrapper.data);
                        if(request[0].intakeId != null && request[0].intakeId != ''){
                            sfNewSigReq.Intake__c = request[0].intakeId;
                        }
                        Database.DMLOptions dmlOptions = new Database.DMLOptions();
                        dmlOptions.allowFieldTruncation = true;
                        Database.insert(sfNewSigReq, dmlOptions);

                        // Create Dropbox Sign Signature records
                        List<Dropbox_Sign_Signature__c> dbSigsToCreate = new List<Dropbox_Sign_Signature__c>();
                        for(DropboxSignAPIModels.ResponseSignature dbRespSig : respWrapper.data.signature_request.signatures){
                            Dropbox_Sign_Signature__c sfNewSig = new Dropbox_Sign_Signature__c();
                            sfNewSig.Dropbox_Sign_Request__c = sfNewSigReq.Id;
                            sfNewSig.Signature_ID__c = dbRespSig.signature_id;
                            sfNewSig.Status_Code__c = dbRespSig.status_code;
                            
                            string customSigId = dbRespSig.signer_name + dbRespSig.signer_email_address + dbRespSig.order;
                            if(signerMap.containsKey(customSigId.toLowerCase())){
                                sfNewSig.Recipient_Role__c = signerMap.get(customSigId.toLowerCase()).roleId;
                                sfNewSig.Recipient__c = signerMap.get(customSigId.toLowerCase()).partyId;
                            }
                            dbSigsToCreate.add(sfNewSig);
                        }

                        if(dbSigsToCreate != null && dbSigsToCreate.size() > 0){
                            insert dbSigsToCreate;
                        }

                        return returnResult(respWrapper.success, respWrapper.data.signature_request.signing_url);
                    }
                    return returnResult(respWrapper.success, respWrapper.message);
                }
            }

            return returnResult(false, 'Error: Internal Server Error');
        }
        catch(Exception e){
            new DropboxSignAPILogger.Log(LoggingLevel.ERROR, 'DropboxSignAPISendSignatureRequest exception',
                e.getMessage() + '\n\n' + e.getStackTraceString());
            DropboxSignAPILogger.writeLogs();
            return returnResult(false, 'Error: ' + e.getMessage() + '\n\n' + e.getStackTraceString());
        }
    }

    private static List<FlowOutputs> returnResult(Boolean success, string message){
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        output.success = success;
        output.message = message;
        outputs.add(output);
        return outputs;
    }

    private static string formatMobilePhone(string phoneNum){
        if(phoneNum == null || phoneNum == ''){
            return '';
        }

        String phone = phoneNum.replaceAll('-', '').replaceAll('\\(', '').replaceAll('\\)', '').replaceAll('\\s+', '');
        if(phone.startsWith('+1')){
            if(phone.length() > 15){
                return 'Invalid';
            }
            else {
                return phone;
            }
        }
        else {
            if(phone.isNumeric()){
                if(phone.length() > 13){
                    return 'Invalid';
                }
                else {
                    phone = '+1' + phone;
                }
            }
            else {
                return 'Invalid';
            }
        }
        return phone;
    }
}