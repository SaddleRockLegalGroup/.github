public without sharing class BRIODbSignHelper {
    //public BRIODbSignHelper() {}


    public static Boolean validateRequest(String eventHash,String eventType,String eventTime){
        Dropbox_Sign_API_Settings__c[] customSetting = [
            select API_Key__c
            from Dropbox_Sign_API_Settings__c
        ];
        String key = customSetting[0].API_Key__c;
        String sfKey = EncodingUtil.convertToHex(System.Crypto.generateMac('HmacSHA256',Blob.valueOf( eventTime + eventType),Blob.valueOf(key)));
        if(eventHash == sfKey){
            return true;
        } 
        else {
            return false;
        }   
        
    }

}