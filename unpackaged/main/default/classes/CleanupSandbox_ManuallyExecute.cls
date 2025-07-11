public class CleanupSandbox_ManuallyExecute {
    public static void cleanupIntake() {
        // Temporarily deactivate dlrs_litify_pm_IntakeTrigger to delete invalid intakes that have missing client
        if(!Test.isRunningTest()){
            CleanupSandbox_MetadataContainerHelper.toggleTrigger('dlrs_litify_pm_IntakeTrigger', 'Inactive');
        }

        CleanupSandbox_BatchIntakeHandler batchIntake = new CleanupSandbox_BatchIntakeHandler(); 
        database.executebatch(batchIntake, 200);
    }
}