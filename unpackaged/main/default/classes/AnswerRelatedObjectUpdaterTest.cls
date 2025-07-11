@isTest
private class AnswerRelatedObjectUpdaterTest {

    @TestSetup
    static void setup() {
        Account acct = new Account(Name = 'Eval Account', litify_pm__First_Name__c = 'Test', litify_pm__Last_Name__c = 'Party', litify_pm__Phone_Home__c = '555-555-5555', litify_pm__Email__c = 'test@example.com');
        insert acct;
        
        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(Name = 'CT', litify_pm__Is_Available__c = true);
        insert caseType;

        litify_pm__Intake__c intake = new litify_pm__Intake__c(litify_pm__Client__c = acct.Id, Test_Intake__c = true, litify_pm__Case_Type__c = caseType.Id);
        insert intake;

        Questionnaire__c questionnaire = new Questionnaire__c(Case_Type__c = caseType.Id, isActive__c = true, isAvailable__c = true);
        insert questionnaire;
        
        Questionnaire_Section__c section = new Questionnaire_Section__c(Name = 'Section', Questionnaire__c = questionnaire.Id, Section_Category__c = 'Short Form');
        insert section;

        Questionnaire_Question__c question = new Questionnaire_Question__c(Questionnaire_Section__c = section.Id, Questionnaire__c = questionnaire.Id);
        insert question;

        Answer__c answer = new Answer__c(Questionnaire_Question__c = question.Id, Intake__c = intake.Id);
        insert answer;

        // Create multiple Campaign_Case__c records with Intake__c
        List<srlg_Emergency_Contact__c> econtacts = new List<srlg_Emergency_Contact__c>{
            new srlg_Emergency_Contact__c(Intake__c = intake.Id, First_Name__c = 'One', Last_Name__c = 'Contact', Phone__c = '111-111-1111', Relationship__c = 'Sibling'),
            new srlg_Emergency_Contact__c(Intake__c = intake.Id, First_Name__c = 'Two', Last_Name__c = 'Contact', Phone__c = '222-222-2222', Relationship__c = 'Parent')
        };
        insert econtacts;
    }

    @isTest
    static void testAccountValuePulledIntoAnswer() {
        Answer__c answer = [SELECT Id FROM Answer__c LIMIT 1];
        litify_pm__Intake__c intake = [SELECT Id FROM litify_pm__Intake__c LIMIT 1];
        String acctFirstName = [SELECT litify_pm__First_Name__c FROM Account LIMIT 1].litify_pm__First_Name__c;

        Test.startTest();
        AnswerRelatedObjectUpdater.Request req = new AnswerRelatedObjectUpdater.Request();
        req.answerId = answer.Id;
        req.intakeId = intake.Id;
        req.objectName = 'Account';
        req.fieldName = 'litify_pm__First_Name__c';
        req.lookupObjectName = null;
        AnswerRelatedObjectUpdater.updateAnswers(new List<AnswerRelatedObjectUpdater.Request>{ req });
        Test.stopTest();

        Answer__c updated = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals('Test', updated.Answer__c);
    }

    @isTest
    static void testSkipUpdateWhenValueIsNull() {
        Answer__c answer = [SELECT Id FROM Answer__c LIMIT 1];
        litify_pm__Intake__c intake = [SELECT Id FROM litify_pm__Intake__c LIMIT 1];

        answer.Answer__c = 'Pre-existing value';
        update answer;

        Account acct = [SELECT Id, litify_pm__Email__c FROM Account LIMIT 1];
        acct.litify_pm__Email__c = null;
        update acct;

        Test.startTest();
        AnswerRelatedObjectUpdater.Request req = new AnswerRelatedObjectUpdater.Request();
        req.answerId = answer.Id;
        req.intakeId = intake.Id;
        req.objectName = 'Account';
        req.fieldName = 'litify_pm__Email__c';
        req.lookupObjectName = null;
        AnswerRelatedObjectUpdater.updateAnswers(new List<AnswerRelatedObjectUpdater.Request>{ req });
        Test.stopTest();

        Answer__c updated = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals('Pre-existing value', updated.Answer__c);
    }

    @isTest
    static void testCustomObjectWithIntakeLookup() {
        litify_pm__Intake__c intake = [SELECT Id FROM litify_pm__Intake__c LIMIT 1];
        Questionnaire_Question__c question = [SELECT Id FROM Questionnaire_Question__c LIMIT 1];

        srlg_Emergency_Contact__c emergency = [SELECT Phone__c FROM srlg_Emergency_Contact__c WHERE Intake__c = :intake.Id LIMIT 1];

        Answer__c answer = new Answer__c(
            Intake__c = intake.Id,
            Questionnaire_Question__c = question.Id
        );
        insert answer;

        Test.startTest();
        AnswerRelatedObjectUpdater.Request req = new AnswerRelatedObjectUpdater.Request();
        req.answerId = answer.Id;
        req.intakeId = intake.Id;
        req.objectName = 'srlg_Emergency_Contact__c';
        req.fieldName = 'Phone__c';
        req.lookupObjectName = null;
        AnswerRelatedObjectUpdater.updateAnswers(new List<AnswerRelatedObjectUpdater.Request>{ req });
        Test.stopTest();

        Answer__c updated = [SELECT Answer__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals(emergency.Phone__c, updated.Answer__c);
    }

    @isTest
    static void testIntakeObjectLookup() {
        Answer__c answer = [SELECT Id FROM Answer__c LIMIT 1];
        litify_pm__Intake__c intake = [SELECT Id, litify_pm__Phone__c FROM litify_pm__Intake__c LIMIT 1];

        Test.startTest();
        AnswerRelatedObjectUpdater.Request req = new AnswerRelatedObjectUpdater.Request();
        req.answerId = answer.Id;
        req.intakeId = intake.Id;
        req.objectName = 'litify_pm__Intake__c';
        req.fieldName = 'litify_pm__Phone__c';
        req.lookupObjectName = null;
        AnswerRelatedObjectUpdater.updateAnswers(new List<AnswerRelatedObjectUpdater.Request>{ req });
        Test.stopTest();

        Answer__c updated = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals(intake.litify_pm__Phone__c, updated.Answer__c);
    }

    @isTest
    static void testLookupObjectReturnsCSV() {
        Answer__c answer = [SELECT Id FROM Answer__c LIMIT 1];
        litify_pm__Intake__c intake = [SELECT Id FROM litify_pm__Intake__c LIMIT 1];
        List<srlg_Emergency_Contact__c> eCons = [SELECT Id FROM srlg_Emergency_Contact__c WHERE Intake__c = :intake.Id];

        Test.startTest();
        AnswerRelatedObjectUpdater.Request req = new AnswerRelatedObjectUpdater.Request();
        req.answerId = answer.Id;
        req.intakeId = intake.Id;
        req.objectName = null;
        req.fieldName = null;
        req.lookupObjectName = 'srlg_Emergency_Contact__c';
        AnswerRelatedObjectUpdater.updateAnswers(new List<AnswerRelatedObjectUpdater.Request>{ req });
        Test.stopTest();

        Answer__c updated = [SELECT Id, Answer__c FROM Answer__c WHERE Id = :answer.Id];
        List<String> idsInAnswer = updated.Answer__c != null ? updated.Answer__c.split(',') : new List<String>();
        System.assertEquals(eCons.size(), idsInAnswer.size(), 'Answer__c should contain all related record Ids in CSV');
    }
}