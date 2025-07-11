trigger triggerAttatchFiletoSignEvent on Dropbox_Sign_Event__ChangeEvent (after insert) {

    for(Dropbox_Sign_Event__ChangeEvent signEvent : Trigger.new) {
        String filesUrl = signEvent.Files_Url__c;
        List<Id> recordIds = signEvent.ChangeEventHeader.getRecordIds();
        String signEventId = recordIds[0];
        String eventType = signEvent.Event_Type__c;
        Boolean getFile = signEvent.Get_File__c;
        String intakeId = signEvent.Intake__c;
        System.debug('Changed Record : '+ signEvent.ChangeEventHeader.getRecordIds());
        System.debug('Changed Fields : '+ signEvent.ChangeEventHeader.getChangedFields());
        String title = signEvent.Title__c;
        if(eventType == 'signature_request_all_signed' || getFile == true){
            //BRIOGetDropboxFile.getDBFile(filesUrl,title, signEventId);
            DownloadFIleUsingDocrioSDK.getFileForDocrio(filesUrl,title, signEventId,intakeId);
            //Update Intake status to 'Retainer Agreement Signed'
            UpdateIntakeStatus.updateStatus(intakeId);
        }
        else {
            System.debug('File not gotten');
        }
        }
    }