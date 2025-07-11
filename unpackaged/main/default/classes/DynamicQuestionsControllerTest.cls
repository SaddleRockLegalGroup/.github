@IsTest
public with sharing class DynamicQuestionsControllerTest {

    @TestSetup
    static void setup() {
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                litify_pm__Last_Name__c = 'Last Name ' + i,
                litify_pm__Phone_Home__c = '123-456-789' + i
            ));
        }
        insert accounts;

        // Create Case Type
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(
            Name = 'Test Case Type',
            litify_pm__Is_Available__c = true
        );
        insert caseType;

        // Create Questionnaire
        Questionnaire__c questionnaire = new Questionnaire__c(
            isActive__c = true,
            isAvailable__c = true,
            Case_Type__c = caseType.Id
        );
        insert questionnaire;

        // Create Section
        Questionnaire_Section__c section = new Questionnaire_Section__c(
            Name = 'Section A',
            Questionnaire__c = questionnaire.Id,
            Section_Category__c = 'Short Form'
        );
        insert section;
        
        // Create Question (no conditional logic)
        Questionnaire_Question__c question = new Questionnaire_Question__c(
            Questionnaire_Section__c = section.Id,
            Questionnaire__c = questionnaire.Id
        );
        insert question;

        // Create Intake
        litify_pm__Intake__c intake = new litify_pm__Intake__c(
            litify_pm__Client__c = accounts[0].Id,
            litify_pm__Case_Type__c = caseType.Id,
            Calling_on_behalf_of_you_or_loved_one__c = 'Self'
        );
        insert intake;

        // Create Answer__c records linked to Intake and Section
        List<Answer__c> answers = new List<Answer__c>();
        for (Integer i = 0; i < 5; i++) {
            answers.add(new Answer__c(
                Intake__c = intake.Id,
                Questionnaire_Question__c = question.Id,
                Answer__c = 'Initial Value ' + i
            ));
        }
        insert answers;
    }
 
    @IsTest
    static void testGetMultiLookupRecords() {
        // Test the getMultiLookupRecords method
        Test.startTest();
        List<SObject> results = DynamicQuestionsController.getMultiLookupRecords('Account');
        Test.stopTest();

        // Assert the results
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(10, results.size(), 'Results should contain 10 records');
    }

    @IsTest
    static void testUpdateAnswer() {
        // Get an existing Answer__c record
        Answer__c answer = [SELECT Id, Answer__c FROM Answer__c LIMIT 1];
        String newValue = 'Updated Value';

        // Test the updateAnswer method
        Test.startTest();
        DynamicQuestionsController.updateAnswer(answer.Id, newValue);
        Test.stopTest();

        // Verify the update
        Answer__c updatedAnswer = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals(newValue, updatedAnswer.Answer__c, 'Answer__c field should be updated');
    }

    @IsTest
    static void testUpdateEncryptedAnswer() {
        // Get an existing Answer__c record
        Answer__c answer = [SELECT Id, Answer__c FROM Answer__c LIMIT 1];
        String encryptedValue = '****';

        // Test the updateAnswer method for Encrypted type
        Test.startTest();
        DynamicQuestionsController.updateAnswer(answer.Id, encryptedValue);
        Test.stopTest();

        // Verify the update
        Answer__c updatedAnswer = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals(encryptedValue, updatedAnswer.Answer__c, 'Answer__c field should be updated with **** for Encrypted type');
    }
    
    @IsTest
    static void testGetMultiLookupRecords_BlankObjectName() {
        Test.startTest();
        try {
            DynamicQuestionsController.getMultiLookupRecords('');
            System.assert(false, 'Expected AuraHandledException for blank object name');
        } catch (AuraHandledException e) {
            System.debug('Caught expected AuraHandledException');
            Test.stopTest();
            return;
        }
        Test.stopTest();
        System.assert(false, 'Expected exception but none was thrown');
    }
    
    @IsTest
    static void testFetchLookupData_WithSearchKey() {
        Account acc=[Select Id, Name, litify_pm__Last_Name__c from Account where litify_pm__Last_Name__c='Last Name 0' limit 1];
        List<Id> accIds=new List<Id>();
        accIds.add(acc.Id);
        List<SObject> results = DynamicQuestionsController.fetchLookupData('', 'Account',accIds);
        System.debug('FetchLookupData results: ' + results);
        System.assert(!results.isEmpty(), 'Should return at least one matching record');
        System.assertEquals('Last Name 0', (String)results[0].get('Name'));
    }
    
    @IsTest
    static void testFetchLookupRecordById_Valid() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SObject result = DynamicQuestionsController.fetchLookupRecordById(acc.Id, 'Account');
        System.assertNotEquals(null, result, 'Should return a matching record');
    }
    
    @IsTest
    static void testFetchLookupRecordById_BlankInputs() {
        Test.startTest();
        try {
            DynamicQuestionsController.fetchLookupRecordById('', '');
            System.assert(false, 'Expected AuraHandledException for missing inputs');
        } catch (AuraHandledException e) {
            System.debug('Caught expected AuraHandledException');
            Test.stopTest();
            return;
        }
        Test.stopTest();
        System.assert(false, 'Expected exception but none was thrown');
    }

    @IsTest
    static void testUpdateAnswer_InvalidId() {
        // Get a real answer and delete it
        Answer__c temp = [SELECT Id FROM Answer__c LIMIT 1];
        delete temp;
    
        Test.startTest();
        try {
            DynamicQuestionsController.updateAnswer(temp.Id, 'Should Fail');
            System.assert(false, 'Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.debug('Caught expected AuraHandledException');
            return; // ✅ Do not assert message — Salesforce masks it as "Script-thrown exception"
        }
        Test.stopTest();
        System.assert(false, 'Expected exception but none was thrown');
    }
}