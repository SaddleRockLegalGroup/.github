//Created by Scott Purcell 3/24/25

// Updated by Duyen Doan 6/2/2025
// - Method not completed/No guidance on if this is still needed
@isTest
public class IntakeDesk_SyncHandler_QC_Test {
    @IsTest
    public static void testRunExistingThroughQC(){
        // List<litify_pm__Intake__c > intakes = [Select Id,Automated_QC_Notes__c From litify_pm__Intake__c ];
        // Test.startTest();
        // IntakeDesk_SyncHandler_QC.runExistingThroughQC(intakes);
        // Test.stopTest();
        // intakes = [Select Id,Automated_QC_Notes__c From litify_pm__Intake__c ];
        // system.debug('intakes after test: '+intakes);
        
    }
    @testSetup
    public static void testDoPostOK() {
        RestRequest req = new RestRequest();
        String s = '{' +
                        '"dateClientFirstSawAdvertising": "2025-01-21",' +
                        '"clientDiscoveredCauseFromAdvertising": "Yes",' +
                        '"integratorMatterId": "183153",' +
                        '"matterIsQualified": "Yes",' +
                        '"campaign": "Roundup",' +
                        '"marketingVendor": "Intake Desk",' +
                        '"intakeVendor": "Intake Desk",' +
                        '"integrator": "Intake Desk",' +
                        '"testingFlag": "true",' +
                        '"client": {' +
                            '"firstName": "Kevin",' +
                            '"middleName": null,' +
                            '"lastName": "Brown",' +
                            '"suffix": "Jr.",' +
                            '"cellPhone": "5555017899",' +
                            '"homePhone": "5555017899",' +
                            '"primaryEmail": "csilva@intakedesk.com",' +
                            '"address": [' +
                                '{' +
                                    '"street1": "450 Hellen Street",' +
                                    '"street2": null,' +
                                    '"city": "Talihina",' +
                                    '"zip": "74571",' +
                                    '"state": "WY",' +
                                    '"isMailing": "Yes",' +
                                    '"isResidence": "Yes"' +
                                '}' +
                            '],' +
                            '"socialSecurityNumber": "123-45-6789",' +
                            '"dateOfBirth": "1984-10-23",' +
                            '"gender": "Male",' +
                            '"maritalStatus": "Single",' +
                            '"relationshipToInjuredParty": "Self",' +
                            '"bestContactTime": "after 4:00 PM",' +
                            '"languagePreference": "English",' +
                            '"notes": null' +
                        '},' +
                        '"injuredParty": {' +
                                '"socialSecurityNumber": "123-45-6789",'+
                                '"firstName": "Bob",'+
                                '"middleName": "bliff",'+
                                '"lastName": "Marley",'+
                                '"suffix": "Jr.",'+
                                '"dateOfBirth": "1984-10-23",'+
                                '"gender": "male",'+
                                '"maritalStatus": "Single",'+
                                '"notes": "these are notes",'+
                                '"email": "bibbitybobbity@boo.com",'+
                                '"isDeceased": "No",'+
                                '"dateOfDeath": "1984-10-23",'+
                                '"causeOfDeath": "Cancer",'+
                                '"stateOfDeath": "UT",'+
                                '"estateHasBeenOpened": "No",'+
                                '"estateIsCurrentlyOpen": "No",'+
                                '"clientIsRepresentativeOfEstate": "Yes",'+
                                '"clientIsExecutorOfWill": "Yes",'+
                                '"namedInformant": "No"'+
            			'},' +
                        '"emergencyContact": [' +
                            '{' +
                                '"firstName": "James Darrell",' +
                                '"lastName": "Edwards III",' +
                                '"suffix": null,' +
                                '"phone": "5555011234",' +
                                '"relationship": "Friend"' +
                            '}' +
                        '],' +
                        '"exposure": [' +
                            '{' +
                                '"startDate": "2016-01-01",' +
                                '"endDate": "2020-01-01",' +
                                '"exposureState": "OK",' +
                                '"exposureHasStopped": "Yes",' +
                                '"residenceStateDuringExposure": "OK",' +
                                '"exposureDetails": {' +
                                    '"address": {' +
                                        '"street1": "450 Hellen Street",' +
                                        '"street2": null,' +
                                        '"city": "Talihina",' +
                                        '"zip": "74571",' +
                                        '"state": "OK"' +
                                    '},' +
                                    '"usedProductAtWork": "No",' +
                                    '"usedProductAtHome": "Yes",' +
                                    '"exposureArea": "Landscape, Driveway, Patio, Flowers, Sidewalk, Fence Line",' +
                                    '"applicationMethod": null,' +
                                    '"totalExposureYears": "4",' +
                                    '"usesPerYear": "12",' +
                                    '"hoursPerUse": "0.5",' +
                                    '"usedProtectiveGear": "Yes",' +
                                    '"protectiveGearDescription": "Face Mask, Gloves",' +
                                    '"ipPurchasedProduct": "Yes",' +
                                    '"clientHasProductContainer": "No",' +
                                    '"clientHasPhotoOfUsage": "No",' +
                                    '"clientHasPurchaseReceipts": "No",' +
                                    '"productContainerSize": "1.3-gallon Ready To Spray",' +
                                    '"purchaseLocation": [],' +
                                    '"notes": "Kevin used the 1.3-gallon of Roundup ready-to-spray"' +
                                '}' +
                            '},' +
                            '{' +
                                '"startDate": "2015-01-01",' +
                                '"endDate": "2016-01-01",' +
                                '"exposureState": "OK",' +
                                '"exposureHasStopped": "Yes",' +
                                '"residenceStateDuringExposure": "OK",' +
                                '"exposureDetails": {' +
                                    '"address": {' +
                                        '"street1": "3650 Golf Course Road",' +
                                        '"street2": null,' +
                                        '"city": "Broken Bow",' +
                                        '"zip": "74728",' +
                                        '"state": "OK"' +
                                    '},' +
                                    '"usedProductAtWork": "Yes",' +
                                    '"usedProductAtHome": "No",' +
                                    '"exposureArea": "Maintenance",' +
                                    '"applicationMethod": "Larger handheld pump sprayer",' +
                                    '"totalExposureYears": "1",' +
                                    '"usesPerYear": "12",' +
                                    '"hoursPerUse": "1",' +
                                    '"usedProtectiveGear": "Yes",' +
                                    '"protectiveGearDescription": "Gloves",' +
                                    '"ipPurchasedProduct": "Yes",' +
                                    '"clientHasProductContainer": "No",' +
                                    '"clientHasPhotoOfUsage": "No",' +
                                    '"clientHasPurchaseReceipts": "No",' +
                                    '"productContainerSize": "2.5-gallon Concentrate",' +
                                    '"purchaseLocation": [],' +
                                    '"notes": "Kevin used the 2.5-gallon of Roundup concentrate mixed into a container with a larger handheld pump sprayer. Kevin sprayed Roundup throughout the 80-acre golf course. "' +
                                '}' +
                            '}' +
                        '],' +
                        '"injury": [' +
                            '{' +
                                '"type": "Adult T-cell lymphoma leukemia (T-ATLL)",' +
                                '"subType": null,' +
                                '"severity": "Unsure",' +
                                '"onsetDate": null,' +
                                '"isDiagnosed": "Yes",' +
                                '"diagnosisDate": "2022-07-01",' +
                                '"stateOfDiagnosis": "AR",' +
                                '"residenceStateAtDiagnosis": null,' +
                                '"injuryDetails": {' +
                                    '"treatedWithChemotherapy": "Yes",' +
                                    '"chemotherapyDetails": "Kevin received chemotherapy for a year; he received infusions once a week. ",' +
                                    '"treatedWithRadiation": "No",' +
                                    '"radiationDetails": null,' +
                                    '"treatedWithSurgery": "No",' +
                                    '"surgeryDetails": null,' +
                                    '"yearsInRemission": null' +
                                '}' +
                            '}' +
                        '],' +
                        '"alternativeCauseDetails": {' +
                            '"priorDxHepatitis": "No",' +
                            '"priorDxHIVorAIDS": "No",' +
                            '"priorDxCancer": "No",' +
                            '"envExposureAgentOrange": "No",' +
                            '"hxOrganTransplant": "No",' +
                            '"hxImmunosuppressantDrugs": "No",' +
                            '"receivedBenefitsForCurrentDx": null,' +
                            '"priorEnvExposureSuperfundToxicSite": "No",' +
                            '"priorDxEbsteinBarr": null,' +
                            '"priorDxBacterialInfection": "No",' +
                            '"priorHxBreastImplants": "No",' +
                            '"priorDxDiabetes": "No",' +
                            '"priorDxDiabetesDetails": null,' +
                            '"hxTobaccoCurrent": "Yes",' +
                            '"hxTobaccoFormer": "No",' +
                            '"hxTobaccoDetails": "Quantity: 1 Pack Frequency: Daily Date Start: 01 01 1999",' +
                            '"hxTobaccoTotalYears": "26 year(s) 1 month(s)",' +
                            '"hxTobaccoYearsStoppedPriorToDx": "26 year(s) 1 month(s)",' +
                            '"familyHxCancer": "No",' +
                            '"familyHxCancerDetails": null,' +
                            '"familyHxNHL": "No",' +
                            '"dxHeightFt": "5",' +
                            '"dxHeightIn": "11",' +
                            '"dxWeight": "252",' +
                            '"dxBmi": "35.1",' +
                            '"currentHeightFt": "5",' +
                            '"currentHeightIn": "11",' +
                            '"currentWeight": "252",' +
                            '"currentBmi": "35.1"' +
                        '},' +
                        '"medicalFacility": [' +
                            '{' +
                                '"name": "Mercy Hospital Fort Smith",' +
                                '"type": null,' +
                                '"facilityType": "Diagnosis Facility",' +
                                '"procedure": "Diagnosis",' +
                                '"street1": "7301 Rogers Avenue ",' +
                                '"city": "Fort Smith",' +
                                '"state": "AR",' +
                                '"zip": "72903",' +
                                '"phone": "(479) 314-6000",' +
                                '"startDate": "2022-07-01",' +
                                '"endDate": null,' +
                                '"notes": null,' +
                                '"providers": [' +
                                    '{' +
                                        '"title": "Dr.",' +
                                        '"firstName": "Daniel",' +
                                        '"lastName": "Mackey, MD",' +
                                        '"type": "Oncologist"' +
                                    '}' +
                                ']' +
                            '},' +
                            '{' +
                                '"name": "Choctaw Nation Healthcare Center",' +
                                '"type": null,' +
                                '"facilityType": "Oncology Clinic",' +
                                '"procedure": "Chemo",' +
                                '"street1": "1 Choctaw Way ",' +
                                '"city": "Talihina",' +
                                '"state": "OK",' +
                                '"zip": "74571",' +
                                '"phone": "(800) 349-7026",' +
                                '"startDate": "2022-07-25",' +
                                '"endDate": "2023-07-25",' +
                                '"notes": "Kevin received chemotherapy for a year; he received infusions once a week. ",' +
                                '"providers": []' +
                            '}' +
                        '],' +
                        '"employmentHistory": {' +
                            '"currentOccupation": "Contractor",' +
                            '"currentOccupationStartDate": null,' +
                            '"previousOccupation": "Groundskeeper",' +
                            '"previousOccupationStartDate": null,' +
                            '"previousOccupationEndDate": null,' +
                            '"occupationBeforeDx": "Agricultural",' +
                            '"militaryService": "No"' +
                        '},' +
                        '"retainerSentDate": "2025-01-31",' +
                        '"retainedDate": "2025-01-31",' +
                        '"discoveryOfCauseDate": "2025-01-21",' +
                        '"howClientDiscoveredCause": "Social Media",' +
                        '"caseSummary": "Kevin was exposed to Roundup between the years 2016 - 2020 at his residences",' +
                        '"clientPreviouslySignedWithLawFirm": "No"' +
                    '}';
		String d = '{' +
                        '"dateClientFirstSawAdvertising": "2025-01-21",' +
                        '"clientDiscoveredCauseFromAdvertising": "Yes",' +
                        '"integratorMatterId": "183154",' +
                        '"matterIsQualified": "Yes",' +
                        '"campaign": "Roundup",' +
                        '"marketingVendor": "Intake Desk",' +
                        '"intakeVendor": "Intake Desk",' +
                        '"integrator": "Intake Desk",' +
                        '"testingFlag": "true",' +
                        '"client": {' +
                            '"firstName": "Kevin",' +
                            '"middleName": null,' +
                            '"lastName": "Brown",' +
                            '"suffix": null,' +
                            '"cellPhone": "5555017899",' +
                            '"homePhone": "5555017899",' +
                            '"primaryEmail": "csilva@intakedesk.com",' +
                            '"address": [' +
                                '{' +
                                    '"street1": "450 Hellen Street",' +
                                    '"street2": null,' +
                                    '"city": "Talihina",' +
                                    '"zip": "74571",' +
                                    '"state": "WY",' +
                                    '"isMailing": "Yes",' +
                                    '"isResidence": "Yes"' +
                                '}' +
                            '],' +
                            '"socialSecurityNumber": "123-45-6789",' +
                            '"dateOfBirth": "1984-10-23",' +
                            '"gender": "Male",' +
                            '"maritalStatus": "Single",' +
                            '"relationshipToInjuredParty": "Self",' +
                            '"bestContactTime": "after 4:00 PM",' +
                            '"languagePreference": "English",' +
                            '"notes": null' +
                        '},' +
                        '"injuredParty": {' +
                                '"socialSecurityNumber": "123-45-6789",'+
                                '"firstName": "Bob",'+
                                '"middleName": "bliff",'+
                                '"lastName": "Marley",'+
                                '"suffix": "Mr.",'+
                                '"dateOfBirth": "1984-10-23",'+
                                '"gender": "male",'+
                                '"maritalStatus": "Single",'+
                                '"notes": "these are notes",'+
                                '"email": "bibbitybobbity@boo.com",'+
                                '"isDeceased": "No",'+
                                '"dateOfDeath": "1984-10-23",'+
                                '"causeOfDeath": "Cancer",'+
                                '"stateOfDeath": "Utah",'+
                                '"estateHasBeenOpened": "No",'+
                                '"estateIsCurrentlyOpen": "No",'+
                                '"clientIsRepresentativeOfEstate": "Yes",'+
                                '"clientIsExecutorOfWill": "Yes",'+
                                '"namedInformant": "No"'+
            			'},' +
                        '"emergencyContact": [' +
                            '{' +
                                '"firstName": "James Darrell",' +
                                '"lastName": "Edwards III",' +
                                '"suffix": null,' +
                                '"phone": "5555011234",' +
                                '"relationship": "Friend"' +
                            '}' +
                        '],' +
                        '"exposure": [' +
                            '{' +
                                '"startDate": "2016-01-01",' +
                                '"endDate": "2020-01-01",' +
                                '"exposureState": "OK",' +
                                '"exposureHasStopped": "Yes",' +
                                '"residenceStateDuringExposure": "OK",' +
                                '"exposureDetails": {' +
                                    '"address": {' +
                                        '"street1": "450 Hellen Street",' +
                                        '"street2": null,' +
                                        '"city": "Talihina",' +
                                        '"zip": "74571",' +
                                        '"state": "OK"' +
                                    '},' +
                                    '"usedProductAtWork": "No",' +
                                    '"usedProductAtHome": "Yes",' +
                                    '"exposureArea": "Landscape, Driveway, Patio, Flowers, Sidewalk, Fence Line",' +
                                    '"applicationMethod": null,' +
                                    '"totalExposureYears": "4",' +
                                    '"usesPerYear": "12",' +
                                    '"hoursPerUse": "0.5",' +
                                    '"usedProtectiveGear": "Yes",' +
                                    '"protectiveGearDescription": "Face Mask, Gloves",' +
                                    '"ipPurchasedProduct": "Yes",' +
                                    '"clientHasProductContainer": "No",' +
                                    '"clientHasPhotoOfUsage": "No",' +
                                    '"clientHasPurchaseReceipts": "No",' +
                                    '"productContainerSize": "1.3-gallon Ready To Spray",' +
                                    '"purchaseLocation": [],' +
                                    '"notes": "Kevin used the 1.3-gallon of Roundup ready-to-spray"' +
                                '}' +
                            '},' +
                            '{' +
                                '"startDate": "2015-01-01",' +
                                '"endDate": "2016-01-01",' +
                                '"exposureState": "OK",' +
                                '"exposureHasStopped": "Yes",' +
                                '"residenceStateDuringExposure": "OK",' +
                                '"exposureDetails": {' +
                                    '"address": {' +
                                        '"street1": "3650 Golf Course Road",' +
                                        '"street2": null,' +
                                        '"city": "Broken Bow",' +
                                        '"zip": "74728",' +
                                        '"state": "OK"' +
                                    '},' +
                                    '"usedProductAtWork": "Yes",' +
                                    '"usedProductAtHome": "No",' +
                                    '"exposureArea": "Maintenance",' +
                                    '"applicationMethod": "Larger handheld pump sprayer",' +
                                    '"totalExposureYears": "1",' +
                                    '"usesPerYear": "12",' +
                                    '"hoursPerUse": "1",' +
                                    '"usedProtectiveGear": "Yes",' +
                                    '"protectiveGearDescription": "Gloves",' +
                                    '"ipPurchasedProduct": "Yes",' +
                                    '"clientHasProductContainer": "No",' +
                                    '"clientHasPhotoOfUsage": "No",' +
                                    '"clientHasPurchaseReceipts": "No",' +
                                    '"productContainerSize": "2.5-gallon Concentrate",' +
                                    '"purchaseLocation": [],' +
                                    '"notes": "Kevin used the 2.5-gallon of Roundup concentrate mixed into a container with a larger handheld pump sprayer. Kevin sprayed Roundup throughout the 80-acre golf course. "' +
                                '}' +
                            '}' +
                        '],' +
                        '"injury": [' +
                            '{' +
                                '"type": "Adult T-cell lymphoma leukemia (T-ATLL)",' +
                                '"subType": null,' +
                                '"severity": "Unsure",' +
                                '"onsetDate": null,' +
                                '"isDiagnosed": "Yes",' +
                                '"diagnosisDate": "2022-07-01",' +
                                '"stateOfDiagnosis": "AR",' +
                                '"residenceStateAtDiagnosis": null,' +
                                '"injuryDetails": {' +
                                    '"treatedWithChemotherapy": "Yes",' +
                                    '"chemotherapyDetails": "Kevin received chemotherapy for a year; he received infusions once a week. ",' +
                                    '"treatedWithRadiation": "No",' +
                                    '"radiationDetails": null,' +
                                    '"treatedWithSurgery": "No",' +
                                    '"surgeryDetails": null,' +
                                    '"yearsInRemission": null' +
                                '}' +
                            '}' +
                        '],' +
                        '"alternativeCauseDetails": {' +
                            '"priorDxHepatitis": "No",' +
                            '"priorDxHIVorAIDS": "No",' +
                            '"priorDxCancer": "No",' +
                            '"envExposureAgentOrange": "No",' +
                            '"hxOrganTransplant": "No",' +
                            '"hxImmunosuppressantDrugs": "No",' +
                            '"receivedBenefitsForCurrentDx": null,' +
                            '"priorEnvExposureSuperfundToxicSite": "No",' +
                            '"priorDxEbsteinBarr": null,' +
                            '"priorDxBacterialInfection": "No",' +
                            '"priorHxBreastImplants": "No",' +
                            '"priorDxDiabetes": "No",' +
                            '"priorDxDiabetesDetails": null,' +
                            '"hxTobaccoCurrent": "Yes",' +
                            '"hxTobaccoFormer": "No",' +
                            '"hxTobaccoDetails": "Quantity: 1 Pack Frequency: Daily Date Start: 01 01 1999",' +
                            '"hxTobaccoTotalYears": "26 year(s) 1 month(s)",' +
                            '"hxTobaccoYearsStoppedPriorToDx": "26 year(s) 1 month(s)",' +
                            '"familyHxCancer": "No",' +
                            '"familyHxCancerDetails": null,' +
                            '"familyHxNHL": "No",' +
                            '"dxHeightFt": "5",' +
                            '"dxHeightIn": "11",' +
                            '"dxWeight": "252",' +
                            '"dxBmi": "35.1",' +
                            '"currentHeightFt": "5",' +
                            '"currentHeightIn": "11",' +
                            '"currentWeight": "252",' +
                            '"currentBmi": "35.1"' +
                        '},' +
                        '"medicalFacility": [' +
                            '{' +
                                '"name": "Mercy Hospital Fort Smith",' +
                                '"type": null,' +
                                '"facilityType": "Diagnosis Facility",' +
                                '"procedure": "Diagnosis",' +
                                '"street1": "7301 Rogers Avenue ",' +
                                '"city": "Fort Smith",' +
                                '"state": "AR",' +
                                '"zip": "72903",' +
                                '"phone": "(479) 314-6000",' +
                                '"startDate": "2022-07-01",' +
                                '"endDate": null,' +
                                '"notes": null,' +
                                '"providers": [' +
                                    '{' +
                                        '"title": "Dr.",' +
                                        '"firstName": "Daniel",' +
                                        '"lastName": "Mackey, MD",' +
                                        '"type": "Oncologist"' +
                                    '}' +
                                ']' +
                            '},' +
                            '{' +
                                '"name": "Choctaw Nation Healthcare Center",' +
                                '"type": null,' +
                                '"facilityType": "Oncology Clinic",' +
                                '"procedure": "Chemo",' +
                                '"street1": "1 Choctaw Way ",' +
                                '"city": "Talihina",' +
                                '"state": "OK",' +
                                '"zip": "74571",' +
                                '"phone": "(800) 349-7026",' +
                                '"startDate": "2022-07-25",' +
                                '"endDate": "2023-07-25",' +
                                '"notes": "Kevin received chemotherapy for a year; he received infusions once a week. ",' +
                                '"providers": []' +
                            '}' +
                        '],' +
                        '"employmentHistory": {' +
                            '"currentOccupation": "Contractor",' +
                            '"currentOccupationStartDate": null,' +
                            '"previousOccupation": "Groundskeeper",' +
                            '"previousOccupationStartDate": null,' +
                            '"previousOccupationEndDate": null,' +
                            '"occupationBeforeDx": "Agricultural",' +
                            '"militaryService": "No"' +
                        '},' +
                        '"retainerSentDate": "2025-01-31",' +
                        '"retainedDate": "2025-01-31",' +
                        '"discoveryOfCauseDate": "2025-01-21",' +
                        '"howClientDiscoveredCause": "Social Media",' +
                        '"caseSummary": "Kevin was exposed to Roundup between the years 2016 - 2020 at his residences",' +
                        '"clientPreviouslySignedWithLawFirm": "No"' +
                    '}';
        Map<string,object> payLoad = new Map<String,object>();
        Map<String, Object> dataParsed = (Map<string, Object>) JSON.deserializeUntyped(s);
        payLoad.put('data', dataParsed);
        payLoad.put('integrationId', '123');

        req.requestBody = Blob.valueOf(JSON.serialize(payLoad));
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
		IntakeDesk_SyncHandler.doPost();
        
        
	
    }
    

}