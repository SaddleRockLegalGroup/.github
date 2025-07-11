/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_brioapi_Integration_Transa3bTrigger on brioapi__Integration_Transaction__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(brioapi__Integration_Transaction__c.SObjectType);
}