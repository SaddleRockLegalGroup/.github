public with sharing class SC_TestDataFactory {
    public static litify_pm__Intake__c createTestIntake(){
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
        //newCL.Cancer_disease_syndrome_fertility_issue__c = 'None of the above';
        //newCL.Military_veteran_mil_spouse_or_civ__c = 'Military veteran';
        //newCL.How_long_did_you_stay_at_Camp_Lejuene__c =  '30 or more days in total';
        newCL.First_Date_at_Camp_Lejuene__c = Date.today();
        newCL.Last_Date_at_Camp_Lejuene__c = Date.today();
        newCL.While_at_Camp_Lejeune_please_indicated__c = 'Other';
        insert newCL;

        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        newIntake.Caller__c = newAcct.Id;
        newIntake.Camp_Lejuene__c = newCL.Id;
        newIntake.API_Casesafe_Id__c = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
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
    public static Simply_Convert_API_Setting__c createTestSimplyConvertSetting(){
        Simply_Convert_API_Setting__c setting = new Simply_Convert_API_Setting__c();
        setting.Debugging__c = true;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Base_URL__c = 'https://simplyconvert.com/api/v2';
        setting.API_Key__c = '123';
        insert setting;
        return setting;
    }
}