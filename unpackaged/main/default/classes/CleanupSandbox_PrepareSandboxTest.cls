@isTest
public class CleanupSandbox_PrepareSandboxTest {
    @isTest
    static void testSandboxPrep() {
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
        testAcct.litify_pm__Email__c = 'test@example.com';
        testAcct.Secondary_Email__c = 'test2@example.com';
        insert testAcct;

        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Email__c = 'test@example.com';
        testIntake.litify_pm__Client__c = testAcct.Id;
        insert testIntake;

        Five9LSP__Five9_List__c testFive9List = new Five9LSP__Five9_List__c();
        testFive9List.Name = 'Test';
        testFive9List.Five9LSP__Five9_User_Name__c = 'Test Username';
        testFive9List.Five9LSP__Five9_User_Password__c = 'Test Password';
        testFive9List.Five9LSP__Disabled__c = false;
        testFive9List.Five9LSP__Five9_Domain__c = 'Test Domain';
        testFive9List.Five9LSP__API_URL__c = 'Test URL';
        insert testFive9List;
        
        litify_pm__Public_Setup__c setting = new litify_pm__Public_Setup__c();
        setting.litify_pm__Run_Triggers__c = true;
        insert setting;
        
        Test.startTest();
        Test.testSandboxPostCopyScript(
            new CleanupSandbox_PrepareSandbox(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName(), true);
        Test.stopTest();
        List<Account> updatedAcct = [SELECT Id, litify_pm__Phone_Mobile__c, litify_pm__Phone_Home__c, litify_pm__Email__c 
                                    FROM Account 
                                    WHERE Id = :testAcct.Id];
        System.assertEquals('0', updatedAcct[0].litify_pm__Phone_Mobile__c);
        System.assertEquals(null, updatedAcct[0].litify_pm__Phone_Home__c);
        System.assertEquals('test@example.com.invalid', updatedAcct[0].litify_pm__Email__c);

        List<Five9LSP__Five9_List__c> updatedFive9List = [SELECT Id, Five9LSP__Disabled__c 
                                                    FROM Five9LSP__Five9_List__c 
                                                    WHERE Id = :testFive9List.Id];
        System.assertEquals(TRUE, updatedFive9List[0].Five9LSP__Disabled__c);
    }

    @isTest
    static void testCleanUpIntake() {
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
        testAcct.litify_pm__Email__c = 'test@example.com';
        testAcct.Secondary_Email__c = 'test2@example.com';
        insert testAcct;

        litify_pm__Intake__c testIntake = new litify_pm__Intake__c();
        testIntake.litify_pm__Email__c = 'test@example.com';
        testIntake.litify_pm__Client__c = testAcct.Id;
        insert testIntake;
        
        litify_pm__Public_Setup__c setting = new litify_pm__Public_Setup__c();
        setting.litify_pm__Run_Triggers__c = true;
        insert setting;
        
        Test.startTest();
        CleanupSandbox_ManuallyExecute.cleanupIntake();
        Test.stopTest();
        List<litify_pm__Intake__c> updatedIntake = [SELECT Id, litify_pm__Email__c
                                    FROM litify_pm__Intake__c 
                                    WHERE Id = :testIntake.Id];
        System.assertEquals('test@example.com.invalid', updatedIntake[0].litify_pm__Email__c);
    }
}