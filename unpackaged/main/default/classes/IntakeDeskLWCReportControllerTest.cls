@isTest
public class IntakeDeskLWCReportControllerTest {
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
        testIntake.Intake_Desk_Review__c = 'Passed';
        testIntake.Intake_Desk_Status__c = 'In Progress';
        testIntake.QC_Type__c = 'Duplicate';
        testIntake.brioapi__API_External_ID__c = 'intakeDesk-123456';
        insert testIntake;

        brioapi__Integration_Transaction__c testTransaction = new brioapi__Integration_Transaction__c();
        testTransaction.Name = 'Single Test Transaction';
        testTransaction.Audited__c = false;
        testTransaction.brioapi__Vendor__c = 'Test Vendor';
        testTransaction.brioapi__Status__c = 'Error';
        insert testTransaction;
    }

    @isTest
    static void testIntakeQCReportQuery() {
        litify_pm__Intake__c intake = [
            SELECT
                Id, Name, CreatedDate, QC_Type__c, Intake_Vendor__c, Intake_VendorName__c, FX_Intake_Desk_ID__c, litify_pm__First_Name__c, litify_pm__Last_Name__c,
                Case_Type_Name_del__c, litify_pm__Status__c, Sub_Status__c, Intake_Desk_Review__c, fx_Intake_Desk_Action__c, ID_EOF_Reason__c, FX_Full_Name__c, Automated_QC_Notes__c,
            Intake_Desk_Status__c, Intake_Note__c, litify_pm__Referred_Out_Date__c, litify_pm__Turn_Down_Reason__c, Referral_Partner_Name__c, Intake_Desk_Qualified__c
            FROM litify_pm__Intake__c
            LIMIT 1
        ];

        intake.QC_Type__c = 'Duplicate';
        update intake;
        
        Test.startTest();
        List<litify_pm__Intake__c> intakes = IntakeDeskLWCReportController.getIntakeDeskQCReport();
        Test.stopTest();

        System.assertEquals(true, !intakes.isEmpty());
    }

    @isTest
    static void testUpdateIntakeStatus() {
        litify_pm__Intake__c intake = [
            SELECT
            Id, Name, CreatedDate, QC_Type__c, Intake_Vendor__c, Intake_VendorName__c, FX_Intake_Desk_ID__c, litify_pm__First_Name__c, litify_pm__Last_Name__c,
            Case_Type_Name__c, litify_pm__Case_Type__r.Name, litify_pm__Status__c, Sub_Status__c, Intake_Desk_Review__c, fx_Intake_Desk_Action__c, ID_EOF_Reason__c,
            Intake_Desk_Status__c, Intake_Note__c, litify_pm__Referred_Out_Date__c, Automated_QC_Notes__c
            FROM litify_pm__Intake__c
            LIMIT 1
        ];

        Test.startTest();
        String resultMsg = IntakeDeskLWCReportController.updateIntakeStatus(intake.Id, 'New');
        Test.stopTest();

        System.assertEquals('Success', resultMsg);
    }

    @isTest
    static void testIntegrationAPIFailureReportQuery() {
        brioapi__Integration_Transaction__c integration = [
            SELECT
                Id, CreatedDate, Name, External_ID__c, brioapi__Vendor__c, FX_Intake_Vendor__c, brioapi__Status__c, brioapi__Request__c, brioapi__Response__c, Audited__c
            FROM brioapi__Integration_Transaction__c
            LIMIT 1
        ];

        Test.startTest();
        List<brioapi__Integration_Transaction__c> integrations = IntakeDeskLWCReportController.getIntakeDeskAPIFailureReport();
        Test.stopTest();

        System.assertEquals(true, !integrations.isEmpty());
    }

    @isTest
    static void testIntakeMissingDocReportQuery() {
        litify_pm__Intake__c intake = [
            SELECT
            Id, Name, CreatedDate, Intake_VendorName__c, FX_Type_of_Payload_to_Resend__c, FX_Caller_First_Name__c, FX_Caller_Last_Name__c, litify_pm__Email__c,
            FX_Status_and_Sub_Status__c, Intake_Desk_Qualified__c, brioapi__API_External_ID__c, litify_pm__Status__c, Count_of_Signed_Retainers__c, litify_pm__Referred_Out_Date__c            FROM litify_pm__Intake__c
            LIMIT 1
        ];

        Test.startTest();
        List<litify_pm__Intake__c> intakes = IntakeDeskLWCReportController.getIntakeDeskMissingDocReport();
        Test.stopTest();

        System.assertEquals(true, !intakes.isEmpty());
    }
}