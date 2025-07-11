//Created by Scott Purcell 3/24/25

// Updated by Duyen Doan 6/2/2025
// - Remove runExistingThroughQC: Method not completed/No guidance on if this is still needed

public class IntakeDesk_SyncHandler_QC {
    public static String message {get;set;}
    
    // public static void runExistingThroughQC(List<litify_pm__Intake__c>intakes){
    //     Map<Id,litify_pm__Intake__c> intakeMap = new Map<Id,litify_pm__Intake__c>();
    //     for(litify_pm__Intake__c intake:intakes)intakeMap.put(intake.Id,intake);
    //     for(brioapi__Integration_Transaction__c transLog:[Select Id, brioapi__Intake__c,brioapi__Request__c From brioapi__Integration_Transaction__c Where brioapi__Intake__c IN: intakeMap.keyset()]){
    //         //system.debug('translog.intake: '+translog.brioapi__Intake__c);
    //         String rawJson = transLog.brioapi__Request__c;
    //         rawJson = rawJson.trim();
    //         String cleanJson = rawJson.replace('\\','');

    //         cleanJson = cleanJson.removeEnd('}');
    //         cleanJson = cleanJson.replaceFirst('"','');
    //         cleanJson = cleanJson.remove('{"integrationId":"123","data":');            
            
    //         system.debug('cleanJson: '+cleanJson);
    //         IntakeDesk_Models.NewMatterRequest requestPayload =(IntakeDesk_Models.NewMatterRequest) JSON.deserialize(cleanJson, IntakeDesk_Models.NewMatterRequest.class);
    //         //POC Dynamic QC Handling
    //         //IntakeDesk_SyncHandler_QC_Dynamic.evaluateRecord(requestPayload);
    //         message = automatedQC(requestPayload);
    //         if(translog.brioapi__Intake__c != null){
    //             litify_pm__Intake__c intake = intakeMap.get(translog.brioapi__Intake__c);
    //         	if(intake.Automated_QC_Notes__c != null)intake.Automated_QC_Notes__c += message;
    //         	else intake.Automated_QC_Notes__c = message;
    //             intake.Ran_QC__c = true;
    //         }
    //     }
    // 	update intakes;
    // }

