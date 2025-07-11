/**
 * @description       : Unit tests for DynamicAnswerCriteriaEvaluator
 * @group             : Questionnaire
 * @last modified on  : 2025-05-12
 * @last modified by  : Jacob Barnett - SaltClick
**/
@IsTest
public class DynamicAnswerCriteriaEvaluatorTest {

    private static Account createTestAccount() {
        Account acct = new Account(
            Name = 'Test Account',
            litify_pm__Last_Name__c = 'Test Last',
            litify_pm__Phone_Home__c = '555-123-4567',
            NumberOfEmployees = 10,
            Intake_Client_Count__c = 1
        );
        insert acct;
        return acct;
    }

    private static litify_pm__Case_Type__c createTestCaseType() {
        litify_pm__Case_Type__c ct = new litify_pm__Case_Type__c(
            Name = 'Test Case Type',
            litify_pm__Is_Available__c = true
        );
        insert ct;
        return ct;
    }

    private static litify_pm__Intake__c createTestIntake(Id acctId, Id caseTypeId) {
        litify_pm__Intake__c intake = new litify_pm__Intake__c(
            litify_pm__Client__c = acctId,
            litify_pm__Case_Type__c = caseTypeId,
            Test_Intake__c = true,
            Count_of_E_Sig_Documents__c = 10,
            Injured_Party_Birthdate__c = Date.today().addYears(-30),
            Date_Last_Modified_by_API__c = Datetime.now().addHours(-24)
        );
        insert intake;
        return intake;
    }

    private static Map<String, Id> createQuestionnaireWithSection(Id caseTypeId) {
        Questionnaire__c q = new Questionnaire__c(
            isActive__c = true,
            isAvailable__c = true,
            Case_Type__c = caseTypeId
        );
        insert q;

        Questionnaire_Section__c section = new Questionnaire_Section__c(
            Questionnaire__c = q.Id,
            Section_Category__c = 'Short Form'
        );
        insert section;

        return new Map<String, Id>{
            'questionnaireId' => q.Id,
            'sectionId' => section.Id
        };
    }

