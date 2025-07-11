@isTest
public class IntakeTriggerHandler_Test {
    @testSetup
    static void testMatchDial800ToIntake() {
        // Simulate a POST request with a JSON payload
        String ani = '1112225555';
        IntakeTriggerHandler.ani = ani;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
       
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"eventType": "create_record","Station": "station","ANI": "1112225555","Call Start": "2023-01-01T12:34:56","DNIS": "1112223333","Call Id": "2223334444","City": "San Francisco","State": "CA","Postal Code": 94105,"Status": "Connected","Target": "Target Name","Media Agency": "Agency Name","Campaign": "Campaign Name","Duration": 300,"Connected Duration": 200}');
        // Call the webhook handler
        Dial800WebhookHandler.handleWebhook();
        
        // Verify the response
        System.assertEquals(200, res.statusCode, 'Response status should be 200');
        System.assert(res.responseBody.toString().contains('"status": "success"'), 'Response should indicate success');
        
        // Verify that the dial800 was created
        List<Dial800__c>dial800 = [SELECT Name, ANI__c,Call_Id__c,Intake__c FROM Dial800__c WHERE ANI__c = '1112225555'];
        system.debug('dial800 record :' +dial800[0]);
        System.assertEquals(1, dial800.size(), 'One Dial800 record should have been created');
        System.assertEquals('1112225555', dial800[0].ANI__c, 'ANI should match');
        System.assertEquals('2223334444', dial800[0].Call_Id__c, 'Call ID should match');
    }
    @isTest
    public static void testRunMatching(){
        // Simulate a POST request with a JSON payload
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"eventType": "create_record","ANI": "1112225555","Station": "station","Call Start": "2023-01-01T12:34:56","DNIS": "9876543210","Call Id": "ABCD1234","City": "San Francisco","State": "CA","Postal Code": 94105,"Status": "Connected","Target": "Target Name","Media Agency": "Agency Name","Campaign": "Campaign Name","Duration": 300,"Connected Duration": 200}');
        // Call the webhook handler
        Dial800WebhookHandler.handleWebhook();
         String ani = '1112225555';
        IntakeTriggerHandler.ani = ani;
		litify_pm__Intake__c inta = new litify_pm__Intake__c(litify_pm__Phone__c=ani);
		insert inta;
        List<Id>intakeIds = new List<Id>();
        intakeIds.add(inta.Id);
        Test.startTest();
        IntakeTriggerHelper.runMatching(intakeIds);
        Test.stopTest();
    }
    @isTest
    public static void testIntake(){
    
        String ani='1112225555';
        IntakeTriggerHandler.ani = ani;
		litify_pm__Intake__c inta = new litify_pm__Intake__c(litify_pm__Phone__c=ani);
		
        Test.startTest();
        insert inta;
        List<Dial800__c>dial800s = [SELECT Name,Intake__c, ANI__c,Call_Id__c FROM Dial800__c LIMIT 1];
        dial800s[0].Intake__c = null;
        update dial800s[0];
        update inta;
        
        Test.stopTest();
        dial800s = [SELECT Name,Intake__c, ANI__c,Call_Id__c FROM Dial800__c LIMIT 1];
        system.debug('dial800s record :' +dial800s[0]);
    
       }
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
		payLoad = new Map<String,object>();
        dataParsed = (Map<string, Object>) JSON.deserializeUntyped(d);
        payLoad.put('data', dataParsed);
        payLoad.put('integrationId', '123');

        req.requestBody = Blob.valueOf(JSON.serialize(payLoad));
        RestContext.request = req;
        res = new RestResponse();
        RestContext.response = res;
		IntakeDesk_SyncHandler.doPost();
		List<litify_pm__Intake__c > intakes = [Select Id,brioapi__API_External_ID__c,Potential_Duplicate_IntakeId__c,Intake_Record_URL_Link__c,Automated_QC_Notes__c
                                               From litify_pm__Intake__c ];
        Test.stopTest();
        System.debug('intakes'+intakes);
        System.assertEquals(200, res.statusCode);
    }

}