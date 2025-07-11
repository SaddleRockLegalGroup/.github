public with sharing class SaddleRockVendorHandler {
    public class FlowInputs {
        @InvocableVariable(label='Vendor Name' required=true) public string vendorName ;
        @InvocableVariable(label='Vendor Salesforce Org ID' required=true) public string vendorSFOrgId ;
        @InvocableVariable(label='Active?') public Boolean active ;
        @InvocableVariable(label='Integration' required=true) public string integration ;
    }

    @InvocableMethod(label='SaddleRock: Add New Vendor' description='Add new vendor and generate API credentials')
    public static void newVendor(List<FlowInputs> request){
        string vendorName = request[0].vendorName;
        string integration = request[0].integration;
        string vendorSFOrgId = request[0].vendorSFOrgId;
        Boolean active = request[0].active;

        addNewVendor(vendorName, integration, vendorSFOrgId, active);
    }

    @Future(callout=true)
    public static void addNewVendor(string vendorName, string integration, string vendorSFOrgId, Boolean active) {
        string apiKey = generateRandomString(18);
        string apiName = vendorName.replaceAll(' ', '_');
        Map<String, Object> vendoInfo = new Map<String, Object>();
        vendoInfo.put('Integration__c', integration);
        vendoInfo.put('API_Key__c', apiKey);
        vendoInfo.put('OrgID__c', vendorSFOrgId);
        vendoInfo.put('Active__c', active);


        Metadata.CustomMetadata vendorMetadata = new Metadata.CustomMetadata();
        vendorMetadata.label = vendorName;
        vendorMetadata.fullName = 'Integration_Vendor__mdt.' + apiName;


        for (String key: vendoInfo.keySet()) {
            Metadata.CustomMetadataValue vendorVal = new Metadata.CustomMetadataValue();
            vendorVal.field = key;
            vendorVal.value = vendoInfo.get(key);
            vendorMetadata.values.add(vendorVal);
        }

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(vendorMetadata);
        SaddleRockMetadataCallback callback = new SaddleRockMetadataCallback();
        if(!Test.isRunningTest()){
            Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }

    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}