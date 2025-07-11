//Created by Scott Purcell 4/1/25

// Updated by Duyen Doan 6/2/2025
// - Remove parseJsonAndFormatFromExisting: Method not completed/No guidance on if this is still needed
// - Remove redundant model classes. Use IntakeDesk_Models instead while parsing JSON data in parseJsonAndFormat
public class IntegrationTransactionJsonFormatter {
    public class IntakeWrapper {
        public String integrationId;
        public IntakeDesk_Models.NewMatterRequest data;
    }

	// public static void parseJsonAndFormatFromExisting(brioapi__Integration_Transaction__c record) {
    //     String rawJson = record.brioapi__Request__c;
       
    //     rawJson = rawJson.trim();
    //     String cleanJson = rawJson.replace('\\','');
    //     cleanJson = cleanJson.removeEnd('}');
    //     cleanJson = cleanJson.replaceFirst('"','');
    //     cleanJson = cleanJson.remove('{"integrationId":"123","data":'); 
    //      system.debug('cleanJson: '+ cleanJson);
    //     parseJsonAndFormat(record,cleanJson);
    // }
    public static void parseJsonAndFormat(brioapi__Integration_Transaction__c record,String rawData) {
        try{
            IntakeWrapper wrapper = (IntakeWrapper) JSON.deserialize(rawData, IntakeWrapper.class);
            IntakeDesk_Models.NewMatterRequest data = wrapper.data;
    
            String baseData = '';
            String clientStr = '';
            String exposureStr = '';
            String injuryStr = '';
            String injuredPartyStr = '';
            String altCauseStr = '';
            // String employmentStr = '';
            String emergencyStr = '';
            String medicalFacilityStr = '';
    
            // BaseData__c
            baseData = 'DATA: \n';
            baseData += 'clientPreviouslySignedWithLawFirm: ' + data.clientPreviouslySignedWithLawFirm + '\n';
            baseData += 'caseSummary: ' + data.caseSummary + '\n';
            baseData += 'howClientDiscoveredCause: ' + data.howClientDiscoveredCause + '\n';
            baseData += 'discoveryOfCauseDate: ' + data.discoveryOfCauseDate + '\n';
            baseData += 'retainedDate: ' + data.retainedDate + '\n';
            baseData += 'retainerSentDate: ' + data.retainerSentDate + '\n';
            baseData += 'testingFlag: ' + data.testingFlag + '\n';
            baseData += 'integrator: ' + data.integrator + '\n';
            baseData += 'integratorMatterId: ' + data.integratorMatterId + '\n';
            baseData += 'intakeVendor: ' + data.intakeVendor + '\n';
            baseData += 'marketingVendor: ' + data.marketingVendor + '\n';
            baseData += 'campaign: ' + data.campaign + '\n';
            baseData += 'matterIsQualified: ' + data.matterIsQualified + '\n';
            baseData += 'clientDiscoveredCauseFromAdvertising: ' + data.clientDiscoveredCauseFromAdvertising + '\n';
    		baseData += 'dateClientFirstSawAdvertising: ' + data.dateClientFirstSawAdvertising + '\n';
            baseData += 'clientDiscoveredCauseFromAdvertising: ' + data.clientDiscoveredCauseFromAdvertising + '\n';
            baseData += 'marketingChannel: ' + data.marketingChannel + '\n';
            
            // Client__c
            if (data.client != null) {
                clientStr = 'CLIENT: \n';
                clientStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(data.client));
            }else clientStr = 'Client info is null \n';

            // Exposure__c & ExposureDetails__c
            if (data.exposure != null) {
                exposureStr = 'EXPOSURE: \n';
                for (IntakeDesk_Models.Exposure e : data.exposure) {
                    exposureStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(e));
                }
            }else exposureStr = 'Exposure info is null.\n';
    
            // Injury__c - 
            if (data.injury != null) {
                injuryStr = 'INJURY: \n';
                for (IntakeDesk_Models.Injury i : data.injury) {
                    injuryStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(i));
                }
            }else injuryStr = 'Injury info is null.\n';
    
            // InjuredParty__c (currently null)
            if (data.injuredParty != null) {
                injuredPartyStr = 'INJURED PARTY: \n';
                injuredPartyStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(data.injuredParty));
            }else injuredPartyStr = 'No injured party info available.\n';
    
            // AlternativeCauseDetails__c
            if (data.alternativeCauseDetails != null) {
                altCauseStr = 'ALTERNATIVE CAUSE DETAILS: \n';
                altCauseStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(data.alternativeCauseDetails));
            }else altCauseStr = 'Alternative Cause info is null.\n';
    
            // // EmploymentHistory__c 
            // if (data.employmentHistory != null) {
            //     employmentStr = 'EMPLOMENT HISTORY: \n';
            //     employmentStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(data.employmentHistory));
            // }else employmentStr = 'Employment History info is null.\n';
    
            // EmergencyContact__c
            if (data.emergencyContact != null) {
                emergencyStr = 'EMERGENCY CONTACTS: \n';
                for (IntakeDesk_Models.EmergencyContact ec : data.emergencyContact) {
                    emergencyStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(ec));
                }
            }else emergencyStr = 'Emergency Contact info is null.\n';
    
            // MedicalFacility__c
            if (data.medicalFacility != null) {
                medicalFacilityStr = 'MEDICAL FACILITIES: \n';
                for (IntakeDesk_Models.MedicalFacility mf : data.medicalFacility) {
                    medicalFacilityStr += 'FACILITY: \n';
                    medicalFacilityStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(mf));
                    
                    for(IntakeDesk_Models.MedicalFacilityProvider p : mf.providers){
                        medicalFacilityStr += 'PROVIDER: \n';
                        medicalFacilityStr += IntakeDesk_Helpers.convertJSONToTextSummary(JSON.serialize(p));
                    }
                    medicalFacilityStr += '\n';
                }
            }else medicalFacilityStr = 'MedicalFacility info is null.\n';
    
            // write to the log
            record.Json_Formatted__c = baseData;
            record.Json_Formatted__c += '\n#########\n'+ clientStr;
            record.Json_Formatted__c += '\n#########\n'+ exposureStr;
            record.Json_Formatted__c += '\n#########\n'+ injuryStr;
            record.Json_Formatted__c += '\n#########\n'+ injuredPartyStr;
            record.Json_Formatted__c += '\n#########\n'+ altCauseStr;
            // record.Json_Formatted__c += '\n#########\n'+ employmentStr;
            record.Json_Formatted__c += '\n#########\n'+ emergencyStr;
            record.Json_Formatted__c += '\n#########\n'+ medicalFacilityStr;
            record.Json_Formatted__c += '\n\n';
            system.debug('formatted log written');
        }catch(Exception e){
            system.debug('exception: '+ e);
            record.Json_Formatted__c = 'Error in formatting' + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
        }
    }
}