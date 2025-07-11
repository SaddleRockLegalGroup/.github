public without sharing class SaddleRockSyncHandler extends SaddleRockMappingHelper {
    public Map<string,object> SaddleRockSyncHandler(string integrationId, List<Map<String, Object>> data) {
        System.debug('SaddleRockSyncHandler started');
        Integration__mdt[] configs = new Integration__mdt[]{};
        
        if(Test.isRunningTest()){
            Integration__mdt testIntegration = SaddleRockTestDataFactory.generateTestIntegration();
            configs.add(testIntegration);
        }
        else {
            configs = [SELECT Id, Name__c, Log_Level__c, Log_Days_to_Keep__c, Debugging__c, Active__c, Base_SObject__r.QualifiedApiName, Sync_Date_Field__c 
                                    FROM Integration__mdt 
                                    WHERE Id = :integrationId AND Active__c = true 
                                    LIMIT 1];
        }

        SObject[] recordsToUpdate = new SObject[]{};
        SaddleRockUtils.integrationId = Test.isRunningTest() ? configs[0].Id : integrationId;

        try {
            recordsToUpdate = jsonToRecords(integrationId, configs[0].Base_SObject__r.QualifiedApiName, configs[0].Sync_Date_Field__c, data);
        
            System.debug(recordsToUpdate);

            if(recordsToUpdate != null && recordsToUpdate.size() > 0){
                update recordsToUpdate;
            }
            return new Map<string,object>{
                'success' => true,
                'data' => 'OK'
            };
        }
        catch(Exception e){
            return new Map<string,object>{
                'success' => false,
                'data' => e.getMessage()
            };
        }
    }
}