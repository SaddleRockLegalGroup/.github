/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_litify_docs_File_InfoTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_litify_docs_File_InfoTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new litify_docs__File_Info__c());
    }
    @IsTest
    private static void testTrigger_Bypass()
    {
        BRIO_BypassApexTriggerWhileTesting.setDoNotRunTrigger();
        // Force the dlrs_litify_docs_File_InfoTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new litify_docs__File_Info__c());
    }
}