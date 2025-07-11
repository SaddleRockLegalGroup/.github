/**
 * @description Partner Portal 15 Day Reporting Notice
 */
public without sharing class PartnerPortalReportNotification implements Schedulable {
    /**
     * @description Execute
     * @params SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        Map<String, String> recipientMap = new Map<String, String>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Set<String> libraryIds = new Set<String>();
        Set<String> entityIds = new Set<String>();
        Set<String> recipients = new Set<String>();
        Set<String> userIds = new Set<String>();
        String emailTemplateName = 'Partner_Reconciliation_Report_Notification';

        List<Partner_Portal_File_Folder_Directory__mdt> folderMetadata = getFolderMetadata(); // get the metadata with library mapping

        for (Partner_Portal_File_Folder_Directory__mdt meta : folderMetadata) {
            libraryIds.add(meta.Partner_Library_Id__c); // get libraries to check for documents
            userIds.add(meta.User__c);
        }

        List<ContentDocumentLink> docs = getContentDocumentLinks(libraryIds, userIds); // get documents from libraries

        for (ContentDocumentLink d : docs) {
            entityIds.add(d.LinkedEntityId); // libraries updated in last 14 days
        }

        for (Partner_Portal_File_Folder_Directory__mdt meta : folderMetadata) {
            if (entityIds.isEmpty() || !entityIds.contains(meta.Partner_Library_Id__c)) { recipientMap.put(meta.User_Email__c, meta.User__c); }
        }

        if (!recipientMap.isEmpty()) {
            recipients = recipientMap.keySet();
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:emailTemplateName];

            for (String rec : recipients) {
                Messaging.SingleEmailMessage message = reportNotification(rec, recipientMap.get(rec), et.Id);
                messages.add(message);
            }
        }

        if (!Test.isRunningTest()) { Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); } // send emails

        selfReschedule();
    }

    /**
     * @description Folder Metadata
     * @return List<Partner_Portal_File_Folder_Directory__mdt>
     */
    private List<Partner_Portal_File_Folder_Directory__mdt> getFolderMetadata() {
        List<Partner_Portal_File_Folder_Directory__mdt> ppFolders = new List<Partner_Portal_File_Folder_Directory__mdt>([
            SELECT MasterLabel, Partner_Library_Id__c, Folder_Name__c, Party_Name__c, User__c, User_Email__c, Username__c, Success_Email__c, Failure_Email__c
            FROM Partner_Portal_File_Folder_Directory__mdt
            WHERE User_Email__c != '' AND Partner_Library_Id__c != ''
        ]);

        return ppFolders;
    }

    /**
     * @description Get Document Links
     * @return List<ContentDocumentLink>
     * @params Set<String> libraryIds, Set<String> userIds
     */
    private List<ContentDocumentLink> getContentDocumentLinks(Set<String> libraryIds, Set<String> userIds) {
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>([
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, LinkedEntityId
            FROM ContentDocumentLink
            WHERE (LinkedEntityId IN :libraryIds OR LinkedEntityId IN :userIds) AND ContentDocument.CreatedDate = LAST_N_DAYS:14
        ]);

        return docLinks;
    }

    /**
     * @description Reporting Notification Email
     * @return Messaging.SingleEmailMessage
     * @params String recipient, String partnerId, Id templateId
     */
    private Messaging.SingleEmailMessage reportNotification(String recipient, String partnerId, Id templateId) {
        // create notification
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { recipient };
        message.setTemplateId(templateId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setTargetObjectId(partnerId);

        return message;
    }

    /**
     * @description Reschedule Job
     */
    private void selfReschedule() { // schedule next job in 1 day
        Integer min = System.now().minute();
        Integer hr = System.now().hour();
        String sec = String.valueOf(System.now().second());

        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        PartnerPortalReportNotification pps = new PartnerPortalReportNotification();
        System.schedule('Partner Portal Report Notification ' + cron, cron, pps);

        cleanup();
    }

    /**
     * @description Delete Old Job
     */
    private void cleanup() { // abort old job
        List<CronTrigger> cron = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Partner Portal Report Notification%' AND TimesTriggered > 0];

        for (CronTrigger ct : cron) {
            System.abortJob(ct.Id);
        }
    }
}