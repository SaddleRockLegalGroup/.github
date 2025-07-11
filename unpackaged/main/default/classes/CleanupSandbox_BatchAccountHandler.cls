global class CleanupSandbox_BatchAccountHandler implements Database.Batchable<sObject>, Database.AllowsCallouts  {
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Phone, litify_pm__Phone_Work__c, litify_pm__Phone_Other__c,litify_pm__Phone_Mobile__c
                                        ,litify_pm__Phone_Home__c,Emergency_Contact_2_Phone__c, Emergency_Contact_Phone__c
                                        ,litify_pm__Email__c, Secondary_Email__c
                                        FROM Account
                                        WHERE Phone != null OR litify_pm__Phone_Work__c != null OR litify_pm__Phone_Other__c != null
                                        OR litify_pm__Phone_Mobile__c != null OR litify_pm__Phone_Home__c != null OR Emergency_Contact_2_Phone__c != null
                                        OR Emergency_Contact_Phone__c != null
                                        OR litify_pm__Email__c != null OR Secondary_Email__c != null]);
    }
                                        
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        if(isSandbox || Test.isRunningTest()){
            System.debug('###CleanupSandbox_BatchAccountHandler: execute###');
            try {
                litify_pm__Public_Setup__c litifySetting = litify_pm__Public_Setup__c.getOrgDefaults();
                if(litifySetting != null && litifySetting.litify_pm__Run_Triggers__c){
                    litifySetting.litify_pm__Run_Triggers__c = false;
                    update litifySetting;
                }

                List<Account> accountsToUpdate = new List<Account>();
                for (Account account : (List<Account>) scope)  {
                    account.Phone = null;
                    account.litify_pm__Phone_Work__c = null;
                    account.litify_pm__Phone_Other__c = null;
                    account.litify_pm__Phone_Mobile__c = '0';
                    account.litify_pm__Phone_Home__c = null;
                    account.Emergency_Contact_2_Phone__c = null;
                    account.Emergency_Contact_Phone__c = null;
                    account.Secondary_Email__c = account.Secondary_Email__c != null ? account.Secondary_Email__c.replace('.invalid','') + '.invalid' : '';
                    account.litify_pm__Email__c = account.litify_pm__Email__c != null ? account.litify_pm__Email__c.replace('.invalid','') + '.invalid' : '';
                    accountsToUpdate.add(account);
                }
                if(accountsToUpdate.size() > 0){
                    Database.DMLOptions dml = new Database.DMLOptions(); 
                    dml.DuplicateRuleHeader.allowSave = true;
                    Database.SaveResult[] updateResults = Database.update(accountsToUpdate, dml);
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
        List<User> admins = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'
                            AND IsActive = true];
        if(admins != null && admins.size() > 0){
            Set<string> adminIds = new Set<string>();
            for(User admin : admins){
                adminIds.add(admin.Id);
            }
            CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                            FROM CustomNotificationType 
                            WHERE DeveloperName='CleanupSandboxNotification'];
                
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('FINISH SANDBOX CLEANUP!');
            notification.setBody('Execute CleanupSandbox_ManuallyExecute.cleanupIntake(); in Developer Console');

            notification.setNotificationTypeId(notificationType.Id);
            String devConsolePage = '{' +
                                '       type: \'standard__webPage\',' +
                                '       attributes: {' +
                                '           url: \'/_ui/common/apex/debug/ApexCSIPage\'' +
                                '       }' +
                                '}';
            notification.setTargetPageRef(devConsolePage);
            
            try {
                notification.send(adminIds);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
    }
}