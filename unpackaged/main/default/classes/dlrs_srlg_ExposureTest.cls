/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_srlg_ExposureTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_srlg_ExposureTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new srlg_Exposure__c());
    }
}