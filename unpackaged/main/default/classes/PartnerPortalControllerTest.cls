@isTest
public class PartnerPortalControllerTest {
    @TestSetup
    static void setup() {
        Account testAcct = new Account();
        testAcct.litify_pm__First_Name__c = 'Test';
        testAcct.litify_pm__Last_Name__c = 'Account';
        testAcct.Emergency_Contact_Phone__c = '123-456-7890';
        testAcct.Emergency_Contact_2_Phone__c = '123-456-7890';
        testAcct.litify_pm__Phone_Home__c = '123-456-7890';
        testAcct.litify_pm__Phone_Mobile__c = '123-456-7890';
        testAcct.litify_pm__Phone_Other__c = '123-456-7890';
        testAcct.litify_pm__Phone_Work__c = '123-456-7890';
        testAcct.Phone = '123-456-7890';
        testAcct.Name = 'Unit Test';
        testAcct.litify_pm__Email__c = 'test@example.com';
        testAcct.Secondary_Email__c = 'test2@example.com';
        insert testAcct;

        Partner__c testPartner = new Partner__c();
        testPartner.Name = 'Unit Test';
        insert testPartner;

        Campaign_Partner__c testCP = new Campaign_Partner__c();
        testCP.Partner__c = testPartner.Id;
        insert testCP;

        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Email__c = 'test@example.com';
        testIntake.litify_pm__Client__c = testAcct.Id;
        testIntake.litify_pm__Status__c = 'Referred Out';
        testIntake.Referral_Partner__c = testAcct.Id;
        testIntake.Campaign_Partner__c = testCP.Id;
        insert testIntake;
    }

    @isTest
    static void testIntakeQuery() {
        litify_pm__Intake__c intake = [SELECT Id, Referral_Partner__c, Referral_Partner_Name__c, litify_pm__Status__c FROM litify_pm__Intake__c LIMIT 1];

        Test.startTest();
        List<litify_pm__Intake__c> intakes = PartnerPortalController.getIntakeRecords();
        Test.stopTest();

        System.assertEquals(true, !intakes.isEmpty());
    }

    @isTest
    static void testReportNotification() {
        Test.startTest();
        PartnerPortalReportNotification schedulableCls = new PartnerPortalReportNotification();
        String cronExp = '0 0 23 * * ?';
        String jobId = System.schedule('Test PP Report Sched', cronExp, schedulableCls);
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();

        System.assertEquals(cronExp, ct.CronExpression);
    }

    @isTest
    static void testNoReportNotification() {
        ContentVersion doc = new ContentVersion();
        doc.Title = 'TestFile_1';
        doc.PathOnClient = '/' + doc.Title + '.jpg';
        doc.VersionData = Blob.valueOf('Some Text');
        insert doc;

        Test.startTest();
        PartnerPortalReportNotification schedulableCls = new PartnerPortalReportNotification();
        String cronExp = '0 0 23 * * ?';
        String jobId = System.schedule('Test PP Report Sched', cronExp, schedulableCls);
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();

        System.assertEquals(cronExp, ct.CronExpression);
    }

    @isTest
    static void testFileMover() {
        List<Partner_Portal_File_Folder_Directory__mdt> folderDetails = new List<Partner_Portal_File_Folder_Directory__mdt>([
            SELECT MasterLabel, Username__c, Partner_Library_Id__c, Folder_Name__c, Party_Name__c
            FROM Partner_Portal_File_Folder_Directory__mdt
        ]);

        ContentVersion doc = new ContentVersion();
        doc.Title = 'TestFile_2';
        doc.PathOnClient = '/' + doc.Title + '.jpg';
        doc.VersionData = Blob.valueOf('Some Text');
        insert doc;

        Test.startTest();
        PartnerPortalFileFolderScheduler schedulableCls = new PartnerPortalFileFolderScheduler();
        String cronExp = '0 0 23 * * ?';
        String jobId = System.schedule('Test PP File Sched', cronExp, schedulableCls);
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();

        System.assertEquals(cronExp, ct.CronExpression);
    }
}