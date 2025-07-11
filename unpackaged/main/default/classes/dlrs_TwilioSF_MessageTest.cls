/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_TwilioSF_MessageTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_TwilioSF_MessageTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new TwilioSF__Message__c());
    }
}