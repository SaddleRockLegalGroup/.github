trigger EmailMessage_SetEmailTemplateIdTrigger on EmailMessage (before insert) {
    for (EmailMessage em : Trigger.new) {
        if (em.EmailTemplateId != null) {
            em.Email_Template_Id__c = em.EmailTemplateId;
        }
    }
}