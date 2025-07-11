public virtual class SaddleRockMappingHelper {
    public Map<String, String> inboundFieldMap = new Map<String, String>();
    public Map<string, Map<string,string>> jsonKeyToFieldObjectMap = new Map<string, Map<string,string>>();
    public Map<String,Object> jsonParentToSObject = new Map<String,Object>();

    public string directRecordId;

    public SObjectType objType;
    public Boolean throwExceptions;
    public class ValidationException extends SaddleRockUtils.BrioException {
    }
    public static Pattern JSON_KEY_PATTERN = Pattern.compile('\\w+');
    
    public Map<String, String> inboundDirectFieldMap = new Map<String, String>();

    public Map<string,Map<String,String>> inboundParentFieldMap = new Map<string,Map<String,String>>();

    public Map<String, String> directLookupMap = new Map<String, String>();
    public Map<String, Object> lookupJsonToValue = new Map<String, Object>();

    public void loadConfigMapping(string integrationId, String objTypeName){
        Integration_Inbound_Payload__mdt[] mappings = new Integration_Inbound_Payload__mdt[]{};
        
        if(Test.isRunningTest()){
            mappings.addAll(SaddleRockTestDataFactory.generateTestInboundPayloadMapping());
        }
        else {
            mappings = [SELECT SObject__r.QualifiedApiName, Target_Field__r.QualifiedApiName, JSON_Key__c, JSON_Type__c
                        , JSON_Parent__c, Integration__c
                        FROM Integration_Inbound_Payload__mdt 
                        WHERE Integration__c = :integrationId AND Active__c = true];
        }
        objType = SaddleRockUtils.getSObjectType(objTypeName);
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'loadConfigMapping.mappings', JSON.serialize(mappings));

        for (Integration_Inbound_Payload__mdt r : mappings) {
            if(r.JSON_Type__c == 'Field' && (r.JSON_Parent__c == '' || r.JSON_Parent__c == null) && r.SObject__r.QualifiedApiName == objTypeName){
                String jsonKeyDirect = validateJsonKey(r.JSON_Key__c, inboundDirectFieldMap);
                inboundDirectFieldMap.put(validateField(r.Target_Field__r.QualifiedApiName, objType, inboundDirectFieldMap), jsonKeyDirect);
            }
            else if(r.JSON_Type__c == 'Object'){
                String jsonKeyLookup = validateJsonKey(r.JSON_Key__c, directLookupMap);
                directLookupMap.put(validateField(r.Target_Field__r.QualifiedApiName, objType, directLookupMap), jsonKeyLookup);
            }
            else if(r.JSON_Type__c == 'Field' && r.JSON_Parent__c != '' && r.JSON_Parent__c != null && r.SObject__r.QualifiedApiName != objTypeName){
                Map<string,string> detailFieldMap = new Map<string,string>();

                if(inboundParentFieldMap.containsKey(r.JSON_Parent__c)){
                    detailFieldMap = inboundParentFieldMap.get(r.JSON_Parent__c);

                }
                
                SObjectType parentObjType = SaddleRockUtils.getSObjectType(r.SObject__r.QualifiedApiName);
                String jsonKeyParent = validateJsonKey(r.JSON_Key__c, detailFieldMap);
                string apiFieldName = r.Target_Field__r.QualifiedApiName;

                //Parse potential Address type
                if(apiFieldName == 'BillingAddress' || apiFieldName == 'ShippingAddress'){
                    switch on jsonKeyParent {
                        when 'clientStreetAddr' {
                            apiFieldName = apiFieldName.replaceAll('Address', 'Street');
                        }
                        when 'clientCity' {
                            apiFieldName = apiFieldName.replaceAll('Address', 'City');
                        }
                        when 'clientState' {
                            apiFieldName = apiFieldName.replaceAll('Address', 'State');
                        }
                        when 'clientZip' {
                            apiFieldName = apiFieldName.replaceAll('Address', 'PostalCode');
                        }
                        when 'clientCountry' {
                            apiFieldName = apiFieldName.replaceAll('Address', 'Country');
                        }
                        when else {
                            apiFieldName = apiFieldName;
                        }
                    }
                }
                detailFieldMap.put(validateField(apiFieldName, parentObjType, detailFieldMap), jsonKeyParent);
                inboundParentFieldMap.put(r.JSON_Parent__c, detailFieldMap);
                if(!jsonParentToSObject.containsKey(r.JSON_Parent__c) || (jsonParentToSObject.containsKey(r.JSON_Parent__c) && jsonParentToSObject.get(r.JSON_Parent__c) == null)){
                    jsonParentToSObject.put(r.JSON_Parent__c, parentObjType);
                }
                
            }
        }

        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'loadConfigMapping.inboundDirectFieldMap', JSON.serialize(inboundDirectFieldMap));
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'loadConfigMapping.directLookupMap', JSON.serialize(directLookupMap));
    }

    public SObject[] jsonToRecords(string integrationId, String objTypeName, String syncFieldName, List<Map<String, Object>> body){
        loadConfigMapping(integrationId, objTypeName);
        SObject[] records = new SObject[]{};
        objType = SaddleRockUtils.getSObjectType(objTypeName);

        
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords.objTypeName', objTypeName);
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords - payload size', body.size());

        Map<SObjectField, String> fieldsToJsonKey = new Map<SObjectField, String>();
        Map<string,Map<SObjectField, Object>> parentFieldsToJsonKey = new Map<string,Map<SObjectField, Object>>();

        for (String fieldName : inboundDirectFieldMap.keySet()) {
            if (!fieldName.contains('.')){
                fieldsToJsonKey.put(SaddleRockUtils.getField(objType, fieldName), inboundDirectFieldMap.get(fieldName));
            }
        }

        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords.fieldsToJsonKey', JSON.serialize(fieldsToJsonKey));

        for(string jsonParentKey : jsonParentToSObject.keySet()){
            SObjectType parentSObjectType = (SObjectType)jsonParentToSObject.get(jsonParentKey);
            Map<SObjectField, Object> fieldsMap = new Map<SObjectField, Object>();
            for(string parentDetailField : inboundParentFieldMap.get(jsonParentKey).keySet()){
                if (!parentDetailField.contains('.')){
                    fieldsMap.put(SaddleRockUtils.getField(parentSObjectType, parentDetailField), inboundParentFieldMap.get(jsonParentKey).get(parentDetailField));
                }
            }
            parentFieldsToJsonKey.put(jsonParentKey, fieldsMap);
        }
        
        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords.parentFieldsToJsonKey', parentFieldsToJsonKey);

        final String jsonIdKey = inboundDirectFieldMap.get('id');

        for (Map<String, Object> jsonKeyToValue : body) {

            // Query all lookup fields in this direct object
            if(directLookupMap.size() > 0){
                directRecordId = string.valueOf(jsonKeyToValue.get('id'));
                
                string dynamicSOQL = 'SELECT Id, ' + String.join(new List<String>(directLookupMap.keySet()), ',') + ' FROM ' + objTypeName + ' WHERE Id = \'' + directRecordId + '\'';
                
                new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords.dynamicSOQL', dynamicSOQL);

                sObject dynamicRec = Database.query(dynamicSOQL);
                
                for(string sfField : directLookupMap.keySet()){
                    lookupJsonToValue.put(directLookupMap.get(sfField), dynamicRec.get(sfField));
                }
                
            }

            Map<String,SObjectField> sField = SaddleRockUtils.getFields(objType);
            SObjectField f = sField != null ? sField.get('Id') : null;
            Object v = jsonKeyToValue.get(jsonIdKey);

            try {
                // Direct fields
                SObject rec = (SObject)objType.newSObject((Id)v);
                rec.put(syncFieldName, Datetime.now());
                for (SObjectField theField : fieldsToJsonKey.keySet()) {
                    f = theField;
                    final String jsonKey = fieldsToJsonKey.get(f);
                    if (jsonKeyToValue.containsKey(jsonKey) && (jsonKey != jsonIdKey)) {
                        v = jsonKeyToValue.get(jsonKey);
                        rec.put(f, toFieldValue(f, v));
                        new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords - DirectFields', 'Key: ' + f + ', Value: ' + v);
                    }
                }
                records.add(rec);


                // Parent fields
                for(string jsonParentKey : jsonParentToSObject.keySet()){
                    SObjectType parentSObjectType = (SObjectType)jsonParentToSObject.get(jsonParentKey);
                    new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords.parentSObjectType', parentSObjectType);
                    
                    
                    SObjectField parentf = SaddleRockUtils.getFields(parentSObjectType).get('Id');
                    Object parentv = lookupJsonToValue.get(jsonParentKey);
                    new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords - RelatedFields', 'Key: ' + parentf + ', Value: ' + parentv);
                    if(parentf != null && parentv != null){
                        Map<SObjectField, Object> detailMap = parentFieldsToJsonKey.get(jsonParentKey);
                        SObject recParent = (SObject)parentSObjectType.newSObject((Id)parentv);
    
                        for (SObjectField theField : detailMap.keySet()) {
                            parentf = theField;
                            final String jsonKey1 = string.valueOf(detailMap.get(parentf));
                            
                            if (jsonKeyToValue.containsKey(jsonKey1)) {
                                parentv = jsonKeyToValue.get(jsonKey1);
                                recParent.put(parentf, toFieldValue(parentf, parentv));
                                new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords - RelatedFields', 'Key: ' + parentf + ', Value: ' + parentv);
                            }
                        }
                        records.add(recParent);

                    }
                }


                new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'jsonToRecords - Number of records to be synced', records.size());
            } catch (Exception e) {
                System.debug(e.getMessage() + '\n\n' + e.getStackTraceString());
                new SaddleRockUtils.Log(LoggingLevel.ERROR, 'SaddleRockMappingHelper.jsonToRecords',
                    e.getMessage() + '\n\n' + e.getStackTraceString());
                    throw e;
                //continue; // go to the next record
            }
        }
        return records;
    }

    @TestVisible Object toFieldValue(SObjectField f, Object v) {
        v = SaddleRockUtils.truncate(f, v);
        final DisplayType fType = f.getDescribe().getType();

        if (DisplayType.DATE == fType) {
            v = (null != v) ? Date.valueOf(String.valueOf(v)) : null;
        } else if (DisplayType.BOOLEAN == fType) {
            v = Boolean.valueOf(v);
        }
        return v;
    }

    static String validateJsonKey(String text, Map<String, String> results) {
        final String jsonKey = (null != text) ? text.trim() : null;
        SaddleRockUtils.throwIf(String.isBlank(jsonKey), 
            new ValidationException('JSON key is required'));
        SaddleRockUtils.throwIf(!JSON_KEY_PATTERN.matcher(jsonKey).matches(), 
            new ValidationException('Invalid JSON key: ' + text));
        SaddleRockUtils.throwIf(new Set<String>(results.values()).contains(jsonKey), 
            new ValidationException('Duplicate JSON key: ' + text));
        return jsonKey;
    }

    static String validateField(String text, SObjectType objType, Map<String, String> results) {
        final String fieldName = text.deleteWhitespace().toLowerCase();
        final SObjectField f = SaddleRockUtils.getField(objType, fieldName);
        SaddleRockUtils.throwIf(null == f, new ValidationException('Invalid field API name: ' + String.valueOf(objType) + '.' + text));
        SaddleRockUtils.throwIf(results.containsKey(fieldName), 
            new ValidationException('Duplicate field: ' + String.valueOf(objType) + '.' + text));
        return fieldName;
    }
}