public with sharing class DynamicQuestionsController {
    
    // --- Helper: Validate object API name ---
    private static void validateObjectApiName(String objectApiName) {
        if (String.isBlank(objectApiName) || !Schema.getGlobalDescribe().containsKey(objectApiName)) {
            throw new AuraHandledException('Invalid object API name: ' + objectApiName);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getMultiLookupRecords(String objectName) {
        System.debug('getMultiLookupRecords method called with objectName: ' + objectName);

        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Object name cannot be blank.');
        }

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        if (sObjectType == null) {
            throw new AuraHandledException('Invalid object name: ' + objectName);
        }
        
        return Database.query('SELECT Id, Name FROM ' + objectName + ' LIMIT 100');
    }

    // --- Retrieve lookup records based on search input or ID list ---
    @AuraEnabled(cacheable=true)
    public static List<SObject> fetchLookupData(String searchKey, String objectApiName, List<Id> recordIds) {
        validateObjectApiName(objectApiName);
    
        if (recordIds != null && !recordIds.isEmpty()) {
            return Database.query('SELECT Id, Name FROM ' + objectApiName + ' WHERE Id IN :recordIds');
        }
    
        if (!String.isBlank(searchKey)) {
            String key = '%' + searchKey + '%';
            return Database.query('SELECT Id, Name FROM ' + objectApiName + ' WHERE Name LIKE :key ORDER BY Name LIMIT 100');
        }
    
        // No input provided — return nothing
        return new List<SObject>();
    }
    
    // --- Fetch single lookup record by Id ---
    @AuraEnabled(cacheable=true)
    public static SObject fetchLookupRecordById(String recordId, String objectApiName) {
        if (String.isBlank(recordId) || String.isBlank(objectApiName)) {
            throw new AuraHandledException('recordId and objectApiName are required.');
        }

        validateObjectApiName(objectApiName);

        String query = 'SELECT Id, Name FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
        List<SObject> results = Database.query(query);
        return results.isEmpty() ? null : results[0];
    }

    @AuraEnabled
    public static void updateAnswer(String answerId, String answerValue) {
        if (String.isBlank(answerId)) {
            throw new AuraHandledException('Answer ID cannot be blank.');
        }

        try {
            Answer__c answerRecord = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answerId LIMIT 1];
            answerRecord.Answer__c = answerValue == '****' ? '****' : answerValue; // Save only masked value for Encrypted type
            update answerRecord;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating Answer__c record: ' + e.getMessage());
        }
    }
}