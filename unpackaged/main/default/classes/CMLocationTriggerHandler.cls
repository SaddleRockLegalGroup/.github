//Created 03/05/25 by Scott Purcell
public class CMLocationTriggerHandler {
    public static boolean ranOnce = false;
    public static void isAfterInsert(List<CM_Location__c> locations){
        List<String>firstNames = new List<String>();
        List<String>lastNames = new List<String>();
        List<String>cities = new List<String>();
        List<String>addresses = new List<String>();
        List<String>zips = new List<String>();
        List<Id>intakeIds = new List<Id>();
        List<Id>dupes = new List<Id>();
        ranOnce = true;
        for(CM_Location__c loc:locations){
            cities.add(loc.Business_CompoundAddress__City__s);
            addresses.add(loc.Business_CompoundAddress__Street__s);
            zips.add(loc.Business_CompoundAddress__PostalCode__s);
            intakeIds.add(loc.Intake__c);
        }
        List<CM_Location__c>existingLocations = [Select Id,Medical_Type__c,Intake__c,Business_CompoundAddress__City__s,
                                                Business_CompoundAddress__Street__s,Business_CompoundAddress__PostalCode__s 
                                                From CM_Location__c 
                                                Where Business_CompoundAddress__City__s IN: cities
                                                AND Business_CompoundAddress__Street__s IN: addresses
                                                AND Business_CompoundAddress__PostalCode__s IN: zips
                                                AND Intake__c IN: intakeIds
                                                AND Id NOT IN:locations
                                               ];
        system.debug('ExistingLocations: '+existingLocations);
        if(existingLocations.size()>0){
            for(CM_Location__c loc:locations){
                for(CM_Location__c eloc:existingLocations){
                    if( loc.Medical_Type__c == eloc.Medical_Type__c
                       && loc.Business_CompoundAddress__City__s == eloc.Business_CompoundAddress__City__s 
                       && loc.Business_CompoundAddress__Street__s == eloc.Business_CompoundAddress__Street__s 
                       && loc.Business_CompoundAddress__PostalCode__s == eloc.Business_CompoundAddress__PostalCode__s
                       && loc.Intake__c == eloc.Intake__c){
                          system.debug('dupe added: '+loc);
                           dupes.add(loc.Id);
                       }
                }
            }
        }
        removeDuplicateLocation(dupes);
    }
    
    @future
    public static void removeDuplicateLocation(List<Id>dupes){
        try{
            system.debug('dupes: '+dupes);
            Database.delete(dupes);
        }catch(Exception e){
            system.debug('Exception: '+ e);
        }
    }
}