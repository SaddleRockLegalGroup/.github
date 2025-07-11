public with sharing class FV_TestDataFactory {
    public static litify_pm__Intake__c createTestCallerClientIntake(){
        Account caller = new Account();
        caller.litify_pm__First_Name__c = 'John';
        caller.litify_pm__Last_Name__c = 'Doe';
        caller.Phone = '1111111111';
        caller.litify_pm__Phone_Mobile__c   = '1111111111';
        caller.litify_pm__Phone_Home__c   = '1111111111';
        caller.litify_pm__Phone_Work__c   = '1111111111';
        caller.litify_pm__Email__c = 'doejo@email.com';
        caller.Secondary_Email__c = 'doejo@email.com';
        caller.BillingStreet = '111 Test Street';
        caller.BillingCity = 'Test City';
        caller.BillingState = 'PA';
        caller.BillingPostalCode = '11111';
        caller.litify_pm__Social_Security_Number__c = '111111111';
        caller.litify_pm__Date_of_birth__c = Date.today();
        caller.Emergency_Contact_Name__c = 'Bill Doe';
        caller.Emergency_Contact_Phone__c = '9999999999';
        insert caller;
        
        Account client = new Account();
        client.litify_pm__First_Name__c = 'Jane';
        client.litify_pm__Last_Name__c = 'Doe';
        client.Phone = '1111111111';
        client.litify_pm__Phone_Mobile__c   = '1111111111';
        caller.litify_pm__Phone_Home__c   = '1111111111';
        caller.litify_pm__Phone_Work__c   = '1111111111';
        client.litify_pm__Email__c = 'doeja@email.com';
        caller.Secondary_Email__c = 'doejo@email.com';
        client.BillingStreet = '111 Test Street';
        client.BillingCity = 'Test City';
        client.BillingState = 'PA';
        client.BillingPostalCode = '11111';
        client.litify_pm__Social_Security_Number__c = '111111111';
        client.litify_pm__Date_of_birth__c = Date.today();
        insert client;

        Camp_Lejeune__c newCL = new Camp_Lejeune__c();
        newCL.First_Date_at_Camp_Lejuene__c = Date.today();
        newCL.Last_Date_at_Camp_Lejuene__c = Date.today();
        newCL.Military_veteran_mil_spouse_or_civ__c = 'Civilian';
        insert newCL;

        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = client.Id;
        newIntake.Caller__c = caller.Id;
        newIntake.Camp_Lejuene__c = newCL.Id;
        newIntake.Client_Estate_Opened__c = 'Yes';
        newIntake.Preferred_Method_of_Contact__c = 'Test';
        newIntake.Is_your_loved_one_still_living__c = 'No';
        insert newIntake;
        return newIntake;
    }

    public static litify_pm__Intake__c createTestCallerIntake(){
        Account newAcct = new Account();
        newAcct.litify_pm__First_Name__c = 'John';
        newAcct.litify_pm__Last_Name__c = 'Doe';
        newAcct.Phone = '1111111111';
        newAcct.litify_pm__Phone_Mobile__c   = '1111111111';
        newAcct.litify_pm__Email__c = 'doej@email.com';
        newAcct.BillingStreet = '111 Test Street';
        newAcct.BillingCity = 'Test City';
        newAcct.BillingState = 'PA';
        newAcct.BillingPostalCode = '11111';
        newAcct.litify_pm__Social_Security_Number__c = '111111111';
        newAcct.litify_pm__Date_of_birth__c = Date.today();
        insert newAcct;

        Camp_Lejeune__c newCL = new Camp_Lejeune__c();
        newCL.First_Date_at_Camp_Lejuene__c = Date.today();
        newCL.Last_Date_at_Camp_Lejuene__c = Date.today();
        insert newCL;

        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        newIntake.Caller__c = newAcct.Id;
        newIntake.Camp_Lejuene__c = newCL.Id;
        newIntake.Client_Estate_Opened__c = 'No';
        newIntake.Preferred_Method_of_Contact__c = 'Any';
        newIntake.What_is_your_relation_to_this_individual__c = 'Grandfather';
        insert newIntake;
        return newIntake;
    }
    public static litify_docs__File_Info__c createTestFileInfo(){
        litify_docs__File_Info__c fileInfo = new litify_docs__File_Info__c();
        fileInfo.Name = 'Test document';
        fileInfo.litify_docs__Description__c = 'This is a test';
        fileInfo.litify_docs__Author__c = 'Test User';
        fileInfo.litify_docs__Delete__c = false;
        fileInfo.litify_docs__Complete__c = true;
        insert fileInfo;
        return fileInfo;
    }
    public static docriosdk__Docrio_Tool_Setting__c createTestDocrioSetting(){
        docriosdk__Docrio_Tool_Setting__c setting = new docriosdk__Docrio_Tool_Setting__c();
        setting.docriosdk__Connected_App_Consumer_Key__c = 'TEST-DOCRIO-KEY';
        setting.docriosdk__Connected_App_Consumer_Secret__c = 'TEST-DOCRIO-SECRET';
        setting.docriosdk__API_Endpoint__c = 'https://api.123.genesisapi.com/v1';
        setting.docriosdk__Bucket_Name__c = 'https://456-us-east-2-documents.s3.us-east-2.amazonaws.com';
        insert setting;
        return setting;
    }
    public static Filevine_API_Settings__c createTestFilevineAPISetting(){
        Filevine_API_Settings__c setting = new Filevine_API_Settings__c();
        setting.Debugging__c = true;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Base_URL__c = 'https://simplyconvert.com/api/v2';
        setting.API_Key__c = '123';
        setting.API_Secret__c = '456';
        setting.Project_Type_ID__c = '4675';
        insert setting;
        return setting;
    }
}