    @IsTest static void verifyFullEvaluationAgainstChildObject() {
        Account acct = createTestAccount();
        litify_pm__Case_Type__c caseType = createTestCaseType();
        litify_pm__Intake__c intake = createTestIntake(acct.Id, caseType.Id);
        Map<String, Id> ids = createQuestionnaireWithSection(caseType.Id);
        Id sectionId = ids.get('sectionId');
        Id questionnaireId = ids.get('questionnaireId');

        srlg_Injured_Party__c injuredParty = new srlg_Injured_Party__c(
            Intake__c = intake.Id,
            Date_Of_Birth__c = Date.today().addYears(-15),
            Date_Of_Death__c = Date.today().addYears(-1),
            First_Name__c = 'test first',
            Last_Name__c = 'test last'
        );
        insert injuredParty;

        List<Questionnaire_Question__c> questions = new List<Questionnaire_Question__c>{
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__r.srlg_Injured_Party__c',
                Conditional_Field__c = 'Date_Of_Death__c',
                Conditional_Operator__c = 'less or equals',
                Conditional_Value__c = String.valueOf(Date.today())
            ),
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__r.srlg_Injured_Party__c',
                Conditional_Field__c = 'Date_Of_Birth__c',
                Conditional_Operator__c = 'greater than',
                Conditional_Value__c = String.valueOf(Date.today().addYears(-20))
            ),
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__r.srlg_Injured_Party__c',
                Conditional_Field__c = 'Date_Of_Death__c',
                Conditional_Operator__c = 'greater or equals',
                Conditional_Value__c = String.valueOf(Date.today().addYears(-2))
            ),
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__r.srlg_Injured_Party__c',
                Conditional_Field__c = 'First_Name__c',
                Conditional_Operator__c = 'contains',
                Conditional_Value__c = 'test'
            ),
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__r.litify_pm__Client__c',
                Conditional_Field__c = 'NumberOfEmployees',
                Conditional_Operator__c = 'not equals',
                Conditional_Value__c = '0'
            ),
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__r.litify_pm__Client__c',
                Conditional_Field__c = 'Intake_Client_Count__c',
                Conditional_Operator__c = 'greater than',
                Conditional_Value__c = '0'
            )
        };
        insert questions;

        List<Answer__c> answers = new List<Answer__c>();
        for (Questionnaire_Question__c q : questions) {
            answers.add(new Answer__c(
                Intake__c = intake.Id,
                Questionnaire_Question__c = q.Id,
                Criteria_Met__c = false
            ));
        }
        insert answers;

        DynamicAnswerCriteriaEvaluator.InputWrapper wrapper = new DynamicAnswerCriteriaEvaluator.InputWrapper();
        wrapper.intakeId = intake.Id;
        wrapper.sectionId = sectionId;

        Test.startTest();
        DynamicAnswerCriteriaEvaluator.evaluateAndCommit(new List<DynamicAnswerCriteriaEvaluator.InputWrapper>{ wrapper });
        Test.stopTest();

        List<Answer__c> updated = [
            SELECT Id, Criteria_Met__c FROM Answer__c WHERE Id IN :answers
        ];

        for (Answer__c a : updated) {
            System.assertEquals(true, a.Criteria_Met__c, 'Expected Criteria_Met__c to be true');
        }
    }

    @IsTest static void verifyDatetimeAndBooleanConditionPasses() {
        Account acct = createTestAccount();
        litify_pm__Case_Type__c caseType = createTestCaseType();
        litify_pm__Intake__c intake = createTestIntake(acct.Id, caseType.Id);
        Map<String, Id> ids = createQuestionnaireWithSection(caseType.Id);
        Id sectionId = ids.get('sectionId');
        Id questionnaireId = ids.get('questionnaireId');
    
        // Datetime in intake is now -24 hours. We compare to a time -7 days ago, so it should pass
        List<Questionnaire_Question__c> questions = new List<Questionnaire_Question__c>{
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__c',
                Conditional_Field__c = 'Date_Last_Modified_by_API__c',
                Conditional_Operator__c = 'greater than',
                Conditional_Value__c = Datetime.now().addDays(-7).formatGmt('yyyy-MM-dd HH:mm:ss')
        	),
            new Questionnaire_Question__c(
                Questionnaire_Section__c = sectionId,
                Questionnaire__c = questionnaireId,
                Conditional_Object__c = 'Intake__c',
                Conditional_Field__c = 'Test_Intake__c',
                Conditional_Operator__c = 'equals',
                Conditional_Value__c = 'true'
        	)
        };
        insert questions;
    
        List<Answer__c> answers = new List<Answer__c>();
        for (Questionnaire_Question__c q : questions) {
            answers.add(new Answer__c(
                Intake__c = intake.Id,
                Questionnaire_Question__c = q.Id,
                Criteria_Met__c = false
            ));
        }
        insert answers;
    
        DynamicAnswerCriteriaEvaluator.InputWrapper wrapper = new DynamicAnswerCriteriaEvaluator.InputWrapper();
        wrapper.intakeId = intake.Id;
        wrapper.sectionId = sectionId;
    
        Test.startTest();
        DynamicAnswerCriteriaEvaluator.evaluateAndCommit(new List<DynamicAnswerCriteriaEvaluator.InputWrapper>{ wrapper });
        Test.stopTest();
    
        List<Answer__c> updated = [
            SELECT Id, Criteria_Met__c FROM Answer__c WHERE Id IN :answers
        ];

        for (Answer__c a : updated) {
            System.assertEquals(true, a.Criteria_Met__c, 'Expected Criteria_Met__c to be true');
        }
    }
    
    @IsTest static void verifyDatetimeConditionFails() {
        Account acct = createTestAccount();
        litify_pm__Case_Type__c caseType = createTestCaseType();
        litify_pm__Intake__c intake = createTestIntake(acct.Id, caseType.Id);
        Map<String, Id> ids = createQuestionnaireWithSection(caseType.Id);
        Id sectionId = ids.get('sectionId');
        Id questionnaireId = ids.get('questionnaireId');
    
        // Compare to now — but intake datetime is 24 hours ago, so it should fail
        Questionnaire_Question__c question = new Questionnaire_Question__c(
            Questionnaire_Section__c = sectionId,
            Questionnaire__c = questionnaireId,
            Conditional_Object__c = 'Intake__c',
            Conditional_Field__c = 'Date_Last_Modified_by_API__c',
            Conditional_Operator__c = 'greater than',
            Conditional_Value__c = Datetime.now().formatGmt('yyyy-MM-dd HH:mm:ss')
        );
        insert question;
    
        Answer__c answer = new Answer__c(
            Intake__c = intake.Id,
            Questionnaire_Question__c = question.Id,
            Criteria_Met__c = true // intentionally set to true so we can verify it flips to false
        );
        insert answer;
    
        DynamicAnswerCriteriaEvaluator.InputWrapper wrapper = new DynamicAnswerCriteriaEvaluator.InputWrapper();
        wrapper.intakeId = intake.Id;
        wrapper.sectionId = sectionId;
    
        Test.startTest();
        DynamicAnswerCriteriaEvaluator.evaluateAndCommit(new List<DynamicAnswerCriteriaEvaluator.InputWrapper>{ wrapper });
        Test.stopTest();
    
        Answer__c result = [SELECT Criteria_Met__c FROM Answer__c WHERE Id = :answer.Id];
        System.assertEquals(false, result.Criteria_Met__c, 'Expected datetime condition to fail');
    }
    
    @IsTest static void verifyParentAccountNumberFieldCriteria() {
        Account acct = new Account(
            Name = 'Account with Counters',
            litify_pm__Last_Name__c = 'Test Last',
            litify_pm__Phone_Home__c = '555-999-8888',
            NumberOfEmployees = 50,
            Intake_Client_Count__c = 1
        );
        insert acct;
    
        litify_pm__Case_Type__c caseType = createTestCaseType();
        litify_pm__Intake__c intake = createTestIntake(acct.Id, caseType.Id);
        Map<String, Id> ids = createQuestionnaireWithSection(caseType.Id);
        Id sectionId = ids.get('sectionId');
        Id questionnaireId = ids.get('questionnaireId');
    
        // One equals, one greater than operator
        Questionnaire_Question__c q1 = new Questionnaire_Question__c(
            Questionnaire_Section__c = sectionId,
            Questionnaire__c = questionnaireId,
            Conditional_Object__c = 'Intake__r.litify_pm__Client__c',
            Conditional_Field__c = 'NumberOfEmployees',
            Conditional_Operator__c = 'not equals',
            Conditional_Value__c = '10'
        );
    
        Questionnaire_Question__c q2 = new Questionnaire_Question__c(
            Questionnaire_Section__c = sectionId,
            Questionnaire__c = questionnaireId,
            Conditional_Object__c = 'Intake__r.litify_pm__Client__c',
            Conditional_Field__c = 'Intake_Client_Count__c',
            Conditional_Operator__c = 'greater than',
            Conditional_Value__c = '0'
        );
    
        insert new List<Questionnaire_Question__c>{ q1, q2 };
    
        List<Answer__c> answers = new List<Answer__c>{
            new Answer__c(Intake__c = intake.Id, Questionnaire_Question__c = q1.Id, Criteria_Met__c = false),
            new Answer__c(Intake__c = intake.Id, Questionnaire_Question__c = q2.Id, Criteria_Met__c = false)
        };
        insert answers;
    
        DynamicAnswerCriteriaEvaluator.InputWrapper wrapper = new DynamicAnswerCriteriaEvaluator.InputWrapper();
        wrapper.intakeId = intake.Id;
        wrapper.sectionId = sectionId;
    
        Test.startTest();
        DynamicAnswerCriteriaEvaluator.evaluateAndCommit(new List<DynamicAnswerCriteriaEvaluator.InputWrapper>{ wrapper });
        Test.stopTest();
    
        Map<Id, Answer__c> updated = new Map<Id, Answer__c>([
            SELECT Id, Criteria_Met__c FROM Answer__c WHERE Id IN :answers
        ]);
    
        System.assertEquals(true, updated.get(answers[0].Id).Criteria_Met__c, 'Caller Count should not equal 10');
        System.assertEquals(true, updated.get(answers[1].Id).Criteria_Met__c, 'Client Count should be greater than 0');
    }
}