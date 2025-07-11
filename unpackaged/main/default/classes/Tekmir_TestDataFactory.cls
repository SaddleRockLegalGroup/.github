public with sharing class Tekmir_TestDataFactory {    
    public static litify_pm__Intake__c createTestIntake(){
        // Create test client
        Account newAcct = new Account();
        newAcct.litify_pm__First_Name__c = 'John';
        newAcct.litify_pm__Last_Name__c = 'Doe';
        newAcct.Phone = '1111111111';
        newAcct.litify_pm__Phone_Mobile__c   = '1111111111';
        newAcct.litify_pm__Email__c = 'doej@email.com';
        newAcct.BillingStreet = '111 Test Street';
        newAcct.BillingCity = 'Test City';
        newAcct.BillingState = 'Pennsylvania';
        newAcct.BillingPostalCode = '11111';
        newAcct.litify_pm__Social_Security_Number__c = '111111111';
        newAcct.litify_pm__Date_of_birth__c = Date.today();
        insert newAcct;

        // Create test intake
        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = newAcct.Id;
        newIntake.Caller__c = newAcct.Id;
        newIntake.Calling_on_behalf_of_you_or_loved_one__c = 'Loved one';
        insert newIntake;
        
        // Create test client address
        srlg_Address__c clientAddress = new srlg_Address__c();
        clientAddress.Street1__c = '123 Test Ave';
        clientAddress.Street2__c = '';
        clientAddress.City__c = 'Test';
        clientAddress.State__c = 'PA';
        clientAddress.Zip__c = '12345';
        clientAddress.Is_Mailing__c = 'Yes';
        clientAddress.Is_Residence__c = 'Yes';
        clientAddress.Client__c = newAcct.Id;
        clientAddress.Intake__c = newIntake.Id;
        insert clientAddress;

        // Create test injured party
        srlg_Injured_Party__c injuredParty = new srlg_Injured_Party__c();
        injuredParty.Intake__c = newIntake.Id;
        insert injuredParty;

        // Create test injured party address
        srlg_Address__c injuredPartyAddress = new srlg_Address__c();
        injuredPartyAddress.Street1__c = '456 Test Blvd';
        injuredPartyAddress.Street2__c = '';
        injuredPartyAddress.City__c = 'Test City';
        injuredPartyAddress.State__c = 'PA';
        injuredPartyAddress.Zip__c = '12345';
        injuredPartyAddress.Is_Mailing__c = 'Yes';
        injuredPartyAddress.Is_Residence__c = 'Yes';
        injuredPartyAddress.Injured_Party__c = injuredParty.Id;
        injuredPartyAddress.Intake__c = newIntake.Id;
        insert injuredPartyAddress;

        // Create test emergency contact
        srlg_Emergency_Contact__c emergencyContact = new srlg_Emergency_Contact__c();
        emergencyContact.First_Name__c = 'Jane';
        emergencyContact.Last_Name__c = 'Doe';
        emergencyContact.Suffix__c = 'Jr';
        emergencyContact.Phone__c = '2222222222';
        emergencyContact.Relationship__c = 'Self';
        emergencyContact.Intake__c = newIntake.Id;
        insert emergencyContact;

        // Create test exposure
        srlg_Exposure__c exposure = new srlg_Exposure__c();
        exposure.Start_Date__c = Date.today().addDays(-30); // 30 days ago
        exposure.End_Date__c = Date.today(); // today
        exposure.Product_Container_Size__c = 'Test';
        exposure.Client_Has_Photo_Of_Usage__c = 'Yes';
        exposure.Client_Has_Product_Container__c = 'Yes';
        exposure.Client_Has_Purchase_Receipts__c = 'Yes';
        exposure.Intake__c = newIntake.Id;
        insert exposure;

        // Create test injury
        srlg_Injury__c injury = new srlg_Injury__c();
        injury.Type__c = 'Test Injury Type';
        injury.Intake__c = newIntake.Id;
        insert injury;

        // Create test alternative cause detail
        srlg_Alternative_Cause_Detail__c alternativeCauseDetail = new srlg_Alternative_Cause_Detail__c();
        alternativeCauseDetail.Intake__c = newIntake.Id;
        insert alternativeCauseDetail;

        // Create test medical facility
        CM_Location__c medicalFacility = new CM_Location__c();
        medicalFacility.Name_of_Location__c = 'Test Medical Facility';
        medicalFacility.Intake__c = newIntake.Id;
        insert medicalFacility;
        srlg_Provider__c provider = new srlg_Provider__c();
        provider.First_Name__c = 'Test';
        provider.Last_Name__c = 'Provider';
        provider.CM_Location__c = medicalFacility.Id;
        insert provider;

        // Create test employment history
        srlg_Employment_History__c employmentHistory = new srlg_Employment_History__c();
        employmentHistory.Intake__c = newIntake.Id;
        employmentHistory.Current_Occupation_Start_Date__c = Date.today().addYears(-1);
        insert employmentHistory;

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
    public static Tekmir_API_Settings__c createTestTekmirAPISetting(Boolean testMode){
        Tekmir_API_Settings__c setting = new Tekmir_API_Settings__c();
        setting.Debugging__c = true;
        setting.Log_Levels__c = 'ERROR, INFO, DEBUG';
        setting.Named_Credentials_Staging__c = 'https://TekmirAPIStaging.com/api/v2';
        setting.Named_Credentials_Prod__c = 'https://TekmirAPIProd.com/api/v2';
        setting.Test_mode__c = testMode;
        insert setting;
        return setting;
    }
}