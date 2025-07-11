public with sharing class DropboxSignAPIModels {
    public class SignatureRequest { 
        public string title {get;set;}
        public string subject {get;set;}
        public string message {get;set;}
        public List<Signer> signers {get;set;}
        // public List<string> cc_email_addresses {get;set;}
        public List<string> file_urls {get;set;}
        // public Map<string, object> metadata {get;set;}
        // public Map<string, object> signing_options {get;set;}
        // public Map<string, object> field_options {get;set;}
        public Boolean test_mode {get;set;}
        public Boolean use_text_tags {get;set;}
        public List<string> cc_email_addresses {get;set;}
    }

    public class Signer {
        public string email_address {get;set;}
        public string name {get;set;}
        public Integer order {get;set;}
        public string sms_phone_number {get;set;}
        public string sms_phone_number_type {get;set;}
    }

    public virtual class HttpResponseWrapper {
        public Boolean success {get;set;}
        public string message {get;set;}
    }

    public class SignatureRequestRespWrapper extends HttpResponseWrapper{
        public SignatureRequestResp data {get;set;}
    }

    public class ResponseSignature{
        public string signature_id {get;set;}
        public string signer_group_guid {get;set;}
        public string signer_email_address {get;set;}
        public string signer_name {get;set;}
        public string signer_role {get;set;}
        public Integer order {get;set;}
        public string status_code {get;set;}
        // public string decline_reason {get;set;}
        // public Integer signed_at {get;set;}
        // public Integer last_viewed_at {get;set;}
        // public Integer last_reminded_at {get;set;}
        // public Boolean has_pin {get;set;}
        // public Boolean has_sms_auth {get;set;}
        // public Boolean has_sms_delivery {get;set;}
        // public string sms_phone_number {get;set;}
        // public string reassigned_by {get;set;}
        // public string reassignment_reason {get;set;}
        // public string reassigned_from {get;set;}
        // public string error {get;set;}
    }

    public class SignatureRequestRespDetail {
        public string signature_request_id {get;set;}
        public string title {get;set;}
        public string signing_url {get;set;}
        public List<ResponseSignature> signatures {get;set;}
    }
    public class SignatureRequestResp {
        public SignatureRequestRespDetail signature_request {get;set;}
    }
}