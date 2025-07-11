trigger AccountTrigger on Account (after insert,before update) {

    if(Trigger.isAfter && Trigger.isInsert)AccountTriggerHandler.isafterInsert(Trigger.new);
    if(Trigger.isBefore && Trigger.isUpdate && AccountTriggerHandler.ranOnce == false)AccountTriggerHandler.isBeforeUpdate(Trigger.new,Trigger.oldMap);
}