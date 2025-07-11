@isTest
private class EmailMessage_SetEmailTempIdTriggerTest {
    @isTest
    static void testEmailTemplateCopy() {
        EmailTemplate et = [select id from EmailTemplate LIMIT 1];
        EmailMessage em = new EmailMessage(
            Subject = 'Test Email',
            FromAddress = 'test@example.com',
            ToAddress = 'user@example.com',
            Status = '0', // Draft
            TextBody = 'Test body',
            EmailTemplateId = et.id
        );
        insert em;

        EmailMessage inserted = [SELECT Id, EmailTemplateId, Email_Template_Id__c FROM EmailMessage WHERE Id = :em.Id];
        System.assertEquals(et.id, inserted.Email_Template_Id__c);
    }
}