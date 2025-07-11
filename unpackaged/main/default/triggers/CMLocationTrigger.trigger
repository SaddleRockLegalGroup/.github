//Created 03/05/25 by Scott Purcell
trigger CMLocationTrigger on CM_Location__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        if(CMLocationTriggerHandler.ranOnce == false)CMLocationTriggerHandler.isAfterInsert(Trigger.new);
    }
}