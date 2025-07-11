@isTest
public with sharing class IntakeDesk_NewMatterWebhookTest {
    @isTest
    public static void testDoPostOK() {
        RestRequest req = new RestRequest();
        String s = '{' +
                    '"integratorMatterId": "intakedesk-1",' +
                    '"campaign": "string",' +
                    '"integrator": "string",' +
                    '"intakeVendor": "string",' +
                    '"marketingVendor": "string",' +
                    '"client": {' +
                        '"firstName": "Tom",' +
                        '"middleName": "Marvolo",' +
                        '"lastName": "Riddle",' +
                        '"suffix": "string",' +
                        '"address": [' +
                        '{' +
                            '"street1": "111",' +
                            '"street2": "Dealthy Hallow Dr",' +
                            '"city": "Philadelphia",' +
                            '"zip": "19178",' +
                            '"state": "Pennsylvania",' +
                            '"isMailing": true,' +
                            '"isResidence": true' +
                        '}' +
                        '],' +
                        '"socialSecurityNumber": "111223456",' +
                        '"dateOfBirth": "1950-02-05",' +
                        '"gender": "Male",' +
                        '"maritalStatus": "Single",' +
                        '"notes": "This is a test",' +
                        '"primaryEmail": "lordvoldemort@gmail.com",' +
                        '"cellPhone": "1234567897",' +
                        '"homePhone": "string",' +
                        '"relationshipToInjuredParty": "string",' +
                        '"isPowerOfAttorney": true,' +
                        '"powerOfAttorneyType": "string",' +
                        '"bestContactTime": "string",' +
                        '"languagePreference": "string"' +
                    '},' +
                    '"injuredParty": {' +
                        '"firstName": "Lucius",' +
                        '"middleName": null,' +
                        '"lastName": "Malfoy",' +
                        '"suffix": "string",' +
                        '"address": [' +
                        '{' +
                            '"street1": "Somewhere rich",' +
                            '"street2": "string",' +
                            '"city": "Conshohocken",' +
                            '"zip": "14524",' +
                            '"state": "Pennsylvania",' +
                            '"isMailing": true,' +
                            '"isResidence": true' +
                        '}' +
                        '],' +
                        '"socialSecurityNumber": "578523542",' +
                        '"dateOfBirth": "1990-02-05",' +
                        '"gender": "string",' +
                        '"maritalStatus": "Married",' +
                        '"notes": "Test test test",' +
                        '"email": "malfoy@outlook.com",' +
                        '"phone": [' +
                        '"4527856554"' +
                        '],' +
                        '"isDeceased": "string",' +
                        '"dateOfDeath": "2024-12-05",' +
                        '"causeOfDeath": "string",' +
                        '"stateOfDeath": "string",' +
                        '"estateHasBeenOpened": "string",' +
                        '"estateIsCurrentlyOpen": "string",' +
                        '"clientIsRepresentativeOfEstate": "string",' +
                        '"clientIsExecutorOfWill": "string",' +
                        '"namedInformant": "string"' +
                    '},' +
                    '"emergencyContact": [' +
                        '{' +
                        '"firstName": "string",' +
                        '"lastName": "string",' +
                        '"suffix": "string",' +
                        '"phone": "string",' +
                        '"relationship": "string"' +
                        '}' +
                    '],' +
                    '"exposure": [' +
                        '{' +
                        '"startDate": "2025-02-05",' +
                        '"endDate": "2025-02-05",' +
                        '"exposureIsOngoing": "string",' +
                        '"exposureHasStopped": "string",' +
                        '"exposureState": "string",' +
                        '"residenceStateDuringExposure": "string",' +
                        '"exposureDetails": {}' +
                        '}' +
                    '],' +
                    '"injury": [' +
                        '{' +
                        '"type": "string",' +
                        '"subType": "string",' +
                        '"severity": "string",' +
                        '"isDiagnosed": "string",' +
                        '"diagnosisDate": "2025-02-05",' +
                        '"stateOfDiagnosis": "string",' +
                        '"residenceStateAtDiagnosis": "string",' +
                        '"injuryDetails": {}' +
                        '}' +
                    '],' +
                    '"alternativeCauseDetails": {},' +
                    '"medicalFacility": [' +
                        '{' +
                        '"name": "Jefferson Hospital",' +
                        '"facilityType": "Hospital",' +
                        '"procedure": "string",' +
                        '"address": "111 Chestnut St",' +
                        '"city": "Philadelphia",' +
                        '"zip": "19147",' +
                        '"state": "PA",' +
                        '"phone": "7854256852",' +
                        '"startDate": "2025-01-05",' +
                        '"endDate": "2025-01-05",' +
                        '"notes": "test hospital",' +
                        '"providers": [' +
                            '{' +
                            '"title": "Dr",' +
                            '"firstName": "NA",' +
                            '"lastName": "Who"' +
                            '}' +
                        ']' +
                        '}' +
                    '],' +
                    '"matterIsQualified": "string",' +
                    '"caseSummary": "this is a test coming from intake desk",' +
                    '"clientPreviouslySignedWithLawFirm": "string",' +
                    '"clientDiscoveredCauseFromAdvertising": "string",' +
                    '"dateClientFirstSawAdvertising": "2025-02-05",' +
                    '"discoveryOfCauseDate": "2025-02-05",' +
                    '"howClientDiscoveredCause": "string",' +
                    '"retainerSentDate": "2025-02-01",' +
                    '"retainedDate": "2025-02-04",' +
                    '"testingFlag": true' +
                    '}';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Mock
        string syncResultStr = '{' +
                                '"data": {' +
                                    '"Exposures": [' +
                                        '{' +
                                            '"State of Residency During Occurrence": "None of the Above",' +
                                            '"State Exposure Occurred": "None of the Above",' +
                                            '"Date of Last Exposure": "2025-02-05",' +
                                            '"Date of First Exposure": "2025-02-05"' +
                                        '}' +
                                    '],' +
                                    '"Medical Facilities": [' +
                                        '{' +
                                            '"End Date": "2025-01-05",' +
                                            '"Start Date": "2025-01-05",' +
                                            '"Facility Address": {' +
                                                '"city": "Philadelphia",' +
                                                '"country": "United States",' +
                                                '"countryCode": "US",' +
                                                '"geocodeAccuracy": null,' +
                                                '"latitude": null,' +
                                                '"longitude": null,' +
                                                '"postalCode": "19147",' +
                                                '"state": "Pennsylvania",' +
                                                '"stateCode": "PA",' +
                                                '"street": "111 Chestnut St"' +
                                            '},' +
                                            '"Facility Location": "Jefferson Hospital",' +
                                            '"Facility Type": "Hospital",' +
                                            '"Facility Phone": "7854256852",' +
                                            '"Provider Address": "Who",' +
                                            '"Provider Name": "NA"' +
                                        '}' +
                                    '],' +
                                    '"Injured Party Date of Death": "2024-12-05",' +
                                    '"Injured Party Marital Status": "Married",' +
                                    '"Injured Party Gender": "Unknown",' +
                                    '"Injured Party Date of Birth": "1990-02-05",' +
                                    '"Injured Party SSN": "578523542",' +
                                    '"Injured Party Suffix": "N/A",' +
                                    '"Does caller have authority to sign?": "Yes",' +
                                    '"Injured Party Name": "Lucius Malfoy",' +
                                    '"Client Best time to reach": "string",' +
                                    '"Client Phone Home": "string",' +
                                    '"Client Phone Mobile": "1234567897",' +
                                    '"Client Email": "lordvoldemort@gmail.com",' +
                                    '"Client Description": "This is a test",' +
                                    '"Client Marital Status": "Single",' +
                                    '"Client Gender": "Male",' +
                                    '"Client Date of Birth": "1950-02-05",' +
                                    '"Client SSN": "111223456",' +
                                    '"Client Billing Address": {' +
                                        '"city": "Philadelphia",' +
                                        '"country": "United States",' +
                                        '"countryCode": "US",' +
                                        '"geocodeAccuracy": null,' +
                                        '"latitude": null,' +
                                        '"longitude": null,' +
                                        '"postalCode": "19178",' +
                                        '"state": "Pennsylvania",' +
                                        '"stateCode": "PA",' +
                                        '"street": "111 Dealthy Hallow Dr"' +
                                    '},' +
                                    '"Client Suffix": "N/A",' +
                                    '"Client Name": "Tom Riddle",' +
                                    '"Cilent Estate Opened": "Yes",' +
                                    '"Intake Retainer Signed": "2025-02-04T00:00:00.000Z",' +
                                    '"Intake Retainer Sent": "2025-02-01T00:00:00.000Z",' +
                                    '"Intake Description": "this is a test coming from intake desk",' +
                                    '"Intake Id": "a0CRL00001r1e4z2AA"' +
                                '},' +
                                '"success": true' +
                            '}';

        SaddleRockCalloutMock syncResult = new SaddleRockCalloutMock(200, 'OK', syncResultStr, null);

        Map<String, HttpCalloutMock> mockResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(mockResp);
        multiCalloutMock.addRequestMock(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/intakedesksync', syncResult);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        IntakeDesk_NewMatterWebhook.doPost();

        Test.stopTest();

        System.assertEquals(200, res.statusCode);
    }
    @isTest
    public static void testDoPostEmptyDateOK() {
        RestRequest req = new RestRequest();
        String s = '{' +
                    '"integratorMatterId": "intakedesk-1",' +
                    '"campaign": "string",' +
                    '"integrator": "string",' +
                    '"intakeVendor": "string",' +
                    '"marketingVendor": "string",' +
                    '"client": {' +
                        '"firstName": "Tom",' +
                        '"middleName": "Marvolo",' +
                        '"lastName": "Riddle",' +
                        '"suffix": "string",' +
                        '"address": [' +
                        '{' +
                            '"street1": "111",' +
                            '"street2": "Dealthy Hallow Dr",' +
                            '"city": "Philadelphia",' +
                            '"zip": "19178",' +
                            '"state": "Pennsylvania",' +
                            '"isMailing": true,' +
                            '"isResidence": true' +
                        '}' +
                        '],' +
                        '"socialSecurityNumber": "111223456",' +
                        '"dateOfBirth": null,' +
                        '"gender": "Male",' +
                        '"maritalStatus": "Single",' +
                        '"notes": "This is a test",' +
                        '"primaryEmail": "lordvoldemort@gmail.com",' +
                        '"cellPhone": "1234567897",' +
                        '"homePhone": "string",' +
                        '"relationshipToInjuredParty": "string",' +
                        '"isPowerOfAttorney": true,' +
                        '"powerOfAttorneyType": "string",' +
                        '"bestContactTime": "string",' +
                        '"languagePreference": "string"' +
                    '},' +
                    '"injuredParty": {' +
                        '"firstName": "Lucius",' +
                        '"middleName": null,' +
                        '"lastName": "Malfoy",' +
                        '"suffix": "string",' +
                        '"address": [' +
                        '{' +
                            '"street1": "Somewhere rich",' +
                            '"street2": "string",' +
                            '"city": "Conshohocken",' +
                            '"zip": "14524",' +
                            '"state": "Pennsylvania",' +
                            '"isMailing": true,' +
                            '"isResidence": true' +
                        '}' +
                        '],' +
                        '"socialSecurityNumber": "578523542",' +
                        '"dateOfBirth": "1990-02-05",' +
                        '"gender": "string",' +
                        '"maritalStatus": "Married",' +
                        '"notes": "Test test test",' +
                        '"email": "malfoy@outlook.com",' +
                        '"phone": [' +
                        '"4527856554"' +
                        '],' +
                        '"isDeceased": "string",' +
                        '"dateOfDeath": "",' +
                        '"causeOfDeath": "string",' +
                        '"stateOfDeath": "string",' +
                        '"estateHasBeenOpened": "string",' +
                        '"estateIsCurrentlyOpen": "string",' +
                        '"clientIsRepresentativeOfEstate": "string",' +
                        '"clientIsExecutorOfWill": "string",' +
                        '"namedInformant": "string"' +
                    '},' +
                    '"emergencyContact": [' +
                        '{' +
                        '"firstName": "string",' +
                        '"lastName": "string",' +
                        '"suffix": "string",' +
                        '"phone": "string",' +
                        '"relationship": "string"' +
                        '}' +
                    '],' +
                    '"exposure": [' +
                        '{' +
                        '"startDate": "2025-02-05",' +
                        '"endDate": "",' +
                        '"exposureIsOngoing": "string",' +
                        '"exposureHasStopped": "string",' +
                        '"exposureState": "string",' +
                        '"residenceStateDuringExposure": "string",' +
                        '"exposureDetails": {}' +
                        '}' +
                    '],' +
                    '"injury": [' +
                        '{' +
                        '"type": "string",' +
                        '"subType": "string",' +
                        '"severity": "string",' +
                        '"isDiagnosed": "string",' +
                        '"diagnosisDate": "",' +
                        '"stateOfDiagnosis": "string",' +
                        '"residenceStateAtDiagnosis": "string",' +
                        '"injuryDetails": {}' +
                        '}' +
                    '],' +
                    '"alternativeCauseDetails": {},' +
                    '"medicalFacility": [' +
                        '{' +
                        '"name": "Jefferson Hospital",' +
                        '"facilityType": "Hospital",' +
                        '"procedure": "string",' +
                        '"address": "111 Chestnut St",' +
                        '"city": "Philadelphia",' +
                        '"zip": "19147",' +
                        '"state": "PA",' +
                        '"phone": "7854256852",' +
                        '"startDate": "",' +
                        '"endDate": "",' +
                        '"notes": "test hospital",' +
                        '"providers": [' +
                            '{' +
                            '"title": "Dr",' +
                            '"firstName": "NA",' +
                            '"lastName": "Who"' +
                            '}' +
                        ']' +
                        '}' +
                    '],' +
                    '"matterIsQualified": "string",' +
                    '"caseSummary": "this is a test coming from intake desk",' +
                    '"clientPreviouslySignedWithLawFirm": "string",' +
                    '"clientDiscoveredCauseFromAdvertising": "string",' +
                    '"dateClientFirstSawAdvertising": "",' +
                    '"discoveryOfCauseDate": "",' +
                    '"howClientDiscoveredCause": "string",' +
                    '"retainerSentDate": "",' +
                    '"retainedDate": "",' +
                    '"testingFlag": true' +
                    '}';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Mock
        string syncResultStr = '{' +
                                '"data": {' +
                                    '"Exposures": [' +
                                        '{' +
                                            '"State of Residency During Occurrence": "None of the Above",' +
                                            '"State Exposure Occurred": "None of the Above",' +
                                            '"Date of Last Exposure": "2025-02-05",' +
                                            '"Date of First Exposure": "2025-02-05"' +
                                        '}' +
                                    '],' +
                                    '"Medical Facilities": [' +
                                        '{' +
                                            '"End Date": "2025-01-05",' +
                                            '"Start Date": "2025-01-05",' +
                                            '"Facility Address": {' +
                                                '"city": "Philadelphia",' +
                                                '"country": "United States",' +
                                                '"countryCode": "US",' +
                                                '"geocodeAccuracy": null,' +
                                                '"latitude": null,' +
                                                '"longitude": null,' +
                                                '"postalCode": "19147",' +
                                                '"state": "Pennsylvania",' +
                                                '"stateCode": "PA",' +
                                                '"street": "111 Chestnut St"' +
                                            '},' +
                                            '"Facility Location": "Jefferson Hospital",' +
                                            '"Facility Type": "Hospital",' +
                                            '"Facility Phone": "7854256852",' +
                                            '"Provider Address": "Who",' +
                                            '"Provider Name": "NA"' +
                                        '}' +
                                    '],' +
                                    '"Injured Party Date of Death": "2024-12-05",' +
                                    '"Injured Party Marital Status": "Married",' +
                                    '"Injured Party Gender": "Unknown",' +
                                    '"Injured Party Date of Birth": "1990-02-05",' +
                                    '"Injured Party SSN": "578523542",' +
                                    '"Injured Party Suffix": "N/A",' +
                                    '"Does caller have authority to sign?": "Yes",' +
                                    '"Injured Party Name": "Lucius Malfoy",' +
                                    '"Client Best time to reach": "string",' +
                                    '"Client Phone Home": "string",' +
                                    '"Client Phone Mobile": "1234567897",' +
                                    '"Client Email": "lordvoldemort@gmail.com",' +
                                    '"Client Description": "This is a test",' +
                                    '"Client Marital Status": "Single",' +
                                    '"Client Gender": "Male",' +
                                    '"Client Date of Birth": "1950-02-05",' +
                                    '"Client SSN": "111223456",' +
                                    '"Client Billing Address": {' +
                                        '"city": "Philadelphia",' +
                                        '"country": "United States",' +
                                        '"countryCode": "US",' +
                                        '"geocodeAccuracy": null,' +
                                        '"latitude": null,' +
                                        '"longitude": null,' +
                                        '"postalCode": "19178",' +
                                        '"state": "Pennsylvania",' +
                                        '"stateCode": "PA",' +
                                        '"street": "111 Dealthy Hallow Dr"' +
                                    '},' +
                                    '"Client Suffix": "N/A",' +
                                    '"Client Name": "Tom Riddle",' +
                                    '"Cilent Estate Opened": "Yes",' +
                                    '"Intake Retainer Signed": "2025-02-04T00:00:00.000Z",' +
                                    '"Intake Retainer Sent": "2025-02-01T00:00:00.000Z",' +
                                    '"Intake Description": "this is a test coming from intake desk",' +
                                    '"Intake Id": "a0CRL00001r1e4z2AA"' +
                                '},' +
                                '"success": true' +
                            '}';

        SaddleRockCalloutMock syncResult = new SaddleRockCalloutMock(200, 'OK', syncResultStr, null);

        Map<String, HttpCalloutMock> mockResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(mockResp);
        multiCalloutMock.addRequestMock(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/intakedesksync', syncResult);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        IntakeDesk_NewMatterWebhook.doPost();

        Test.stopTest();

        System.assertEquals(200, res.statusCode);
    }
    @isTest
    public static void testDoPostBodyEmpty() {
        RestRequest req = new RestRequest();
        String s = '';

        req.requestBody = Blob.valueOf(s);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

        IntakeDesk_NewMatterWebhook.doPost();

        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }
}