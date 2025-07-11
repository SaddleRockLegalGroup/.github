@isTest
public class CMLocationTriggerHandler_Test {
	@isTest
    public static void testDeletionOfFirstLocation(){
        String ani='1112225555';
        IntakeTriggerHandler.ani = ani;
		litify_pm__Intake__c inta = new litify_pm__Intake__c(litify_pm__Phone__c=ani);
        insert inta;
        
        CM_Location__c location = new CM_Location__c();
        location.Provider_First_Name__c = 'Test';
        location.Provider_Last_Name__c = 'Lasty';
        location.Business_CompoundAddress__City__s = 'Provo';
        location.Business_CompoundAddress__Street__s = '1234 north 1400 west';
        location.Business_CompoundAddress__PostalCode__s = '84058';
        location.Medical_Type__c = 'Provider';
        location.Intake__c = inta.Id;
        
        test.startTest();
        CMLocationTriggerHandler.ranOnce = false;
        insert location;
        List<CM_Location__c>existingLocations = [Select Id,Business_CompoundAddress__City__s,Business_CompoundAddress__Street__s,Business_CompoundAddress__PostalCode__s 
                                                From CM_Location__c];
        system.assert(existingLocations.size()==1,'There should be 1 location');
        Test.stopTest();
                                               
    }
    
    @isTest
    public static void testDuplicateLocations(){
        String ani='1112225555';
        IntakeTriggerHandler.ani = ani;
		litify_pm__Intake__c inta = new litify_pm__Intake__c(litify_pm__Phone__c=ani);
        insert inta;
        
        CM_Location__c location = new CM_Location__c();
        location.Business_CompoundAddress__City__s = 'Provo';
        location.Business_CompoundAddress__Street__s = '1234 north 1400 west';
        location.Business_CompoundAddress__PostalCode__s = '84058';
        location.Medical_Type__c = 'Provider';
        location.Intake__c = inta.Id;
        location.Provider_First_Name__c = 'Test';
        location.Provider_Last_Name__c = 'Lasty';
        CMLocationTriggerHandler.ranOnce = true;
        insert location;
        
        CM_Location__c location2 = new CM_Location__c();
        location2.Business_CompoundAddress__City__s = 'Provo';
        location2.Business_CompoundAddress__Street__s = '1234 north 1400 west';
        location2.Business_CompoundAddress__PostalCode__s = '84058';
        location2.Medical_Type__c = 'Provider';
        location2.Provider_First_Name__c = 'Test2';
        location2.Provider_Last_Name__c = 'Lasty2';
        location2.Intake__c = inta.Id;
        
        test.startTest();
        CMLocationTriggerHandler.ranOnce = false;
        insert location2;
        
        Test.stopTest();
        List<CM_Location__c>existingLocations = [Select Id,Business_CompoundAddress__City__s,Business_CompoundAddress__Street__s,Business_CompoundAddress__PostalCode__s 
                                                From CM_Location__c];
        system.assert(existingLocations.size()==1,'There should be 1 location');
                                               
    }
}