trigger TransactionTrigger on litify_fin__lit_Transaction__c (before insert, after insert, after update, after delete) {
    if(TransactionTriggerHandler.isDisabled()) {
        return;
    }

    TransactionTriggerHandler handler = new TransactionTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    } 
    else if(Trigger.isInsert&& Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }  
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }   
    else if(Trigger.isAfter && Trigger.isDelete){
        handler.OnAfterDelete(Trigger.old,Trigger.oldMap);
    } 
}