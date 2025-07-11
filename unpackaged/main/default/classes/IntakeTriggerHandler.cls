//Created 02/26/25 by Scott Purcell
public class IntakeTriggerHandler {
    public static Boolean runOnce = false;
    public static Boolean isUpdate = false;
    public static string ani ='';
    
    public static void isAfterInsertUpdate(List<litify_pm__Intake__c>newList,Boolean isupdate){
       
        isUpdate = isupdate;
        runOnce = true;
        system.debug('intakeTriggerHandler.isAfterInsert:newList: '+newList);
        List<Id> intakeIds = new List<Id>();
        for (litify_pm__Intake__c record : newList) {
            // record should be less than 24hrs old to match with a dial800
            if(record.CreatedDate > DateTime.now().addHours(-24)){
    			intakeIds.add(record.Id);
            }
		}
        system.debug('intakeTriggerHandler.isAfterInsert.intakeids: '+intakeIds);
        system.debug('intakeTriggerHandler.isAfterInsert.isUpdate: '+isUpdate);
        if(!isUpdate)matchDial800(intakeIds);
        else if(isUpdate)IntakeTriggerHelper.runMatching(intakeIds);
    }
    public static void isBeforeInsert(List<litify_pm__Intake__c> intakes){
        system.debug('isBeforeInsert');
    }
    public static void isBeforeUpdate(List<litify_pm__Intake__c>newList){
       system.debug('isBeforeUpdate');
    }
    @Future
    public static void matchDial800(List<Id>intakeIds){
        system.debug('intakeTriggerHandler.isAfterInsert.matchDial800');
        IntakeTriggerHelper.runMatching(intakeIds);
    }
}