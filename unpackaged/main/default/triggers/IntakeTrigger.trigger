//Created 02/26/25 by Scott Purcell
trigger IntakeTrigger on litify_pm__Intake__c (after insert, after update,before insert,before update) {
    if(Trigger.isAfter && Trigger.isInsert ){
        IntakeTriggerHandler.isAfterInsertUpdate(Trigger.new,false);
    }
    else if(Trigger.isAfter && Trigger.isUpdate && IntakeTriggerHandler.runOnce == false){
        IntakeTriggerHandler.isAfterInsertUpdate(Trigger.new,true);
    }
    else if(Trigger.isBefore && Trigger.isInsert){
        IntakeTriggerHandler.isBeforeInsert(Trigger.new);
    }
    else if(Trigger.isBefore && Trigger.isUpdate){
        IntakeTriggerHandler.isBeforeUpdate(Trigger.new);
    }
}