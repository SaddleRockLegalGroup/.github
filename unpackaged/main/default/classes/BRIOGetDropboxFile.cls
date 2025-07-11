public with sharing class BRIOGetDropboxFile {
    public BRIOGetDropboxFile() {}
    @Future(callout=true)
    public static void getDBFile(String filesUrl, String title, String signEventId){
        try {
            HttpRequest req = new HttpRequest();
            String endpoint = 'callout:DropboxSignFiles'+ filesUrl;
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBodyAsBlob());
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; 
            cv.Origin = 'C';
            cv.SharingOption  = 'A';
            cv.Title = title; 
            cv.PathOnClient = title + '.pdf'; 
            cv.VersionData = res.getBodyAsBlob(); 
            cv.FirstPublishLocationId = signEventId;
            //cv.ownerId = UserInfo.getUserId();
            System.debug(UserInfo.getUserId());
            System.debug(cv);
            insert cv;

            

        }
        catch(Exception e){
            System.debug(e.getMessage());
            
        }
        

    }
}