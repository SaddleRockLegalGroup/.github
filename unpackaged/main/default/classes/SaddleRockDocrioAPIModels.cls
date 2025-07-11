public with sharing class SaddleRockDocrioAPIModels {
    public class ExternalLinkPostRequest {
        public List<Map<string,object>> FileInfoRecords {get;set;}
        public Map<string,object> FileLinkRecord {get;set;}
    }
    public class ExternalLinkPostResponseWrapper {
        public Map<string,object> data {get;set;}
        public Boolean success {get;set;}
        public string message {get;set;}
    }
    public class SignedUrlObject {
        public String SignedUrl {get;set;}
        public String Id {get;set;}
    }
    public class FilesGetResponse {
        public List<SignedUrlObject> Records {get;set;}
    }
}