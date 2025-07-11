//test in restExplorer w/ this link: /services/apexrest/intakedesksync and use the json from the testclass
//Edited by Scott Purcell 3/13/25 - added debug statements
//updated by Scott Purcell 3/24/25 - moved record creation and QC checking to their own classes.

// Updated by Duyen Doan 6/2/2025
// - Update response data model. Returning the original request plus intake ID instead.
@RestResource(urlMapping='/intakedesksync/*')
global class IntakeDesk_SyncHandler {
    public static Boolean dq {get;set;}
    @HttpPost
    global static void doPost(){
        dq = false;
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;		
        
        Date diagnosisDate;
        String rawData = req.requestBody.toString();
        system.debug('RawData: '+rawData);
        Map<String, Object> dataParsed = (Map<String, Object>) JSON.deserializeUntyped(rawData);
        brioapi__Integration_Transaction__c transLog = new brioapi__Integration_Transaction__c();
        String integrationId = String.valueOf(dataParsed.get('integrationId'));
        String data = JSON.serialize(dataParsed.get('data'));
		List<brioapi__Integration__mdt> integrations = IntakeDesk_SyncHandler_CreateRecords.getIntegrations(integrationId);
        transLog = IntakeDesk_SyncHandler_CreateRecords.createIntegrationLog(integrations,rawData);
        
        Savepoint sp = Database.setSavepoint();
        try {
            IntakeDesk_Models.NewMatterRequest requestPayload = (IntakeDesk_Models.NewMatterRequest) JSON.deserialize(data, IntakeDesk_Models.NewMatterRequest.class);
            //system.debug('doPost.payload: '+requestPayload);
            
            // do QC checking
            String message = requestPayload.campaign != 'PFAS' ? IntakeDesk_SyncHandler_QC.automatedQC(requestPayload) : ''; // Do not run QC for PFAS
            // Create party: Client
            IntakeDesk_SyncHandler_CreateRecords.createParty(requestPayload);
            // Create intake
            litify_pm__Intake__c newIntake = IntakeDesk_SyncHandler_CreateRecords.createIntake(requestPayload);
            newIntake.Test_Intake__c = Boolean.valueOf(requestPayload.testingFlag) ? true : false;
            newIntake.brioapi__API_External_ID__c = 'intakeDesk-' + requestPayload.integratorMatterId;
            if(message != null && message != ''){
                newIntake.Automated_QC_Notes__c = message;
                newIntake.Intake_Desk_Review__c = 'Needs Review';
                newIntake.EOF_Email_Summary__c = message.left(254);
            }
            system.debug('DQ: '+dq);
            if(newIntake.QC_Type__c == 'Duplicate'){
                newIntake.QC_Type__c = 'Duplicate';
            }else if(newIntake.QC_Type__c != 'Duplicate'){
                newIntake.QC_Type__c = 'EOF';
            }

            Boolean externalIdExists = IntakeDesk_SyncHandler_QC.checkForExistingIntakesExternalId(newIntake);
            if(!externalIdExists){
               
                insert newIntake;
                IntakeDesk_SyncHandler_CreateRecords.intakeId = newIntake.Id;
                // Create createInjuredParty
                String iPartyId = IntakeDesk_SyncHandler_CreateRecords.createInjuredParty(requestPayload);
                system.debug('iPartyId: '+iPartyId);
                // Create injury
            	IntakeDesk_SyncHandler_CreateRecords.createInjury(requestPayload);
                // Create campaign case
                IntakeDesk_SyncHandler_CreateRecords.createCampaignCase(requestPayload);
                // Create CM locations
                IntakeDesk_SyncHandler_CreateRecords.createMedicalFacility(requestPayload);
                // Create Exposure
                IntakeDesk_SyncHandler_CreateRecords.createExposure(requestPayload);
                // Create EmergencyContact
                IntakeDesk_SyncHandler_CreateRecords.createEmergencyContact(requestPayload);
                // Create AlternativeCauseDetails
                //06232025 CS Addition - add setting Additional_Case_Detail__c lookup on Intake
                String acd = IntakeDesk_SyncHandler_CreateRecords.createAlternativeCauseDetails(requestPayload);
                system.debug('acd: '+acd);
                Boolean intakeUpdate = false;
                if(acd != null && acd != ''){
                    newIntake.Additional_Case_Detail__c = acd;
                    intakeUpdate = true;
                }
                if(iPartyId != null && iPartyId != ''){
                    newIntake.Injured_Party__c = iPartyId;
                    intakeUpdate = true;
                }
                if(intakeUpdate){
                    update newIntake;
                }
                //createEmploymentHistory
                // IntakeDesk_SyncHandler_CreateRecords.createEmploymentHistory(requestPayload);
                // return response
                // Map<string,object> result = IntakeDesk_SyncHandler_CreateRecords.createResponse(newIntake);
                Map<string,object> result = new Map<string,object>();
                result.put('intakeId', newIntake.Id);
                result.put('success', true);
                result.put('data', requestPayload);
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                
                transLog.brioapi__Intake__c = newIntake.Id;
                transLog.brioapi__Response__c = JSON.serializePretty(result);
    
                if( translog != null){
                    insert transLog; 
                    System.debug('Translog Inserted');
                }
                return;
            }else{
                System.debug('IntakeDesk_SyncHandler.The external Id for this matter already exists');     
                res.responseBody = Blob.valueOf('The external Id for this matter already exists'); res.statusCode = 500;
                transLog.brioapi__Status__c = 'ERROR';transLog.brioapi__Response__c = res.responseBody.toString();transLog.Potential_Duplicate_Found__c = true;
                if( translog != null){insert transLog;}
            	return;
            }
        }
        catch (Exception ex) {            
            Database.rollback(sp);
            System.debug(ex);
            String stackTraceString = ex.getStackTraceString();    
            system.debug('error: '+ex.getMessage() + '-' + ex.getStackTraceString());
            res.responseBody = Blob.valueOf(ex.getMessage() + '-' + ex.getStackTraceString());res.statusCode = 500;
            transLog.brioapi__Status__c = 'ERROR';transLog.brioapi__Response__c = res.responseBody.toString();
            if(integrations.size()>0 && integrations[0].brioapi__Debugging__c){insert transLog;}
            return;
        }
    }
}