    public static Boolean checkForExistingIntakesExternalId(litify_pm__Intake__c intake){
        system.debug('IntakeTriggerHelper.checkForExistingIntakesExternalId');
        List<litify_pm__Intake__c> intakes = [Select Id,brioapi__API_External_ID__c  From litify_pm__Intake__c Where brioapi__API_External_ID__c =:intake.brioapi__API_External_ID__c AND Id !=:intake.Id];
        if(intakes.size()>0)return true;
        else return false;
    }
    public static String automatedQC(IntakeDesk_Models.NewMatterRequest requestPayload){
        system.debug('***** automatedQC *****');
        String message='';
       	IntakeDesk_SyncHandler.dq = false;
        Date diagnosisDate;
        //************************** Intake ******************************
        if(requestPayload.campaign == null || requestPayload.campaign != 'Roundup'){message = ' Campaign != Roundup,';IntakeDesk_SyncHandler.dq =true;}
        if(requestPayload.marketingVendor == null ||requestPayload.marketingVendor != 'Intake Desk'){message += ' marketingVendor != Intake Desk,';IntakeDesk_SyncHandler.dq =true;}
        if(requestPayload.intakeVendor == null ||requestPayload.intakeVendor != 'Intake Desk'){message += ' intakeVendor != Intake Desk,';IntakeDesk_SyncHandler.dq =true;}
        if(requestPayload.integrator == null ||requestPayload.integrator != 'Intake Desk'){message += ' integrator != Intake Desk,';IntakeDesk_SyncHandler.dq =true;}
        if(requestPayload.retainedDate == null)message += ' retainedDate == null,';
// Rule #21        
        if(requestPayload.clientPreviouslySignedWithLawFirm == null ||requestPayload.clientPreviouslySignedWithLawFirm != 'No'){message += ' clientPreviouslySignedWithLawFirm = Yes,';IntakeDesk_SyncHandler.dq =true;}
//        
        if(requestPayload.clientDiscoveredCauseFromAdvertising == null)message += ' clientDiscoveredCauseFromAdvertising == null,';
        if(requestPayload.dateClientFirstSawAdvertising == null)message += ' dateClientFirstSawAdvertising == null,';
        if(requestPayload.integratorMatterId == null)message += ' integratorMatterId == null,';
        
        //************************** AlternativeCauseDetails ******************************
        if(requestPayload.alternativeCauseDetails != null){
            //if(requestPayload.alternativeCauseDetails.envExposureAgentOrange == null || requestPayload.alternativeCauseDetails.envExposureAgentOrange == 'Yes')message += ' envExposureAgentOrange is null or Yes,';
// Rule #18           
            if(requestPayload.alternativeCauseDetails.priorDxHepatitis ==null || requestPayload.alternativeCauseDetails.priorDxHepatitis == 'Yes'){message += ' priorDxHepatitis = Yes,';IntakeDesk_SyncHandler.dq =true;}
//            
            if(requestPayload.alternativeCauseDetails.priorDxHIVorAIDS == null || requestPayload.alternativeCauseDetails.priorDxHIVorAIDS == 'Yes'){message += ' priorDxHIVorAIDS is null or Yes,';IntakeDesk_SyncHandler.dq =true;}
//Rule #22            
            if(requestPayload.alternativeCauseDetails.envExposureAgentOrange == 'Yes' && requestPayload.alternativeCauseDetails.receivedBenefitsForCurrentDx == 'yes'){message += 'envExposureAgentOrange & receivedBenefitsForCurrentDx is Yes,';IntakeDesk_SyncHandler.dq =true;}
//            
        }else{message = 'alternativeCauseDetails = null';} 
        
        //************************** MedicalFacility ******************************
        if(requestPayload.medicalFacility != null){
            for(IntakeDesk_Models.MedicalFacility mf : requestPayload.medicalFacility){
                if(mf.name == null)message += ' medicalFacility.name = null,';
                if(mf.city == null)message += ' medicalFacility.city = null,';
                if(mf.state == null)message += ' medicalFacility.state = null,';
                if(mf.zip == null)message += ' medicalFacility.zip = null,';
            }
// Rule #7            
        }else{ message += ' medicalFacility = null,';IntakeDesk_SyncHandler.dq =true;} 
//        
        //************************** Injuries ******************************
        if(requestPayload.injury != null){
            List<IntakeDesk_Models.Injury> injuries = requestPayload.injury;
            if(injuries.size()>0){
                 for(IntakeDesk_Models.Injury inj : injuries){
                
                     if(inj.type == null)message += ' Injury.type == null,';IntakeDesk_SyncHandler.dq =true;
// Rule #5
                     if(inj.type != 'Non-Hodgkins Lymphoma (NHL)' || inj.type != 'Non-Hodgkins Lymphoma'){message += ' Injury.type must be NHL,';IntakeDesk_SyncHandler.dq =true;}
// Rule #6                     
                     if(inj.subType == null){message += ' injury.subtype = null-Required to have a subtype of NHL,';IntakeDesk_SyncHandler.dq =true;}
//                     
                     if(inj.isDiagnosed == null || inj.isDiagnosed != 'Yes'){message += ' Injury.isDiagnosed = null OR no,';IntakeDesk_SyncHandler.dq =true;}
                     if(inj.diagnosisDate == null)message += ' Injury.diagnosisDate = null,';
                     system.debug('inj.diagnosisDate: '+inj.diagnosisDate);
                     if(inj.diagnosisDate != null){
                         Date diagDate = Date.valueOf(inj.diagnosisDate);
                         diagnosisDate = diagDate;
                         Integer yr = diagDate.year();
// Rule #15                         
                         if(yr <2000)message += ' Injury.diagnosisDate is before 2000,';
//                         
                     }
                 }
        	}else {message += 'Injuries = null';}
        }else {message += 'Injuries = null';}
        //************************** InjuredParty ******************************
            if(requestPayload.injuredParty == null){
// Rule #8                
                if (requestPayload.client == null || requestPayload.client.dateOfBirth  == null) {message += ' client.dateOfBirth is required.';} //
                else if (diagnosisDate != null) {
                    Integer ageAtDiagnosis = diagnosisDate.year() - Date.valueOf(requestPayload.client.dateOfBirth).year();
                    // Adjust if the birthday hasn't occurred yet in the diagnosis year
                    if (diagnosisDate < Date.valueOf(requestPayload.client.dateOfBirth).addYears(ageAtDiagnosis)) {
                        ageAtDiagnosis--;
                    }
// Rule #17                      
                    if (ageAtDiagnosis < 18 || ageAtDiagnosis > 80) {message += ' Client must be between 18 and 80 years old at time of diagnosis.';IntakeDesk_SyncHandler.dq =true;}
                }
            }else{
                if (requestPayload.injuredParty.dateOfBirth  == null) {message += ' injuredParty.dateOfBirth is required.';} 
                else if (diagnosisDate != null) {
                    Integer ageAtDiagnosis = diagnosisDate.year() - Date.valueOf(requestPayload.injuredParty.dateOfBirth).year();
                    // Adjust if the birthday hasn't occurred yet in the diagnosis year
                    if (diagnosisDate < Date.valueOf(requestPayload.injuredParty.dateOfBirth).addYears(ageAtDiagnosis)) {
                        ageAtDiagnosis--;
                    }
// Rule #17                    
                    if (ageAtDiagnosis < 18 || ageAtDiagnosis > 80) {message += ' Injured Party must be between 18 and 80 years old at time of diagnosis.';IntakeDesk_SyncHandler.dq =true;}
// Rule :Signer must be injured party, next of kin, executor of estate, or have power of attorney
                    if((requestPayload.injuredParty == null && requestPayload.client.relationshipToInjuredParty != 'Self' && requestPayload.client.relationshipToInjuredParty != null) || (requestPayload.client.relationshipToInjuredParty == 'Self' && requestPayload.injuredParty != null && requestPayload.injuredParty.clientIsRepresentativeOfEstate == 'No' && requestPayload.injuredParty.clientIsExecutorOfWill == 'No' && requestPayload.client.isPowerOfAttorney == 'No')){
                       message += ' Signer must be injured party, next of kin, executor of estate, or have power of attorney.';
                        IntakeDesk_SyncHandler.dq =true;}
//					                
                
                }
            }
            system.debug('message 2: '+message);
        //************************** Client ******************************
    		if(requestPayload.client != null){
                if(requestPayload.client.address[0].city == null) message += ' addr.address.city == null,';
                if(requestPayload.client.address[0].street1 == null) message += ' addr.address.street1 == null,';
                if(requestPayload.client.address[0].zip == null) message += ' addr.address.zip == null,';
                if(requestPayload.client.address[0].state == null) message += ' addr.address.state == null,';
                if(requestPayload.client.address[0].state != null && diagnosisDate != null){
// Rule #16                    
                    if(requestPayload.client.address[0].state == 'AL' && (Date.today() < diagnosisDate.addMonths(-19) || Date.today() > diagnosisDate.addMonths(19)))message += ' (AL)Todays date is not within 19 months of Diagnosis Date,';
                    if(requestPayload.client.address[0].state == 'VA' && (Date.today() < diagnosisDate.addMonths(-19) || Date.today() > diagnosisDate.addMonths(19)))message += ' (VA)Todays date is not within 19 months of Diagnosis Date,';
                    if(requestPayload.client.address[0].state == 'SD' && (Date.today() < diagnosisDate.addMonths(-31) || Date.today() > diagnosisDate.addMonths(31)))message += ' (SD)Todays date is not within 31 months of Diagnosis Date,';
                    if(requestPayload.client.address[0].state == 'ME' && (Date.today() < diagnosisDate.addMonths(-67) || Date.today() > diagnosisDate.addMonths(67)))message += ' (ME)Todays date is not within 67 months of Diagnosis Date,';
//
                }
                if(requestPayload.client.firstName == null) message += ' Client.firstName == null,';
            	if(requestPayload.client.lastName == null) message += ' Client.lastName == null,';
            	if(requestPayload.client.cellPhone == null && requestPayload.client.homePhone == null) message += ' Client.cellPhone OR client.homePhone: = null,';
            }else{message += 'Client Address = null';}
        	//************************** Exposure ******************************
            if(requestPayload.exposure != null && diagnosisDate != null){
                for(IntakeDesk_Models.Exposure ex : requestPayload.exposure){
                    Date startDate = Date.valueOf(ex.startDate);
                    Date endDate = Date.valueOf(ex.endDate);
                    Date maxStartDate = Date.newInstance(1999, 12, 31);
                    Date maxEndDate = Date.newInstance(1984,12,31);
                    Boolean isValid = !(startDate >= diagnosisDate.addYears(-1) && startDate <= diagnosisDate.addYears(1));
                    Boolean isValid2 = endDate.addYears(20) >= diagnosisDate;
                    system.debug('isvalid: '+isValid + '    isValid2: '+isValid2);
//  Rule #12                    
                    if(!isValid){message += ' Exposure.startDate is not 1 year b/n diagnosis,';IntakeDesk_SyncHandler.dq =true;}
// Rule #13                   
                    if(startDate < maxStartDate && diagnosisDate != null){message += ' Exposure.startDate is before 12-31-1999,';IntakeDesk_SyncHandler.dq =true;}
                    if(endDate < maxEndDate && diagnosisDate != null){message += ' Exposure.endDate is not after 12-31-1984,';IntakeDesk_SyncHandler.dq =true;}
                    if(!isValid2){message += ' Exposure.endDate is not within 20 years of diagnosis,';IntakeDesk_SyncHandler.dq =true;}
//                    
                    Integer uses = Integer.valueOf(ex.exposureDetails.usesPerYear);
                    Decimal hrs = Decimal.valueOf(ex.exposureDetails.hoursPerUse);
                    Integer tots = Integer.valueOf(ex.exposureDetails.totalExposureYears);
// Rule #11                    
                    if(uses * hrs * tots <10){message += ' Must have more than 10hrs of use before Diagnosis,';IntakeDesk_SyncHandler.dq =true;}
// Rule #10                    
                    if(uses <10){message += ' Must have more than 10 uses before Diagnosis,';IntakeDesk_SyncHandler.dq =true;}
// Rule #9                    
                    if(tots <2){message += ' Must have used at least 2 years,';IntakeDesk_SyncHandler.dq =true;}
// Rule #25                   
                    if(ex.exposureState == 'TN'){message += ' Exposure.exposureState: TN cannot be the only state of exposure,';IntakeDesk_SyncHandler.dq =true;}
                    system.debug('message 3: '+message );
                }
            }else{
                if(requestPayload.exposure == null)message += 'Exposure and/or diagnosisDate = null ';
            }
        	//************************** InjuredParty extended  ******************************
    		if (requestPayload.injuredParty != null && requestPayload.injuredParty.dateOfDeath != null){
                Date today = Date.today();
                //Date retained = Date.valueOf(requestPayload.retainedDate);
                Date deathWindowStart = today;
                
                if (diagnosisDate != null && requestPayload.injuredParty.dateOfDeath != null) {
                    Integer diagnosisYear = diagnosisDate.year();
                    Integer deathYear = Date.valueOf(requestPayload.injuredParty.dateOfDeath).year();
                    
                    if (diagnosisYear > 2000 && diagnosisYear <2014) {
// Rule #14                      
                        if(Date.today().addYears(-2) < diagnosisDate){message += 'Death must be within 2 years of today,';IntakeDesk_SyncHandler.dq =true;}
                    }else if(diagnosisYear > 2014 && deathYear >=2024){message += 'Death must be after 2023,';IntakeDesk_SyncHandler.dq =true;}
// 
                        // Date deathThresholdStart = deathWindowStart; Date deathThresholdEnd = retained;
                        //if (Date.valueOf(requestPayload.injuredParty.dateOfDeath) < deathThresholdStart || Date.valueOf(requestPayload.injuredParty.dateOfDeath) > deathThresholdEnd) {
                            //message += ' Death must be between ' + deathThresholdStart.format() + ' and ' + deathThresholdEnd.format() + ' for diagnosis year 2000–2013.';}
// Rule #15                        
                     else{message += 'Diagnosis in the case of death must be after the year 2000, or 2024 for cases diagnosed after 2014,';IntakeDesk_SyncHandler.dq =true;}
                }
            }
    	system.debug('IntakeDesk_SyncHandler.dq: '+IntakeDesk_SyncHandler.dq);
        
        return message;
    }
}