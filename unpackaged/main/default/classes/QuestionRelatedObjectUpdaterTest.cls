@isTest
public class QuestionRelatedObjectUpdaterTest {

    // Happy path test for direct Intake field update
    @isTest
    static void testUpdateCallingOnBehalfOfField() {
        Account acct = new Account(
            Name = 'Test Account',
            litify_pm__Last_Name__c = 'Last Name',
            litify_pm__Phone_Home__c = '123-456-789'
        );
        insert acct;

        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(
            Name = 'Test Case Type',
            litify_pm__Is_Available__c = true
        );
        insert caseType;

        litify_pm__Intake__c intake = new litify_pm__Intake__c(
            litify_pm__Client__c = acct.Id,
            Test_Intake__c = true,
            litify_pm__Case_Type__c = caseType.Id,
            Calling_on_behalf_of_you_or_loved_one__c = 'Self'
        );
        insert intake;

        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'litify_pm__Intake__c';
        req.intakeId = intake.Id;
        req.fieldName = 'Calling_on_behalf_of_you_or_loved_one__c';
        req.newValue = 'Loved one';

        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();

        intake = [
            SELECT Calling_on_behalf_of_you_or_loved_one__c
            FROM litify_pm__Intake__c
            WHERE Id = :intake.Id
        ];
        System.assertEquals('Loved one', intake.Calling_on_behalf_of_you_or_loved_one__c);
    }

    // Unsupported object
    @isTest
    static void testUnsupportedObjectName() {
        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'Does_Not_Exist__c';
        req.intakeId = '001000000000001';
        req.fieldName = 'Fake_Field__c';
        req.newValue = 'Some Value';

        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    }

    // Object without Intake lookup
    @isTest
    static void testObjectWithoutIntakeLookup() {
        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'Task';
        req.intakeId = '001000000000002';
        req.fieldName = 'Subject';
        req.newValue = 'New Subject';

        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    }

    // Invalid field name
    @isTest
    static void testInvalidFieldName() {
        Account acct = new Account(
            Name='Invalid Field Test',
            litify_pm__Last_Name__c='Doe',
            litify_pm__Phone_Home__c='123'
        );
        insert acct;

        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(Name='Test', litify_pm__Is_Available__c=true);
        insert caseType;

        litify_pm__Intake__c intake = new litify_pm__Intake__c(litify_pm__Client__c=acct.Id, Test_Intake__c = true, litify_pm__Case_Type__c=caseType.Id);
        insert intake;

        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'litify_pm__Intake__c';
        req.intakeId = intake.Id;
        req.fieldName = 'DoesNotExist__c';
        req.newValue = 'Oops';

        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    }

    // Invalid Id format
    @isTest
    static void testInvalidIntakeIdFormat() {
        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'litify_pm__Intake__c';
        req.intakeId = 'notAnId';
        req.fieldName = 'Calling_on_behalf_of_you_or_loved_one__c';
        req.newValue = 'Self';

        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    }

    // Valid ID format, but no matching records
    @isTest
    static void testNoMatchingRecords() {
        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'litify_pm__Intake__c';
        req.intakeId = '001000000000003';
        req.fieldName = 'Calling_on_behalf_of_you_or_loved_one__c';
        req.newValue = 'Self';

        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    }

