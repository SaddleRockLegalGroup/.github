/**
 * @description       : Pulls field values from related objects using Intake__c and updates Answer__c records
 * @group             : Utility
 * @last modified on  : 2025-05-06
 * @last modified by  : Jacob Barnett - SaltClick
**/
public with sharing class AnswerRelatedObjectUpdater {

    public class Request {
        @InvocableVariable(required=true)
        public Id answerId;

        @InvocableVariable(required=true)
        public String intakeId;

        @InvocableVariable
        public String objectName;

        @InvocableVariable
        public String fieldName;

        @InvocableVariable
        public String lookupObjectName;
    }

    @InvocableMethod(label='Update Answer from Related Object')
    public static void updateAnswers(List<Request> requests) {
        System.debug('>>> Invoked AnswerRelatedObjectUpdater with ' + requests.size() + ' request(s)');

        Set<Id> answerIds = new Set<Id>();
        for (Request r : requests) {
            answerIds.add(r.answerId);
        }

        Map<Id, Answer__c> answers = new Map<Id, Answer__c>([
            SELECT Id FROM Answer__c WHERE Id IN :answerIds
        ]);

        // Preload Intake → Account mappings
        Map<Id, Id> intakeToAccountMap = new Map<Id, Id>();
        Set<Id> intakeIds = new Set<Id>();
        for (Request req : requests) {
            intakeIds.add(Id.valueOf(req.intakeId));
        }

        for (litify_pm__Intake__c intake : [
            SELECT Id, litify_pm__Client__c FROM litify_pm__Intake__c WHERE Id IN :intakeIds
        ]) {
            if (intake.litify_pm__Client__c != null) {
                intakeToAccountMap.put(intake.Id, intake.litify_pm__Client__c);
            }
        }

        List<Answer__c> answersToUpdate = new List<Answer__c>();

        for (Request req : requests) {
            try {
                if (String.isNotBlank(req.lookupObjectName)) {
                    // Custom lookup case: find all records with Intake__c reference and store as CSV of Ids
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(req.lookupObjectName);
                    if (objType == null) {
                        System.debug('❌ Lookup object not found: ' + req.lookupObjectName);
                        continue;
                    }

                    // Find the Intake__c lookup field
                    String intakeLookupField = null;
                    for (Schema.SObjectField field : objType.getDescribe().fields.getMap().values()) {
                        Schema.DescribeFieldResult fDesc = field.getDescribe();
                        List<Schema.SObjectType> refs = fDesc.getReferenceTo();
                        for (Schema.SObjectType ref : refs) {
                            if (ref.getDescribe().getName() == 'litify_pm__Intake__c') {
                                intakeLookupField = fDesc.getName();
                                break;
                            }
                        }
                        if (intakeLookupField != null) break;
                    }

                    if (intakeLookupField == null) {
                        System.debug('❌ No Intake lookup field found on object: ' + req.lookupObjectName);
                        continue;
                    }

                    String objectName = req.lookupObjectName;
                    String intakeField = intakeLookupField;
                    Id boundIntakeId = Id.valueOf(req.intakeId);
                    String soql = 'SELECT Id FROM ' + objectName + ' WHERE ' + intakeField + ' = :boundIntakeId';
                    List<SObject> results = Database.query(soql);
                    String csv = String.join(new List<String>{}, '');
                    if (!results.isEmpty()) {
                        List<String> idStrings = new List<String>();
                        for (SObject s : results) {
                            idStrings.add((String)s.get('Id'));
                        }
                        csv = String.join(idStrings, ',');
                    }
                    Answer__c a = new Answer__c(Id = req.answerId);
                    a.Answer__c = csv;
                    answersToUpdate.add(a);
                    continue;
                }

                Id relatedRecordId;

                if (req.objectName == 'Account') {
                    relatedRecordId = intakeToAccountMap.get(Id.valueOf(req.intakeId));
                    if (relatedRecordId == null) {
                        System.debug('⚠️ No Account found for Intake Id: ' + req.intakeId);
                        continue;
                    }
                } else if (req.objectName == 'litify_pm__Intake__c') {
                    relatedRecordId = Id.valueOf(req.intakeId);
                } else {
                    // Identify the intake lookup field on the object
                    String intakeLookupField = null;
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(req.objectName);
                    if (objType == null) {
                        System.debug('❌ Object not found: ' + req.objectName);
                        continue;
                    }

                    for (Schema.SObjectField field : objType.getDescribe().fields.getMap().values()) {
                        Schema.DescribeFieldResult fDesc = field.getDescribe();
                        List<Schema.SObjectType> referenceTypes = fDesc.getReferenceTo();
                        for (Schema.SObjectType refType : referenceTypes) {
                            if (refType.getDescribe().getName() == 'litify_pm__Intake__c') {
                                intakeLookupField = fDesc.getName();
                                break;
                            }
                        }
                        if (intakeLookupField != null) break;
                    }

                    if (intakeLookupField == null) {
                        System.debug('❌ No Intake lookup field found on ' + req.objectName);
                        continue;
                    }

                    // Query related record
                    Id boundIntakeId = Id.valueOf(req.intakeId);
                    String soql = 'SELECT Id, ' + req.fieldName +
                                  ' FROM ' + req.objectName +
                                  ' WHERE ' + intakeLookupField + ' = :boundIntakeId LIMIT 1';
                    System.debug('🔍 SOQL: ' + soql);
                    SObject result = Database.query(soql);
                    relatedRecordId = result != null ? (Id)result.get('Id') : null;

                    if (relatedRecordId == null) {
                        System.debug('⚠️ No related record found for ' + req.objectName + ' using Intake ' + req.intakeId);
                        continue;
                    }
                }

                // Retrieve the value from the related record
                String valueQuery = 'SELECT Id, ' + req.fieldName + ' FROM ' + req.objectName + ' WHERE Id = :relatedRecordId';
                SObject relatedRecord = Database.query(valueQuery);
                Object valueToCopy = relatedRecord.get(req.fieldName);

                if (valueToCopy == null) {
                    System.debug('⚠️ Skipping update for Answer ' + req.answerId + ' because value is null.');
                    continue;
                }

                Answer__c a = new Answer__c(Id = req.answerId);
                a.Answer__c = String.valueOf(valueToCopy);
                answersToUpdate.add(a);

                System.debug('✅ Answer ' + req.answerId + ' → Answer__c = ' + String.valueOf(valueToCopy));
            } catch (Exception e) {
                System.debug('❌ Error processing request for Answer ' + req.answerId + ': ' + e.getMessage());
            }
        }

        if (!answersToUpdate.isEmpty()) {
            try {
                update answersToUpdate;
                System.debug('✅ Updated ' + answersToUpdate.size() + ' Answer__c record(s)');
            } catch (DmlException ex) {
                System.debug('❌ DML error: ' + ex.getMessage());
            }
        } else {
            System.debug('⚠️ No Answer__c records updated');
        }
    }
}