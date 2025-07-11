@isTest
public class AccountTriggerHandler_Test {

    @isTest
    public static void testAccountTriggerAfterInsert(){
        Account acc = new Account();
        acc.Name = 'bob';
        acc.litify_pm__First_Name__c = 'First';
        acc.litify_pm__Last_Name__c = 'Last';
        acc.Suffix__c = 'Sr.';
        acc.litify_pm__Phone_Mobile__c  = '1112223344';
        test.startTest();
        insert acc;
       test.stopTest();
}
    
    @isTest
    public static void testAccountTriggerAfterInsertMiddleName(){
        Account acc = new Account();
        acc.Name = 'bob';
        acc.litify_pm__First_Name__c = 'First';
        acc.litify_pm__Last_Name__c = 'Last';
        acc.Middle_Name__c = 'Middle';
        acc.Suffix__c = 'Sr.';
        acc.litify_pm__Phone_Mobile__c  = '1112223344';
        test.startTest();
        insert acc;
       test.stopTest();
}
    
    @isTest
    public static void testAccountTriggerBeforeUpdate(){
        Account acc = new Account();
        acc.Name = 'bob';
        acc.litify_pm__First_Name__c = 'First';
        acc.litify_pm__Last_Name__c = 'Last';
        acc.litify_pm__Phone_Mobile__c  = '1112223344';
        insert acc;
        AccountTriggerHandler.ranOnce = false;
        
        test.startTest();
        acc.Suffix__c = 'Sr.';
        update acc;
      test.stopTest();
        
    }
    
    @isTest
    public static void testAccountTriggerBeforeUpdateMiddleName(){
        Account acc = new Account();
        acc.Name = 'bob';
        acc.litify_pm__First_Name__c = 'First';
        acc.litify_pm__Last_Name__c = 'Last';
        acc.litify_pm__Phone_Mobile__c  = '1112223344';
        acc.Middle_Name__c = 'Middle';
        insert acc;
        AccountTriggerHandler.ranOnce = false;
        
        test.startTest();
        acc.Suffix__c = 'Sr.';
        update acc;
test.stopTest();
        
    }
}