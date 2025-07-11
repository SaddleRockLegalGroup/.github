global class CleanupSandbox_BatchFive9ListHandler implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Five9LSP__Disabled__c
                                        FROM Five9LSP__Five9_List__c
                                        WHERE Five9LSP__Disabled__c = FALSE]);
    }
                                        
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        if(isSandbox || Test.isRunningTest()){
            System.debug('###CleanupSandbox_BatchFive9ListHandler: execute###');
            try {
                List<Five9LSP__Five9_List__c> five9ListsToUpdate = new List<Five9LSP__Five9_List__c>();
                for (Five9LSP__Five9_List__c five9List : (List<Five9LSP__Five9_List__c>) scope)  {
                    five9List.Five9LSP__Disabled__c = TRUE;
                    five9ListsToUpdate.add(five9List);
                }
                if(five9ListsToUpdate.size() > 0){
                    Database.DMLOptions dml = new Database.DMLOptions(); 
                    dml.DuplicateRuleHeader.allowSave = true;
                    Database.SaveResult[] updateResults = Database.update(five9ListsToUpdate, dml);
                    for(Database.SaveResult updateResult : updateResults){
                        if(!updateResult.isSuccess()){
                            for(Database.Error error : updateResult.getErrors()){
                                throw new IllegalArgumentException(error.getMessage());
                            }
                        }
                    }
                }
            }
            catch (Exception e){
                System.debug(e.getMessage());
                throw e;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        CleanupSandbox_BatchAccountHandler batchAccount = new CleanupSandbox_BatchAccountHandler(); 
        database.executebatch(batchAccount, 200);
    }
}