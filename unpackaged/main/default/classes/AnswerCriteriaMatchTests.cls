@IsTest
public class AnswerCriteriaMatchTests {
    
    static final Datetime FIXED_DATETIME = Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0);
    static final String FIXED_DATETIME_STRING = FIXED_DATETIME.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

    static litify_pm__Intake__c createTestIntake() {
        Account acct = new Account(
            Name = 'Test Account',
            litify_pm__Last_Name__c = 'Test Last',
            litify_pm__Phone_Home__c = '555-123-4567'
        );
        insert acct;

        litify_pm__Case_Type__c caseType = new litify_pm__Case_Type__c(Name = 'QACaseType', litify_pm__Is_Available__c = true);
        insert caseType;

        litify_pm__Intake__c intake = new litify_pm__Intake__c(
            litify_pm__Client__c = acct.Id,
            litify_pm__Case_Type__c = caseType.Id,
            Count_of_E_Sig_Documents__c = 10,
            Allow_email_send__c = true,
            Injured_Party_Birthdate__c = Date.newInstance(2024, 1, 1),
            Date_Last_Modified_by_API__c = FIXED_DATETIME,
            Campaign_Partner_Packet_Name__c = 'Test Campaign'
        );

        insert intake;

        return intake;
    }

    static void runMatchTest(String field, String op, String val, String type) {
        litify_pm__Intake__c intake = createTestIntake();

        Questionnaire__c questionnaire = new Questionnaire__c(
            Case_Type__c = intake.litify_pm__Case_Type__c,
            isActive__c = true,
            isAvailable__c = true
        );
        insert questionnaire;

        Questionnaire_Section__c section = new Questionnaire_Section__c(
            Name = 'QA Section',
            Questionnaire__c = questionnaire.Id,
            Section_Category__c = 'Short Form',
            Conditional_Object__c = 'litify_pm__Intake__c',
            Conditional_Field__c = field,
            Conditional_Operator__c = op,
            Conditional_Value__c = val
        );
        insert section;

        Questionnaire_Question__c question = new Questionnaire_Question__c(
            Questionnaire__c = questionnaire.Id,
            Questionnaire_Section__c = section.Id
        );
        insert question;

        Answer__c answer = new Answer__c(
            Questionnaire_Question__c = question.Id,
            Intake__c = intake.Id,
            Criteria_Met__c = false
        );
        insert answer;

        DynamicAnswerCriteriaEvaluator.InputWrapper wrapper = new DynamicAnswerCriteriaEvaluator.InputWrapper();
        wrapper.intakeId = intake.Id;
        wrapper.sectionId = section.Id;

        Test.startTest();
        DynamicAnswerCriteriaEvaluator.evaluateAndCommit(new List<DynamicAnswerCriteriaEvaluator.InputWrapper>{ wrapper });
        Test.stopTest();
    }

    // === BOOLEAN ===
    @IsTest static void testEqualsBoolean() {
        runMatchTest('Allow_email_send__c', 'equals', 'true', 'boolean');
    }
    @IsTest static void testNotEqualsBoolean() {
        runMatchTest('Allow_email_send__c', 'not equals', 'false', 'boolean');
    }

    // === NUMBER ===
    @IsTest static void testEqualsNumber() {
        runMatchTest('Count_of_E_Sig_Documents__c', 'equals', '10', 'number');
    }
    @IsTest static void testNotEqualsNumber() {
        runMatchTest('Count_of_E_Sig_Documents__c', 'not equals', '5', 'number');
    }
    @IsTest static void testLessThanNumber() {
        runMatchTest('Count_of_E_Sig_Documents__c', 'less than', '11', 'number');
    }
    @IsTest static void testLessOrEqualsNumber() {
        runMatchTest('Count_of_E_Sig_Documents__c', 'less or equals', '10', 'number');
    }
    @IsTest static void testGreaterThanNumber() {
        runMatchTest('Count_of_E_Sig_Documents__c', 'greater than', '9', 'number');
    }
    @IsTest static void testGreaterOrEqualsNumber() {
        runMatchTest('Count_of_E_Sig_Documents__c', 'greater or equals', '10', 'number');
    }

    // === DATE ===
    @IsTest static void testDateEquals() {
        runMatchTest('Injured_Party_Birthdate__c', 'equals', '2024-01-01', 'date');
    }
    @IsTest static void testDateNotEquals() {
        runMatchTest('Injured_Party_Birthdate__c', 'not equals', '2024-01-02', 'date');
    }
    @IsTest static void testDateLessThan() {
        runMatchTest('Injured_Party_Birthdate__c', 'less than', '2024-01-02', 'date');
    }
    @IsTest static void testDateLessOrEquals() {
        runMatchTest('Injured_Party_Birthdate__c', 'less or equals', '2024-01-01', 'date');
    }
    @IsTest static void testDateGreaterThan() {
        runMatchTest('Injured_Party_Birthdate__c', 'greater than', '2023-12-31', 'date');
    }
    @IsTest static void testDateGreaterOrEquals() {
        runMatchTest('Injured_Party_Birthdate__c', 'greater or equals', '2024-01-01', 'date');
    }

    // === DATETIME ===
    @IsTest static void testDateTimeEquals() {
        runMatchTest('Date_Last_Modified_by_API__c', 'equals', FIXED_DATETIME_STRING, 'datetime');
    }
    @IsTest static void testDateTimeNotEquals() {
        runMatchTest('Date_Last_Modified_by_API__c', 'not equals', FIXED_DATETIME_STRING, 'datetime');
    }
    @IsTest static void testDateTimeLessThan() {
        runMatchTest('Date_Last_Modified_by_API__c', 'less than', FIXED_DATETIME_STRING, 'datetime');
    }
    @IsTest static void testDateTimeLessOrEquals() {
        runMatchTest('Date_Last_Modified_by_API__c', 'less or equals', FIXED_DATETIME_STRING, 'datetime');
    }
    @IsTest static void testDateTimeGreaterThan() {
        runMatchTest('Date_Last_Modified_by_API__c', 'greater than', FIXED_DATETIME_STRING, 'datetime');
    }
    @IsTest static void testDateTimeGreaterOrEquals() {
        runMatchTest('Date_Last_Modified_by_API__c', 'greater or equals', FIXED_DATETIME_STRING, 'datetime');
    }

    // === STRING ===
    @IsTest static void testStringEquals() {
        runMatchTest('Campaign_Partner_Packet_Name__c', 'equals', 'Test Campaign', 'string');
    }
    @IsTest static void testStringNotEquals() {
        runMatchTest('Campaign_Partner_Packet_Name__c', 'not equals', 'Wrong Name', 'string');
    }
    @IsTest static void testStringStartsWith() {
        runMatchTest('Campaign_Partner_Packet_Name__c', 'starts with', 'Test', 'string');
    }
    @IsTest static void testStringEndsWith() {
        runMatchTest('Campaign_Partner_Packet_Name__c', 'ends with', 'Campaign', 'string');
    }
    @IsTest static void testStringContains() {
        runMatchTest('Campaign_Partner_Packet_Name__c', 'contains', 'ampa', 'string');
    }

    // ❌ Invalid operator for strings - fallback test (should return false and debug unsupported op)
    @IsTest static void testUnsupportedStringOperator() {
        runMatchTest('litify_pm__Client__r.Name', 'greater than', 'Aardvark', 'string');
    }
}