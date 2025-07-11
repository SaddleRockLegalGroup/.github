/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_litify_docs_File_InfoTrigger on litify_docs__File_Info__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(BRIO_BypassApexTriggerWhileTesting.shouldRunTrigger()){
        dlrs.RollupService.triggerHandler(litify_docs__File_Info__c.SObjectType);
    }
}