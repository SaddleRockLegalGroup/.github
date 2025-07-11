public with sharing class FV_Models {
    public class HttpResponseWrapper {
        public boolean success {get;set;}
        public string data {get;set;}
    }
    public class LoginModel {
        public string mode {get;set;}
        public string apiKey {get;set;}
        public string apiHash {get;set;}
        public string apiTimestamp {get;set;}
    }
    public class LoginRespModel {
        public string accessToken {get;set;}
        public string refreshToken {get;set;}
        public string refreshTokenExpiry {get;set;}
        public string refreshTokenTtl {get;set;}
        public string userId {get;set;}
        public string orgId {get;set;}
    }
    public class FVIdentifier {
        public string native {get;set;}
        public string partner {get;set;}
    }
    public class Contact {
        public FVIdentifier personId {get;set;}
        // public string firstName {get;set;}
        // public string middleName {get;set;}
        // public string lastName {get;set;}
        // public string fullName {get;set;}
        // public string birthDate {get;set;}
    }
    public class Project {
        public FVIdentifier projectId {get;set;}
    }
    public class DocumentURLResp {
        public FVIdentifier documentId {get;set;}
        public string contentType {get;set;}
        public string url {get;set;}
    }
    public class Document {
        public FVIdentifier documentId {get;set;}
        // public string filename {get;set;}
        // public string size {get;set;}
        // public FVIdentifier folderId {get;set;}
        // public FVIdentifier uploaderId {get;set;}
        // public string uploadDate {get;set;}
    }
}