@isTest
private class SC_TestDataFactoryTest {
    
    @isTest
    static void testCreateTestIntake() {
        // Call the method under test
        litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
        
        // Query the created record
        litify_pm__Intake__c retrievedIntake = [SELECT Id FROM litify_pm__Intake__c WHERE Id = :intake.Id];
        
        // Assert that the record was created successfully
        System.assertNotEquals(null, retrievedIntake, 'Intake record was not created successfully');
    }
    
    @isTest
    static void testCreateTestFileInfo() {
        // Call the method under test
        litify_docs__File_Info__c fileInfo = SC_TestDataFactory.createTestFileInfo();
        
        // Query the created record
        litify_docs__File_Info__c retrievedFileInfo = [SELECT Id FROM litify_docs__File_Info__c WHERE Id = :fileInfo.Id];
        
        // Assert that the record was created successfully
        System.assertNotEquals(null, retrievedFileInfo, 'File Info record was not created successfully');
    }
    
    @isTest
    static void testCreateTestDocrioSetting() {
        // Call the method under test
        docriosdk__Docrio_Tool_Setting__c setting = SC_TestDataFactory.createTestDocrioSetting();
        
        // Query the created record
        docriosdk__Docrio_Tool_Setting__c retrievedSetting = [SELECT Id FROM docriosdk__Docrio_Tool_Setting__c WHERE Id = :setting.Id];
        
        // Assert that the record was created successfully
        System.assertNotEquals(null, retrievedSetting, 'Docrio Tool Setting record was not created successfully');
    }
    
    @isTest
    static void testCreateTestSimplyConvertSetting() {
        // Call the method under test
        Simply_Convert_API_Setting__c setting = SC_TestDataFactory.createTestSimplyConvertSetting();
        
        // Query the created record
        Simply_Convert_API_Setting__c retrievedSetting = [SELECT Id FROM Simply_Convert_API_Setting__c WHERE Id = :setting.Id];
        
        // Assert that the record was created successfully
        System.assertNotEquals(null, retrievedSetting, 'Simply Convert API Setting record was not created successfully');
    }
}