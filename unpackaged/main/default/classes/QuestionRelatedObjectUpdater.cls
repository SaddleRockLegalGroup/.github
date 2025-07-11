/**
 * @description       : Dynamic Field Updater for Intake and related objects via Flow
 * @group             : Utility
 * @last modified on  : 2025-05-30
 * @last modified by  : Jacob Barnett - SaltClick
**/
public with sharing class QuestionRelatedObjectUpdater {

    public class Request {
        @InvocableVariable(required=true)
        public String objectName;

        @InvocableVariable(required=true)
        public String intakeId;

        @InvocableVariable(required=true)
        public String fieldName;

        @InvocableVariable(required=true)
        public String newValue;
    }

    @InvocableMethod(label='Update Dynamic Field')
    public static void updateField(List<Request> requests) {
        System.debug('>>> Invoked QuestionRelatedObjectUpdater with ' + requests.size() + ' request(s)');
        for (Request r : requests) {
            System.debug('-- REQUEST --');
            System.debug('Object: ' + r.objectName);
            System.debug('IntakeId: ' + r.intakeId);
            System.debug('Field: ' + r.fieldName);
            System.debug('Value: ' + r.newValue);
        }

        Map<String, List<SObject>> recordsToUpdateMap = new Map<String, List<SObject>>();
        Map<String, Set<String>> intakeIdsMap = new Map<String, Set<String>>();

        for (Request req : requests) {
            if (!intakeIdsMap.containsKey(req.objectName)) {
                intakeIdsMap.put(req.objectName, new Set<String>());
            }
            intakeIdsMap.get(req.objectName).add(req.intakeId);
        }

        Map<String, Map<Id, Id>> intakeToParentIdMap = new Map<String, Map<Id, Id>>();

        Map<String, String> intakeFieldMap = new Map<String, String>();

        for (String objectName : intakeIdsMap.keySet()) {
            try {
                if (objectName == 'Account') {
                    Set<Id> intakeIds = new Set<Id>();
                    for (String idStr : intakeIdsMap.get(objectName)) {
                        try {
                            intakeIds.add(Id.valueOf(idStr));
                        } catch (Exception e) {
                            System.debug('⚠️ Invalid Id format for Account resolution: ' + idStr);
                        }
                    }
                    
                    Map<Id, Id> intakeToAccountIdMap = new Map<Id, Id>();
                    for (litify_pm__Intake__c intake : [
                        SELECT Id, litify_pm__Client__c
                        FROM litify_pm__Intake__c
                        WHERE Id IN :intakeIds
                    ]) {
                        if (intake.litify_pm__Client__c != null) {
                            intakeToAccountIdMap.put(intake.Id, intake.litify_pm__Client__c);
                        }
                    }
                    
                    intakeToParentIdMap.put(objectName, intakeToAccountIdMap);
                    
                    List<Account> accountsToUpdate = [
                        SELECT Id FROM Account WHERE Id IN :intakeToAccountIdMap.values()
                    ];
                    
                    recordsToUpdateMap.put(objectName, new List<SObject>());
                    for (Account acct : accountsToUpdate) {
                        recordsToUpdateMap.get(objectName).add(acct);
                    }
                    
                    continue; // Skip default handling
                }
        
                // Standard object handling
                Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
                if (sObjectType == null) {
                    System.debug('❌ Object not found: ' + objectName);
                    continue;
                }
        
                Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        
                // 🔍 Direct Intake or related object lookup
                String intakeLookupField = null;
                if (objectName == 'litify_pm__Intake__c') {
                    intakeLookupField = 'Id';
                } else {
                    for (Schema.SObjectField field : describeResult.fields.getMap().values()) {
                        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                        for (Schema.SObjectType refType : fieldDescribe.getReferenceTo()) {
                            if (refType.getDescribe().getName() == 'litify_pm__Intake__c') {
                                intakeLookupField = fieldDescribe.getName();
                                break;
                            }
                        }
                        if (intakeLookupField != null) break;
                    }
                }
                
                if (intakeLookupField != null) {
                    intakeFieldMap.put(objectName, intakeLookupField);
                } else {
                    System.debug('❌ No intake lookup field found on object: ' + objectName);
                    continue;
                }
        
                Set<Id> intakeIds = new Set<Id>();
                for (String idStr : intakeIdsMap.get(objectName)) {
                    try {
                        intakeIds.add(Id.valueOf(idStr));
                    } catch (Exception e) {
                        System.debug('⚠️ Invalid Id format: ' + idStr);
                    }
                }
        
                String query;
                if (intakeLookupField == 'Id') {
                    query = 'SELECT Id FROM ' + objectName + ' WHERE Id IN :intakeIds';
                } else {
                    query = 'SELECT Id, ' + intakeLookupField + ' FROM ' + objectName +
                            ' WHERE ' + intakeLookupField + ' IN :intakeIds';
                }
        
                System.debug('🔍 QUERY: ' + query);
                List<SObject> records = Database.query(query);
        
                if (!recordsToUpdateMap.containsKey(objectName)) {
                    recordsToUpdateMap.put(objectName, new List<SObject>());
                }
                recordsToUpdateMap.get(objectName).addAll(records);
        
            } catch (Exception e) {
                System.debug('❌ Error processing object ' + objectName + ': ' + e.getMessage());
            }
        }

        Map<Id, SObject> allRecordsToUpdateMap = new Map<Id, SObject>();

        for (Request req : requests) {
            if (recordsToUpdateMap.containsKey(req.objectName)) {
                for (SObject record : recordsToUpdateMap.get(req.objectName)) {
                    try {
                        Boolean isMatch = false;

                        if (req.objectName == 'litify_pm__Intake__c') {
                            isMatch = (record.Id == Id.valueOf(req.intakeId));
                        } else if (req.objectName == 'Account' && intakeToParentIdMap.containsKey('Account')) {
                            Id expectedAccountId = intakeToParentIdMap.get('Account').get(Id.valueOf(req.intakeId));
                            isMatch = (record.Id == expectedAccountId);
                        } else {
                            String intakeField = intakeFieldMap.get(req.objectName);
                            if (intakeField != null) {
                                try {
                                    Id intakeIdValue = (Id) record.get(intakeField);
                                    isMatch = (intakeIdValue == Id.valueOf(req.intakeId));
                                } catch (Exception ex) {
                                    System.debug('⚠️ Failed to get intake field "' + intakeField + '" from object ' + req.objectName + ': ' + ex.getMessage());
                                }
                            } else {
                                System.debug('❌ Intake field not found in intakeFieldMap or record for object: ' + req.objectName);
                            }
                        }

                        if (isMatch) {
                            Id recordId = (Id) record.get('Id');
                            SObject recordToUpdate = Schema.getGlobalDescribe()
                                .get(req.objectName)
                                .newSObject(recordId);
                            
                            // Enhanced: Check field type and convert value if needed
                            Schema.SObjectField fieldDef = Schema.getGlobalDescribe()
                                .get(req.objectName)
                                .getDescribe()
                                .fields.getMap().get(req.fieldName);

                            if (fieldDef != null) {
                                Schema.DisplayType fieldType = fieldDef.getDescribe().getType();
                                Object valueToSet = req.newValue;
                                if (req.newValue == null && fieldType == Schema.DisplayType.String) {
                                    valueToSet = '';
                                } else if (fieldType == Schema.DisplayType.Date && req.newValue != null) {
                                    try {
                                        valueToSet = Date.valueOf(req.newValue);
                                    } catch (Exception e) {
                                        System.debug('❌ Invalid Date value for field ' + req.fieldName + ': ' + req.newValue);
                                        valueToSet = null;
                                    }
                                } else if (fieldType == Schema.DisplayType.Boolean && req.newValue != null) {
                                    valueToSet = (req.newValue.toLowerCase() == 'true');
                                } else if (fieldType == Schema.DisplayType.Integer && req.newValue != null) {
                                    try {
                                        valueToSet = Integer.valueOf(req.newValue);
                                    } catch (Exception e) {
                                        System.debug('❌ Invalid Integer value for field ' + req.fieldName + ': ' + req.newValue);
                                        valueToSet = null;
                                    }
                                } else if (fieldType == Schema.DisplayType.Double && req.newValue != null) {
                                    try {
                                        valueToSet = Double.valueOf(req.newValue);
                                    } catch (Exception e) {
                                        System.debug('❌ Invalid Double value for field ' + req.fieldName + ': ' + req.newValue);
                                        valueToSet = null;
                                    }
                                }
                                recordToUpdate.put(req.fieldName, valueToSet);
                            } else {
                                recordToUpdate.put(req.fieldName, req.newValue);
                            }
                            
                            allRecordsToUpdateMap.put(recordId, recordToUpdate);

                            System.debug('✅ Preparing update for ' + req.objectName + ' Id: ' + record.get('Id') +
                                             ' → ' + req.fieldName + ' = ' + req.newValue);
                        }
    
                    } catch (Exception e) {
                        System.debug('❌ Error preparing update for ' + req.objectName + ': ' + e.getMessage());
                    }
                }
            }
        }

        if (!allRecordsToUpdateMap.isEmpty()) {
            try {
                update allRecordsToUpdateMap.values();
                System.debug('✅ Updated ' + allRecordsToUpdateMap.size() + ' record(s)');
            } catch (DmlException dmlEx) {
                System.debug('❌ DML update failed: ' + dmlEx.getMessage());
            }
        } else {
            System.debug('⚠️ No records matched for update.');
        }
    }
}