/**
 * @description       : Evaluates dynamic criteria for Answer__c records based on related Question and Section, filtered by IntakeId and SectionId.
 * @group             : Questionnaire
 * @last modified on  : 2025-04-15
 * @last modified by  : Jacob Barnett - SaltClick
**/
public class DynamicAnswerCriteriaEvaluator {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public Id intakeId;

        @InvocableVariable(required=true)
        public Id sectionId;
    }

    @InvocableMethod(label='Evaluate and Commit Answer Criteria')
    public static void evaluateAndCommit(List<InputWrapper> inputs) {
        if (inputs == null || inputs.isEmpty()) return;

        Id intakeId = inputs[0].intakeId;
        Id sectionId = inputs[0].sectionId;

        List<Answer__c> answers = [
            SELECT Id,
                   Criteria_Met__c,
                   Intake__c,
                   Questionnaire_Question__r.Questionnaire_Section__c,
                   Questionnaire_Question__r.Conditional_Object__c,
                   Questionnaire_Question__r.Conditional_Field__c,
                   Questionnaire_Question__r.Conditional_Operator__c,
                   Questionnaire_Question__r.Conditional_Value__c,
                   Questionnaire_Question__r.Questionnaire_Section__r.Conditional_Object__c,
                   Questionnaire_Question__r.Questionnaire_Section__r.Conditional_Field__c,
                   Questionnaire_Question__r.Questionnaire_Section__r.Conditional_Operator__c,
                   Questionnaire_Question__r.Questionnaire_Section__r.Conditional_Value__c,
                   Intake__r.litify_pm__Client__c,
                   Intake__r.Name
            FROM Answer__c
            WHERE Intake__c = :intakeId
              AND Questionnaire_Question__r.Questionnaire_Section__c = :sectionId
        ];

        List<Answer__c> toUpdate = new List<Answer__c>();

        for (Answer__c answer : answers) {
            Boolean isMatch = false;
            System.debug('🔍 Evaluating Answer: ' + answer.Id);

            try {
                Questionnaire_Question__c question = answer.Questionnaire_Question__r;
                Questionnaire_Section__c section = question != null ? question.Questionnaire_Section__r : null;

                Boolean hasQuestion = (
                    question != null &&
                    !String.isBlank(question.Conditional_Object__c) &&
                    !String.isBlank(question.Conditional_Field__c) &&
                    !String.isBlank(question.Conditional_Operator__c) &&
                    question.Conditional_Value__c != null
                );

                Boolean hasSection = (
                    section != null &&
                    !String.isBlank(section.Conditional_Object__c) &&
                    !String.isBlank(section.Conditional_Field__c) &&
                    !String.isBlank(section.Conditional_Operator__c) &&
                    section.Conditional_Value__c != null
                );

                System.debug('hasQuestionCriteria: ' + hasQuestion);
                System.debug('hasSectionCriteria: ' + hasSection);

                Boolean questionMatch = evaluateCriteriaFromObject(answer,
                    hasQuestion ? question.Conditional_Object__c : null,
                    hasQuestion ? question.Conditional_Field__c : null,
                    hasQuestion ? question.Conditional_Operator__c : null,
                    hasQuestion ? question.Conditional_Value__c : null
                );

                Boolean sectionMatch = evaluateCriteriaFromObject(answer,
                    hasSection ? section.Conditional_Object__c : null,
                    hasSection ? section.Conditional_Field__c : null,
                    hasSection ? section.Conditional_Operator__c : null,
                    hasSection ? section.Conditional_Value__c : null
                );

                if (hasQuestion && hasSection) {
                    isMatch = questionMatch && sectionMatch;
                } else if (hasQuestion) {
                    isMatch = questionMatch;
                } else if (hasSection) {
                    isMatch = sectionMatch;
                } else {
                    isMatch = true; // ✅ No criteria = auto-pass
                }

                System.debug('✅ Final isMatch result: ' + isMatch);

                if (answer.Criteria_Met__c != isMatch) {
                    toUpdate.add(new Answer__c(Id = answer.Id, Criteria_Met__c = isMatch));
                }

            } catch (Exception e) {
                System.debug('❌ Error evaluating answer ' + answer.Id + ': ' + e.getMessage());
                if (answer.Criteria_Met__c != false) {
                    toUpdate.add(new Answer__c(Id = answer.Id, Criteria_Met__c = false));
                }
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    private static Boolean evaluateCriteriaFromObject(
    SObject answer,
    String objectPath,
    String field,
    String op,
    String val
    ) {
        if (String.isBlank(objectPath) || String.isBlank(field) || String.isBlank(op) || val == null) return false;
    
        try {
            SObject intake = answer.getSObject('Intake__r');
            if (intake == null) {
                System.debug('❌ Intake__r is null for Answer ' + answer.Id);
                return false;
            }
    
            // Direct field on Intake object
            if (objectPath == 'litify_pm__Intake__c' || objectPath == 'Intake__c' || objectPath == 'Intake__r') {
                System.debug('👀 Evaluating intake field directly: ' + field);
                String intakeObjName = intake.getSObjectType().getDescribe().getName();
                Object fieldValue = getFieldWithFallback(intake, intakeObjName, field);
                System.debug('✅ Fallback field value: ' + fieldValue);
                return evaluateMatch(fieldValue, op, val);
            }

    
            // Parent Account via Intake__r.litify_pm__Client__r
            if (objectPath.startsWith('Intake__r.litify_pm__Client__c')) {
                System.debug('🏢 Evaluating Account (parent) field: ' + field);
            
                Id acctId = (Id) intake.get('litify_pm__Client__c');
                if (acctId == null) {
                    System.debug('⚠️ Intake.litify_pm__Client__c was null');
                    return false;
                }
            
                Schema.SObjectType objType = Schema.getGlobalDescribe().get('Account');
                Schema.SObjectField sf = objType.getDescribe().fields.getMap().get(field);
                Schema.DescribeFieldResult fieldDescribe = sf != null ? sf.getDescribe() : null;
            
                Object accountValue = getFieldWithFallback('Account', acctId, field, fieldDescribe);
                System.debug('🏢 Final Account field value for [' + field + ']: ' + accountValue);
            
                return evaluateMatch(accountValue, op, val);
            }
    
            // Dynamic child object off Intake (based on objectPath ending)
            if (objectPath.contains('.')) {
                String[] parts = objectPath.split('\\.');
                String childObject = parts.isEmpty() ? null : parts[parts.size() - 1];
                if (String.isBlank(childObject)) {
                    System.debug('❌ Unable to resolve child object from path: ' + objectPath);
                    return false;
                }
            
                String intakeLookupField = getIntakeLookupField(childObject);
                if (String.isBlank(intakeLookupField)) {
                    System.debug('❌ No Intake lookup found on ' + childObject);
                    return false;
                }
            
                Id intakeId = (Id) intake.get('Id');
                List<SObject> children = Database.query(
                    'SELECT Id, ' + field + ' FROM ' + childObject + ' WHERE ' + intakeLookupField + ' = :intakeId LIMIT 1'
                );
                if (children.isEmpty()) {
                    System.debug('⚠️ No matching child record found for ' + childObject);
                    return false;
                }
            
                Object fieldValue = getFieldWithFallback(children[0], childObject, field);
                return evaluateMatch(fieldValue, op, val);
            }
    
            System.debug('⚠️ No matching object path handler for: ' + objectPath);
            return false;
    
        } catch (Exception e) {
            System.debug('❌ Exception during field evaluation [' + objectPath + '.' + field + ']: ' + e.getMessage());
            return false;
        }
    }
    
    private static String getIntakeLookupField(String childObjectName) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(childObjectName);
        if (objType == null) return null;
    
        String intakeObjectName = Schema.getGlobalDescribe().get('litify_pm__Intake__c').getDescribe().getName();
    
        Map<String, Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
        for (String fieldName : fields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                for (Schema.SObjectType ref : fieldDescribe.getReferenceTo()) {
                    if (ref.getDescribe().getName() == intakeObjectName) {
                        return fieldName;
                    }
                }
            }
        }
        return null;
    }
    
    // Updated fallback method (overloaded)
    private static Object getFieldWithFallback(SObject record, String objectName, String field) {
        try {
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
            Schema.SObjectField sf = sObjType.getDescribe().fields.getMap().get(field);
            Schema.DescribeFieldResult describe = sf != null ? sf.getDescribe() : null;
            return getFieldWithFallback(objectName, (Id) record.get('Id'), field, describe);
        } catch (Exception e) {
            System.debug('❌ Error in getFieldWithFallback overload: ' + e.getMessage());
            return null;
        }
    }
    
    private static Object getFieldWithFallback(String objectName, Id recordId, String field, Schema.DescribeFieldResult fieldDescribe) {
        System.debug('🤩 getFieldWithFallback called for object=' + objectName + ', field=' + field);

        if (recordId == null || String.isBlank(field) || String.isBlank(objectName)) {
            System.debug('⚠️ Missing inputs — skipping fallback.');
            return null;
        }

        try {
            String query = 'SELECT ' + field + ' FROM ' + objectName + ' WHERE Id = :recordId';
            System.debug('📈 Executing fallback query: ' + query);
            SObject record = Database.query(query);
            Object fieldValue = record.get(field);

            if (fieldValue != null && fieldDescribe != null && fieldValue instanceof Datetime && fieldDescribe.getType() == Schema.DisplayType.Date) {
                System.debug('🕐 Converting Datetime to Date for field: ' + field);
                return ((Datetime) fieldValue).date();
            }

            System.debug('📤 Final fallback value for [' + field + ']: ' + fieldValue);
            return fieldValue;
        } catch (Exception e) {
            System.debug('❌ Fallback query failed: ' + e.getMessage());
            return null;
        }
    }

    private static Boolean evaluateMatch(Object fieldValue, String op, String val) {
        if (fieldValue == null || val == null) return false;

        String operator = op.toLowerCase().trim();
        String input = val.trim();
        
        // Normalize: If value looks like a date and fieldValue is a Datetime, convert to Date
        if (fieldValue instanceof Datetime && Pattern.matches('\\d{4}-\\d{2}-\\d{2}', input)) {
            fieldValue = ((Datetime) fieldValue).date();
        }

        // Boolean
        if (fieldValue instanceof Boolean) {
            System.debug('🧠 Type detected: Boolean');
            Boolean actual = (Boolean) fieldValue;
            Boolean expected = input.equalsIgnoreCase('true');
            return operator == 'equals' ? actual == expected
                 : operator == 'not equals' ? actual != expected : false;
        }

        // Number
        if (fieldValue instanceof Decimal || fieldValue instanceof Integer || fieldValue instanceof Long || fieldValue instanceof Double) {
            System.debug('🧠 Type detected: Decimal');
            Decimal actual = Decimal.valueOf(String.valueOf(fieldValue));
            Decimal expected;
            try { expected = Decimal.valueOf(input); } catch (Exception e) { return false; }
            if (operator == 'equals') return actual == expected;
            if (operator == 'not equals') return actual != expected;
            if (operator == 'less than') return actual < expected;
            if (operator == 'less or equals') return actual <= expected;
            if (operator == 'greater than') return actual > expected;
            if (operator == 'greater or equals') return actual >= expected;
        }

        // Date
        if (fieldValue instanceof Date) {
            try {
                System.debug('🧠 Type detected: Date');
                Date actual = (Date) fieldValue;
                Date expected = Date.valueOf(input);
                if (operator == 'equals') return actual == expected;
                if (operator == 'not equals') return actual != expected;
                if (operator == 'less than') return actual < expected;
                if (operator == 'less or equals') return actual <= expected;
                if (operator == 'greater than') return actual > expected;
                if (operator == 'greater or equals') return actual >= expected;
            } catch (Exception e) {
                return false;
            }
        }

        // DateTime
        if (fieldValue instanceof Datetime) {
            try {
                System.debug('🧠 Type detected: DateTime');
                Datetime actual = (Datetime) fieldValue;
                Datetime expected = Datetime.valueOfGmt(input);
                if (operator == 'equals') return actual == expected;
                if (operator == 'not equals') return actual != expected;
                if (operator == 'less than') return actual < expected;
                if (operator == 'less or equals') return actual <= expected;
                if (operator == 'greater than') return actual > expected;
                if (operator == 'greater or equals') return actual >= expected;
            } catch (Exception e) {
                System.debug('❌ Datetime.valueOfGmt failed for input: ' + input + ' → ' + e.getMessage());
                return false;
            }
        }

        // String
        String actualStr = String.valueOf(fieldValue).toLowerCase();
        String expectedStr = input.toLowerCase();
		System.debug('🧠 Type detected: String');
        if (operator == 'equals') return actualStr == expectedStr;
        if (operator == 'not equals') return actualStr != expectedStr;
        if (operator == 'starts with') return actualStr.startsWith(expectedStr);
        if (operator == 'ends with') return actualStr.endsWith(expectedStr);
        if (operator == 'contains') return actualStr.contains(expectedStr);

        return false;
    }
}