public with sharing class TransactionTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static Boolean dontInvokeTrigger = false;
    public TransactionTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public static Boolean isDisabled(){
        Financials__c setting = Financials__c.getOrgDefaults();
        return (setting == null || (setting != null && setting.Enable_Transaction_Calculation__c == false));
    }

    public void OnBeforeInsert(List<litify_fin__lit_Transaction__c> l_new)  {
        Map<String, String> m_objectField = getRelationships(Schema.litify_fin__lit_Transaction__c.SObjectType);
        system.debug('m_objectField==='+m_objectField);
        for(litify_fin__lit_Transaction__c record : l_new) {
            if (record.litify_fin__lit_Related_Record__c != null) {
                Id recId = (Id) record.litify_fin__lit_Related_Record__c;
                //system.debug('recId=='+recId);
                String field = m_objectField.get(recId.getSobjectType().getDescribe().getName());
                if (field != null) {
                    record.put(field, recId);
                }
            }
            if (record.litify_fin__lit_Item__c != null) {
                Id recId = (Id) record.litify_fin__lit_Item__c;
                //system.debug('recId=='+recId);
                String field = m_objectField.get(recId.getSobjectType().getDescribe().getName());
                if (field != null) {
                    record.put(field, recId);
                }
            }
        }
    }
    public void OnAfterInsert(List<litify_fin__lit_Transaction__c> l_new)  {
        Set<Id> s_ids = new Set<Id>();
        Set<String> s_fields = getFields('litify_fin__lit_Transaction__c');
        system.debug('s_fields=='+s_fields);
        for(litify_fin__lit_Transaction__c record : l_new) {
            for(String field : s_fields) {
                if (record.get(field) != null){
                    s_ids.add((Id) record.get(field));
                }
            }
        }
        system.debug('s_ids===='+s_ids);
        if (s_ids.size() > 0) {
            calculationAction(s_ids, 'litify_fin__lit_Transaction__c');
        }
    }
    public void OnAfterUpdate(List<litify_fin__lit_Transaction__c > l_old, List<litify_fin__lit_Transaction__c > l_new, Map<Id, litify_fin__lit_Transaction__c > m_old,  Map<Id, litify_fin__lit_Transaction__c > m_new)  {
        Set<Id> s_ids = new Set<Id>();
        Set<String> s_fields = getFields('litify_fin__lit_Transaction__c');
        for(litify_fin__lit_Transaction__c record : l_new) {
            for(String field : s_fields) {
                if (record.get(field) != m_old.get(record.Id).get(field)){
                    if (record.get(field) != null) {
                        s_ids.add((Id) record.get(field));
                    }
                    if (m_old.get(record.Id).get(field) != null) {
                        s_ids.add((Id) m_old.get(record.Id).get(field));
                    }
                }
            }
            if (record.litify_fin__lit_Amount__c != m_old.get(record.Id).litify_fin__lit_Amount__c) {
                for(String field : s_fields) {
                    if (record.get(field) != m_old.get(record.Id).get(field)){
                        if (record.get(field) != null) {
                            s_ids.add((Id) record.get(field));
                        }
                        if (m_old.get(record.Id).get(field) != null) {
                            s_ids.add((Id) m_old.get(record.Id).get(field));
                        }
                    }
                }
            }
        }
        if (s_ids.size() > 0) {
            calculationAction(s_ids, 'litify_fin__lit_Transaction__c');
        }
    }

    public void OnAfterDelete(List<litify_fin__lit_Transaction__c > l_old, Map<ID, litify_fin__lit_Transaction__c > m_old){ 
        Set<Id> s_ids = new Set<Id>();
        Set<String> s_fields = getFields('litify_fin__lit_Transaction__c');
        for(litify_fin__lit_Transaction__c record : l_old) {
            for(String field : s_fields) {
                if (record.get(field) != null){
                    s_ids.add((Id) record.get(field));
                }
            }
        }
        if (s_ids.size() > 0) {
            calculationAction(s_ids, 'litify_fin__lit_Transaction__c');
        }
    }

    public static Map<String, String> getRelationships(Schema.SObjectType objectType) {
        Map<String, String> m_results = new Map<String, String>();
        Schema.DescribeSObjectResult sfdcObject = objectType.getDescribe();
        Map<String,Schema.SObjectField> m_fields = sfdcObject.fields.getMap();
        for(Schema.SObjectField sfdc_field : m_fields.values()) {
            if (sfdc_field.getDescribe().isCustom() == true) {
                List<Schema.sObjectType> l_relatedsObjectTypes = sfdc_field.getDescribe().getReferenceTo();
                if (l_relatedsObjectTypes != null && l_relatedsObjectTypes.size() > 0) {
                    for(Schema.sObjectType otype : l_relatedsObjectTypes) {
                        m_results.put(otype.getDescribe().getName(), sfdc_field.getDescribe().getName());
                    }
                }
            }
        }
        return m_results;
    }

    public class CalculationWrapper{
        public String objectName;
        public List<Transaction_Setup__mdt> l_config;
        public List<Id> l_ids;
        public CalculationWrapper() {
            this.l_config = new List<Transaction_Setup__mdt>();
            this.l_ids = new List<Id>();
        }
    }
    public static Set<String> getFields(String objectName) {
        List<Transaction_Setup__mdt> l_setup = [SELECT Id,Aggregate_Operation__c, 
                                                                    Aggregate_Result_Field__r.QualifiedApiName, 
                                                                    Child_Object__r.QualifiedApiName, 
                                                                    Field_to_Aggregate__r.QualifiedApiName, 
                                                                    Is_Active__c, 
                                                                    Parent_Object__r.QualifiedApiName,
                                                                    Relationship_Criteria__c,
                                                                    Relationship_Field__r.QualifiedApiName  FROM Transaction_Setup__mdt WHERE Is_Active__c = true 
                                                                    //AND Parent_Object__r.QualifiedApiName IN : s_objects
                                                                    AND Child_Object__r.QualifiedApiName =: objectName];
        Set<String> s_fields = new Set<String>();
        for(Transaction_Setup__mdt setup : l_setup) {
            if (setup.Relationship_Field__r.QualifiedApiName != null) {
                s_fields.add(setup.Relationship_Field__r.QualifiedApiName);
            }
        }
        return s_fields;
    }
    public static void calculationAction(Set<Id> s_ids, String objectName){
        /*Set<String> s_objects = new Set<String>();
        for(Id recId : s_ids) {
            s_objects.add(recId.getSobjectType().getDescribe().getName());
        }*/
        //sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject()
        if (s_ids.size() > 0 && objectName != null)  {
            List<Transaction_Setup__mdt> l_setup = [SELECT Id,Aggregate_Operation__c, 
                                                                    Aggregate_Result_Field__r.QualifiedApiName, 
                                                                    Child_Object__r.QualifiedApiName, 
                                                                    Field_to_Aggregate__r.QualifiedApiName, 
                                                                    Is_Active__c, 
                                                                    Parent_Object__r.QualifiedApiName,
                                                                    Relationship_Criteria__c,
                                                                    Relationship_Field__r.QualifiedApiName  FROM Transaction_Setup__mdt WHERE Is_Active__c = true 
                                                                    //AND Parent_Object__r.QualifiedApiName IN : s_objects
                                                                    AND Child_Object__r.QualifiedApiName =: objectName];
            system.debug('l_setup==='+l_setup);
            if (l_setup.size() > 0) {
                Map<String, Schema.SObjectType> m_globalDescribe = Schema.getGlobalDescribe();
                Map<String, CalculationWrapper> m_wrapper = new Map<String, CalculationWrapper>();
                for(Transaction_Setup__mdt setting : l_setup) {
                    CalculationWrapper wrapper = m_wrapper.get(setting.Parent_Object__r.QualifiedApiName);
                    if (wrapper == null) {
                        wrapper = new CalculationWrapper();
                    }
                    wrapper.l_config.add(setting);
                    m_wrapper.put(setting.Parent_Object__r.QualifiedApiName, wrapper);
                }
                for(Id recId : s_ids) {
                    if (recId != null) {
                        CalculationWrapper wrapper = m_wrapper.get(recId.getSobjectType().getDescribe().getName());
                        if (wrapper != null) {
                            wrapper.l_ids.add(recId);
                        }
                    }
                }
                Map<String, List<sObject>> m_updates = new Map<String, List<sObject>>();
                for(CalculationWrapper item : m_wrapper.values()) {
                    if (item.l_ids != null && item.l_ids.size() > 0) {
                        Map<Id, sObject> m_objects = new Map<Id, sObject>();
                        for(Transaction_Setup__mdt setup : item.l_config) {
                            String soqlQuery = 'SELECT';
                            soqlQuery+= ' '+setup.Aggregate_Operation__c+'('+setup.Field_to_Aggregate__r.QualifiedApiName+') res, '+setup.Relationship_Field__r.QualifiedApiName+' FROM '+setup.Child_Object__r.QualifiedApiName+' WHERE '+setup.Relationship_Field__r.QualifiedApiName+' IN ';
                            String strIdsJoin  = '(\''+String.join(item.l_ids, '\',\'')+'\')';
                            soqlQuery+=strIdsJoin;
                            if (setup.Relationship_Criteria__c != null){
                                soqlQuery+=' AND '+setup.Relationship_Criteria__c;
                            }
                            soqlQuery+= ' GROUP BY '+setup.Relationship_Field__r.QualifiedApiName;
                            system.debug('soqlQuery=='+soqlQuery);
                            for(Id recId : item.l_ids) {
                                sObject obj = m_objects.get(recId);
                                if (obj == null) {
                                    obj = recId.getSobjectType().newSObject(recId);
                                }
                                obj.put(setup.Aggregate_Result_Field__r.QualifiedApiName, 0);
                                m_objects.put(recId, obj);
                            }
                            for(AggregateResult result : Database.query(soqlQuery)) {
                                Id recordId = (Id) result.get(setup.Relationship_Field__r.QualifiedApiName);

                                sObject obj = m_objects.get(recordId);
                                if (obj == null) {
                                    obj = recordId.getSobjectType().newSObject(recordId);
                                }
                                obj.put(setup.Aggregate_Result_Field__r.QualifiedApiName, result.get('res'));
                                m_objects.put(recordId, obj);
                            }
                            /*List < AggregateResult > l_results  = [SELECT SUM(litify_pm__Amount__c) sum, litify_pm__Matter__c FROM litify_pm__Expense__c GROUP BY litify_pm__Matter__c]; 
                            system.debug(l_results);
                            for(AggregateResult item : l_results) {
                                system.debug(item.get('sum'));
                                system.debug(item.get('litify_pm__Matter__c'));
                            }*/
                            
                        }
                        m_updates.put(item.objectName,m_objects.values());
                    }
                }
                if (m_updates.size() > 0) {
                    for(List<sObject> l_obj : m_updates.values()) {
                        update l_obj;
                    }
                }
            }
        }
    }
}