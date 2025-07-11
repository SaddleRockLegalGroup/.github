public class  BRIOWebhookVFPage_Controller {
    public String outputText {get; set;}{
        outputText = 'blah bla bla';
    }
    public String eventPayload {get; set;}{
        eventPayload = '';      
        if (ApexPages.currentPage() != null){
            eventPayload = ApexPages.currentPage().getParameters().get('json');
        }
    }

    /*public Map<String, Object> eventHeaders {get; set;}{
        eventHeaders = null;      
        if (ApexPages.currentPage() != null){
            eventHeaders = ApexPages.currentPage().getHeaders();
        }
    }*/
    public BRIOWebhookVFPage_Controller(){}
    
    public PageReference init() { 

        Dropbox_Sign_API_Settings__c customSetting = new Dropbox_Sign_API_Settings__c();

     try {   
        
        Map<String, Object> parsedPayload = (Map<String, Object>) JSON.deserializeUntyped(eventPayload); 
        Map<String, Object> eventData = (Map<String, Object>) parsedPayload.get('event');
        Map<String, Object> eventMetadata = (Map<String, Object>) eventData.get('event_metadata');
        Map<String, Object> signatureRequest = (Map<String, Object>) parsedPayload.get('signature_request');
		
        String eventType = (String) eventData.get('event_type');
        String eventTime = (String) eventData.get('event_time');
        String eventHash = (String) eventData.get('event_hash');
        String filesUrl = (String) signatureRequest.get('files_url');
        String relatedSigId = (String) eventMetadata.get('related_signature_id');
        String title = (String) signatureRequest.get('title');
        String finalCopyUri = (String) signatureRequest.get('final_copy_uri');
        String signatureRequestId = (String) signatureRequest.get('signature_request_id');

        
            if(BRIODbSignHelper.validateRequest(eventHash,eventType,eventTime) == true){
                Dropbox_Sign_Request__c[] sfSigReq = [
                    select id,Intake__c
                    from Dropbox_Sign_Request__c
                    where Signature_Request_ID__c = :signatureRequestId
                ];
                Dropbox_Sign_Event__c signEvent = new Dropbox_Sign_Event__c();
                if(sfSigReq.size() > 0){
                    signEvent.Dropbox_Sign_Request__c = sfSigReq[0].id;
                    signEvent.Intake__c = sfSigReq[0].Intake__c;

                }
                
                signEvent.Event_Time__c = eventTime;
                signEvent.Event_Type__c = eventType;
                signEvent.Event_Metadata__c = String.valueOf(eventMetadata);
                signEvent.Signature_Request__c = signatureRequestId;
                signEvent.Full_Payload__c = eventPayload;
                signEvent.Final_Copy_URI__c = finalCopyUri;
                signEvent.Title__c = title;
                if(filesUrl != null ){
                    signEvent.Files_Url__c = filesUrl;
                }
                
                insert signEvent;
                outputText = 'Success' + sfSigReq[0].id;
                /*if(eventType == 'signature_request_all_signed'){
                    BRIOGetDropboxFile.getDBFile(finalCopyUri,title, signEvent.Id);

                } */
               
              
                return null;
    
            } 
            else {
                outputText = String.valueOf(BRIODbSignHelper.validateRequest(eventHash,eventType,eventTime));
                return null;
            }       

        }
        catch (Exception e){
            outputText = e.getMessage();
            return null;
        }
        
    }
}