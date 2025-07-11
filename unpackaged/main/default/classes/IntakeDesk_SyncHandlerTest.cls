@isTest 
public with sharing class IntakeDesk_SyncHandlerTest {
    @isTest 
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
                                '"stateOfDeath": "CA",'+
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

        Test.startTest();

        IntakeDesk_SyncHandler.doPost();
		List<brioapi__Integration_Transaction__c> transLog = [Select Id From brioapi__Integration_Transaction__c];
        system.assertNotEquals(0,transLog.size(),'There should be 1 log created');
        Test.stopTest();
        System.debug(res.responseBody.toString());
        System.assertEquals(200, res.statusCode);
    }
	@isTest 
    public static void testMatterAlreadyExists() {
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
                        '"injuredParty": null,'+
                        '"emergencyContact": [' +
                            '{' +
                                '"firstName": "James Darrell",' +
                                '"lastName": "Edwards III",' +
                                '"suffix": "Jr.",' +
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
        Test.startTest();

        IntakeDesk_SyncHandler.doPost();
		List<brioapi__Integration_Transaction__c> transLog = [Select Id From brioapi__Integration_Transaction__c Where Potential_Duplicate_Found__c = true];
        System.debug('transLog: '+transLog);
            system.assertEquals(1,transLog.size(),'There should be 1 log with the duplicate marked');
        List<CM_Location__c> locs = [Select Id,Name From CM_Location__c];
        system.assertEquals(2,locs.Size(),'There should be 2 locations');
        Test.stopTest();
        System.debug(res.responseBody.toString());
        System.assertEquals(500, res.statusCode);
    }
    @isTest 
    public static void testModels(){
        Test.startTest();
        IntakeDesk_Models.NewMatterRequest model = new IntakeDesk_Models.NewMatterRequest();
        model.matterIsQualified = 'Yes';
        model.caseSummary = 'Test';
        model.clientPreviouslySignedWithLawFirm = 'No';
        model.clientDiscoveredCauseFromAdvertising = 'Yes';
        model.dateClientFirstSawAdvertising = String.valueOf(Date.today());
        model.discoveryOfCauseDate = String.valueOf(Date.today());
        model.howClientDiscoveredCause = 'Social Media';
        model.retainerSentDate = String.valueOf(Date.today());
        model.retainedDate = String.valueOf(Date.today());
        model.testingFlag = 'true';
        model.injuredParty = new IntakeDesk_Models.InjuredParty();
        model.injuredParty.firstName = 'Test';
        model.injuredParty.middleName = 'Test';
        model.injuredParty.lastName = 'Test';
        model.injuredParty.suffix = 'Jr';
        model.injuredParty.socialSecurityNumber = '111111111';
        model.injuredParty.dateOfBirth = String.valueOf(Date.today());
        model.injuredParty.gender = 'Male';
        model.injuredParty.notes = 'Test';
        model.injuredParty.email = 'test@email.com';
        model.injuredParty.phone = new List<String>();
        model.injuredParty.phone.add('1111111111');
        model.injuredParty.isDeceased = 'Yes';
        model.injuredParty.dateOfDeath = String.valueOf(Date.today());
        model.injuredParty.causeOfDeath = 'Test';
        model.injuredParty.stateOfDeath = 'OK';
        model.injuredParty.estateHasBeenOpened = 'Yes';
        model.injuredParty.estateIsCurrentlyOpen = 'Yes';
        model.injuredParty.clientIsRepresentativeOfEstate = 'Yes';
        model.injuredParty.clientIsExecutorOfWill = 'Yes';
        model.injuredParty.namedInformant = 'Test';
        model.emergencyContact = new List<IntakeDesk_Models.EmergencyContact>();
        model.emergencyContact.add(new IntakeDesk_Models.EmergencyContact());
        model.emergencyContact[0].firstName ='ec first';
        model.emergencyContact[0].lastName = 'ec laST';
        model.emergencyContact[0].suffix = 'Mr.';
        model.emergencyContact[0].phone ='1112223333';
        model.emergencyContact[0].relationship ='Wife';
        model.injury = new List<IntakeDesk_Models.Injury>();
        model.injury.add(new IntakeDesk_Models.Injury());
        model.Injury[0].type = 'Bad';
        model.Injury[0].subType = 'enough';
        model.Injury[0].severity = 'severe';
        model.Injury[0].onsetDate = String.valueOf(Date.today());
        model.Injury[0].isDiagnosed = 'Yes';
        model.Injury[0].diagnosisDate= String.valueOf(Date.today());
        model.Injury[0].stateOfDiagnosis = 'Ut';
        model.Injury[0].residenceStateAtDiagnosis = 'Ut';
        Test.stopTest();
        System.assertNotEquals(null, model);
    }
}