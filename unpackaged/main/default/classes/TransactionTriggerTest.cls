@isTest(SeeAllData=false)
private class TransactionTriggerTest {
    @testSetup static void initData() {
        Financials__c setting = new Financials__c();
        setting.Enable_Transaction_Calculation__c = true;
        insert setting;
        
        List<Account> l_accounts = new List<Account>();
        Account acc1 = new Account(litify_pm__First_Name__c ='Account 1', litify_pm__Last_Name__c ='Last Name 1');
        acc1.BillingCity = 'New York';
        acc1.BillingCountry = 'United States';
        acc1.BillingStreet = 'Avenue';
        acc1.BillingPostalCode = '12412';
        l_accounts.add(acc1);
        Account acc2 = new Account(litify_pm__First_Name__c ='Account 2', litify_pm__Last_Name__c ='Last Name 2');
        acc2.BillingCity = 'New York';
        acc2.BillingCountry = 'United States';
        acc2.BillingStreet = 'Avenue';
        acc2.BillingPostalCode = '12412';
        l_accounts.add(acc2);
        insert l_accounts;
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acc1.Id;
        insert intake;
       
        List<litify_PM__Matter__c> mattersToInsert = new List<litify_PM__Matter__c>();
        litify_PM__Matter__c matter = new litify_PM__Matter__c();
        matter.litify_pm__Client__c = acc1.Id;
        matter.litify_pm__Display_Name__c = 'matter test 1';
        mattersToInsert.add(matter);
        insert mattersToInsert;

        /*litify_pm__Negotiation__c negotiation = new litify_pm__Negotiation__c (Name = 'Name', litify_pm__Matter__c = m1.Id, litify_ext__Negotiating_with_Party__c = acc2.Id);
        insert negotiation;
        litify_pm__Lien__c lien = new litify_pm__Lien__c(Name = 'Test', litify_pm__lit_Matter__c = m1.Id, litify_ext__Payee_Party__c = acc2.Id);
        insert lien;
        
        litify_pm__Expense__c expense = new litify_pm__Expense__c( litify_pm__Matter__c = m1.Id,litify_pm__Amount__c = 1, litify_pm__Date__c = Date.Today(),  litify_ext__Payee_Party__c  = acc2.Id);
        insert expense;
        litify_pm__Request__c request = new litify_pm__Request__c(Name = 'TEST', litify_pm__Matter__c = m1.Id, litify_ext__Facility_Party__c  = acc2.Id);
        insert request;*/
        litify_pm__Role__c role1 = new litify_pm__Role__c();
        role1.litify_pm__Party__c =  acc2.Id;
        role1.litify_PM__Matter__c = matter.Id;
        role1.litify_pm__Role__c = 'Other';
        insert role1;

        litify_pm__Expense__c expense1 = new litify_pm__Expense__c( litify_pm__Matter__c = matter.Id,litify_pm__Amount__c = 1, litify_pm__Date__c = Date.Today(),  litify_ext__Payee_Party__c  = acc1.Id);
        insert expense1;
        litify_pm__Expense__c expense2 = new litify_pm__Expense__c( litify_pm__Matter__c = matter.Id,litify_pm__Amount__c = 1, litify_pm__Date__c = Date.Today(),  litify_ext__Payee_Party__c  = acc2.Id);
        insert expense2;
        litify_fin__lit_Financial_Summary_Setup_Parent__c parentSetup = new litify_fin__lit_Financial_Summary_Setup_Parent__c();
        parentSetup.Name = 'basic Setup';
        insert parentSetup;
        litify_fin__lit_Financials_Summary_Setup__c fSetup = new litify_fin__lit_Financials_Summary_Setup__c();
        fSetup.litify_fin__lit_Active__c = true;
        fSetup.litify_fin__lit_Financial_Summary_Setup_Parent__c = parentSetup.Id;
        fSetup.litify_fin__lit_Master_Object__c = 'litify_pm__Matter__c';
        fSetup.litify_fin__lit_Type__c = 'Standard';
        fSetup.Name = 'Base Setup';
        insert fSetup;
        litify_fin__lit_Group_Template__c template = new litify_fin__lit_Group_Template__c();
        template.litify_fin__lit_Financials_Summary_Setup__c = fSetup.Id;
        template.litify_fin__lit_Is_Multi_Item_Group__c = false;
        template.litify_fin__lit_Transaction_Type__c = 'Debit';
        template.Name = 'Expenses Due To Vendors';
        insert template;
    }


    static testmethod void test_transaction_update() {
        Account acc1 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c = 'Account 1'];
        Account acc2 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c = 'Account 2'];
        litify_pm__Expense__c  expense1 = [SELECT ID,litify_pm__lit_Reductions__c FROM litify_pm__Expense__c WHERE litify_ext__Payee_Party__c = :acc1.Id];
        litify_pm__Expense__c  expense2 = [SELECT ID FROM litify_pm__Expense__c WHERE litify_ext__Payee_Party__c = :acc2.Id];
        litify_PM__Matter__c matter = [SELECT ID FROM litify_PM__Matter__c  LIMIT 1];
        litify_fin__lit_Group_Template__c group_template = [SELECT ID FROM litify_fin__lit_Group_Template__c LIMIT 1];
        Test.startTest();
        litify_fin__lit_Transaction__c record = new litify_fin__lit_Transaction__c();
        record.litify_fin__lit_Amount__c = 100;
        record.litify_fin__lit_Item__c = expense1.Id;
        record.litify_fin__lit_Group_Template__c = group_template.Id;
        record.litify_fin__lit_Payor_Payee__c = acc1.Id;
        record.litify_fin__lit_Transaction_Type__c = 'Debit';
        record.litify_fin__lit_Account_Source__c = 'Trust';
        record.litify_fin__lit_Related_Record__c = matter.Id;
        insert record;
        record.litify_fin__lit_Item__c = expense2.Id;
        //update record;
        expense1 = [SELECT ID,litify_pm__lit_Reductions__c FROM litify_pm__Expense__c WHERE ID =: expense1.Id];
        system.assert(expense1.litify_pm__lit_Reductions__c == 100);
        delete record;
        expense1 = [SELECT ID,litify_pm__lit_Reductions__c FROM litify_pm__Expense__c WHERE ID =: expense1.Id];
        system.assert(expense1.litify_pm__lit_Reductions__c == 0);
        Test.stopTest();
    } 

}