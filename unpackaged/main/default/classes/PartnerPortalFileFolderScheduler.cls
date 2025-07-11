/**
 * @description Partner Portal move File to Partner Folder
 */
public without sharing class PartnerPortalFileFolderScheduler implements Schedulable {
    /**
     * @description Execute
     * @params SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        Map<Id, Partner_Portal_File_Folder_Directory__mdt> mdt = new Map<Id, Partner_Portal_File_Folder_Directory__mdt>();
        Map<Id, Id> docMap = new Map<Id, Id>();
        List<ContentDocumentLink> createDocLinks = new List<ContentDocumentLink>();
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Set<Id> movedFiles = new Set<Id>();
        Set<Id> newDocIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> docIds = new Set<Id>();
        Boolean matchingSize = false;

        List<Partner_Portal_File_Folder_Directory__mdt> folderMetadata = getFolderMetadata(); // get the metadata with library mapping

        mdt = getMdtMap(folderMetadata);

        if (!mdt.isEmpty()) { userIds = mdt.keySet(); } // get user ids

        List<ContentDocumentLink> docs = getContentDocumentLinks(userIds); // get documents from partner portal users

        if (docs.isEmpty()) {
            selfReschedule();

            return;
        }

        for (ContentDocumentLink d : docs) {
            docMap.put(d.ContentDocumentId, d.LinkedEntityId); // map document to user

            String libraryId = mdt.get(d.LinkedEntityId).Partner_Library_Id__c;
            ContentDocumentLink docLink = createDocumentLink(d.ContentDocumentId, libraryId); // create a document link record for the library association
            createDocLinks.add(docLink);
        }

        if (!docMap.isEmpty()) { docIds = docMap.keySet(); } // get all doc ids being processed

        Database.SaveResult[] srList = Database.insert(createDocLinks, false); // allow partial save of new doc link to move to library

        // Iterate through each returned result and get ids
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) { movedFiles.add(sr.getId()); } // get new ids
        }

        matchingSize = movedFiles.size() == docIds.size();
        if (!matchingSize) {
            newLinks = getContentDocumentLinksById(movedFiles); // get success/failure files
            for (ContentDocumentLink n : newLinks) {
                newDocIds.add(n.ContentDocumentId); // new files
            }
        }

        messages = getEmails(docs, docMap, mdt, newDocIds, matchingSize);

        if (!Test.isRunningTest()) { Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); } // send emails

        selfReschedule(); // schedule job every 5 minutes
    }

    /**
     * @description Metadata Mapped to User
     * @return Map<Id, Partner_Portal_File_Folder_Directory__mdt>
     * @params List<Partner_Portal_File_Folder_Directory__mdt>
     */
    private Map<Id, Partner_Portal_File_Folder_Directory__mdt> getMdtMap(List<Partner_Portal_File_Folder_Directory__mdt> folderMetadata) {
        Map<Id, Partner_Portal_File_Folder_Directory__mdt> mdt = new Map<Id, Partner_Portal_File_Folder_Directory__mdt>();

        for (Partner_Portal_File_Folder_Directory__mdt meta : folderMetadata) {
            if (!String.isBlank(meta.User__c)) { mdt.put(meta.User__c, meta); } // map metadata to user

            if (Test.isRunningTest() && meta.Folder_Name__c == 'Unit Test') { mdt.put(UserInfo.getUserId(), meta); } // set test metadata
        }

        return mdt;
    }

    /**
     * @description Create Document Link to Move File
     * @return ContentDocumentLink
     * @params String docId
     * @params String libraryId
     */
    private ContentDocumentLink createDocumentLink(String docId, String libraryId) {
        // create library association record for file
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.ContentDocumentId = docId;
        docLink.LinkedEntityId = libraryId;
        docLink.ShareType = 'I';
        docLink.Visibility = 'AllUsers';

        return docLink;
    }

    /**
     * @description Partner Metadata for File Structure
     * @return List<Partner_Portal_File_Folder_Directory__mdt>
     */
    private List<Partner_Portal_File_Folder_Directory__mdt> getFolderMetadata() {
        List<Partner_Portal_File_Folder_Directory__mdt> ppFolders = new List<Partner_Portal_File_Folder_Directory__mdt>([
            SELECT MasterLabel, Username__c, Partner_Library_Id__c, Folder_Name__c, Party_Name__c, User__c, Success_Email__c, Failure_Email__c
            FROM Partner_Portal_File_Folder_Directory__mdt
        ]);

        return ppFolders;
    }

    /**
     * @description Partner Document Link
     * @return List<ContentDocumentLink>
     * @params Set<Id> userIds
     */
    private List<ContentDocumentLink> getContentDocumentLinks(Set<Id> userIds) {
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>([
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (SELECT Id FROM User WHERE Id IN :userIds)
        ]);

        return docLinks;
    }

    /**
     * @description Documents to Move
     * @return List<ContentDocumentLink>
     * @params Set<Id> docLinkIds
     */
    private List<ContentDocumentLink> getContentDocumentLinksById(Set<Id> docLinkIds) {
        if (docLinkIds.isEmpty() || docLinkIds == null) { return new List<ContentDocumentLink>(); }

        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>([
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, LinkedEntityId
            FROM ContentDocumentLink
            WHERE Id IN :docLinkIds
        ]);

        return docLinks;
    }

    /**
     * @description Create Emails
     * @return List<Messaging.SingleEmailMessage>
     * @params List<ContentDocumentLink> docs, Map<Id, Id> mdt, Set<Id> newDocIds, Boolean matchingSize
     */
    private List<Messaging.SingleEmailMessage> getEmails(List<ContentDocumentLink> docs, Map<Id, Id> docMap, Map<Id, Partner_Portal_File_Folder_Directory__mdt> mdt, Set<Id> newDocIds, Boolean matchingSize) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        String ppMessage = 'Partner Portal: File ';

        for (ContentDocumentLink d : docs) {
            Id uId = docMap?.get(d.ContentDocumentId); // user id to get metadata
            String folderName = mdt?.get(uId).Folder_Name__c; // folder name from metadata
            String partnerId = mdt?.get(uId).User__c;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            if (newDocIds?.contains(d.ContentDocumentId) || matchingSize) { // success emails
                String successRecp = mdt?.get(uId).Success_Email__c; // success email from metadata
                if (!String.isBlank(successRecp)) {
                    email = fileUploadNotification(successRecp, partnerId, ppMessage + 'Uploaded to ' + folderName, ppMessage + 'uploaded to ' + folderName + ' successfully.', true);
                    messages.add(email);
                }
            } else { // failure emails
                String failRecp = mdt?.get(uId).Failure_Email__c; // failure email from metadata
                if (!String.isBlank(failRecp)) {
                    email = fileUploadNotification(failRecp, partnerId, ppMessage + 'Upload Failed ' + folderName, ppMessage + 'upload to ' + folderName + ' failure.', false);
                    messages.add(email);
                }
            }
        }

        return messages;
    }

    /**
     * @description Email Notification
     * @return Messaging.SingleEmailMessage
     * @params String recipient, Id partnerId, String subject, String textBody, Boolean success
     */
    private Messaging.SingleEmailMessage fileUploadNotification(String recipient, Id partnerId, String subject, String textBody, Boolean success) {
        List<String> recipients = !String.isBlank(recipient) && recipient.contains(',') ? recipient.split(',') : new List<String>{recipient};

        // create notification
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = recipients;
        message.setTreatTargetObjectAsRecipient(false);
        message.setTargetObjectId(partnerId);
        message.subject = subject;
        message.plaintextbody = textBody;

        return message;
    }

    /**
     * @description Reschedule Job
     */
    private void selfReschedule() { // schedule next job in 5 min
        Integer min = System.now().minute();
        Integer hr = System.now().hour();
        String sec = String.valueOf(System.now().second());

        String calcMin = String.valueOf(min < 55 ? min + 5 : 1);
        String calcHr = String.valueOf(min < 55 ? hr : (hr < 23 ? hr + 1 : 0));

        String cron = sec + ' ' + calcMin + ' ' + calcHr + ' * * ?';
        PartnerPortalFileFolderScheduler pps = new PartnerPortalFileFolderScheduler();
        System.schedule('Partner Portal Job ' + cron, cron, pps);

        cleanup();
    }

    /**
     * @description Delete Old Job
     */
    private void cleanup() { // abort old job
        List<CronTrigger> cron = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Partner Portal Job%' AND TimesTriggered > 0];

        for (CronTrigger ct : cron) {
            System.abortJob(ct.Id);
        }
    }
}