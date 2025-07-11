//Created 02/26/25 by Scott Purcell
public class IntakeTriggerHelper {
	public static String ani {get;set;}
    
    public static void runMatching(List<Id>intakeIds){
        IntakeTriggerHandler.runOnce = true;
        system.debug('ani: '+ani+'  IntakeTriggerHandler.matchDial800.intakeIds: '+intakeIds);
        DateTime twelveHoursAgo = DateTime.now().addHours(-12);
        List<Dial800__c> dial800List = new List<Dial800__c>();
        List<litify_pm__Intake__c> intakesToUpdate = new List<litify_pm__Intake__c>();
        Map<String,litify_pm__Intake__c>intakesMap = new Map<String,litify_pm__Intake__c>();
        for(litify_pm__Intake__c intake:[Select Id, D8_Call_Id__c,litify_pm__Phone__c,D8_ANI__c,D8_Connected_Duration__c,D8_Duration__c,D8_Status__c,D8_Target__c,D8_Call_Start__c,
                                         D8_Media_Agency__c,ani_identifier__c,Marketing_Campaign__c,MarketingTVStation__c,
                                         litify_pm__Case_City__c ,ani_assigned__c, litify_pm__Case_Postal_Code__c,litify_pm__Case_State__c    
                                         From litify_pm__Intake__c Where Id IN:intakeIds]){
            system.debug('intake: '+intake );
            if(intake.litify_pm__Phone__c != null && ani == null){
                intakesMap.put(intake.litify_pm__Phone__c,intake);
            }else if(Test.isRunningTest() && ani != null){intakesMap.put(ani,intake);}
        }
        system.debug('IntakeTriggerHelper.runMatchingintakesMap.keyset(),size(): '+intakesMap.keyset().size());
        system.debug('IntakeTriggerHelper.runMatching.intakesMap.values().size(): '+intakesMap.values().Size());
        
        for(Dial800__c detail:[Select Id,ANI__c,Call_Start__c ,Station__c,State__c,Call_Id__c,DNIS__c,Connected_Duration__c,Duration__c,Intake__c,
            Media_Agency__c,Campaign__c,Postal_Code__c,City__c,Status__c,Target__c,Name 
            From Dial800__c Where ANI__c IN: intakesMap.keySet() AND Intake__c = null]){
                system.debug('IntakeTriggerHelper.runMatching.dial800 record: '+detail);
                if(intakesMap.containsKey(detail.ANI__c)&& !intakesToUpdate.contains(intakesMap.get(detail.ANI__c))){
                    if(intakesMap.get(detail.ANI__c).D8_ANI__c == null){
                    	intakesMap.get(detail.ANI__c).D8_DNIS__c = detail.DNIS__c;
                        intakesMap.get(detail.ANI__c).MarketingTVStation__c = detail.Station__c;
                        intakesMap.get(detail.ANI__c).D8_ANI__c = detail.ANI__c;
                        if(intakesMap.get(detail.ANI__c).litify_pm__Case_City__c==null)intakesMap.get(detail.ANI__c).litify_pm__Case_City__c  = detail.City__c;
                        intakesMap.get(detail.ANI__c).D8_Connected_Duration__c = detail.Connected_Duration__c;
                        intakesMap.get(detail.ANI__c).D8_Duration__c = detail.Duration__c;
                        if(intakesMap.get(detail.ANI__c).litify_pm__Case_Postal_Code__c==null)intakesMap.get(detail.ANI__c).litify_pm__Case_Postal_Code__c = String.valueOf(detail.Postal_Code__c);
                        intakesMap.get(detail.ANI__c).D8_Status__c = detail.Status__c;
                        intakesMap.get(detail.ANI__c).D8_Target__c = detail.Target__c;
                        intakesMap.get(detail.ANI__c).D8_Call_Start__c  = detail.Call_Start__c ;
                        intakesMap.get(detail.ANI__c).Marketing_Campaign__c   = detail.Campaign__c ;
                        intakesMap.get(detail.ANI__c).D8_Media_Agency__c  = detail.Media_Agency__c ;
                        intakesMap.get(detail.ANI__c).D8_Call_Id__c  = detail.Call_Id__c ;
                        
                        intakesToUpdate.add(intakesMap.get(detail.ANI__c));
                    }
                    detail.Intake__c = intakesMap.get(detail.ANI__c).Id;
                    dial800List.add(detail);
                }
        }
        try{
            system.debug('IntakeTriggerHelper.runMatching.isUpdate?: '+IntakeTriggerHandler.isUpdate);
            if(!IntakeTriggerHandler.isUpdate)Update intakesToUpdate;
            system.debug('IntakeTriggerHelper.runMatching.updated intakesToUpdate: '+intakesToUpdate);
            update dial800List;
            system.debug('IntakeTriggerHelper.runMatching.updated idial800List: '+dial800List);
        }catch (Exception ex) {system.debug('IntakeTriggerHelper.runMatching.Error creating record: ' + ex.getMessage());throw ex;}
    }
}