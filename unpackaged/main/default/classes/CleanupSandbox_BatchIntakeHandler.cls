global class CleanupSandbox_BatchIntakeHandler implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, litify_pm__Email__c
                                        FROM litify_pm__Intake__c
                                        WHERE litify_pm__Email__c != null]);
    }
                                        
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        if(isSandbox || Test.isRunningTest()){
            System.debug('###CleanupSandbox_BatchIntakeHandler: execute###');
            try {
                List<Id> intakeIdsToDelete = new List<Id>();
                List<litify_pm__Intake__c> intakesToUpdate = new List<litify_pm__Intake__c>();
                for (litify_pm__Intake__c intake : (List<litify_pm__Intake__c>) scope)  {
                    intake.litify_pm__Email__c = intake.litify_pm__Email__c != null ? intake.litify_pm__Email__c.replace('.invalid','') + '.invalid' : '';
                    intakesToUpdate.add(intake);
                }
                if(intakesToUpdate.size() > 0){
                    Database.DMLOptions dml = new Database.DMLOptions(); 
                    dml.DuplicateRuleHeader.allowSave = true;
                    Database.SaveResult[] updateResults = Database.update(intakesToUpdate, dml);
                    for(Database.SaveResult updateResult : updateResults){
                        if(!updateResult.isSuccess()){
                            intakeIdsToDelete.add(updateResult.id);
                            // for(Database.Error error : updateResult.getErrors()){
                            //     // throw new IllegalArgumentException(error.getMessage());
                            //     System.debug(error.getMessage());
                            // }
                        }
                    }
                    if(intakeIdsToDelete != null && intakeIdsToDelete.size() > 0){
                        List<litify_pm__Intake__c> intakesToDelete = [SELECT Id FROM litify_pm__Intake__c WHERE Id IN :intakeIdsToDelete];
                        delete intakesToDelete;
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
        if(!Test.isRunningTest()){
            CleanupSandbox_MetadataContainerHelper.toggleTrigger('dlrs_litify_pm_IntakeTrigger', 'Active');
        }

        litify_pm__Public_Setup__c litifySetting = litify_pm__Public_Setup__c.getOrgDefaults();
        if(litifySetting != null && !litifySetting.litify_pm__Run_Triggers__c){
            litifySetting.litify_pm__Run_Triggers__c = true;
            update litifySetting;
        }

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
            notification.setTitle('SANDBOX CLEANUP FINISHED!');
            notification.setBody('Sandbox has been cleaned up successfully. Please check the logs for any errors.');

            notification.setNotificationTypeId(notificationType.Id);
            String devConsolePage = '{' +
                                '       type: \'standard__webPage\',' +
                                '       attributes: {' +
                                '           url: \'/lightning/setup/ApexDebugLogs/home\'' +
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