    // Bulk updates for valid requests
    @isTest
    static void testBulkRequests() {
        Account acct = new Account(
            Name='Bulk Account',
            litify_pm__Last_Name__c='Smith',
            litify_pm__Phone_Home__c='555-555-5555'
        );
        insert acct;
    
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(Name='Bulk Case', litify_pm__Is_Available__c=true);
        insert caseType;
    
        litify_pm__Intake__c intake1 = new litify_pm__Intake__c(litify_pm__Client__c=acct.Id, Test_Intake__c = true, litify_pm__Case_Type__c=caseType.Id);
        litify_pm__Intake__c intake2 = new litify_pm__Intake__c(litify_pm__Client__c=acct.Id, Test_Intake__c = true, litify_pm__Case_Type__c=caseType.Id);
        insert new List<litify_pm__Intake__c>{intake1, intake2};
    
        QuestionRelatedObjectUpdater.Request req1 = new QuestionRelatedObjectUpdater.Request();
        req1.objectName = 'litify_pm__Intake__c';
        req1.intakeId = intake1.Id;
        req1.fieldName = 'Calling_on_behalf_of_you_or_loved_one__c';
        req1.newValue = 'Self';
    
        QuestionRelatedObjectUpdater.Request req2 = new QuestionRelatedObjectUpdater.Request();
        req2.objectName = 'litify_pm__Intake__c';
        req2.intakeId = intake2.Id;
        req2.fieldName = 'Calling_on_behalf_of_you_or_loved_one__c';
        req2.newValue = 'Loved one';
    
        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req1, req2 });
        Test.stopTest();
    
        List<litify_pm__Intake__c> updated = [
            SELECT Id, Calling_on_behalf_of_you_or_loved_one__c
            FROM litify_pm__Intake__c
            WHERE Id IN :new List<Id>{intake1.Id, intake2.Id}
        ];
        System.assertEquals('Self', updated[0].Calling_on_behalf_of_you_or_loved_one__c);
        System.assertEquals('Loved one', updated[1].Calling_on_behalf_of_you_or_loved_one__c);
    }
    
    @isTest
    static void testUpdateAccountViaIntake() {
        // Create Account with required fields
        Account acct = new Account(
            Name = 'Account Parent',
            litify_pm__Last_Name__c = 'Parent Last',
            litify_pm__Email__c = 'original@example.com',
            litify_pm__Phone_Home__c = '111-222-3333'
        );
        insert acct;
    
        // Create Case Type
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(
            Name = 'Account Update Case Type',
            litify_pm__Is_Available__c = true
        );
        insert caseType;
    
        // Create Intake with lookup to Account
        litify_pm__Intake__c intake = new litify_pm__Intake__c(
            litify_pm__Client__c = acct.Id,
            Test_Intake__c = true,
            litify_pm__Case_Type__c = caseType.Id
        );
        insert intake;
    
        // Request to update Account.litify_pm__Email__c via Intake.Id
        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'Account';
        req.intakeId = intake.Id;
        req.fieldName = 'litify_pm__Email__c';
        req.newValue = 'updated@example.com';
    
        // Run the updater
        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    
        // Assert the Account email was updated
        acct = [SELECT litify_pm__Email__c FROM Account WHERE Id = :acct.Id];
        System.assertEquals('updated@example.com', acct.litify_pm__Email__c,
            'Account email should have been updated');
    }
    
    @isTest
    static void testUpdateAdditionalCaseDetails() {
        // Create Account with required fields
        Account acct = new Account(
            Name = 'Account Parent',
            litify_pm__Last_Name__c = 'Parent Last',
            litify_pm__Email__c = 'original@example.com',
            litify_pm__Phone_Home__c = '111-222-3333'
        );
        insert acct;
    
        // Create Case Type
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(
            Name = 'Account Update Case Type',
            litify_pm__Is_Available__c = true
        );
        insert caseType;
    
        // Create Intake with lookup to Account
        litify_pm__Intake__c intake = new litify_pm__Intake__c(
            litify_pm__Client__c = acct.Id,
            Test_Intake__c = true,
            litify_pm__Case_Type__c = caseType.Id
        );
        insert intake;
        
        // Create Additional Case Details with lookup to Intake
        srlg_Alternative_Cause_Detail__c addtlCase = new srlg_Alternative_Cause_Detail__c(
            Intake__c = intake.Id
        );
        insert addtlCase;
    
        // Request to update srlg_Alternative_Cause_Detail__c.dxWeight__c via Intake__c
        QuestionRelatedObjectUpdater.Request req = new QuestionRelatedObjectUpdater.Request();
        req.objectName = 'srlg_Alternative_Cause_Detail__c';
        req.intakeId = intake.Id;
        req.fieldName = 'dxWeight__c';
        req.newValue = '180';
    
        // Run the updater
        Test.startTest();
        QuestionRelatedObjectUpdater.updateField(new List<QuestionRelatedObjectUpdater.Request>{ req });
        Test.stopTest();
    
        // Assert the Account email was updated
        addtlCase = [SELECT dxWeight__c FROM srlg_Alternative_Cause_Detail__c WHERE Id = :addtlCase.Id];
        System.assertEquals(180, addtlCase.dxWeight__c, 'Weight should be 180');
    }
}