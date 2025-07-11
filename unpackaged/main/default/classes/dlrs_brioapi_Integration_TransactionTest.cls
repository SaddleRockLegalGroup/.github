/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_brioapi_Integration_TransactionTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_brioapi_Integration_Transa3bTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new brioapi__Integration_Transaction__c());
    }
}