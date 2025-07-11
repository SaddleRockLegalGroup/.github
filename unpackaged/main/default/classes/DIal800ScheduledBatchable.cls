global class DIal800ScheduledBatchable implements Schedulable, Database.Batchable<sObject> {

    // Schedulable Interface Method
    global void execute(SchedulableContext sc) {
        // Schedule the batch job
        Database.executeBatch(this, 200); // Specify batch size
    }

    // Batchable Interface - Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query records to process
        return Database.getQueryLocator('SELECT Id, ANI__c, Intake__c FROM Dial800__c WHERE Intake__c = null');
    }

    // Batchable Interface - Execute Method
    global void execute(Database.BatchableContext bc, List<Dial800__c> details) {
        List<String>anis = new list<String>();               
        for(Dial800__c det:details){
            anis.add(det.ANI__c);
            system.debug('details: '+det.ANI__c);
        }

        List<Id>intakeIds = new List<Id>();
        for(litify_pm__Intake__c intake:[Select Id, D8_Call_Id__c,D8_ANI__c,litify_pm__Phone__c,Intake_Label__c,D8_Connected_Duration__c,D8_Duration__c,D8_Status__c,D8_Target__c,D8_Call_Start__c,
                                                 D8_Media_Agency__c,ani_identifier__c,Marketing_Campaign__c,
                                                 litify_pm__Case_City__c ,ani_assigned__c, litify_pm__Case_Postal_Code__c,litify_pm__Case_State__c    
                                                 From litify_pm__Intake__c Where litify_pm__Phone__c IN:anis OR D8_ANI__c IN :anis]){
                                                     intakeIds.add(intake.Id);
                                                 }
        system.debug('intakeIds: '+intakeIds);
        IntakeTriggerHandler.runMatching(intakeIds);
    }

    // Batchable Interface - Finish Method
    global void finish(Database.BatchableContext bc) {
        // Post-batch processing or logging
        System.debug('Batch process completed successfully.');
    }
}

// Schedule the job to run daily at 2 AM
//String cronExp = '0 0 2 * * ?'; // Cron expression for 2:00 AM daily
//System.schedule('Daily Dial800 mop-up Job', cronExp, new DIal800ScheduledBatchable());