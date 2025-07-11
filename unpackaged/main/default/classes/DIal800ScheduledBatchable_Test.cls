@isTest
public class DIal800ScheduledBatchable_Test {

    @IsTest
    static void testBatchable() {
        // Test Data Setup
        String ani = '111222334';
        IntakeTriggerHandler.ani = ani;

        List<litify_pm__Intake__c> intakeRecords = new List<litify_pm__Intake__c>();
        
        intakeRecords.add(new litify_pm__Intake__c(
            litify_pm__Phone__c = ani,
            D8_ANI__c = ani,
            D8_Call_Id__c = 'CID',
            ani_identifier__c = 'Identifier' 
        ));
        IntakeTriggerHandler.runOnce = true;
        insert intakeRecords;
        
        List<Dial800__c> dial800Records = new List<Dial800__c>();
       
        dial800Records.add(new Dial800__c(ANI__c = ani, Intake__c = null));
        
        insert dial800Records;
		List<Dial800__c> Dial800s = [SELECT Id, ANI__c, Intake__c FROM Dial800__c WHERE Intake__c = null AND ANI__c =: ani];
        system.assert(Dial800s.size()>0,'There should be 1 dial800 record that was inserted');
        system.debug('dial800: '+Dial800s);
        Dial800s[0].Intake__c = null;
        update Dial800s[0];
        // Initialize Batchable
        DIal800ScheduledBatchable batchable = new DIal800ScheduledBatchable();

        // Execute Batch
        Test.startTest();
        Database.executeBatch(batchable); // Batch size
        Test.stopTest();

        // Assertions
        List<Dial800__c> updatedDial800s = [SELECT Id, ANI__c, Intake__c FROM Dial800__c WHERE Intake__c != null];
        System.assertEquals(1, updatedDial800s.size(), '1 Dial800__c records should be matched and updated.');
    }

    @IsTest
    static void testSchedulable() {
        // Test Data Setup
        String ani = '987654321';
        IntakeTriggerHandler.ani = ani;
        List<Dial800__c> dial800Records = new List<Dial800__c>();
        
            dial800Records.add(new Dial800__c(ANI__c = ani, Intake__c = null));
        
        insert dial800Records;

        List<litify_pm__Intake__c> intakeRecords = new List<litify_pm__Intake__c>();
        
        intakeRecords.add(new litify_pm__Intake__c(
            litify_pm__Phone__c = ani,
            D8_Call_Id__c = 'Call' ,
            ani_identifier__c = 'Identifier' 
        ));
        
        insert intakeRecords;

        // Initialize Schedulable
        DIal800ScheduledBatchable schedulable = new DIal800ScheduledBatchable();

        // Schedule Job
        String cronExp = '0 0 1 * * ?'; // Cron expression for 1 AM
        String jobId = System.schedule('Test Dial800 Job', cronExp, schedulable);

        // Execute Scheduled Job
        Test.startTest();
        CronTrigger ct = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('WAITING', ct.State, 'Scheduled job should be in waiting state.');

        // Validate if Batch runs as part of schedule
        Database.executeBatch(schedulable, 200);
        Test.stopTest();

        // Assertions
        List<Dial800__c> updatedDial800s = [SELECT Id, ANI__c, Intake__c FROM Dial800__c WHERE Intake__c != null];
        System.assert(updatedDial800s.size() > 0, 'At least one Dial800__c record should be matched and updated.');
    }
}