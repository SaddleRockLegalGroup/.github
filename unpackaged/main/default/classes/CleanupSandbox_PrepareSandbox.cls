global class CleanupSandbox_PrepareSandbox implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        if(context != null){
            System.debug('Org ID: ' + context.organizationId());
            System.debug('Sandbox ID: ' + context.sandboxId());
            System.debug('Sandbox Name: ' + context.sandboxName());
        }

        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        if(isSandbox || Test.isRunningTest()){
            CleanupSandbox_BatchFive9ListHandler batchFive9 = new CleanupSandbox_BatchFive9ListHandler(); 
            database.executebatch(batchFive9, 200);
        }
    }
}