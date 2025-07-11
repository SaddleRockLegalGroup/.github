public class AccountTriggerHandler {
    Public static Boolean ranOnce = false;
    public static void isAfterInsert(List<Account>newAccounts){
        system.debug('AccountTriggerHandler');
        AccountTriggerHelper.concatPartyName(newAccounts);
    }
    public static void isBeforeUpdate(List<Account>newAccounts,Map<Id,Account>oldMap){
		system.debug('AccountTriggerHandler');
         AccountTriggerHelper.concatPartyName(newAccounts);
    }

}