@isTest
public with sharing class FV_CreateProjectInvocableTest {
    public static final Endpoints ENDPOINTS { get {
        Boolean isSandbox = [ SELECT IsSandbox FROM Organization ].IsSandbox;
        
        if (isSandbox || Test.isRunningTest()) {
            return new Endpoints(
                'https://test.salesforce.com/services/oauth2/authorize',
                'https://test.salesforce.com/services/oauth2/token'
            );
        }
        
        return new Endpoints(
            'https://login.salesforce.com/services/oauth2/authorize',
            'https://login.salesforce.com/services/oauth2/token'
        );
    }}
    public class Endpoints {
        String oAuthEndpoint;
        String tokenEndpoint;
        
        public Endpoints(String oAuthEndpoint, String tokenEndpoint) {
            this.oAuthEndpoint = oAuthEndpoint;
            this.tokenEndpoint = tokenEndpoint;
        }
    }

    @isTest 
    public static void test_OK_ClientNotCaller() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerClientIntake();
        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        string customContactUrl = fvSetting.Base_URL__c + '/core/custom-contacts';
        string projectUrl = fvSetting.Base_URL__c + '/core/projects';
        string initialIntakeUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/initialintake';
        string masstortUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/masstortinfo';
        string casesummaryUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/casesummary';
        string fvNewDocUploadUrl = fvSetting.Base_URL__c + '/core/documents';
        string fvUploadUrl = 'https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5';
        string fvAddDocToProjUrl = fvSetting.Base_URL__c + '/core/projects/4580812/documents/311047751';

        string sessionRespStr = '{' +
                                    '"accessToken": "abc1234",' +
                                    '"refreshToken": "defghi",' +
                                    '"refreshTokenExpiry": "56719877617",' +
                                    '"refreshTokenTtl": "24 hours",' +
                                    '"userId": "12345",' +
                                    '"orgId": "5293"' +
                                '}';
        string customContactRespStr = '{' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Caller",' +
                                        '"lastName": "API",' +
                                        '"isSingleName": false,' +
                                        '"fullName": "Test Caller API",' +
                                        '"primaryEmail": "test@test.com",' +
                                        '"pictureUrl": "/images/Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"pictureKey": "Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"ssn": "123456789",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"personTypes": [],' +
                                        '"uniqueId": "6a820963-01b7-4bcc-a6ea-3cf2445ee94f",' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"caller",' +
                                            '"api",' +
                                            '"test caller api",' +
                                            '"test api"' +
                                        '],' +
                                        '"phones": [' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568205,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568206,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568207,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334495,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test@test.com",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334496,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test1@test.com",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"addressId": {' +
                                                    '"native": 11910464,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"line1": "123 Test Street",' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"fullAddress": "123 Test Street, Test, PA",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"hashtags": [],' +
                                        '"links": {' +
                                            '"self": "/contacts/19472883",' +
                                            '"projects": "/contacts/19472883/projects",' +
                                            '"phones": "/contacts/19472883/phones",' +
                                            '"emailAddresses": "/contacts/19472883/emailAddresses",' +
                                            '"addresses": "/contacts/19472883/addresses"' +
                                        '}' +
                                    '}';
        string projectRespStr = '{' +
                                    '"projectTypeCode": "MT3",' +
                                    '"rootDocFolderId": {' +
                                        '"native": 148064847,' +
                                        '"partner": null' +
                                    '},' +
                                    '"phaseName": "Migration for Review",' +
                                    '"clientName": "Test Client API",' +
                                    '"clientPictureURL": "/image-error.png",' +
                                    '"firstPrimaryName": "Filevine Integration",' +
                                    '"firstPrimaryUsername": "filevine128",' +
                                    '"isArchived": false,' +
                                    '"lastActivity": "2024-05-01T17:06:08.4192757Z",' +
                                    '"uniqueKey": "TestClientAPIZ4580812",' +
                                    '"projectOrClientName": "Test Client API",' +
                                    '"hashtags": [],' +
                                    '"projectEmailAddress": "TestClientAPIZ4580812@ashcraftandgerel.filevineapp.com",' +
                                    '"createdDate": "2024-05-01T17:06:08.4156183Z",' +
                                    '"projectUrl": "https://ashcraftandgerel.filevineapp.com/#/project/4580812",' +
                                    '"projectId": {' +
                                        '"native": 4580812,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectTypeId": {' +
                                        '"native": 4675,' +
                                        '"partner": null' +
                                    '},' +
                                    '"clientId": {' +
                                        '"native": 19467459,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectName": "Test Client API",' +
                                    '"phaseId": {' +
                                        '"native": 41897,' +
                                        '"partner": null' +
                                    '},' +
                                    '"links": {' +
                                        '"self": "/projects/4580812",' +
                                        '"projectType": "/projecttypes/4675",' +
                                        '"rootFolder": "/folders/148064847",' +
                                        '"client": "/contacts/19467459",' +
                                        '"contacts": "/projects/4580812/contacts"' +
                                    '}' +
                                '}';
        string initialIntakeStr = '{' +
                                        '"dateofintake": null,' +
                                        '"personperformingintakeLegacy": null,' +
                                        '"referralsource": null,' +
                                        '"referredfrom1": null,' +
                                        '"referredfrom1feepercentage": null,' +
                                        '"originatingattorney": null,' +
                                        '"casedescription": "Testing litify_pm__Description__c",' +
                                        '"leadstatus": null,' +
                                        '"rejectionreason": null,' +
                                        '"additionaldescriptionforrejection": null,' +
                                        '"casereferredto": null,' +
                                        '"referralfee": null,' +
                                        '"referralcontracts": null,' +
                                        '"datecontractsent": null,' +
                                        '"datecontractsigned": null,' +
                                        '"casetype": null,' +
                                        '"priorclient": null,' +
                                        '"othercasetype": null,' +
                                        '"referringfrom2": null,' +
                                        '"referralfrom2feepercenta": null,' +
                                        '"referredfrom3": null,' +
                                        '"referredfrom3feepercentage": null,' +
                                        '"otherrelevantreferralinfo": null,' +
                                        '"attorneyreviewwc3rdparty": null,' +
                                        '"additionalreferralsources": null,' +
                                        '"referralfrom4": null,' +
                                        '"referralsource5space": null,' +
                                        '"referredfrom5": null,' +
                                        '"isthecallertheinjuredpart": null,' +
                                        '"callername": null,' +
                                        '"callerrelationshiptoinjured": null,' +
                                        '"callerrelationshipother": null,' +
                                        '"3rdpartyattorneyreviewnote": null,' +
                                        '"initialIntakeInfo": null,' +
                                        '"referralMarketingInfo": null,' +
                                        '"litigationSubtype": null,' +
                                        '"personPerformingIntake": null,' +
                                        '"leadSentForReplacement": null,' +
                                        '"marketingSourceAgreedToRep": null,' +
                                        '"diagnosisReceived": null,' +
                                        '"diagnosisDate": null,' +
                                        '"firstSurgeryDate": null,' +
                                        '"stateWhereDiagnosed": null,' +
                                        '"discoveryDate": null,' +
                                        '"surgeryType": null,' +
                                        '"nameOfProductsUsed": null,' +
                                        '"dateOfFirstUse": null,' +
                                        '"dateOfLastUse": null,' +
                                        '"marketingSourceID": null,' +
                                        '"whatCityWereYouBorn": null,' +
                                        '"stateBorn": null,' +
                                        '"relationship": "The caller is the formal next of kin (when through all levels and they are the next in line)",' +
                                        '"personalInformation": null,' +
                                        '"legalRelation": null,' +
                                        '"callSelf": null,' +
                                        '"callerSELF": null,' +
                                        '"callerOTHER": null,' +
                                        '"causeofdeath": null,' +
                                        '"cityBorn": null,' +
                                        '"stateBornOther": null,' +
                                        '"whyAreYouThePointOfConta": null,' +
                                        '"coCounselID": "a0CVF00000TQOxG2AX",' +
                                        '"healthcareProvider": null,' +
                                        '"treatingHealthcareProvider": null,' +
                                        '"outreachLetterSent": null,' +
                                        '"hasAnEstateBeenOpened": true,' +
                                        '"isTheEstateCurrentlyOpen": true,' +
                                        '"doYouHaveACopyOfTheDeat": true,' +
                                        '"allLocationsLivedWorkedOr": "Knox Trailer Park;Hadnot Point",' +
                                        '"haveYouEverSmokedCigarette": "Smoked less than 1 year prior to throat related cancer DX",' +
                                        '"doYouCurrentlySmokeCigaret": true,' +
                                        '"haveYouEverSmokedCigarette_1": true,' +
                                        '"forHowLongDidYouSmoke": "10 years",' +
                                        '"howManyCigarettesPerDay": "4",' +
                                        '"whenDidYouBeginSmoking": "2000",' +
                                        '"whenDidYouStopSmoking": "2010",' +
                                        '"doYouHaveAnyDocumentsRela": "Yes",' +
                                        '"ifCivilianWhatWasTheNatu": "Testing Nature_Of_Presence_At_Camp_Lejeune__c",' +
                                        '"militaryDetails": "Testing Branch_discharge_status_and_rank__c",' +
                                        '"fullNameOfMilitaryService": "Testing Military_Stationed_Family_Mem_Full_Name__c",' +
                                        '"branchOfService": "Testing Branch_of_Service__c",' +
                                        '"dischargeStatus": "Honorable",' +
                                        '"rank": "Captain",' +
                                        '"tier1Diagnosis": "Kidney disease (End stage renal (ESRD), Renal Toxicity, Chronic Kidney Disease, etc.)",' +
                                        '"tier2Diagnosis": "Esophageal cancer",' +
                                        '"tier3Diagnosis": "None of the above",' +
                                        '"tier4Diagnosis": null,' +
                                        '"diagnosisDates": null,' +
                                        '"treatingDoctors": "Testing List_Dx_treating_doctor_names_spec__c",' +
                                        '"treatingFacilities": "Testing Treatment_Facilities_Name_and_Addresses__c",' +
                                        '"militaryPersonnelSSN": "123589852",' +
                                        '"militaryPersonnelDOB": "1980-12-24T00:00:00Z",' +
                                        '"militaryPersonnelPlaceOfBi": "CA",' +
                                        '"serviceNumber": "123456",' +
                                        '"militaryPersonnelAliveOrDe": "Alive",' +
                                        '"diagnosisInformation": null,' +
                                        '"diagnosisdriver": "Neurological effect and/or Neurobehavioral Performance Deficit"' +
                                    '}';
        string masstortStr = '{' +
                                    '"masstortcasetype": "Camp Lejeune Q Review",' +
                                    '"didtheuserhavetype1diabe": null,' +
                                    '"didyouhavetohavesurgeryt": null,' +
                                    '"didyouundergochemotherapy": null,' +
                                    '"dateofdeath": null,' +
                                    '"ageattimeofdeath": null,' +
                                    '"inwhatstatedidshepassawa": null,' +
                                    '"placeofresidenceattimeof": null,' +
                                    '"doyouhaveacopyofthedece": null,' +
                                    '"whatisthecauseofdeathlis": null,' +
                                    '"didshehaveawill": null,' +
                                    '"haveyoubeenappointedbyac": null,' +
                                    '"wasthedecentdiagnosedwith": null,' +
                                    '"atwhatmedicalfacilitywass": null,' +
                                    '"didshehavetohavesurgeryt": null,' +
                                    '"didshehavetoundergochemot": null,' +
                                    '"atwhatmedicalfacilitydids": null,' +
                                    '"wherewasshelivingattheti": null,' +
                                    '"masstorts": null,' +
                                    '"dateOfSurgery": null,' +
                                    '"jJBP": null,' +
                                    '"dateOfFirstRecurrence": null,' +
                                    '"histologicType": null,' +
                                    '"usageDates1": null,' +
                                    '"treatments": null,' +
                                    '"stage": null,' +
                                    '"usageDates2": null,' +
                                    '"histologicGrade": null,' +
                                    '"showerToShower": null,' +
                                    '"primarySiteS": null,' +
                                    '"ageAtDiagnosis": null,' +
                                    '"otherProductsUsed": null,' +
                                    '"genericTestingResults": null,' +
                                    '"familyHistory": null,' +
                                    '"riskFactors": null,' +
                                    '"protectiveFactors": null,' +
                                    '"additionalNotesOnDiagnosis_1": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"dateDiagnosisConfirmed": null,' +
                                    '"deathCertificateUpload": null,' +
                                    '"willUpload": null,' +
                                    '"otherLitigationType": null,' +
                                    '"litigationSubType": null,' +
                                    '"diagnosisConfirmed": null,' +
                                    '"legacyUsageState": null,' +
                                    '"paragardPlacementDate": null,' +
                                    '"paragardRemovalDate": null,' +
                                    '"placementFacility": null,' +
                                    '"removalFacility": null,' +
                                    '"didParagardArmSBreakBefo": null,' +
                                    '"didClientHaveSurgeryToRem": null,' +
                                    '"dateOfParagardSurgery": null,' +
                                    '"surgeryFacility": null,' +
                                    '"hasSurgeryBeenRecommended": null,' +
                                    '"removedParagardStatus": null,' +
                                    '"directExposure": null,' +
                                    '"indirectExposure": null,' +
                                    '"purchasesParaquatProducts": null,' +
                                    '"appliedParaquatProducts": null,' +
                                    '"certifiedApplicator": null,' +
                                    '"licensingAuthority": null,' +
                                    '"yearOfLicense": null,' +
                                    '"licenseNumber": null,' +
                                    '"yearOfFirstExposure": null,' +
                                    '"yearOfLastExposure": null,' +
                                    '"frequencyOfExposure": null,' +
                                    '"exposureStates": null,' +
                                    '"whereEmployed": null,' +
                                    '"otherPlace": null,' +
                                    '"placeOfExposure": null,' +
                                    '"distanceFromResidenceToSpr": null,' +
                                    '"methodOfDirectExposure": null,' +
                                    '"otherMethod": null,' +
                                    '"exposureDescription": null,' +
                                    '"paraquatProducts": null,' +
                                    '"otherParaquatProduct": null,' +
                                    '"cropsAppliedOn": null,' +
                                    '"documentsConfirmingPurchase": null,' +
                                    '"exposureToOtherChemical": null,' +
                                    '"otherChemicals": null,' +
                                    '"yearOfFirstExposureToOthe": null,' +
                                    '"yearOfLastExposureToOther": null,' +
                                    '"frequencyOfExposureToOther": null,' +
                                    '"descriptionOfOtherExposure": null,' +
                                    '"parkinsonSDiagnosisConfirme": null,' +
                                    '"dateOfParkinsonSDiagnosis": null,' +
                                    '"parkinsonSDiagnosingProvide": null,' +
                                    '"closeFamilyHistoryOfParkin": null,' +
                                    '"listOfFamilyMembersWithPa": null,' +
                                    '"probateCourtAppointment": null,' +
                                    '"anyPhotosOfParagard": null,' +
                                    '"confirmedGynecomastiaDiagnos": null,' +
                                    '"dateOfGynecomastiaDiagnosis": null,' +
                                    '"gynecomastiaSurgery": null,' +
                                    '"dateOfGynecomastiaSurgery": null,' +
                                    '"descriptionOfSurgery": null,' +
                                    '"gynecomastiaSurgeryFacility": null,' +
                                    '"ifNoGynecomastiaSurgeryHa": null,' +
                                    '"ifNoPlannedSurgeryWhyNot": null,' +
                                    '"anyCurrentTreatmentForGyne": null,' +
                                    '"dateOfLastTreatmentForGyn": null,' +
                                    '"anyPicturesOfGynecomastia": null,' +
                                    '"otherSignificantMedicalCond": null,' +
                                    '"gynecomastiaDiagnosisInforma": null,' +
                                    '"risperdalUsage": null,' +
                                    '"confirmedRisperdalRisperdo": null,' +
                                    '"prescribedDrug": null,' +
                                    '"otherDrug": null,' +
                                    '"datesOfDrugUsage": null,' +
                                    '"stateSOfUsage": null,' +
                                    '"drugDosage": null,' +
                                    '"reasonForDrugPrescription": null,' +
                                    '"usagePreLabel": null,' +
                                    '"usagePostLabel": null,' +
                                    '"minorUsePreLabel": null,' +
                                    '"minorUsePostLabel": null,' +
                                    '"adultUseOnly": null,' +
                                    '"settlementInfoCosts": null,' +
                                    '"medicalBillsAttributableTo": null,' +
                                    '"caseCosts": null,' +
                                    '"deathCertificate": null,' +
                                    '"will": null,' +
                                    '"probateCourtDocuments": null,' +
                                    '"parkinsonSDiagnosisRecords": null,' +
                                    '"paraquatPurchaseOrExposure": null,' +
                                    '"gynecomastiaDiagnosisRecords": null,' +
                                    '"gynecomastiaSurgeryRecords": null,' +
                                    '"gynecomastiaPictures": null,' +
                                    '"prescriptionRecords": null,' +
                                    '"medicalBills": null,' +
                                    '"paragardPlacementRecords": null,' +
                                    '"paragardRemovalRecords": null,' +
                                    '"paragardSurgeryRecords": null,' +
                                    '"paragardPhotos": null,' +
                                    '"medtronicMinimedPumpInjury": null,' +
                                    '"minimedPumpInjuryConfirmed": null,' +
                                    '"minimedPumpInjury": null,' +
                                    '"dateOfMinimedPumpInjury": null,' +
                                    '"ageAtMinimedPumpInjury": null,' +
                                    '"stateOfResidenceAtTimeOf": null,' +
                                    '"descriptionOfPumpInjury": null,' +
                                    '"treatmentForPumpInjury": null,' +
                                    '"treatmentDuration": null,' +
                                    '"treatmentRecords": null,' +
                                    '"medicalExpensesForPumpInju": null,' +
                                    '"descriptionOfTreatment": null,' +
                                    '"minimedPUmpInformation": null,' +
                                    '"defectiveMinimedPumpModel": null,' +
                                    '"serialNumber": null,' +
                                    '"retainerRingDescription": null,' +
                                    '"retainerRingPhotos": null,' +
                                    '"locationOfPump": null,' +
                                    '"pumpStartDate": null,' +
                                    '"statesUsedIn": null,' +
                                    '"pumpEndDate": null,' +
                                    '"notesOnDefectivePump": null,' +
                                    '"otherPumpsUsed": null,' +
                                    '"diabetesInformation": null,' +
                                    '"type1DiabetesConfirmed": null,' +
                                    '"dateOfDiabetesDiagnosis": null,' +
                                    '"diabetesStatus": null,' +
                                    '"diabetesManagementBeforeDef": null,' +
                                    '"currentDiabetesManagement": null,' +
                                    '"miniMedSeries600Confirmed": null,' +
                                    '"retainerRingColor": null,' +
                                    '"otherInjury": null,' +
                                    '"daysHospitalized": null,' +
                                    '"treatmentFacility": null,' +
                                    '"recurrence": null,' +
                                    '"additionalPrescriptionRecord": null,' +
                                    '"ageAtParkinsonSDiagnosis": null,' +
                                    '"additionalParkisonSDiagnosi": null,' +
                                    '"diagnosisRecordsOpPathRep": null,' +
                                    '"usageAffidavitOrDeclaration": null,' +
                                    '"geneticTestingRecords": null,' +
                                    '"space3392": null,' +
                                    '"space2402": null,' +
                                    '"space2412": null,' +
                                    '"space2422": null,' +
                                    '"space2442": null,' +
                                    '"space2452": null,' +
                                    '"space1882": null,' +
                                    '"space1902": null,' +
                                    '"space1942": null,' +
                                    '"qualifyingCancer": null,' +
                                    '"space2031": null,' +
                                    '"space2032": null,' +
                                    '"campLejeune": null,' +
                                    '"confirmedExposureToWaterAt": null,' +
                                    '"startDateOfExposure": "1990-12-12T00:00:00Z",' +
                                    '"endDateOfExposure": "1990-01-12T00:00:00Z",' +
                                    '"lengthOfExposure": null,' +
                                    '"exposureLocationS": null,' +
                                    '"methodOfExposure": null,' +
                                    '"statusWhenStationedAtCamp": "Military Veteran",' +
                                    '"militaryService": null,' +
                                    '"militaryServicemember": null,' +
                                    '"branchOfMilitary": null,' +
                                    '"lastRank": null,' +
                                    '"lastPayGrade": null,' +
                                    '"datesOfService": null,' +
                                    '"typeOfSeparation": null,' +
                                    '"dDForm214Received": null,' +
                                    '"dDForm214": null,' +
                                    '"documentationOfExposure": null,' +
                                    '"injuryInformation": null,' +
                                    '"campLejeuneInjuryConfirmed": null,' +
                                    '"diagnosisProvider": null,' +
                                    '"treatingProviderS": null,' +
                                    '"diagnosisRecords": null,' +
                                    '"treatingRecords": null,' +
                                    '"currentlyTreating": null,' +
                                    '"currentTreatingProviderS": null,' +
                                    '"nonVAMedicalInsurance": null,' +
                                    '"insuranceCarrier": null,' +
                                    '"policyNumber": null,' +
                                    '"groupNumber": null,' +
                                    '"insuranceInformation": null,' +
                                    '"medicareCoverage": null,' +
                                    '"medicarePolicyNumber": null,' +
                                    '"medicaidCoverage": null,' +
                                    '"medicaidPolicyNumber": null,' +
                                    '"otherMedicalConditionsForW": null,' +
                                    '"descriptionOfOtherVABenefi": null,' +
                                    '"priorCampLajeuneClaimInfor": null,' +
                                    '"filedAPriorForm95Claim": null,' +
                                    '"denialLetter": null,' +
                                    '"adjudicatedReceivedDenial": null,' +
                                    '"ageAtTimeOfExposure": null,' +
                                    '"space3172": null,' +
                                    '"space3162": null,' +
                                    '"deathInformation": null,' +
                                    '"welcomePacketSent": null,' +
                                    '"allRecordsRequested": null,' +
                                    '"oMPF": null,' +
                                    '"officialMilitaryPersonnelFi_1": null,' +
                                    '"officialMilitaryPersonnelFi": null,' +
                                    '"cLWelcomeEmailAGOnly": null,' +
                                    '"cLWelcomeEmailSinkReferra": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"talcumPowderInformation": null,' +
                                    '"additionalDiagnosisRecords": null,' +
                                    '"tubalLigation": null,' +
                                    '"dateOfTubalLigation": null,' +
                                    '"confirmedInjury": null,' +
                                    '"otherCancerDiseaseCondition": null,' +
                                    '"claimedInjury": null,' +
                                    '"otherClaimedInjury": null,' +
                                    '"clientDocumentsReceived": null,' +
                                    '"documentsReceived": null,' +
                                    '"missingDocuments": null,' +
                                    '"additionalStatusWhenStation": null,' +
                                    '"intakeSummaryOfInjuries": null,' +
                                    '"space3391": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"space3412": null,' +
                                    '"typeOfTreatment": null,' +
                                    '"clientDoesNotRecallTreatme": null,' +
                                    '"currentTreatingRecords": null,' +
                                    '"smokingStatus": null,' +
                                    '"yearsSmoked": null,' +
                                    '"averageCigarettesPerDay": null,' +
                                    '"didYouOrAFamilyMemberSer": null,' +
                                    '"exposedIndividualSName": null,' +
                                    '"otherExposureLocation": null,' +
                                    '"nameOfEmployerIfNonMilit": null,' +
                                    '"additionalStatusInformation": null,' +
                                    '"dateOfDiagnosis": null,' +
                                    '"areYouCurrentlyReceivingVA": null,' +
                                    '"doYouHaveAnyOfTheFollowi": [' +
                                        '"Official Military Personnel File",' +
                                        '"Medical Records"' +
                                    '],' +
                                    '"currentOrMostRecentPrimary": null,' +
                                    '"haveYouEverBeenTreatedFor": null,' +
                                    '"identifyTheMilitaryBaseAnd": null,' +
                                    '"cLWelcomeEmailTwoCoCouns": null,' +
                                    '"sponsorName": null,' +
                                    '"hadnotPointIndustrialArea": null,' +
                                    '"medicalConditionsInvestigati": null,' +
                                    '"questionnaireFollowUpEmail": null,' +
                                    '"questionnaireFollowUpEmail_1": null,' +
                                    '"additionalInjuryDates": null,' +
                                    '"dateSubmitted": null,' +
                                    '"serviceRequestNumber": null,' +
                                    '"recordRequest": null,' +
                                    '"otherMilitaryFiles": null,' +
                                    '"typeOfEmploymentWhileAtCa": null,' +
                                    '"dateEnteredService": null,' +
                                    '"serviceEndDate": null,' +
                                    '"trtStrDate": null,' +
                                    '"injfamhis": null,' +
                                    '"ompfExp": null,' +
                                    '"ompfExpEnd": null,' +
                                    '"totalDaysAtCampLejeune": null,' +
                                    '"diagnosisDate": null,' +
                                    '"daysAtCL": null,' +
                                    '"onsetDate": null,' +
                                    '"medicalReviewNotes": null,' +
                                    '"oMPFDeficiency": null,' +
                                    '"letterMailDate": null,' +
                                    '"deficiencyLetter": null,' +
                                    '"electiveoption": null,' +
                                    '"clientQualifiesForEO": null,' +
                                    '"electiveOptionNotice": null,' +
                                    '"mailDate": null,' +
                                    '"relationshipToSponsor": null,' +
                                    '"otherRelationToSponsor": null,' +
                                    '"otherResidenceInformation": null,' +
                                    '"clientWishesToPursueEO": null,' +
                                    '"oMPFNotes": null,' +
                                    '"monthsAtCL": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        string docrioSignedUrlRespStr = '{' +
                                            '"Records": [' +
                                                '{' +
                                                    '"Id": "' + testFile.Id + '",' +
                                                    '"SignedUrl": "https://test.pdf"' +
                                                '}' +
                                            ']' +
                                        '}';
        string docrioFileContentRespStr = 'a'.repeat(100);
        string docrioUploadFileRespStr = '{' +
                                        '"message": "Document Uploaded"' +
                                    '}';
        
        string fvNewDocUploadRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify1234"' +
                                            '},' +
                                            '"contentType": "application/pdf",' +
                                            '"url": "https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5",' +
                                            '"links": {}' +
                                        '}';
        string fvUploadStr = '';
        string fvAddDocToProjRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify123"' +
                                            '},' +
                                            '"filename": "Test.pdf",' +
                                            '"size": 0,' +
                                            '"folderId": {' +
                                                '"native": 148064847,' +
                                                '"partner": null' +
                                            '},' +
                                            '"projectId": {' +
                                                '"native": 4580812,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploaderId": {' +
                                                '"native": 2941,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploadDate": "2024-05-01T18:15:56.9337196Z",' +
                                            '"hashtags": [],' +
                                            '"links": {' +
                                                '"project": "/projects/4580812",' +
                                                '"self": "/documents/311047751",' +
                                                '"folder": "/folders/148064847",' +
                                                '"hashtags": "/documents/311047751/hashtags"' +
                                            '}' +
                                        '}';
        string caseSummaryStr = '{' +
                                    '"tier": null,' +
                                    '"assignedattorney": null,' +
                                    '"assignedparalegal": null,' +
                                    '"masstortcoordinator": null,' +
                                    '"datecontacted": null,' +
                                    '"practicearea": "Test Case Type",' +
                                    '"statuteoflimitation": null,' +
                                    '"personalinjurysol": null,' +
                                    '"wrongfuldeathsol": null,' +
                                    '"solnotes": null,' +
                                    '"coCounsel1": {' +
                                        '"personId": {' +
                                            '"native": 19043693,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19043693,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Saddle Rock Legal Group, LLC",' +
                                        '"middleName": null,' +
                                        '"lastName": null,' +
                                        '"fullname": "Saddle Rock Legal Group, LLC",' +
                                        '"isSingleName": true,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Saddle Rock Legal Group, LLC",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [],' +
                                        '"emails": [],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11628545,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington DC",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington DC, DC 20005"' +
                                            '},' +
                                            '{' +
                                                '"id": 11628546,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington, DC 20005"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"pictureKey": "Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"birthDate": null,' +
                                        '"deathDate": null,' +
                                        '"isDeceased": null,' +
                                        '"uniqueID": "589380d7-2c7f-44bd-9883-77b217b98e2e",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": null,' +
                                        '"notes": null,' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": null,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"saddle",' +
                                            '"rock",' +
                                            '"legal",' +
                                            '"group,",' +
                                            '"llc",' +
                                            '"saddle rock legal group, llc"' +
                                        ']' +
                                    '},' +
                                    '"coCounsel2": null,' +
                                    '"coCounsel3": null,' +
                                    '"coCounsel1FeePercentage": null,' +
                                    '"coCounsel2FeePercentage": null,' +
                                    '"6Space": null,' +
                                    '"coCounsel3FeePercentage": null,' +
                                    '"7Space": null,' +
                                    '"coCounsel": true,' +
                                    '"courtInfo": null,' +
                                    '"courtCase1": null,' +
                                    '"caption": null,' +
                                    '"dateFiled": null,' +
                                    '"localCounsel": null,' +
                                    '"localCounselFeePercentage": null,' +
                                    '"otherLitigationType": null,' +
                                    '"areYouLocalCouncil": false,' +
                                    '"staffAssignments": null,' +
                                    '"practiceAreaCaseStatus": null,' +
                                    '"litigationSubtype": "Personal Injury",' +
                                    '"coCounselReferralInformat": null,' +
                                    '"localCounselFeePercentage_1": null,' +
                                    '"caseReferredOut": false,' +
                                    '"referralFirmFeePercentage": null,' +
                                    '"referralFirm": null,' +
                                    '"referralFirm2": null,' +
                                    '"referralFirm3": null,' +
                                    '"referralToFirm": null,' +
                                    '"courtlegacy": null,' +
                                    '"activeDateFiled": null,' +
                                    '"trialDate": null,' +
                                    '"pTCDate": null,' +
                                    '"dateOf1stExposureToAsbest": null,' +
                                    '"dateOf1stDiagnosisOfAsbes": null,' +
                                    '"dateLastExposureToAsbestos": null,' +
                                    '"probateCourt": null,' +
                                    '"probateCourtDocket": null,' +
                                    '"activeInactive": null,' +
                                    '"bMLCTNO": null,' +
                                    '"complaintAmendedToAllegeNe": null,' +
                                    '"complaintAmendedForWrongful": null,' +
                                    '"complaintAmendedToAddPerso": null,' +
                                    '"trialGroup": null,' +
                                    '"complaintAmendedToAddUseP": null,' +
                                    '"complaintAmendedPlaintiffsD": null,' +
                                    '"complaintAmendedNewDisease": null,' +
                                    '"complaintAmendedWrongfulDea": null,' +
                                    '"complaintAmendedPersonalRep": null,' +
                                    '"statusConferenceHearings": null,' +
                                    '"spacer432": null,' +
                                    '"spacer21": null,' +
                                    '"spacer52": null,' +
                                    '"judge": null,' +
                                    '"matterID": null,' +
                                    '"archivedReason": null,' +
                                    '"archivedDate": null,' +
                                    '"prevailStatus": null,' +
                                    '"court1CurrentCourt": null,' +
                                    '"court2": null,' +
                                    '"caseNumber2": null,' +
                                    '"court3": null,' +
                                    '"caseNumber3": null,' +
                                    '"relationshipToDecedent": null,' +
                                    '"tolled": null,' +
                                    '"tollingStart": null,' +
                                    '"tollingEnd": null,' +
                                    '"otherArchiveReason": null,' +
                                    '"retainerFeePercentage": null,' +
                                    '"8Space": null,' +
                                    '"coCounsel4": null,' +
                                    '"coCounsel4Fee": null,' +
                                    '"referralFirm4": null,' +
                                    '"complaintUpload": null,' +
                                    '"retainer": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"aGLocalCounselAgreement": null,' +
                                    '"coCounselAgreement": null,' +
                                    '"localCounselAgreement": null,' +
                                    '"tollingAgreement": null,' +
                                    '"nonQualifyingInjury": null,' +
                                    '"doYouHaveLocalCounsel": null,' +
                                    '"clientBankruptcyInformation": null,' +
                                    '"pendingBankruptcy": null,' +
                                    '"priorBankruptcy": null,' +
                                    '"pendingBankruptcyChapter": null,' +
                                    '"pendingBankruptcyCourt": null,' +
                                    '"pendingBankruptcyCaseNo": null,' +
                                    '"clientBankruptcyAttorney": null,' +
                                    '"aGAppointedAsLitigationCo": null,' +
                                    '"aGAppointmentOrder": null,' +
                                    '"dateOfMostRecentPriorBank": null,' +
                                    '"chapterOfPriorBankruptcy": null,' +
                                    '"courtOfPriorBankruptcy": null,' +
                                    '"priorBankruptcyCaseNo": null,' +
                                    '"priorBankruptcyDischargeDat": null,' +
                                    '"bankruptcyTrustee": null,' +
                                    '"dateOfClaimedInjury": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"legacyAsbestosCaseInfo": null,' +
                                    '"injuredPersonPersonalInform": null,' +
                                    '"dateOfBirth": null,' +
                                    '"socialSecurityNumber": null,' +
                                    '"maritalStatus": null,' +
                                    '"children": null,' +
                                    '"highestEducation": null,' +
                                    '"highestDegreeObtained": null,' +
                                    '"nameOfInstitutionOfHighest": null,' +
                                    '"occupation": null,' +
                                    '"lastAnnualPayPriorToInjur": null,' +
                                    '"lastPlaceOfEmployment": null,' +
                                    '"space243": null,' +
                                    '"retainerFullyExecuted": null,' +
                                    '"decedentIfWrongfulDeathCa": null,' +
                                    '"coCounsel5": null,' +
                                    '"coCounsel5FeePercentage": null,' +
                                    '"referralFirm5": null,' +
                                    '"9Space": null,' +
                                    '"printToSmartMailroom": null,' +
                                    '"space32": null,' +
                                    '"space33": null,' +
                                    '"space53": null,' +
                                    '"space54": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"welcomeLetterSent": null,' +
                                    '"allClientDocumentsReceived": null,' +
                                    '"allRecordsOrdered": null,' +
                                    '"questionnaireStatus": null,' +
                                    '"questionnaire": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"authorizationsStatus": null,' +
                                    '"hIPAAAuthorization": null,' +
                                    '"otherAuthorizations": null,' +
                                    '"otherQuestionnaires": null,' +
                                    '"clientWelcomeEmail": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"duplicateProjectID": null,' +
                                    '"criteriaIssue": null,' +
                                    '"deathCertificateStatus": null,' +
                                    '"deathCertificate": null,' +
                                    '"lastWillStatus": null,' +
                                    '"estateOrderLetters": null,' +
                                    '"estateStatus": null,' +
                                    '"lastWill": null,' +
                                    '"clientNamedAsExecutor": null,' +
                                    '"clientAppointedPersonalRepr": null,' +
                                    '"causeOfDeath": null,' +
                                    '"clientMedicalRecords": null,' +
                                    '"space212": null,' +
                                    '"filedCivilCoverSheet": null,' +
                                    '"generateShortFormComplaint_1": null,' +
                                    '"draftCivilCoverSheet": null,' +
                                    '"milestonesEnabled": true,' +
                                    '"clientSRelationshipToInjur": "Work Spouse",' +
                                    '"injuredPerson": {' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19467459,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Client",' +
                                        '"lastName": "API",' +
                                        '"fullname": "Test Client API",' +
                                        '"isSingleName": false,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Test Client API",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [' +
                                            '{' +
                                                '"id": 17563433,' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563434,' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563435,' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"id": 6332234,' +
                                                '"address": "test@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 6332235,' +
                                                '"address": "test1@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11907151,' +
                                                '"line1": "123 Test Street",' +
                                                '"line2": null,' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"zip": null,' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": null,' +
                                                '"fullAddress": "123 Test Street, Test, PA"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"pictureKey": "Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"deathDate": "2024-04-29T00:00:00Z",' +
                                        '"isDeceased": true,' +
                                        '"uniqueID": "e7f5c781-bfa2-4c46-abf1-3bc2d9d0a46d",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": "123456789",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": true,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"client",' +
                                            '"api",' +
                                            '"test client api",' +
                                            '"test api"' +
                                        ']' +
                                    '},' +
                                    '"pOAOrGuardianshipPapers": null,' +
                                    '"presumptiveCondition": null,' +
                                    '"jAGPerfectionLetter": null,' +
                                    '"jAGSubstantiationLetter": null,' +
                                    '"dONClaim": null,' +
                                    '"perfectionLetter": null,' +
                                    '"substantiationLetter": null,' +
                                    '"parkerDenial": null,' +
                                    '"stateOfDeath": null,' +
                                    '"appointedJudge": null,' +
                                    '"coCounselProvidedMedicalRe": null,' +
                                    '"stateEstablished": null,' +
                                    '"countyEstablished": null,' +
                                    '"tier2": null,' +
                                    '"tier2_1": null,' +
                                    '"mDLRemandJurisdiction": null,' +
                                    '"caseWorks": null,' +
                                    '"dateSentToCaseWorks": null,' +
                                    '"defendantsHairRelaxers": null,' +
                                    '"caseDevelopment": null,' +
                                    '"vendor": null,' +
                                    '"dateSentToVendor": null,' +
                                    '"vendorStatus": null,' +
                                    '"statusComments": null,' +
                                    '"statusDate": null,' +
                                    '"communicationStatus": null,' +
                                    '"comments": null,' +
                                    '"commDate": null,' +
                                    '"proofOfIdentity": null,' +
                                    '"withdrawalTrackingNumber": null,' +
                                    '"dateAmended": null,' +
                                    '"amendedComplaint": null,' +
                                    '"space582": null,' +
                                    '"space583": null,' +
                                    '"alertsNotes": null,' +
                                    '"settlementProjections": null,' +
                                    '"injuryCategory": null,' +
                                    '"projectedSettlement": null,' +
                                    '"feeCap": null,' +
                                    '"aGFeeSum": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(200, 'OK', sessionRespStr, null);
        SaddleRockCalloutMock customContactResp = new SaddleRockCalloutMock(200, 'OK', customContactRespStr, null);
        SaddleRockCalloutMock projectResp = new SaddleRockCalloutMock(200, 'OK', projectRespStr, null);
        SaddleRockCalloutMock initialIntakeResp = new SaddleRockCalloutMock(200, 'OK', initialIntakeStr, null);
        SaddleRockCalloutMock masstortResp = new SaddleRockCalloutMock(200, 'OK', masstortStr, null);
        SaddleRockCalloutMock docrioAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', docrioFileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', docrioUploadFileRespStr, null);
        SaddleRockCalloutMock fvNewDocUploadResp = new SaddleRockCalloutMock(200, 'OK', fvNewDocUploadRespStr, null);
        SaddleRockCalloutMock fvUploadResp = new SaddleRockCalloutMock(200, 'OK', fvUploadStr, null);
        SaddleRockCalloutMock fvAddDocToProjResp = new SaddleRockCalloutMock(200, 'OK', fvAddDocToProjRespStr, null);
        SaddleRockCalloutMock caseSummaryResp = new SaddleRockCalloutMock(200, 'OK', caseSummaryStr, null);

        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);
        multiCalloutMock.addRequestMock(customContactUrl, customContactResp);
        multiCalloutMock.addRequestMock(projectUrl, projectResp);
        multiCalloutMock.addRequestMock(initialIntakeUrl, initialIntakeResp);
        multiCalloutMock.addRequestMock(masstortUrl, masstortResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, docrioAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(docrioUploadFileRespStr, uploadFileResp);
        multiCalloutMock.addRequestMock(fvNewDocUploadUrl, fvNewDocUploadResp);
        multiCalloutMock.addRequestMock(fvUploadUrl, fvUploadResp);
        multiCalloutMock.addRequestMock(fvAddDocToProjUrl, fvAddDocToProjResp);
        multiCalloutMock.addRequestMock(casesummaryUrl, caseSummaryResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_External_ID__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('4580812', intakes[0].Referral_Partner_API_External_ID__c);
    }

    @isTest 
    public static void test_OK_ClientIsCaller() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerIntake();
        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        string customContactUrl = fvSetting.Base_URL__c + '/core/custom-contacts';
        string projectUrl = fvSetting.Base_URL__c + '/core/projects';
        string initialIntakeUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/initialintake';
        string masstortUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/masstortinfo';
        string casesummaryUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/casesummary';
        string fvNewDocUploadUrl = fvSetting.Base_URL__c + '/core/documents';
        string fvUploadUrl = 'https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5';
        string fvAddDocToProjUrl = fvSetting.Base_URL__c + '/core/projects/4580812/documents/311047751';

        string sessionRespStr = '{' +
                                    '"accessToken": "abc1234",' +
                                    '"refreshToken": "defghi",' +
                                    '"refreshTokenExpiry": "56719877617",' +
                                    '"refreshTokenTtl": "24 hours",' +
                                    '"userId": "12345",' +
                                    '"orgId": "5293"' +
                                '}';
        string customContactRespStr = '{' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Caller",' +
                                        '"lastName": "API",' +
                                        '"isSingleName": false,' +
                                        '"fullName": "Test Caller API",' +
                                        '"primaryEmail": "test@test.com",' +
                                        '"pictureUrl": "/images/Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"pictureKey": "Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"ssn": "123456789",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"personTypes": [],' +
                                        '"uniqueId": "6a820963-01b7-4bcc-a6ea-3cf2445ee94f",' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"caller",' +
                                            '"api",' +
                                            '"test caller api",' +
                                            '"test api"' +
                                        '],' +
                                        '"phones": [' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568205,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568206,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568207,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334495,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test@test.com",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334496,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test1@test.com",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"addressId": {' +
                                                    '"native": 11910464,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"line1": "123 Test Street",' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"fullAddress": "123 Test Street, Test, PA",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"hashtags": [],' +
                                        '"links": {' +
                                            '"self": "/contacts/19472883",' +
                                            '"projects": "/contacts/19472883/projects",' +
                                            '"phones": "/contacts/19472883/phones",' +
                                            '"emailAddresses": "/contacts/19472883/emailAddresses",' +
                                            '"addresses": "/contacts/19472883/addresses"' +
                                        '}' +
                                    '}';
        string projectRespStr = '{' +
                                    '"projectTypeCode": "MT3",' +
                                    '"rootDocFolderId": {' +
                                        '"native": 148064847,' +
                                        '"partner": null' +
                                    '},' +
                                    '"phaseName": "Migration for Review",' +
                                    '"clientName": "Test Client API",' +
                                    '"clientPictureURL": "/image-error.png",' +
                                    '"firstPrimaryName": "Filevine Integration",' +
                                    '"firstPrimaryUsername": "filevine128",' +
                                    '"isArchived": false,' +
                                    '"lastActivity": "2024-05-01T17:06:08.4192757Z",' +
                                    '"uniqueKey": "TestClientAPIZ4580812",' +
                                    '"projectOrClientName": "Test Client API",' +
                                    '"hashtags": [],' +
                                    '"projectEmailAddress": "TestClientAPIZ4580812@ashcraftandgerel.filevineapp.com",' +
                                    '"createdDate": "2024-05-01T17:06:08.4156183Z",' +
                                    '"projectUrl": "https://ashcraftandgerel.filevineapp.com/#/project/4580812",' +
                                    '"projectId": {' +
                                        '"native": 4580812,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectTypeId": {' +
                                        '"native": 4675,' +
                                        '"partner": null' +
                                    '},' +
                                    '"clientId": {' +
                                        '"native": 19467459,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectName": "Test Client API",' +
                                    '"phaseId": {' +
                                        '"native": 41897,' +
                                        '"partner": null' +
                                    '},' +
                                    '"links": {' +
                                        '"self": "/projects/4580812",' +
                                        '"projectType": "/projecttypes/4675",' +
                                        '"rootFolder": "/folders/148064847",' +
                                        '"client": "/contacts/19467459",' +
                                        '"contacts": "/projects/4580812/contacts"' +
                                    '}' +
                                '}';
        string initialIntakeStr = '{' +
                                        '"dateofintake": null,' +
                                        '"personperformingintakeLegacy": null,' +
                                        '"referralsource": null,' +
                                        '"referredfrom1": null,' +
                                        '"referredfrom1feepercentage": null,' +
                                        '"originatingattorney": null,' +
                                        '"casedescription": "Testing litify_pm__Description__c",' +
                                        '"leadstatus": null,' +
                                        '"rejectionreason": null,' +
                                        '"additionaldescriptionforrejection": null,' +
                                        '"casereferredto": null,' +
                                        '"referralfee": null,' +
                                        '"referralcontracts": null,' +
                                        '"datecontractsent": null,' +
                                        '"datecontractsigned": null,' +
                                        '"casetype": null,' +
                                        '"priorclient": null,' +
                                        '"othercasetype": null,' +
                                        '"referringfrom2": null,' +
                                        '"referralfrom2feepercenta": null,' +
                                        '"referredfrom3": null,' +
                                        '"referredfrom3feepercentage": null,' +
                                        '"otherrelevantreferralinfo": null,' +
                                        '"attorneyreviewwc3rdparty": null,' +
                                        '"additionalreferralsources": null,' +
                                        '"referralfrom4": null,' +
                                        '"referralsource5space": null,' +
                                        '"referredfrom5": null,' +
                                        '"isthecallertheinjuredpart": null,' +
                                        '"callername": null,' +
                                        '"callerrelationshiptoinjured": null,' +
                                        '"callerrelationshipother": null,' +
                                        '"3rdpartyattorneyreviewnote": null,' +
                                        '"initialIntakeInfo": null,' +
                                        '"referralMarketingInfo": null,' +
                                        '"litigationSubtype": null,' +
                                        '"personPerformingIntake": null,' +
                                        '"leadSentForReplacement": null,' +
                                        '"marketingSourceAgreedToRep": null,' +
                                        '"diagnosisReceived": null,' +
                                        '"diagnosisDate": null,' +
                                        '"firstSurgeryDate": null,' +
                                        '"stateWhereDiagnosed": null,' +
                                        '"discoveryDate": null,' +
                                        '"surgeryType": null,' +
                                        '"nameOfProductsUsed": null,' +
                                        '"dateOfFirstUse": null,' +
                                        '"dateOfLastUse": null,' +
                                        '"marketingSourceID": null,' +
                                        '"whatCityWereYouBorn": null,' +
                                        '"stateBorn": null,' +
                                        '"relationship": "The caller is the formal next of kin (when through all levels and they are the next in line)",' +
                                        '"personalInformation": null,' +
                                        '"legalRelation": null,' +
                                        '"callSelf": null,' +
                                        '"callerSELF": null,' +
                                        '"callerOTHER": null,' +
                                        '"causeofdeath": null,' +
                                        '"cityBorn": null,' +
                                        '"stateBornOther": null,' +
                                        '"whyAreYouThePointOfConta": null,' +
                                        '"coCounselID": "a0CVF00000TQOxG2AX",' +
                                        '"healthcareProvider": null,' +
                                        '"treatingHealthcareProvider": null,' +
                                        '"outreachLetterSent": null,' +
                                        '"hasAnEstateBeenOpened": true,' +
                                        '"isTheEstateCurrentlyOpen": true,' +
                                        '"doYouHaveACopyOfTheDeat": true,' +
                                        '"allLocationsLivedWorkedOr": "Knox Trailer Park;Hadnot Point",' +
                                        '"haveYouEverSmokedCigarette": "Smoked less than 1 year prior to throat related cancer DX",' +
                                        '"doYouCurrentlySmokeCigaret": true,' +
                                        '"haveYouEverSmokedCigarette_1": true,' +
                                        '"forHowLongDidYouSmoke": "10 years",' +
                                        '"howManyCigarettesPerDay": "4",' +
                                        '"whenDidYouBeginSmoking": "2000",' +
                                        '"whenDidYouStopSmoking": "2010",' +
                                        '"doYouHaveAnyDocumentsRela": "Yes",' +
                                        '"ifCivilianWhatWasTheNatu": "Testing Nature_Of_Presence_At_Camp_Lejeune__c",' +
                                        '"militaryDetails": "Testing Branch_discharge_status_and_rank__c",' +
                                        '"fullNameOfMilitaryService": "Testing Military_Stationed_Family_Mem_Full_Name__c",' +
                                        '"branchOfService": "Testing Branch_of_Service__c",' +
                                        '"dischargeStatus": "Honorable",' +
                                        '"rank": "Captain",' +
                                        '"tier1Diagnosis": "Kidney disease (End stage renal (ESRD), Renal Toxicity, Chronic Kidney Disease, etc.)",' +
                                        '"tier2Diagnosis": "Esophageal cancer",' +
                                        '"tier3Diagnosis": "None of the above",' +
                                        '"tier4Diagnosis": null,' +
                                        '"diagnosisDates": null,' +
                                        '"treatingDoctors": "Testing List_Dx_treating_doctor_names_spec__c",' +
                                        '"treatingFacilities": "Testing Treatment_Facilities_Name_and_Addresses__c",' +
                                        '"militaryPersonnelSSN": "123589852",' +
                                        '"militaryPersonnelDOB": "1980-12-24T00:00:00Z",' +
                                        '"militaryPersonnelPlaceOfBi": "CA",' +
                                        '"serviceNumber": "123456",' +
                                        '"militaryPersonnelAliveOrDe": "Alive",' +
                                        '"diagnosisInformation": null,' +
                                        '"diagnosisdriver": "Neurological effect and/or Neurobehavioral Performance Deficit"' +
                                    '}';
        string masstortStr = '{' +
                                    '"masstortcasetype": "Camp Lejeune Q Review",' +
                                    '"didtheuserhavetype1diabe": null,' +
                                    '"didyouhavetohavesurgeryt": null,' +
                                    '"didyouundergochemotherapy": null,' +
                                    '"dateofdeath": null,' +
                                    '"ageattimeofdeath": null,' +
                                    '"inwhatstatedidshepassawa": null,' +
                                    '"placeofresidenceattimeof": null,' +
                                    '"doyouhaveacopyofthedece": null,' +
                                    '"whatisthecauseofdeathlis": null,' +
                                    '"didshehaveawill": null,' +
                                    '"haveyoubeenappointedbyac": null,' +
                                    '"wasthedecentdiagnosedwith": null,' +
                                    '"atwhatmedicalfacilitywass": null,' +
                                    '"didshehavetohavesurgeryt": null,' +
                                    '"didshehavetoundergochemot": null,' +
                                    '"atwhatmedicalfacilitydids": null,' +
                                    '"wherewasshelivingattheti": null,' +
                                    '"masstorts": null,' +
                                    '"dateOfSurgery": null,' +
                                    '"jJBP": null,' +
                                    '"dateOfFirstRecurrence": null,' +
                                    '"histologicType": null,' +
                                    '"usageDates1": null,' +
                                    '"treatments": null,' +
                                    '"stage": null,' +
                                    '"usageDates2": null,' +
                                    '"histologicGrade": null,' +
                                    '"showerToShower": null,' +
                                    '"primarySiteS": null,' +
                                    '"ageAtDiagnosis": null,' +
                                    '"otherProductsUsed": null,' +
                                    '"genericTestingResults": null,' +
                                    '"familyHistory": null,' +
                                    '"riskFactors": null,' +
                                    '"protectiveFactors": null,' +
                                    '"additionalNotesOnDiagnosis_1": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"dateDiagnosisConfirmed": null,' +
                                    '"deathCertificateUpload": null,' +
                                    '"willUpload": null,' +
                                    '"otherLitigationType": null,' +
                                    '"litigationSubType": null,' +
                                    '"diagnosisConfirmed": null,' +
                                    '"legacyUsageState": null,' +
                                    '"paragardPlacementDate": null,' +
                                    '"paragardRemovalDate": null,' +
                                    '"placementFacility": null,' +
                                    '"removalFacility": null,' +
                                    '"didParagardArmSBreakBefo": null,' +
                                    '"didClientHaveSurgeryToRem": null,' +
                                    '"dateOfParagardSurgery": null,' +
                                    '"surgeryFacility": null,' +
                                    '"hasSurgeryBeenRecommended": null,' +
                                    '"removedParagardStatus": null,' +
                                    '"directExposure": null,' +
                                    '"indirectExposure": null,' +
                                    '"purchasesParaquatProducts": null,' +
                                    '"appliedParaquatProducts": null,' +
                                    '"certifiedApplicator": null,' +
                                    '"licensingAuthority": null,' +
                                    '"yearOfLicense": null,' +
                                    '"licenseNumber": null,' +
                                    '"yearOfFirstExposure": null,' +
                                    '"yearOfLastExposure": null,' +
                                    '"frequencyOfExposure": null,' +
                                    '"exposureStates": null,' +
                                    '"whereEmployed": null,' +
                                    '"otherPlace": null,' +
                                    '"placeOfExposure": null,' +
                                    '"distanceFromResidenceToSpr": null,' +
                                    '"methodOfDirectExposure": null,' +
                                    '"otherMethod": null,' +
                                    '"exposureDescription": null,' +
                                    '"paraquatProducts": null,' +
                                    '"otherParaquatProduct": null,' +
                                    '"cropsAppliedOn": null,' +
                                    '"documentsConfirmingPurchase": null,' +
                                    '"exposureToOtherChemical": null,' +
                                    '"otherChemicals": null,' +
                                    '"yearOfFirstExposureToOthe": null,' +
                                    '"yearOfLastExposureToOther": null,' +
                                    '"frequencyOfExposureToOther": null,' +
                                    '"descriptionOfOtherExposure": null,' +
                                    '"parkinsonSDiagnosisConfirme": null,' +
                                    '"dateOfParkinsonSDiagnosis": null,' +
                                    '"parkinsonSDiagnosingProvide": null,' +
                                    '"closeFamilyHistoryOfParkin": null,' +
                                    '"listOfFamilyMembersWithPa": null,' +
                                    '"probateCourtAppointment": null,' +
                                    '"anyPhotosOfParagard": null,' +
                                    '"confirmedGynecomastiaDiagnos": null,' +
                                    '"dateOfGynecomastiaDiagnosis": null,' +
                                    '"gynecomastiaSurgery": null,' +
                                    '"dateOfGynecomastiaSurgery": null,' +
                                    '"descriptionOfSurgery": null,' +
                                    '"gynecomastiaSurgeryFacility": null,' +
                                    '"ifNoGynecomastiaSurgeryHa": null,' +
                                    '"ifNoPlannedSurgeryWhyNot": null,' +
                                    '"anyCurrentTreatmentForGyne": null,' +
                                    '"dateOfLastTreatmentForGyn": null,' +
                                    '"anyPicturesOfGynecomastia": null,' +
                                    '"otherSignificantMedicalCond": null,' +
                                    '"gynecomastiaDiagnosisInforma": null,' +
                                    '"risperdalUsage": null,' +
                                    '"confirmedRisperdalRisperdo": null,' +
                                    '"prescribedDrug": null,' +
                                    '"otherDrug": null,' +
                                    '"datesOfDrugUsage": null,' +
                                    '"stateSOfUsage": null,' +
                                    '"drugDosage": null,' +
                                    '"reasonForDrugPrescription": null,' +
                                    '"usagePreLabel": null,' +
                                    '"usagePostLabel": null,' +
                                    '"minorUsePreLabel": null,' +
                                    '"minorUsePostLabel": null,' +
                                    '"adultUseOnly": null,' +
                                    '"settlementInfoCosts": null,' +
                                    '"medicalBillsAttributableTo": null,' +
                                    '"caseCosts": null,' +
                                    '"deathCertificate": null,' +
                                    '"will": null,' +
                                    '"probateCourtDocuments": null,' +
                                    '"parkinsonSDiagnosisRecords": null,' +
                                    '"paraquatPurchaseOrExposure": null,' +
                                    '"gynecomastiaDiagnosisRecords": null,' +
                                    '"gynecomastiaSurgeryRecords": null,' +
                                    '"gynecomastiaPictures": null,' +
                                    '"prescriptionRecords": null,' +
                                    '"medicalBills": null,' +
                                    '"paragardPlacementRecords": null,' +
                                    '"paragardRemovalRecords": null,' +
                                    '"paragardSurgeryRecords": null,' +
                                    '"paragardPhotos": null,' +
                                    '"medtronicMinimedPumpInjury": null,' +
                                    '"minimedPumpInjuryConfirmed": null,' +
                                    '"minimedPumpInjury": null,' +
                                    '"dateOfMinimedPumpInjury": null,' +
                                    '"ageAtMinimedPumpInjury": null,' +
                                    '"stateOfResidenceAtTimeOf": null,' +
                                    '"descriptionOfPumpInjury": null,' +
                                    '"treatmentForPumpInjury": null,' +
                                    '"treatmentDuration": null,' +
                                    '"treatmentRecords": null,' +
                                    '"medicalExpensesForPumpInju": null,' +
                                    '"descriptionOfTreatment": null,' +
                                    '"minimedPUmpInformation": null,' +
                                    '"defectiveMinimedPumpModel": null,' +
                                    '"serialNumber": null,' +
                                    '"retainerRingDescription": null,' +
                                    '"retainerRingPhotos": null,' +
                                    '"locationOfPump": null,' +
                                    '"pumpStartDate": null,' +
                                    '"statesUsedIn": null,' +
                                    '"pumpEndDate": null,' +
                                    '"notesOnDefectivePump": null,' +
                                    '"otherPumpsUsed": null,' +
                                    '"diabetesInformation": null,' +
                                    '"type1DiabetesConfirmed": null,' +
                                    '"dateOfDiabetesDiagnosis": null,' +
                                    '"diabetesStatus": null,' +
                                    '"diabetesManagementBeforeDef": null,' +
                                    '"currentDiabetesManagement": null,' +
                                    '"miniMedSeries600Confirmed": null,' +
                                    '"retainerRingColor": null,' +
                                    '"otherInjury": null,' +
                                    '"daysHospitalized": null,' +
                                    '"treatmentFacility": null,' +
                                    '"recurrence": null,' +
                                    '"additionalPrescriptionRecord": null,' +
                                    '"ageAtParkinsonSDiagnosis": null,' +
                                    '"additionalParkisonSDiagnosi": null,' +
                                    '"diagnosisRecordsOpPathRep": null,' +
                                    '"usageAffidavitOrDeclaration": null,' +
                                    '"geneticTestingRecords": null,' +
                                    '"space3392": null,' +
                                    '"space2402": null,' +
                                    '"space2412": null,' +
                                    '"space2422": null,' +
                                    '"space2442": null,' +
                                    '"space2452": null,' +
                                    '"space1882": null,' +
                                    '"space1902": null,' +
                                    '"space1942": null,' +
                                    '"qualifyingCancer": null,' +
                                    '"space2031": null,' +
                                    '"space2032": null,' +
                                    '"campLejeune": null,' +
                                    '"confirmedExposureToWaterAt": null,' +
                                    '"startDateOfExposure": "1990-12-12T00:00:00Z",' +
                                    '"endDateOfExposure": "1990-01-12T00:00:00Z",' +
                                    '"lengthOfExposure": null,' +
                                    '"exposureLocationS": null,' +
                                    '"methodOfExposure": null,' +
                                    '"statusWhenStationedAtCamp": "Military Veteran",' +
                                    '"militaryService": null,' +
                                    '"militaryServicemember": null,' +
                                    '"branchOfMilitary": null,' +
                                    '"lastRank": null,' +
                                    '"lastPayGrade": null,' +
                                    '"datesOfService": null,' +
                                    '"typeOfSeparation": null,' +
                                    '"dDForm214Received": null,' +
                                    '"dDForm214": null,' +
                                    '"documentationOfExposure": null,' +
                                    '"injuryInformation": null,' +
                                    '"campLejeuneInjuryConfirmed": null,' +
                                    '"diagnosisProvider": null,' +
                                    '"treatingProviderS": null,' +
                                    '"diagnosisRecords": null,' +
                                    '"treatingRecords": null,' +
                                    '"currentlyTreating": null,' +
                                    '"currentTreatingProviderS": null,' +
                                    '"nonVAMedicalInsurance": null,' +
                                    '"insuranceCarrier": null,' +
                                    '"policyNumber": null,' +
                                    '"groupNumber": null,' +
                                    '"insuranceInformation": null,' +
                                    '"medicareCoverage": null,' +
                                    '"medicarePolicyNumber": null,' +
                                    '"medicaidCoverage": null,' +
                                    '"medicaidPolicyNumber": null,' +
                                    '"otherMedicalConditionsForW": null,' +
                                    '"descriptionOfOtherVABenefi": null,' +
                                    '"priorCampLajeuneClaimInfor": null,' +
                                    '"filedAPriorForm95Claim": null,' +
                                    '"denialLetter": null,' +
                                    '"adjudicatedReceivedDenial": null,' +
                                    '"ageAtTimeOfExposure": null,' +
                                    '"space3172": null,' +
                                    '"space3162": null,' +
                                    '"deathInformation": null,' +
                                    '"welcomePacketSent": null,' +
                                    '"allRecordsRequested": null,' +
                                    '"oMPF": null,' +
                                    '"officialMilitaryPersonnelFi_1": null,' +
                                    '"officialMilitaryPersonnelFi": null,' +
                                    '"cLWelcomeEmailAGOnly": null,' +
                                    '"cLWelcomeEmailSinkReferra": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"talcumPowderInformation": null,' +
                                    '"additionalDiagnosisRecords": null,' +
                                    '"tubalLigation": null,' +
                                    '"dateOfTubalLigation": null,' +
                                    '"confirmedInjury": null,' +
                                    '"otherCancerDiseaseCondition": null,' +
                                    '"claimedInjury": null,' +
                                    '"otherClaimedInjury": null,' +
                                    '"clientDocumentsReceived": null,' +
                                    '"documentsReceived": null,' +
                                    '"missingDocuments": null,' +
                                    '"additionalStatusWhenStation": null,' +
                                    '"intakeSummaryOfInjuries": null,' +
                                    '"space3391": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"space3412": null,' +
                                    '"typeOfTreatment": null,' +
                                    '"clientDoesNotRecallTreatme": null,' +
                                    '"currentTreatingRecords": null,' +
                                    '"smokingStatus": null,' +
                                    '"yearsSmoked": null,' +
                                    '"averageCigarettesPerDay": null,' +
                                    '"didYouOrAFamilyMemberSer": null,' +
                                    '"exposedIndividualSName": null,' +
                                    '"otherExposureLocation": null,' +
                                    '"nameOfEmployerIfNonMilit": null,' +
                                    '"additionalStatusInformation": null,' +
                                    '"dateOfDiagnosis": null,' +
                                    '"areYouCurrentlyReceivingVA": null,' +
                                    '"doYouHaveAnyOfTheFollowi": [' +
                                        '"Official Military Personnel File",' +
                                        '"Medical Records"' +
                                    '],' +
                                    '"currentOrMostRecentPrimary": null,' +
                                    '"haveYouEverBeenTreatedFor": null,' +
                                    '"identifyTheMilitaryBaseAnd": null,' +
                                    '"cLWelcomeEmailTwoCoCouns": null,' +
                                    '"sponsorName": null,' +
                                    '"hadnotPointIndustrialArea": null,' +
                                    '"medicalConditionsInvestigati": null,' +
                                    '"questionnaireFollowUpEmail": null,' +
                                    '"questionnaireFollowUpEmail_1": null,' +
                                    '"additionalInjuryDates": null,' +
                                    '"dateSubmitted": null,' +
                                    '"serviceRequestNumber": null,' +
                                    '"recordRequest": null,' +
                                    '"otherMilitaryFiles": null,' +
                                    '"typeOfEmploymentWhileAtCa": null,' +
                                    '"dateEnteredService": null,' +
                                    '"serviceEndDate": null,' +
                                    '"trtStrDate": null,' +
                                    '"injfamhis": null,' +
                                    '"ompfExp": null,' +
                                    '"ompfExpEnd": null,' +
                                    '"totalDaysAtCampLejeune": null,' +
                                    '"diagnosisDate": null,' +
                                    '"daysAtCL": null,' +
                                    '"onsetDate": null,' +
                                    '"medicalReviewNotes": null,' +
                                    '"oMPFDeficiency": null,' +
                                    '"letterMailDate": null,' +
                                    '"deficiencyLetter": null,' +
                                    '"electiveoption": null,' +
                                    '"clientQualifiesForEO": null,' +
                                    '"electiveOptionNotice": null,' +
                                    '"mailDate": null,' +
                                    '"relationshipToSponsor": null,' +
                                    '"otherRelationToSponsor": null,' +
                                    '"otherResidenceInformation": null,' +
                                    '"clientWishesToPursueEO": null,' +
                                    '"oMPFNotes": null,' +
                                    '"monthsAtCL": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        string docrioSignedUrlRespStr = '{' +
                                            '"Records": [' +
                                                '{' +
                                                    '"Id": "' + testFile.Id + '",' +
                                                    '"SignedUrl": "https://test.pdf"' +
                                                '}' +
                                            ']' +
                                        '}';
        string docrioFileContentRespStr = 'a'.repeat(100);
        string docrioUploadFileRespStr = '{' +
                                        '"message": "Document Uploaded"' +
                                    '}';
        
        string fvNewDocUploadRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify1234"' +
                                            '},' +
                                            '"contentType": "application/pdf",' +
                                            '"url": "https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5",' +
                                            '"links": {}' +
                                        '}';
        string fvUploadStr = '';
        string fvAddDocToProjRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify123"' +
                                            '},' +
                                            '"filename": "Test.pdf",' +
                                            '"size": 0,' +
                                            '"folderId": {' +
                                                '"native": 148064847,' +
                                                '"partner": null' +
                                            '},' +
                                            '"projectId": {' +
                                                '"native": 4580812,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploaderId": {' +
                                                '"native": 2941,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploadDate": "2024-05-01T18:15:56.9337196Z",' +
                                            '"hashtags": [],' +
                                            '"links": {' +
                                                '"project": "/projects/4580812",' +
                                                '"self": "/documents/311047751",' +
                                                '"folder": "/folders/148064847",' +
                                                '"hashtags": "/documents/311047751/hashtags"' +
                                            '}' +
                                        '}';
        string caseSummaryStr = '{' +
                                    '"tier": null,' +
                                    '"assignedattorney": null,' +
                                    '"assignedparalegal": null,' +
                                    '"masstortcoordinator": null,' +
                                    '"datecontacted": null,' +
                                    '"practicearea": "Test Case Type",' +
                                    '"statuteoflimitation": null,' +
                                    '"personalinjurysol": null,' +
                                    '"wrongfuldeathsol": null,' +
                                    '"solnotes": null,' +
                                    '"coCounsel1": {' +
                                        '"personId": {' +
                                            '"native": 19043693,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19043693,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Saddle Rock Legal Group, LLC",' +
                                        '"middleName": null,' +
                                        '"lastName": null,' +
                                        '"fullname": "Saddle Rock Legal Group, LLC",' +
                                        '"isSingleName": true,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Saddle Rock Legal Group, LLC",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [],' +
                                        '"emails": [],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11628545,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington DC",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington DC, DC 20005"' +
                                            '},' +
                                            '{' +
                                                '"id": 11628546,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington, DC 20005"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"pictureKey": "Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"birthDate": null,' +
                                        '"deathDate": null,' +
                                        '"isDeceased": null,' +
                                        '"uniqueID": "589380d7-2c7f-44bd-9883-77b217b98e2e",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": null,' +
                                        '"notes": null,' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": null,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"saddle",' +
                                            '"rock",' +
                                            '"legal",' +
                                            '"group,",' +
                                            '"llc",' +
                                            '"saddle rock legal group, llc"' +
                                        ']' +
                                    '},' +
                                    '"coCounsel2": null,' +
                                    '"coCounsel3": null,' +
                                    '"coCounsel1FeePercentage": null,' +
                                    '"coCounsel2FeePercentage": null,' +
                                    '"6Space": null,' +
                                    '"coCounsel3FeePercentage": null,' +
                                    '"7Space": null,' +
                                    '"coCounsel": true,' +
                                    '"courtInfo": null,' +
                                    '"courtCase1": null,' +
                                    '"caption": null,' +
                                    '"dateFiled": null,' +
                                    '"localCounsel": null,' +
                                    '"localCounselFeePercentage": null,' +
                                    '"otherLitigationType": null,' +
                                    '"areYouLocalCouncil": false,' +
                                    '"staffAssignments": null,' +
                                    '"practiceAreaCaseStatus": null,' +
                                    '"litigationSubtype": "Personal Injury",' +
                                    '"coCounselReferralInformat": null,' +
                                    '"localCounselFeePercentage_1": null,' +
                                    '"caseReferredOut": false,' +
                                    '"referralFirmFeePercentage": null,' +
                                    '"referralFirm": null,' +
                                    '"referralFirm2": null,' +
                                    '"referralFirm3": null,' +
                                    '"referralToFirm": null,' +
                                    '"courtlegacy": null,' +
                                    '"activeDateFiled": null,' +
                                    '"trialDate": null,' +
                                    '"pTCDate": null,' +
                                    '"dateOf1stExposureToAsbest": null,' +
                                    '"dateOf1stDiagnosisOfAsbes": null,' +
                                    '"dateLastExposureToAsbestos": null,' +
                                    '"probateCourt": null,' +
                                    '"probateCourtDocket": null,' +
                                    '"activeInactive": null,' +
                                    '"bMLCTNO": null,' +
                                    '"complaintAmendedToAllegeNe": null,' +
                                    '"complaintAmendedForWrongful": null,' +
                                    '"complaintAmendedToAddPerso": null,' +
                                    '"trialGroup": null,' +
                                    '"complaintAmendedToAddUseP": null,' +
                                    '"complaintAmendedPlaintiffsD": null,' +
                                    '"complaintAmendedNewDisease": null,' +
                                    '"complaintAmendedWrongfulDea": null,' +
                                    '"complaintAmendedPersonalRep": null,' +
                                    '"statusConferenceHearings": null,' +
                                    '"spacer432": null,' +
                                    '"spacer21": null,' +
                                    '"spacer52": null,' +
                                    '"judge": null,' +
                                    '"matterID": null,' +
                                    '"archivedReason": null,' +
                                    '"archivedDate": null,' +
                                    '"prevailStatus": null,' +
                                    '"court1CurrentCourt": null,' +
                                    '"court2": null,' +
                                    '"caseNumber2": null,' +
                                    '"court3": null,' +
                                    '"caseNumber3": null,' +
                                    '"relationshipToDecedent": null,' +
                                    '"tolled": null,' +
                                    '"tollingStart": null,' +
                                    '"tollingEnd": null,' +
                                    '"otherArchiveReason": null,' +
                                    '"retainerFeePercentage": null,' +
                                    '"8Space": null,' +
                                    '"coCounsel4": null,' +
                                    '"coCounsel4Fee": null,' +
                                    '"referralFirm4": null,' +
                                    '"complaintUpload": null,' +
                                    '"retainer": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"aGLocalCounselAgreement": null,' +
                                    '"coCounselAgreement": null,' +
                                    '"localCounselAgreement": null,' +
                                    '"tollingAgreement": null,' +
                                    '"nonQualifyingInjury": null,' +
                                    '"doYouHaveLocalCounsel": null,' +
                                    '"clientBankruptcyInformation": null,' +
                                    '"pendingBankruptcy": null,' +
                                    '"priorBankruptcy": null,' +
                                    '"pendingBankruptcyChapter": null,' +
                                    '"pendingBankruptcyCourt": null,' +
                                    '"pendingBankruptcyCaseNo": null,' +
                                    '"clientBankruptcyAttorney": null,' +
                                    '"aGAppointedAsLitigationCo": null,' +
                                    '"aGAppointmentOrder": null,' +
                                    '"dateOfMostRecentPriorBank": null,' +
                                    '"chapterOfPriorBankruptcy": null,' +
                                    '"courtOfPriorBankruptcy": null,' +
                                    '"priorBankruptcyCaseNo": null,' +
                                    '"priorBankruptcyDischargeDat": null,' +
                                    '"bankruptcyTrustee": null,' +
                                    '"dateOfClaimedInjury": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"legacyAsbestosCaseInfo": null,' +
                                    '"injuredPersonPersonalInform": null,' +
                                    '"dateOfBirth": null,' +
                                    '"socialSecurityNumber": null,' +
                                    '"maritalStatus": null,' +
                                    '"children": null,' +
                                    '"highestEducation": null,' +
                                    '"highestDegreeObtained": null,' +
                                    '"nameOfInstitutionOfHighest": null,' +
                                    '"occupation": null,' +
                                    '"lastAnnualPayPriorToInjur": null,' +
                                    '"lastPlaceOfEmployment": null,' +
                                    '"space243": null,' +
                                    '"retainerFullyExecuted": null,' +
                                    '"decedentIfWrongfulDeathCa": null,' +
                                    '"coCounsel5": null,' +
                                    '"coCounsel5FeePercentage": null,' +
                                    '"referralFirm5": null,' +
                                    '"9Space": null,' +
                                    '"printToSmartMailroom": null,' +
                                    '"space32": null,' +
                                    '"space33": null,' +
                                    '"space53": null,' +
                                    '"space54": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"welcomeLetterSent": null,' +
                                    '"allClientDocumentsReceived": null,' +
                                    '"allRecordsOrdered": null,' +
                                    '"questionnaireStatus": null,' +
                                    '"questionnaire": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"authorizationsStatus": null,' +
                                    '"hIPAAAuthorization": null,' +
                                    '"otherAuthorizations": null,' +
                                    '"otherQuestionnaires": null,' +
                                    '"clientWelcomeEmail": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"duplicateProjectID": null,' +
                                    '"criteriaIssue": null,' +
                                    '"deathCertificateStatus": null,' +
                                    '"deathCertificate": null,' +
                                    '"lastWillStatus": null,' +
                                    '"estateOrderLetters": null,' +
                                    '"estateStatus": null,' +
                                    '"lastWill": null,' +
                                    '"clientNamedAsExecutor": null,' +
                                    '"clientAppointedPersonalRepr": null,' +
                                    '"causeOfDeath": null,' +
                                    '"clientMedicalRecords": null,' +
                                    '"space212": null,' +
                                    '"filedCivilCoverSheet": null,' +
                                    '"generateShortFormComplaint_1": null,' +
                                    '"draftCivilCoverSheet": null,' +
                                    '"milestonesEnabled": true,' +
                                    '"clientSRelationshipToInjur": "Work Spouse",' +
                                    '"injuredPerson": {' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19467459,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Client",' +
                                        '"lastName": "API",' +
                                        '"fullname": "Test Client API",' +
                                        '"isSingleName": false,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Test Client API",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [' +
                                            '{' +
                                                '"id": 17563433,' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563434,' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563435,' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"id": 6332234,' +
                                                '"address": "test@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 6332235,' +
                                                '"address": "test1@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11907151,' +
                                                '"line1": "123 Test Street",' +
                                                '"line2": null,' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"zip": null,' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": null,' +
                                                '"fullAddress": "123 Test Street, Test, PA"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"pictureKey": "Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"deathDate": "2024-04-29T00:00:00Z",' +
                                        '"isDeceased": true,' +
                                        '"uniqueID": "e7f5c781-bfa2-4c46-abf1-3bc2d9d0a46d",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": "123456789",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": true,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"client",' +
                                            '"api",' +
                                            '"test client api",' +
                                            '"test api"' +
                                        ']' +
                                    '},' +
                                    '"pOAOrGuardianshipPapers": null,' +
                                    '"presumptiveCondition": null,' +
                                    '"jAGPerfectionLetter": null,' +
                                    '"jAGSubstantiationLetter": null,' +
                                    '"dONClaim": null,' +
                                    '"perfectionLetter": null,' +
                                    '"substantiationLetter": null,' +
                                    '"parkerDenial": null,' +
                                    '"stateOfDeath": null,' +
                                    '"appointedJudge": null,' +
                                    '"coCounselProvidedMedicalRe": null,' +
                                    '"stateEstablished": null,' +
                                    '"countyEstablished": null,' +
                                    '"tier2": null,' +
                                    '"tier2_1": null,' +
                                    '"mDLRemandJurisdiction": null,' +
                                    '"caseWorks": null,' +
                                    '"dateSentToCaseWorks": null,' +
                                    '"defendantsHairRelaxers": null,' +
                                    '"caseDevelopment": null,' +
                                    '"vendor": null,' +
                                    '"dateSentToVendor": null,' +
                                    '"vendorStatus": null,' +
                                    '"statusComments": null,' +
                                    '"statusDate": null,' +
                                    '"communicationStatus": null,' +
                                    '"comments": null,' +
                                    '"commDate": null,' +
                                    '"proofOfIdentity": null,' +
                                    '"withdrawalTrackingNumber": null,' +
                                    '"dateAmended": null,' +
                                    '"amendedComplaint": null,' +
                                    '"space582": null,' +
                                    '"space583": null,' +
                                    '"alertsNotes": null,' +
                                    '"settlementProjections": null,' +
                                    '"injuryCategory": null,' +
                                    '"projectedSettlement": null,' +
                                    '"feeCap": null,' +
                                    '"aGFeeSum": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(200, 'OK', sessionRespStr, null);
        SaddleRockCalloutMock customContactResp = new SaddleRockCalloutMock(200, 'OK', customContactRespStr, null);
        SaddleRockCalloutMock projectResp = new SaddleRockCalloutMock(200, 'OK', projectRespStr, null);
        SaddleRockCalloutMock initialIntakeResp = new SaddleRockCalloutMock(200, 'OK', initialIntakeStr, null);
        SaddleRockCalloutMock masstortResp = new SaddleRockCalloutMock(200, 'OK', masstortStr, null);
        SaddleRockCalloutMock docrioAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', docrioFileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', docrioUploadFileRespStr, null);
        SaddleRockCalloutMock fvNewDocUploadResp = new SaddleRockCalloutMock(200, 'OK', fvNewDocUploadRespStr, null);
        SaddleRockCalloutMock fvUploadResp = new SaddleRockCalloutMock(200, 'OK', fvUploadStr, null);
        SaddleRockCalloutMock fvAddDocToProjResp = new SaddleRockCalloutMock(200, 'OK', fvAddDocToProjRespStr, null);
        SaddleRockCalloutMock caseSummaryResp = new SaddleRockCalloutMock(200, 'OK', caseSummaryStr, null);

        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);
        multiCalloutMock.addRequestMock(customContactUrl, customContactResp);
        multiCalloutMock.addRequestMock(projectUrl, projectResp);
        multiCalloutMock.addRequestMock(initialIntakeUrl, initialIntakeResp);
        multiCalloutMock.addRequestMock(masstortUrl, masstortResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, docrioAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(docrioUploadFileRespStr, uploadFileResp);
        multiCalloutMock.addRequestMock(fvNewDocUploadUrl, fvNewDocUploadResp);
        multiCalloutMock.addRequestMock(fvUploadUrl, fvUploadResp);
        multiCalloutMock.addRequestMock(fvAddDocToProjUrl, fvAddDocToProjResp);
        multiCalloutMock.addRequestMock(casesummaryUrl, caseSummaryResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_External_ID__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('4580812', intakes[0].Referral_Partner_API_External_ID__c);
    }

    @isTest 
    public static void test_OK_OtherMapping() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerIntake();
        testIntake.What_is_your_relation_to_this_individual__c = 'Test';
        testIntake.Preferred_Method_of_Contact__c = null;
        update testIntake;

        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        string customContactUrl = fvSetting.Base_URL__c + '/core/custom-contacts';
        string projectUrl = fvSetting.Base_URL__c + '/core/projects';
        string initialIntakeUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/initialintake';
        string masstortUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/masstortinfo';
        string casesummaryUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/casesummary';
        string fvNewDocUploadUrl = fvSetting.Base_URL__c + '/core/documents';
        string fvUploadUrl = 'https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5';
        string fvAddDocToProjUrl = fvSetting.Base_URL__c + '/core/projects/4580812/documents/311047751';

        string sessionRespStr = '{' +
                                    '"accessToken": "abc1234",' +
                                    '"refreshToken": "defghi",' +
                                    '"refreshTokenExpiry": "56719877617",' +
                                    '"refreshTokenTtl": "24 hours",' +
                                    '"userId": "12345",' +
                                    '"orgId": "5293"' +
                                '}';
        string customContactRespStr = '{' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Caller",' +
                                        '"lastName": "API",' +
                                        '"isSingleName": false,' +
                                        '"fullName": "Test Caller API",' +
                                        '"primaryEmail": "test@test.com",' +
                                        '"pictureUrl": "/images/Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"pictureKey": "Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"ssn": "123456789",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"personTypes": [],' +
                                        '"uniqueId": "6a820963-01b7-4bcc-a6ea-3cf2445ee94f",' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"caller",' +
                                            '"api",' +
                                            '"test caller api",' +
                                            '"test api"' +
                                        '],' +
                                        '"phones": [' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568205,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568206,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568207,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334495,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test@test.com",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334496,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test1@test.com",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"addressId": {' +
                                                    '"native": 11910464,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"line1": "123 Test Street",' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"fullAddress": "123 Test Street, Test, PA",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"hashtags": [],' +
                                        '"links": {' +
                                            '"self": "/contacts/19472883",' +
                                            '"projects": "/contacts/19472883/projects",' +
                                            '"phones": "/contacts/19472883/phones",' +
                                            '"emailAddresses": "/contacts/19472883/emailAddresses",' +
                                            '"addresses": "/contacts/19472883/addresses"' +
                                        '}' +
                                    '}';
        string projectRespStr = '{' +
                                    '"projectTypeCode": "MT3",' +
                                    '"rootDocFolderId": {' +
                                        '"native": 148064847,' +
                                        '"partner": null' +
                                    '},' +
                                    '"phaseName": "Migration for Review",' +
                                    '"clientName": "Test Client API",' +
                                    '"clientPictureURL": "/image-error.png",' +
                                    '"firstPrimaryName": "Filevine Integration",' +
                                    '"firstPrimaryUsername": "filevine128",' +
                                    '"isArchived": false,' +
                                    '"lastActivity": "2024-05-01T17:06:08.4192757Z",' +
                                    '"uniqueKey": "TestClientAPIZ4580812",' +
                                    '"projectOrClientName": "Test Client API",' +
                                    '"hashtags": [],' +
                                    '"projectEmailAddress": "TestClientAPIZ4580812@ashcraftandgerel.filevineapp.com",' +
                                    '"createdDate": "2024-05-01T17:06:08.4156183Z",' +
                                    '"projectUrl": "https://ashcraftandgerel.filevineapp.com/#/project/4580812",' +
                                    '"projectId": {' +
                                        '"native": 4580812,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectTypeId": {' +
                                        '"native": 4675,' +
                                        '"partner": null' +
                                    '},' +
                                    '"clientId": {' +
                                        '"native": 19467459,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectName": "Test Client API",' +
                                    '"phaseId": {' +
                                        '"native": 41897,' +
                                        '"partner": null' +
                                    '},' +
                                    '"links": {' +
                                        '"self": "/projects/4580812",' +
                                        '"projectType": "/projecttypes/4675",' +
                                        '"rootFolder": "/folders/148064847",' +
                                        '"client": "/contacts/19467459",' +
                                        '"contacts": "/projects/4580812/contacts"' +
                                    '}' +
                                '}';
        string initialIntakeStr = '{' +
                                        '"dateofintake": null,' +
                                        '"personperformingintakeLegacy": null,' +
                                        '"referralsource": null,' +
                                        '"referredfrom1": null,' +
                                        '"referredfrom1feepercentage": null,' +
                                        '"originatingattorney": null,' +
                                        '"casedescription": "Testing litify_pm__Description__c",' +
                                        '"leadstatus": null,' +
                                        '"rejectionreason": null,' +
                                        '"additionaldescriptionforrejection": null,' +
                                        '"casereferredto": null,' +
                                        '"referralfee": null,' +
                                        '"referralcontracts": null,' +
                                        '"datecontractsent": null,' +
                                        '"datecontractsigned": null,' +
                                        '"casetype": null,' +
                                        '"priorclient": null,' +
                                        '"othercasetype": null,' +
                                        '"referringfrom2": null,' +
                                        '"referralfrom2feepercenta": null,' +
                                        '"referredfrom3": null,' +
                                        '"referredfrom3feepercentage": null,' +
                                        '"otherrelevantreferralinfo": null,' +
                                        '"attorneyreviewwc3rdparty": null,' +
                                        '"additionalreferralsources": null,' +
                                        '"referralfrom4": null,' +
                                        '"referralsource5space": null,' +
                                        '"referredfrom5": null,' +
                                        '"isthecallertheinjuredpart": null,' +
                                        '"callername": null,' +
                                        '"callerrelationshiptoinjured": null,' +
                                        '"callerrelationshipother": null,' +
                                        '"3rdpartyattorneyreviewnote": null,' +
                                        '"initialIntakeInfo": null,' +
                                        '"referralMarketingInfo": null,' +
                                        '"litigationSubtype": null,' +
                                        '"personPerformingIntake": null,' +
                                        '"leadSentForReplacement": null,' +
                                        '"marketingSourceAgreedToRep": null,' +
                                        '"diagnosisReceived": null,' +
                                        '"diagnosisDate": null,' +
                                        '"firstSurgeryDate": null,' +
                                        '"stateWhereDiagnosed": null,' +
                                        '"discoveryDate": null,' +
                                        '"surgeryType": null,' +
                                        '"nameOfProductsUsed": null,' +
                                        '"dateOfFirstUse": null,' +
                                        '"dateOfLastUse": null,' +
                                        '"marketingSourceID": null,' +
                                        '"whatCityWereYouBorn": null,' +
                                        '"stateBorn": null,' +
                                        '"relationship": "The caller is the formal next of kin (when through all levels and they are the next in line)",' +
                                        '"personalInformation": null,' +
                                        '"legalRelation": null,' +
                                        '"callSelf": null,' +
                                        '"callerSELF": null,' +
                                        '"callerOTHER": null,' +
                                        '"causeofdeath": null,' +
                                        '"cityBorn": null,' +
                                        '"stateBornOther": null,' +
                                        '"whyAreYouThePointOfConta": null,' +
                                        '"coCounselID": "a0CVF00000TQOxG2AX",' +
                                        '"healthcareProvider": null,' +
                                        '"treatingHealthcareProvider": null,' +
                                        '"outreachLetterSent": null,' +
                                        '"hasAnEstateBeenOpened": true,' +
                                        '"isTheEstateCurrentlyOpen": true,' +
                                        '"doYouHaveACopyOfTheDeat": true,' +
                                        '"allLocationsLivedWorkedOr": "Knox Trailer Park;Hadnot Point",' +
                                        '"haveYouEverSmokedCigarette": "Smoked less than 1 year prior to throat related cancer DX",' +
                                        '"doYouCurrentlySmokeCigaret": true,' +
                                        '"haveYouEverSmokedCigarette_1": true,' +
                                        '"forHowLongDidYouSmoke": "10 years",' +
                                        '"howManyCigarettesPerDay": "4",' +
                                        '"whenDidYouBeginSmoking": "2000",' +
                                        '"whenDidYouStopSmoking": "2010",' +
                                        '"doYouHaveAnyDocumentsRela": "Yes",' +
                                        '"ifCivilianWhatWasTheNatu": "Testing Nature_Of_Presence_At_Camp_Lejeune__c",' +
                                        '"militaryDetails": "Testing Branch_discharge_status_and_rank__c",' +
                                        '"fullNameOfMilitaryService": "Testing Military_Stationed_Family_Mem_Full_Name__c",' +
                                        '"branchOfService": "Testing Branch_of_Service__c",' +
                                        '"dischargeStatus": "Honorable",' +
                                        '"rank": "Captain",' +
                                        '"tier1Diagnosis": "Kidney disease (End stage renal (ESRD), Renal Toxicity, Chronic Kidney Disease, etc.)",' +
                                        '"tier2Diagnosis": "Esophageal cancer",' +
                                        '"tier3Diagnosis": "None of the above",' +
                                        '"tier4Diagnosis": null,' +
                                        '"diagnosisDates": null,' +
                                        '"treatingDoctors": "Testing List_Dx_treating_doctor_names_spec__c",' +
                                        '"treatingFacilities": "Testing Treatment_Facilities_Name_and_Addresses__c",' +
                                        '"militaryPersonnelSSN": "123589852",' +
                                        '"militaryPersonnelDOB": "1980-12-24T00:00:00Z",' +
                                        '"militaryPersonnelPlaceOfBi": "CA",' +
                                        '"serviceNumber": "123456",' +
                                        '"militaryPersonnelAliveOrDe": "Alive",' +
                                        '"diagnosisInformation": null,' +
                                        '"diagnosisdriver": "Neurological effect and/or Neurobehavioral Performance Deficit"' +
                                    '}';
        string masstortStr = '{' +
                                    '"masstortcasetype": "Camp Lejeune Q Review",' +
                                    '"didtheuserhavetype1diabe": null,' +
                                    '"didyouhavetohavesurgeryt": null,' +
                                    '"didyouundergochemotherapy": null,' +
                                    '"dateofdeath": null,' +
                                    '"ageattimeofdeath": null,' +
                                    '"inwhatstatedidshepassawa": null,' +
                                    '"placeofresidenceattimeof": null,' +
                                    '"doyouhaveacopyofthedece": null,' +
                                    '"whatisthecauseofdeathlis": null,' +
                                    '"didshehaveawill": null,' +
                                    '"haveyoubeenappointedbyac": null,' +
                                    '"wasthedecentdiagnosedwith": null,' +
                                    '"atwhatmedicalfacilitywass": null,' +
                                    '"didshehavetohavesurgeryt": null,' +
                                    '"didshehavetoundergochemot": null,' +
                                    '"atwhatmedicalfacilitydids": null,' +
                                    '"wherewasshelivingattheti": null,' +
                                    '"masstorts": null,' +
                                    '"dateOfSurgery": null,' +
                                    '"jJBP": null,' +
                                    '"dateOfFirstRecurrence": null,' +
                                    '"histologicType": null,' +
                                    '"usageDates1": null,' +
                                    '"treatments": null,' +
                                    '"stage": null,' +
                                    '"usageDates2": null,' +
                                    '"histologicGrade": null,' +
                                    '"showerToShower": null,' +
                                    '"primarySiteS": null,' +
                                    '"ageAtDiagnosis": null,' +
                                    '"otherProductsUsed": null,' +
                                    '"genericTestingResults": null,' +
                                    '"familyHistory": null,' +
                                    '"riskFactors": null,' +
                                    '"protectiveFactors": null,' +
                                    '"additionalNotesOnDiagnosis_1": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"dateDiagnosisConfirmed": null,' +
                                    '"deathCertificateUpload": null,' +
                                    '"willUpload": null,' +
                                    '"otherLitigationType": null,' +
                                    '"litigationSubType": null,' +
                                    '"diagnosisConfirmed": null,' +
                                    '"legacyUsageState": null,' +
                                    '"paragardPlacementDate": null,' +
                                    '"paragardRemovalDate": null,' +
                                    '"placementFacility": null,' +
                                    '"removalFacility": null,' +
                                    '"didParagardArmSBreakBefo": null,' +
                                    '"didClientHaveSurgeryToRem": null,' +
                                    '"dateOfParagardSurgery": null,' +
                                    '"surgeryFacility": null,' +
                                    '"hasSurgeryBeenRecommended": null,' +
                                    '"removedParagardStatus": null,' +
                                    '"directExposure": null,' +
                                    '"indirectExposure": null,' +
                                    '"purchasesParaquatProducts": null,' +
                                    '"appliedParaquatProducts": null,' +
                                    '"certifiedApplicator": null,' +
                                    '"licensingAuthority": null,' +
                                    '"yearOfLicense": null,' +
                                    '"licenseNumber": null,' +
                                    '"yearOfFirstExposure": null,' +
                                    '"yearOfLastExposure": null,' +
                                    '"frequencyOfExposure": null,' +
                                    '"exposureStates": null,' +
                                    '"whereEmployed": null,' +
                                    '"otherPlace": null,' +
                                    '"placeOfExposure": null,' +
                                    '"distanceFromResidenceToSpr": null,' +
                                    '"methodOfDirectExposure": null,' +
                                    '"otherMethod": null,' +
                                    '"exposureDescription": null,' +
                                    '"paraquatProducts": null,' +
                                    '"otherParaquatProduct": null,' +
                                    '"cropsAppliedOn": null,' +
                                    '"documentsConfirmingPurchase": null,' +
                                    '"exposureToOtherChemical": null,' +
                                    '"otherChemicals": null,' +
                                    '"yearOfFirstExposureToOthe": null,' +
                                    '"yearOfLastExposureToOther": null,' +
                                    '"frequencyOfExposureToOther": null,' +
                                    '"descriptionOfOtherExposure": null,' +
                                    '"parkinsonSDiagnosisConfirme": null,' +
                                    '"dateOfParkinsonSDiagnosis": null,' +
                                    '"parkinsonSDiagnosingProvide": null,' +
                                    '"closeFamilyHistoryOfParkin": null,' +
                                    '"listOfFamilyMembersWithPa": null,' +
                                    '"probateCourtAppointment": null,' +
                                    '"anyPhotosOfParagard": null,' +
                                    '"confirmedGynecomastiaDiagnos": null,' +
                                    '"dateOfGynecomastiaDiagnosis": null,' +
                                    '"gynecomastiaSurgery": null,' +
                                    '"dateOfGynecomastiaSurgery": null,' +
                                    '"descriptionOfSurgery": null,' +
                                    '"gynecomastiaSurgeryFacility": null,' +
                                    '"ifNoGynecomastiaSurgeryHa": null,' +
                                    '"ifNoPlannedSurgeryWhyNot": null,' +
                                    '"anyCurrentTreatmentForGyne": null,' +
                                    '"dateOfLastTreatmentForGyn": null,' +
                                    '"anyPicturesOfGynecomastia": null,' +
                                    '"otherSignificantMedicalCond": null,' +
                                    '"gynecomastiaDiagnosisInforma": null,' +
                                    '"risperdalUsage": null,' +
                                    '"confirmedRisperdalRisperdo": null,' +
                                    '"prescribedDrug": null,' +
                                    '"otherDrug": null,' +
                                    '"datesOfDrugUsage": null,' +
                                    '"stateSOfUsage": null,' +
                                    '"drugDosage": null,' +
                                    '"reasonForDrugPrescription": null,' +
                                    '"usagePreLabel": null,' +
                                    '"usagePostLabel": null,' +
                                    '"minorUsePreLabel": null,' +
                                    '"minorUsePostLabel": null,' +
                                    '"adultUseOnly": null,' +
                                    '"settlementInfoCosts": null,' +
                                    '"medicalBillsAttributableTo": null,' +
                                    '"caseCosts": null,' +
                                    '"deathCertificate": null,' +
                                    '"will": null,' +
                                    '"probateCourtDocuments": null,' +
                                    '"parkinsonSDiagnosisRecords": null,' +
                                    '"paraquatPurchaseOrExposure": null,' +
                                    '"gynecomastiaDiagnosisRecords": null,' +
                                    '"gynecomastiaSurgeryRecords": null,' +
                                    '"gynecomastiaPictures": null,' +
                                    '"prescriptionRecords": null,' +
                                    '"medicalBills": null,' +
                                    '"paragardPlacementRecords": null,' +
                                    '"paragardRemovalRecords": null,' +
                                    '"paragardSurgeryRecords": null,' +
                                    '"paragardPhotos": null,' +
                                    '"medtronicMinimedPumpInjury": null,' +
                                    '"minimedPumpInjuryConfirmed": null,' +
                                    '"minimedPumpInjury": null,' +
                                    '"dateOfMinimedPumpInjury": null,' +
                                    '"ageAtMinimedPumpInjury": null,' +
                                    '"stateOfResidenceAtTimeOf": null,' +
                                    '"descriptionOfPumpInjury": null,' +
                                    '"treatmentForPumpInjury": null,' +
                                    '"treatmentDuration": null,' +
                                    '"treatmentRecords": null,' +
                                    '"medicalExpensesForPumpInju": null,' +
                                    '"descriptionOfTreatment": null,' +
                                    '"minimedPUmpInformation": null,' +
                                    '"defectiveMinimedPumpModel": null,' +
                                    '"serialNumber": null,' +
                                    '"retainerRingDescription": null,' +
                                    '"retainerRingPhotos": null,' +
                                    '"locationOfPump": null,' +
                                    '"pumpStartDate": null,' +
                                    '"statesUsedIn": null,' +
                                    '"pumpEndDate": null,' +
                                    '"notesOnDefectivePump": null,' +
                                    '"otherPumpsUsed": null,' +
                                    '"diabetesInformation": null,' +
                                    '"type1DiabetesConfirmed": null,' +
                                    '"dateOfDiabetesDiagnosis": null,' +
                                    '"diabetesStatus": null,' +
                                    '"diabetesManagementBeforeDef": null,' +
                                    '"currentDiabetesManagement": null,' +
                                    '"miniMedSeries600Confirmed": null,' +
                                    '"retainerRingColor": null,' +
                                    '"otherInjury": null,' +
                                    '"daysHospitalized": null,' +
                                    '"treatmentFacility": null,' +
                                    '"recurrence": null,' +
                                    '"additionalPrescriptionRecord": null,' +
                                    '"ageAtParkinsonSDiagnosis": null,' +
                                    '"additionalParkisonSDiagnosi": null,' +
                                    '"diagnosisRecordsOpPathRep": null,' +
                                    '"usageAffidavitOrDeclaration": null,' +
                                    '"geneticTestingRecords": null,' +
                                    '"space3392": null,' +
                                    '"space2402": null,' +
                                    '"space2412": null,' +
                                    '"space2422": null,' +
                                    '"space2442": null,' +
                                    '"space2452": null,' +
                                    '"space1882": null,' +
                                    '"space1902": null,' +
                                    '"space1942": null,' +
                                    '"qualifyingCancer": null,' +
                                    '"space2031": null,' +
                                    '"space2032": null,' +
                                    '"campLejeune": null,' +
                                    '"confirmedExposureToWaterAt": null,' +
                                    '"startDateOfExposure": "1990-12-12T00:00:00Z",' +
                                    '"endDateOfExposure": "1990-01-12T00:00:00Z",' +
                                    '"lengthOfExposure": null,' +
                                    '"exposureLocationS": null,' +
                                    '"methodOfExposure": null,' +
                                    '"statusWhenStationedAtCamp": "Military Veteran",' +
                                    '"militaryService": null,' +
                                    '"militaryServicemember": null,' +
                                    '"branchOfMilitary": null,' +
                                    '"lastRank": null,' +
                                    '"lastPayGrade": null,' +
                                    '"datesOfService": null,' +
                                    '"typeOfSeparation": null,' +
                                    '"dDForm214Received": null,' +
                                    '"dDForm214": null,' +
                                    '"documentationOfExposure": null,' +
                                    '"injuryInformation": null,' +
                                    '"campLejeuneInjuryConfirmed": null,' +
                                    '"diagnosisProvider": null,' +
                                    '"treatingProviderS": null,' +
                                    '"diagnosisRecords": null,' +
                                    '"treatingRecords": null,' +
                                    '"currentlyTreating": null,' +
                                    '"currentTreatingProviderS": null,' +
                                    '"nonVAMedicalInsurance": null,' +
                                    '"insuranceCarrier": null,' +
                                    '"policyNumber": null,' +
                                    '"groupNumber": null,' +
                                    '"insuranceInformation": null,' +
                                    '"medicareCoverage": null,' +
                                    '"medicarePolicyNumber": null,' +
                                    '"medicaidCoverage": null,' +
                                    '"medicaidPolicyNumber": null,' +
                                    '"otherMedicalConditionsForW": null,' +
                                    '"descriptionOfOtherVABenefi": null,' +
                                    '"priorCampLajeuneClaimInfor": null,' +
                                    '"filedAPriorForm95Claim": null,' +
                                    '"denialLetter": null,' +
                                    '"adjudicatedReceivedDenial": null,' +
                                    '"ageAtTimeOfExposure": null,' +
                                    '"space3172": null,' +
                                    '"space3162": null,' +
                                    '"deathInformation": null,' +
                                    '"welcomePacketSent": null,' +
                                    '"allRecordsRequested": null,' +
                                    '"oMPF": null,' +
                                    '"officialMilitaryPersonnelFi_1": null,' +
                                    '"officialMilitaryPersonnelFi": null,' +
                                    '"cLWelcomeEmailAGOnly": null,' +
                                    '"cLWelcomeEmailSinkReferra": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"talcumPowderInformation": null,' +
                                    '"additionalDiagnosisRecords": null,' +
                                    '"tubalLigation": null,' +
                                    '"dateOfTubalLigation": null,' +
                                    '"confirmedInjury": null,' +
                                    '"otherCancerDiseaseCondition": null,' +
                                    '"claimedInjury": null,' +
                                    '"otherClaimedInjury": null,' +
                                    '"clientDocumentsReceived": null,' +
                                    '"documentsReceived": null,' +
                                    '"missingDocuments": null,' +
                                    '"additionalStatusWhenStation": null,' +
                                    '"intakeSummaryOfInjuries": null,' +
                                    '"space3391": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"space3412": null,' +
                                    '"typeOfTreatment": null,' +
                                    '"clientDoesNotRecallTreatme": null,' +
                                    '"currentTreatingRecords": null,' +
                                    '"smokingStatus": null,' +
                                    '"yearsSmoked": null,' +
                                    '"averageCigarettesPerDay": null,' +
                                    '"didYouOrAFamilyMemberSer": null,' +
                                    '"exposedIndividualSName": null,' +
                                    '"otherExposureLocation": null,' +
                                    '"nameOfEmployerIfNonMilit": null,' +
                                    '"additionalStatusInformation": null,' +
                                    '"dateOfDiagnosis": null,' +
                                    '"areYouCurrentlyReceivingVA": null,' +
                                    '"doYouHaveAnyOfTheFollowi": [' +
                                        '"Official Military Personnel File",' +
                                        '"Medical Records"' +
                                    '],' +
                                    '"currentOrMostRecentPrimary": null,' +
                                    '"haveYouEverBeenTreatedFor": null,' +
                                    '"identifyTheMilitaryBaseAnd": null,' +
                                    '"cLWelcomeEmailTwoCoCouns": null,' +
                                    '"sponsorName": null,' +
                                    '"hadnotPointIndustrialArea": null,' +
                                    '"medicalConditionsInvestigati": null,' +
                                    '"questionnaireFollowUpEmail": null,' +
                                    '"questionnaireFollowUpEmail_1": null,' +
                                    '"additionalInjuryDates": null,' +
                                    '"dateSubmitted": null,' +
                                    '"serviceRequestNumber": null,' +
                                    '"recordRequest": null,' +
                                    '"otherMilitaryFiles": null,' +
                                    '"typeOfEmploymentWhileAtCa": null,' +
                                    '"dateEnteredService": null,' +
                                    '"serviceEndDate": null,' +
                                    '"trtStrDate": null,' +
                                    '"injfamhis": null,' +
                                    '"ompfExp": null,' +
                                    '"ompfExpEnd": null,' +
                                    '"totalDaysAtCampLejeune": null,' +
                                    '"diagnosisDate": null,' +
                                    '"daysAtCL": null,' +
                                    '"onsetDate": null,' +
                                    '"medicalReviewNotes": null,' +
                                    '"oMPFDeficiency": null,' +
                                    '"letterMailDate": null,' +
                                    '"deficiencyLetter": null,' +
                                    '"electiveoption": null,' +
                                    '"clientQualifiesForEO": null,' +
                                    '"electiveOptionNotice": null,' +
                                    '"mailDate": null,' +
                                    '"relationshipToSponsor": null,' +
                                    '"otherRelationToSponsor": null,' +
                                    '"otherResidenceInformation": null,' +
                                    '"clientWishesToPursueEO": null,' +
                                    '"oMPFNotes": null,' +
                                    '"monthsAtCL": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        string docrioSignedUrlRespStr = '{' +
                                            '"Records": [' +
                                                '{' +
                                                    '"Id": "' + testFile.Id + '",' +
                                                    '"SignedUrl": "https://test.pdf"' +
                                                '}' +
                                            ']' +
                                        '}';
        string docrioFileContentRespStr = 'a'.repeat(100);
        string docrioUploadFileRespStr = '{' +
                                        '"message": "Document Uploaded"' +
                                    '}';
        
        string fvNewDocUploadRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify1234"' +
                                            '},' +
                                            '"contentType": "application/pdf",' +
                                            '"url": "https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5",' +
                                            '"links": {}' +
                                        '}';
        string fvUploadStr = '';
        string fvAddDocToProjRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify123"' +
                                            '},' +
                                            '"filename": "Test.pdf",' +
                                            '"size": 0,' +
                                            '"folderId": {' +
                                                '"native": 148064847,' +
                                                '"partner": null' +
                                            '},' +
                                            '"projectId": {' +
                                                '"native": 4580812,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploaderId": {' +
                                                '"native": 2941,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploadDate": "2024-05-01T18:15:56.9337196Z",' +
                                            '"hashtags": [],' +
                                            '"links": {' +
                                                '"project": "/projects/4580812",' +
                                                '"self": "/documents/311047751",' +
                                                '"folder": "/folders/148064847",' +
                                                '"hashtags": "/documents/311047751/hashtags"' +
                                            '}' +
                                        '}';
        string caseSummaryStr = '{' +
                                    '"tier": null,' +
                                    '"assignedattorney": null,' +
                                    '"assignedparalegal": null,' +
                                    '"masstortcoordinator": null,' +
                                    '"datecontacted": null,' +
                                    '"practicearea": "Test Case Type",' +
                                    '"statuteoflimitation": null,' +
                                    '"personalinjurysol": null,' +
                                    '"wrongfuldeathsol": null,' +
                                    '"solnotes": null,' +
                                    '"coCounsel1": {' +
                                        '"personId": {' +
                                            '"native": 19043693,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19043693,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Saddle Rock Legal Group, LLC",' +
                                        '"middleName": null,' +
                                        '"lastName": null,' +
                                        '"fullname": "Saddle Rock Legal Group, LLC",' +
                                        '"isSingleName": true,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Saddle Rock Legal Group, LLC",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [],' +
                                        '"emails": [],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11628545,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington DC",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington DC, DC 20005"' +
                                            '},' +
                                            '{' +
                                                '"id": 11628546,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington, DC 20005"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"pictureKey": "Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"birthDate": null,' +
                                        '"deathDate": null,' +
                                        '"isDeceased": null,' +
                                        '"uniqueID": "589380d7-2c7f-44bd-9883-77b217b98e2e",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": null,' +
                                        '"notes": null,' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": null,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"saddle",' +
                                            '"rock",' +
                                            '"legal",' +
                                            '"group,",' +
                                            '"llc",' +
                                            '"saddle rock legal group, llc"' +
                                        ']' +
                                    '},' +
                                    '"coCounsel2": null,' +
                                    '"coCounsel3": null,' +
                                    '"coCounsel1FeePercentage": null,' +
                                    '"coCounsel2FeePercentage": null,' +
                                    '"6Space": null,' +
                                    '"coCounsel3FeePercentage": null,' +
                                    '"7Space": null,' +
                                    '"coCounsel": true,' +
                                    '"courtInfo": null,' +
                                    '"courtCase1": null,' +
                                    '"caption": null,' +
                                    '"dateFiled": null,' +
                                    '"localCounsel": null,' +
                                    '"localCounselFeePercentage": null,' +
                                    '"otherLitigationType": null,' +
                                    '"areYouLocalCouncil": false,' +
                                    '"staffAssignments": null,' +
                                    '"practiceAreaCaseStatus": null,' +
                                    '"litigationSubtype": "Personal Injury",' +
                                    '"coCounselReferralInformat": null,' +
                                    '"localCounselFeePercentage_1": null,' +
                                    '"caseReferredOut": false,' +
                                    '"referralFirmFeePercentage": null,' +
                                    '"referralFirm": null,' +
                                    '"referralFirm2": null,' +
                                    '"referralFirm3": null,' +
                                    '"referralToFirm": null,' +
                                    '"courtlegacy": null,' +
                                    '"activeDateFiled": null,' +
                                    '"trialDate": null,' +
                                    '"pTCDate": null,' +
                                    '"dateOf1stExposureToAsbest": null,' +
                                    '"dateOf1stDiagnosisOfAsbes": null,' +
                                    '"dateLastExposureToAsbestos": null,' +
                                    '"probateCourt": null,' +
                                    '"probateCourtDocket": null,' +
                                    '"activeInactive": null,' +
                                    '"bMLCTNO": null,' +
                                    '"complaintAmendedToAllegeNe": null,' +
                                    '"complaintAmendedForWrongful": null,' +
                                    '"complaintAmendedToAddPerso": null,' +
                                    '"trialGroup": null,' +
                                    '"complaintAmendedToAddUseP": null,' +
                                    '"complaintAmendedPlaintiffsD": null,' +
                                    '"complaintAmendedNewDisease": null,' +
                                    '"complaintAmendedWrongfulDea": null,' +
                                    '"complaintAmendedPersonalRep": null,' +
                                    '"statusConferenceHearings": null,' +
                                    '"spacer432": null,' +
                                    '"spacer21": null,' +
                                    '"spacer52": null,' +
                                    '"judge": null,' +
                                    '"matterID": null,' +
                                    '"archivedReason": null,' +
                                    '"archivedDate": null,' +
                                    '"prevailStatus": null,' +
                                    '"court1CurrentCourt": null,' +
                                    '"court2": null,' +
                                    '"caseNumber2": null,' +
                                    '"court3": null,' +
                                    '"caseNumber3": null,' +
                                    '"relationshipToDecedent": null,' +
                                    '"tolled": null,' +
                                    '"tollingStart": null,' +
                                    '"tollingEnd": null,' +
                                    '"otherArchiveReason": null,' +
                                    '"retainerFeePercentage": null,' +
                                    '"8Space": null,' +
                                    '"coCounsel4": null,' +
                                    '"coCounsel4Fee": null,' +
                                    '"referralFirm4": null,' +
                                    '"complaintUpload": null,' +
                                    '"retainer": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"aGLocalCounselAgreement": null,' +
                                    '"coCounselAgreement": null,' +
                                    '"localCounselAgreement": null,' +
                                    '"tollingAgreement": null,' +
                                    '"nonQualifyingInjury": null,' +
                                    '"doYouHaveLocalCounsel": null,' +
                                    '"clientBankruptcyInformation": null,' +
                                    '"pendingBankruptcy": null,' +
                                    '"priorBankruptcy": null,' +
                                    '"pendingBankruptcyChapter": null,' +
                                    '"pendingBankruptcyCourt": null,' +
                                    '"pendingBankruptcyCaseNo": null,' +
                                    '"clientBankruptcyAttorney": null,' +
                                    '"aGAppointedAsLitigationCo": null,' +
                                    '"aGAppointmentOrder": null,' +
                                    '"dateOfMostRecentPriorBank": null,' +
                                    '"chapterOfPriorBankruptcy": null,' +
                                    '"courtOfPriorBankruptcy": null,' +
                                    '"priorBankruptcyCaseNo": null,' +
                                    '"priorBankruptcyDischargeDat": null,' +
                                    '"bankruptcyTrustee": null,' +
                                    '"dateOfClaimedInjury": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"legacyAsbestosCaseInfo": null,' +
                                    '"injuredPersonPersonalInform": null,' +
                                    '"dateOfBirth": null,' +
                                    '"socialSecurityNumber": null,' +
                                    '"maritalStatus": null,' +
                                    '"children": null,' +
                                    '"highestEducation": null,' +
                                    '"highestDegreeObtained": null,' +
                                    '"nameOfInstitutionOfHighest": null,' +
                                    '"occupation": null,' +
                                    '"lastAnnualPayPriorToInjur": null,' +
                                    '"lastPlaceOfEmployment": null,' +
                                    '"space243": null,' +
                                    '"retainerFullyExecuted": null,' +
                                    '"decedentIfWrongfulDeathCa": null,' +
                                    '"coCounsel5": null,' +
                                    '"coCounsel5FeePercentage": null,' +
                                    '"referralFirm5": null,' +
                                    '"9Space": null,' +
                                    '"printToSmartMailroom": null,' +
                                    '"space32": null,' +
                                    '"space33": null,' +
                                    '"space53": null,' +
                                    '"space54": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"welcomeLetterSent": null,' +
                                    '"allClientDocumentsReceived": null,' +
                                    '"allRecordsOrdered": null,' +
                                    '"questionnaireStatus": null,' +
                                    '"questionnaire": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"authorizationsStatus": null,' +
                                    '"hIPAAAuthorization": null,' +
                                    '"otherAuthorizations": null,' +
                                    '"otherQuestionnaires": null,' +
                                    '"clientWelcomeEmail": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"duplicateProjectID": null,' +
                                    '"criteriaIssue": null,' +
                                    '"deathCertificateStatus": null,' +
                                    '"deathCertificate": null,' +
                                    '"lastWillStatus": null,' +
                                    '"estateOrderLetters": null,' +
                                    '"estateStatus": null,' +
                                    '"lastWill": null,' +
                                    '"clientNamedAsExecutor": null,' +
                                    '"clientAppointedPersonalRepr": null,' +
                                    '"causeOfDeath": null,' +
                                    '"clientMedicalRecords": null,' +
                                    '"space212": null,' +
                                    '"filedCivilCoverSheet": null,' +
                                    '"generateShortFormComplaint_1": null,' +
                                    '"draftCivilCoverSheet": null,' +
                                    '"milestonesEnabled": true,' +
                                    '"clientSRelationshipToInjur": "Work Spouse",' +
                                    '"injuredPerson": {' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19467459,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Client",' +
                                        '"lastName": "API",' +
                                        '"fullname": "Test Client API",' +
                                        '"isSingleName": false,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Test Client API",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [' +
                                            '{' +
                                                '"id": 17563433,' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563434,' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563435,' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"id": 6332234,' +
                                                '"address": "test@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 6332235,' +
                                                '"address": "test1@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11907151,' +
                                                '"line1": "123 Test Street",' +
                                                '"line2": null,' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"zip": null,' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": null,' +
                                                '"fullAddress": "123 Test Street, Test, PA"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"pictureKey": "Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"deathDate": "2024-04-29T00:00:00Z",' +
                                        '"isDeceased": true,' +
                                        '"uniqueID": "e7f5c781-bfa2-4c46-abf1-3bc2d9d0a46d",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": "123456789",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": true,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"client",' +
                                            '"api",' +
                                            '"test client api",' +
                                            '"test api"' +
                                        ']' +
                                    '},' +
                                    '"pOAOrGuardianshipPapers": null,' +
                                    '"presumptiveCondition": null,' +
                                    '"jAGPerfectionLetter": null,' +
                                    '"jAGSubstantiationLetter": null,' +
                                    '"dONClaim": null,' +
                                    '"perfectionLetter": null,' +
                                    '"substantiationLetter": null,' +
                                    '"parkerDenial": null,' +
                                    '"stateOfDeath": null,' +
                                    '"appointedJudge": null,' +
                                    '"coCounselProvidedMedicalRe": null,' +
                                    '"stateEstablished": null,' +
                                    '"countyEstablished": null,' +
                                    '"tier2": null,' +
                                    '"tier2_1": null,' +
                                    '"mDLRemandJurisdiction": null,' +
                                    '"caseWorks": null,' +
                                    '"dateSentToCaseWorks": null,' +
                                    '"defendantsHairRelaxers": null,' +
                                    '"caseDevelopment": null,' +
                                    '"vendor": null,' +
                                    '"dateSentToVendor": null,' +
                                    '"vendorStatus": null,' +
                                    '"statusComments": null,' +
                                    '"statusDate": null,' +
                                    '"communicationStatus": null,' +
                                    '"comments": null,' +
                                    '"commDate": null,' +
                                    '"proofOfIdentity": null,' +
                                    '"withdrawalTrackingNumber": null,' +
                                    '"dateAmended": null,' +
                                    '"amendedComplaint": null,' +
                                    '"space582": null,' +
                                    '"space583": null,' +
                                    '"alertsNotes": null,' +
                                    '"settlementProjections": null,' +
                                    '"injuryCategory": null,' +
                                    '"projectedSettlement": null,' +
                                    '"feeCap": null,' +
                                    '"aGFeeSum": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(200, 'OK', sessionRespStr, null);
        SaddleRockCalloutMock customContactResp = new SaddleRockCalloutMock(200, 'OK', customContactRespStr, null);
        SaddleRockCalloutMock projectResp = new SaddleRockCalloutMock(200, 'OK', projectRespStr, null);
        SaddleRockCalloutMock initialIntakeResp = new SaddleRockCalloutMock(200, 'OK', initialIntakeStr, null);
        SaddleRockCalloutMock masstortResp = new SaddleRockCalloutMock(200, 'OK', masstortStr, null);
        SaddleRockCalloutMock docrioAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', docrioFileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', docrioUploadFileRespStr, null);
        SaddleRockCalloutMock fvNewDocUploadResp = new SaddleRockCalloutMock(200, 'OK', fvNewDocUploadRespStr, null);
        SaddleRockCalloutMock fvUploadResp = new SaddleRockCalloutMock(200, 'OK', fvUploadStr, null);
        SaddleRockCalloutMock fvAddDocToProjResp = new SaddleRockCalloutMock(200, 'OK', fvAddDocToProjRespStr, null);
        SaddleRockCalloutMock caseSummaryResp = new SaddleRockCalloutMock(200, 'OK', caseSummaryStr, null);

        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);
        multiCalloutMock.addRequestMock(customContactUrl, customContactResp);
        multiCalloutMock.addRequestMock(projectUrl, projectResp);
        multiCalloutMock.addRequestMock(initialIntakeUrl, initialIntakeResp);
        multiCalloutMock.addRequestMock(masstortUrl, masstortResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, docrioAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(docrioUploadFileRespStr, uploadFileResp);
        multiCalloutMock.addRequestMock(fvNewDocUploadUrl, fvNewDocUploadResp);
        multiCalloutMock.addRequestMock(fvUploadUrl, fvUploadResp);
        multiCalloutMock.addRequestMock(fvAddDocToProjUrl, fvAddDocToProjResp);
        multiCalloutMock.addRequestMock(casesummaryUrl, caseSummaryResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_External_ID__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('4580812', intakes[0].Referral_Partner_API_External_ID__c);
    }


    @isTest 
    public static void test_OK_OtherMapping1() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerIntake();
        testIntake.What_is_your_relation_to_this_individual__c = 'Test';
        testIntake.Preferred_Method_of_Contact__c = 'email';
        update testIntake;

        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        string customContactUrl = fvSetting.Base_URL__c + '/core/custom-contacts';
        string projectUrl = fvSetting.Base_URL__c + '/core/projects';
        string initialIntakeUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/initialintake';
        string masstortUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/masstortinfo';
        string casesummaryUrl = fvSetting.Base_URL__c + '/core/projects/4580812/forms/casesummary';
        string fvNewDocUploadUrl = fvSetting.Base_URL__c + '/core/documents';
        string fvUploadUrl = 'https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5';
        string fvAddDocToProjUrl = fvSetting.Base_URL__c + '/core/projects/4580812/documents/311047751';

        string sessionRespStr = '{' +
                                    '"accessToken": "abc1234",' +
                                    '"refreshToken": "defghi",' +
                                    '"refreshTokenExpiry": "56719877617",' +
                                    '"refreshTokenTtl": "24 hours",' +
                                    '"userId": "12345",' +
                                    '"orgId": "5293"' +
                                '}';
        string customContactRespStr = '{' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Caller",' +
                                        '"lastName": "API",' +
                                        '"isSingleName": false,' +
                                        '"fullName": "Test Caller API",' +
                                        '"primaryEmail": "test@test.com",' +
                                        '"pictureUrl": "/images/Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"pictureKey": "Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"ssn": "123456789",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"personTypes": [],' +
                                        '"uniqueId": "6a820963-01b7-4bcc-a6ea-3cf2445ee94f",' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"caller",' +
                                            '"api",' +
                                            '"test caller api",' +
                                            '"test api"' +
                                        '],' +
                                        '"phones": [' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568205,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568206,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568207,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334495,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test@test.com",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334496,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test1@test.com",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"addressId": {' +
                                                    '"native": 11910464,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"line1": "123 Test Street",' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"fullAddress": "123 Test Street, Test, PA",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"hashtags": [],' +
                                        '"links": {' +
                                            '"self": "/contacts/19472883",' +
                                            '"projects": "/contacts/19472883/projects",' +
                                            '"phones": "/contacts/19472883/phones",' +
                                            '"emailAddresses": "/contacts/19472883/emailAddresses",' +
                                            '"addresses": "/contacts/19472883/addresses"' +
                                        '}' +
                                    '}';
        string projectRespStr = '{' +
                                    '"projectTypeCode": "MT3",' +
                                    '"rootDocFolderId": {' +
                                        '"native": 148064847,' +
                                        '"partner": null' +
                                    '},' +
                                    '"phaseName": "Migration for Review",' +
                                    '"clientName": "Test Client API",' +
                                    '"clientPictureURL": "/image-error.png",' +
                                    '"firstPrimaryName": "Filevine Integration",' +
                                    '"firstPrimaryUsername": "filevine128",' +
                                    '"isArchived": false,' +
                                    '"lastActivity": "2024-05-01T17:06:08.4192757Z",' +
                                    '"uniqueKey": "TestClientAPIZ4580812",' +
                                    '"projectOrClientName": "Test Client API",' +
                                    '"hashtags": [],' +
                                    '"projectEmailAddress": "TestClientAPIZ4580812@ashcraftandgerel.filevineapp.com",' +
                                    '"createdDate": "2024-05-01T17:06:08.4156183Z",' +
                                    '"projectUrl": "https://ashcraftandgerel.filevineapp.com/#/project/4580812",' +
                                    '"projectId": {' +
                                        '"native": 4580812,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectTypeId": {' +
                                        '"native": 4675,' +
                                        '"partner": null' +
                                    '},' +
                                    '"clientId": {' +
                                        '"native": 19467459,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectName": "Test Client API",' +
                                    '"phaseId": {' +
                                        '"native": 41897,' +
                                        '"partner": null' +
                                    '},' +
                                    '"links": {' +
                                        '"self": "/projects/4580812",' +
                                        '"projectType": "/projecttypes/4675",' +
                                        '"rootFolder": "/folders/148064847",' +
                                        '"client": "/contacts/19467459",' +
                                        '"contacts": "/projects/4580812/contacts"' +
                                    '}' +
                                '}';
        string initialIntakeStr = '{' +
                                        '"dateofintake": null,' +
                                        '"personperformingintakeLegacy": null,' +
                                        '"referralsource": null,' +
                                        '"referredfrom1": null,' +
                                        '"referredfrom1feepercentage": null,' +
                                        '"originatingattorney": null,' +
                                        '"casedescription": "Testing litify_pm__Description__c",' +
                                        '"leadstatus": null,' +
                                        '"rejectionreason": null,' +
                                        '"additionaldescriptionforrejection": null,' +
                                        '"casereferredto": null,' +
                                        '"referralfee": null,' +
                                        '"referralcontracts": null,' +
                                        '"datecontractsent": null,' +
                                        '"datecontractsigned": null,' +
                                        '"casetype": null,' +
                                        '"priorclient": null,' +
                                        '"othercasetype": null,' +
                                        '"referringfrom2": null,' +
                                        '"referralfrom2feepercenta": null,' +
                                        '"referredfrom3": null,' +
                                        '"referredfrom3feepercentage": null,' +
                                        '"otherrelevantreferralinfo": null,' +
                                        '"attorneyreviewwc3rdparty": null,' +
                                        '"additionalreferralsources": null,' +
                                        '"referralfrom4": null,' +
                                        '"referralsource5space": null,' +
                                        '"referredfrom5": null,' +
                                        '"isthecallertheinjuredpart": null,' +
                                        '"callername": null,' +
                                        '"callerrelationshiptoinjured": null,' +
                                        '"callerrelationshipother": null,' +
                                        '"3rdpartyattorneyreviewnote": null,' +
                                        '"initialIntakeInfo": null,' +
                                        '"referralMarketingInfo": null,' +
                                        '"litigationSubtype": null,' +
                                        '"personPerformingIntake": null,' +
                                        '"leadSentForReplacement": null,' +
                                        '"marketingSourceAgreedToRep": null,' +
                                        '"diagnosisReceived": null,' +
                                        '"diagnosisDate": null,' +
                                        '"firstSurgeryDate": null,' +
                                        '"stateWhereDiagnosed": null,' +
                                        '"discoveryDate": null,' +
                                        '"surgeryType": null,' +
                                        '"nameOfProductsUsed": null,' +
                                        '"dateOfFirstUse": null,' +
                                        '"dateOfLastUse": null,' +
                                        '"marketingSourceID": null,' +
                                        '"whatCityWereYouBorn": null,' +
                                        '"stateBorn": null,' +
                                        '"relationship": "The caller is the formal next of kin (when through all levels and they are the next in line)",' +
                                        '"personalInformation": null,' +
                                        '"legalRelation": null,' +
                                        '"callSelf": null,' +
                                        '"callerSELF": null,' +
                                        '"callerOTHER": null,' +
                                        '"causeofdeath": null,' +
                                        '"cityBorn": null,' +
                                        '"stateBornOther": null,' +
                                        '"whyAreYouThePointOfConta": null,' +
                                        '"coCounselID": "a0CVF00000TQOxG2AX",' +
                                        '"healthcareProvider": null,' +
                                        '"treatingHealthcareProvider": null,' +
                                        '"outreachLetterSent": null,' +
                                        '"hasAnEstateBeenOpened": true,' +
                                        '"isTheEstateCurrentlyOpen": true,' +
                                        '"doYouHaveACopyOfTheDeat": true,' +
                                        '"allLocationsLivedWorkedOr": "Knox Trailer Park;Hadnot Point",' +
                                        '"haveYouEverSmokedCigarette": "Smoked less than 1 year prior to throat related cancer DX",' +
                                        '"doYouCurrentlySmokeCigaret": true,' +
                                        '"haveYouEverSmokedCigarette_1": true,' +
                                        '"forHowLongDidYouSmoke": "10 years",' +
                                        '"howManyCigarettesPerDay": "4",' +
                                        '"whenDidYouBeginSmoking": "2000",' +
                                        '"whenDidYouStopSmoking": "2010",' +
                                        '"doYouHaveAnyDocumentsRela": "Yes",' +
                                        '"ifCivilianWhatWasTheNatu": "Testing Nature_Of_Presence_At_Camp_Lejeune__c",' +
                                        '"militaryDetails": "Testing Branch_discharge_status_and_rank__c",' +
                                        '"fullNameOfMilitaryService": "Testing Military_Stationed_Family_Mem_Full_Name__c",' +
                                        '"branchOfService": "Testing Branch_of_Service__c",' +
                                        '"dischargeStatus": "Honorable",' +
                                        '"rank": "Captain",' +
                                        '"tier1Diagnosis": "Kidney disease (End stage renal (ESRD), Renal Toxicity, Chronic Kidney Disease, etc.)",' +
                                        '"tier2Diagnosis": "Esophageal cancer",' +
                                        '"tier3Diagnosis": "None of the above",' +
                                        '"tier4Diagnosis": null,' +
                                        '"diagnosisDates": null,' +
                                        '"treatingDoctors": "Testing List_Dx_treating_doctor_names_spec__c",' +
                                        '"treatingFacilities": "Testing Treatment_Facilities_Name_and_Addresses__c",' +
                                        '"militaryPersonnelSSN": "123589852",' +
                                        '"militaryPersonnelDOB": "1980-12-24T00:00:00Z",' +
                                        '"militaryPersonnelPlaceOfBi": "CA",' +
                                        '"serviceNumber": "123456",' +
                                        '"militaryPersonnelAliveOrDe": "Alive",' +
                                        '"diagnosisInformation": null,' +
                                        '"diagnosisdriver": "Neurological effect and/or Neurobehavioral Performance Deficit"' +
                                    '}';
        string masstortStr = '{' +
                                    '"masstortcasetype": "Camp Lejeune Q Review",' +
                                    '"didtheuserhavetype1diabe": null,' +
                                    '"didyouhavetohavesurgeryt": null,' +
                                    '"didyouundergochemotherapy": null,' +
                                    '"dateofdeath": null,' +
                                    '"ageattimeofdeath": null,' +
                                    '"inwhatstatedidshepassawa": null,' +
                                    '"placeofresidenceattimeof": null,' +
                                    '"doyouhaveacopyofthedece": null,' +
                                    '"whatisthecauseofdeathlis": null,' +
                                    '"didshehaveawill": null,' +
                                    '"haveyoubeenappointedbyac": null,' +
                                    '"wasthedecentdiagnosedwith": null,' +
                                    '"atwhatmedicalfacilitywass": null,' +
                                    '"didshehavetohavesurgeryt": null,' +
                                    '"didshehavetoundergochemot": null,' +
                                    '"atwhatmedicalfacilitydids": null,' +
                                    '"wherewasshelivingattheti": null,' +
                                    '"masstorts": null,' +
                                    '"dateOfSurgery": null,' +
                                    '"jJBP": null,' +
                                    '"dateOfFirstRecurrence": null,' +
                                    '"histologicType": null,' +
                                    '"usageDates1": null,' +
                                    '"treatments": null,' +
                                    '"stage": null,' +
                                    '"usageDates2": null,' +
                                    '"histologicGrade": null,' +
                                    '"showerToShower": null,' +
                                    '"primarySiteS": null,' +
                                    '"ageAtDiagnosis": null,' +
                                    '"otherProductsUsed": null,' +
                                    '"genericTestingResults": null,' +
                                    '"familyHistory": null,' +
                                    '"riskFactors": null,' +
                                    '"protectiveFactors": null,' +
                                    '"additionalNotesOnDiagnosis_1": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"dateDiagnosisConfirmed": null,' +
                                    '"deathCertificateUpload": null,' +
                                    '"willUpload": null,' +
                                    '"otherLitigationType": null,' +
                                    '"litigationSubType": null,' +
                                    '"diagnosisConfirmed": null,' +
                                    '"legacyUsageState": null,' +
                                    '"paragardPlacementDate": null,' +
                                    '"paragardRemovalDate": null,' +
                                    '"placementFacility": null,' +
                                    '"removalFacility": null,' +
                                    '"didParagardArmSBreakBefo": null,' +
                                    '"didClientHaveSurgeryToRem": null,' +
                                    '"dateOfParagardSurgery": null,' +
                                    '"surgeryFacility": null,' +
                                    '"hasSurgeryBeenRecommended": null,' +
                                    '"removedParagardStatus": null,' +
                                    '"directExposure": null,' +
                                    '"indirectExposure": null,' +
                                    '"purchasesParaquatProducts": null,' +
                                    '"appliedParaquatProducts": null,' +
                                    '"certifiedApplicator": null,' +
                                    '"licensingAuthority": null,' +
                                    '"yearOfLicense": null,' +
                                    '"licenseNumber": null,' +
                                    '"yearOfFirstExposure": null,' +
                                    '"yearOfLastExposure": null,' +
                                    '"frequencyOfExposure": null,' +
                                    '"exposureStates": null,' +
                                    '"whereEmployed": null,' +
                                    '"otherPlace": null,' +
                                    '"placeOfExposure": null,' +
                                    '"distanceFromResidenceToSpr": null,' +
                                    '"methodOfDirectExposure": null,' +
                                    '"otherMethod": null,' +
                                    '"exposureDescription": null,' +
                                    '"paraquatProducts": null,' +
                                    '"otherParaquatProduct": null,' +
                                    '"cropsAppliedOn": null,' +
                                    '"documentsConfirmingPurchase": null,' +
                                    '"exposureToOtherChemical": null,' +
                                    '"otherChemicals": null,' +
                                    '"yearOfFirstExposureToOthe": null,' +
                                    '"yearOfLastExposureToOther": null,' +
                                    '"frequencyOfExposureToOther": null,' +
                                    '"descriptionOfOtherExposure": null,' +
                                    '"parkinsonSDiagnosisConfirme": null,' +
                                    '"dateOfParkinsonSDiagnosis": null,' +
                                    '"parkinsonSDiagnosingProvide": null,' +
                                    '"closeFamilyHistoryOfParkin": null,' +
                                    '"listOfFamilyMembersWithPa": null,' +
                                    '"probateCourtAppointment": null,' +
                                    '"anyPhotosOfParagard": null,' +
                                    '"confirmedGynecomastiaDiagnos": null,' +
                                    '"dateOfGynecomastiaDiagnosis": null,' +
                                    '"gynecomastiaSurgery": null,' +
                                    '"dateOfGynecomastiaSurgery": null,' +
                                    '"descriptionOfSurgery": null,' +
                                    '"gynecomastiaSurgeryFacility": null,' +
                                    '"ifNoGynecomastiaSurgeryHa": null,' +
                                    '"ifNoPlannedSurgeryWhyNot": null,' +
                                    '"anyCurrentTreatmentForGyne": null,' +
                                    '"dateOfLastTreatmentForGyn": null,' +
                                    '"anyPicturesOfGynecomastia": null,' +
                                    '"otherSignificantMedicalCond": null,' +
                                    '"gynecomastiaDiagnosisInforma": null,' +
                                    '"risperdalUsage": null,' +
                                    '"confirmedRisperdalRisperdo": null,' +
                                    '"prescribedDrug": null,' +
                                    '"otherDrug": null,' +
                                    '"datesOfDrugUsage": null,' +
                                    '"stateSOfUsage": null,' +
                                    '"drugDosage": null,' +
                                    '"reasonForDrugPrescription": null,' +
                                    '"usagePreLabel": null,' +
                                    '"usagePostLabel": null,' +
                                    '"minorUsePreLabel": null,' +
                                    '"minorUsePostLabel": null,' +
                                    '"adultUseOnly": null,' +
                                    '"settlementInfoCosts": null,' +
                                    '"medicalBillsAttributableTo": null,' +
                                    '"caseCosts": null,' +
                                    '"deathCertificate": null,' +
                                    '"will": null,' +
                                    '"probateCourtDocuments": null,' +
                                    '"parkinsonSDiagnosisRecords": null,' +
                                    '"paraquatPurchaseOrExposure": null,' +
                                    '"gynecomastiaDiagnosisRecords": null,' +
                                    '"gynecomastiaSurgeryRecords": null,' +
                                    '"gynecomastiaPictures": null,' +
                                    '"prescriptionRecords": null,' +
                                    '"medicalBills": null,' +
                                    '"paragardPlacementRecords": null,' +
                                    '"paragardRemovalRecords": null,' +
                                    '"paragardSurgeryRecords": null,' +
                                    '"paragardPhotos": null,' +
                                    '"medtronicMinimedPumpInjury": null,' +
                                    '"minimedPumpInjuryConfirmed": null,' +
                                    '"minimedPumpInjury": null,' +
                                    '"dateOfMinimedPumpInjury": null,' +
                                    '"ageAtMinimedPumpInjury": null,' +
                                    '"stateOfResidenceAtTimeOf": null,' +
                                    '"descriptionOfPumpInjury": null,' +
                                    '"treatmentForPumpInjury": null,' +
                                    '"treatmentDuration": null,' +
                                    '"treatmentRecords": null,' +
                                    '"medicalExpensesForPumpInju": null,' +
                                    '"descriptionOfTreatment": null,' +
                                    '"minimedPUmpInformation": null,' +
                                    '"defectiveMinimedPumpModel": null,' +
                                    '"serialNumber": null,' +
                                    '"retainerRingDescription": null,' +
                                    '"retainerRingPhotos": null,' +
                                    '"locationOfPump": null,' +
                                    '"pumpStartDate": null,' +
                                    '"statesUsedIn": null,' +
                                    '"pumpEndDate": null,' +
                                    '"notesOnDefectivePump": null,' +
                                    '"otherPumpsUsed": null,' +
                                    '"diabetesInformation": null,' +
                                    '"type1DiabetesConfirmed": null,' +
                                    '"dateOfDiabetesDiagnosis": null,' +
                                    '"diabetesStatus": null,' +
                                    '"diabetesManagementBeforeDef": null,' +
                                    '"currentDiabetesManagement": null,' +
                                    '"miniMedSeries600Confirmed": null,' +
                                    '"retainerRingColor": null,' +
                                    '"otherInjury": null,' +
                                    '"daysHospitalized": null,' +
                                    '"treatmentFacility": null,' +
                                    '"recurrence": null,' +
                                    '"additionalPrescriptionRecord": null,' +
                                    '"ageAtParkinsonSDiagnosis": null,' +
                                    '"additionalParkisonSDiagnosi": null,' +
                                    '"diagnosisRecordsOpPathRep": null,' +
                                    '"usageAffidavitOrDeclaration": null,' +
                                    '"geneticTestingRecords": null,' +
                                    '"space3392": null,' +
                                    '"space2402": null,' +
                                    '"space2412": null,' +
                                    '"space2422": null,' +
                                    '"space2442": null,' +
                                    '"space2452": null,' +
                                    '"space1882": null,' +
                                    '"space1902": null,' +
                                    '"space1942": null,' +
                                    '"qualifyingCancer": null,' +
                                    '"space2031": null,' +
                                    '"space2032": null,' +
                                    '"campLejeune": null,' +
                                    '"confirmedExposureToWaterAt": null,' +
                                    '"startDateOfExposure": "1990-12-12T00:00:00Z",' +
                                    '"endDateOfExposure": "1990-01-12T00:00:00Z",' +
                                    '"lengthOfExposure": null,' +
                                    '"exposureLocationS": null,' +
                                    '"methodOfExposure": null,' +
                                    '"statusWhenStationedAtCamp": "Military Veteran",' +
                                    '"militaryService": null,' +
                                    '"militaryServicemember": null,' +
                                    '"branchOfMilitary": null,' +
                                    '"lastRank": null,' +
                                    '"lastPayGrade": null,' +
                                    '"datesOfService": null,' +
                                    '"typeOfSeparation": null,' +
                                    '"dDForm214Received": null,' +
                                    '"dDForm214": null,' +
                                    '"documentationOfExposure": null,' +
                                    '"injuryInformation": null,' +
                                    '"campLejeuneInjuryConfirmed": null,' +
                                    '"diagnosisProvider": null,' +
                                    '"treatingProviderS": null,' +
                                    '"diagnosisRecords": null,' +
                                    '"treatingRecords": null,' +
                                    '"currentlyTreating": null,' +
                                    '"currentTreatingProviderS": null,' +
                                    '"nonVAMedicalInsurance": null,' +
                                    '"insuranceCarrier": null,' +
                                    '"policyNumber": null,' +
                                    '"groupNumber": null,' +
                                    '"insuranceInformation": null,' +
                                    '"medicareCoverage": null,' +
                                    '"medicarePolicyNumber": null,' +
                                    '"medicaidCoverage": null,' +
                                    '"medicaidPolicyNumber": null,' +
                                    '"otherMedicalConditionsForW": null,' +
                                    '"descriptionOfOtherVABenefi": null,' +
                                    '"priorCampLajeuneClaimInfor": null,' +
                                    '"filedAPriorForm95Claim": null,' +
                                    '"denialLetter": null,' +
                                    '"adjudicatedReceivedDenial": null,' +
                                    '"ageAtTimeOfExposure": null,' +
                                    '"space3172": null,' +
                                    '"space3162": null,' +
                                    '"deathInformation": null,' +
                                    '"welcomePacketSent": null,' +
                                    '"allRecordsRequested": null,' +
                                    '"oMPF": null,' +
                                    '"officialMilitaryPersonnelFi_1": null,' +
                                    '"officialMilitaryPersonnelFi": null,' +
                                    '"cLWelcomeEmailAGOnly": null,' +
                                    '"cLWelcomeEmailSinkReferra": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"talcumPowderInformation": null,' +
                                    '"additionalDiagnosisRecords": null,' +
                                    '"tubalLigation": null,' +
                                    '"dateOfTubalLigation": null,' +
                                    '"confirmedInjury": null,' +
                                    '"otherCancerDiseaseCondition": null,' +
                                    '"claimedInjury": null,' +
                                    '"otherClaimedInjury": null,' +
                                    '"clientDocumentsReceived": null,' +
                                    '"documentsReceived": null,' +
                                    '"missingDocuments": null,' +
                                    '"additionalStatusWhenStation": null,' +
                                    '"intakeSummaryOfInjuries": null,' +
                                    '"space3391": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"space3412": null,' +
                                    '"typeOfTreatment": null,' +
                                    '"clientDoesNotRecallTreatme": null,' +
                                    '"currentTreatingRecords": null,' +
                                    '"smokingStatus": null,' +
                                    '"yearsSmoked": null,' +
                                    '"averageCigarettesPerDay": null,' +
                                    '"didYouOrAFamilyMemberSer": null,' +
                                    '"exposedIndividualSName": null,' +
                                    '"otherExposureLocation": null,' +
                                    '"nameOfEmployerIfNonMilit": null,' +
                                    '"additionalStatusInformation": null,' +
                                    '"dateOfDiagnosis": null,' +
                                    '"areYouCurrentlyReceivingVA": null,' +
                                    '"doYouHaveAnyOfTheFollowi": [' +
                                        '"Official Military Personnel File",' +
                                        '"Medical Records"' +
                                    '],' +
                                    '"currentOrMostRecentPrimary": null,' +
                                    '"haveYouEverBeenTreatedFor": null,' +
                                    '"identifyTheMilitaryBaseAnd": null,' +
                                    '"cLWelcomeEmailTwoCoCouns": null,' +
                                    '"sponsorName": null,' +
                                    '"hadnotPointIndustrialArea": null,' +
                                    '"medicalConditionsInvestigati": null,' +
                                    '"questionnaireFollowUpEmail": null,' +
                                    '"questionnaireFollowUpEmail_1": null,' +
                                    '"additionalInjuryDates": null,' +
                                    '"dateSubmitted": null,' +
                                    '"serviceRequestNumber": null,' +
                                    '"recordRequest": null,' +
                                    '"otherMilitaryFiles": null,' +
                                    '"typeOfEmploymentWhileAtCa": null,' +
                                    '"dateEnteredService": null,' +
                                    '"serviceEndDate": null,' +
                                    '"trtStrDate": null,' +
                                    '"injfamhis": null,' +
                                    '"ompfExp": null,' +
                                    '"ompfExpEnd": null,' +
                                    '"totalDaysAtCampLejeune": null,' +
                                    '"diagnosisDate": null,' +
                                    '"daysAtCL": null,' +
                                    '"onsetDate": null,' +
                                    '"medicalReviewNotes": null,' +
                                    '"oMPFDeficiency": null,' +
                                    '"letterMailDate": null,' +
                                    '"deficiencyLetter": null,' +
                                    '"electiveoption": null,' +
                                    '"clientQualifiesForEO": null,' +
                                    '"electiveOptionNotice": null,' +
                                    '"mailDate": null,' +
                                    '"relationshipToSponsor": null,' +
                                    '"otherRelationToSponsor": null,' +
                                    '"otherResidenceInformation": null,' +
                                    '"clientWishesToPursueEO": null,' +
                                    '"oMPFNotes": null,' +
                                    '"monthsAtCL": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        string docrioSignedUrlRespStr = '{' +
                                            '"Records": [' +
                                                '{' +
                                                    '"Id": "' + testFile.Id + '",' +
                                                    '"SignedUrl": "https://test.pdf"' +
                                                '}' +
                                            ']' +
                                        '}';
        string docrioFileContentRespStr = 'a'.repeat(100);
        string docrioUploadFileRespStr = '{' +
                                        '"message": "Document Uploaded"' +
                                    '}';
        
        string fvNewDocUploadRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify1234"' +
                                            '},' +
                                            '"contentType": "application/pdf",' +
                                            '"url": "https://fv-prod-us-shard-b-docs.s3.us-west-2.amazonaws.com/3e6f3225-dfd3-4531-a072-70027fc0076e.pdf?X-Amz-Expires=18000&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUD326UZZYHRDLTGF/20240502/us-west-2/s3/aws4_request&X-Amz-Date=20240502T195203Z&X-Amz-SignedHeaders=content-type;host&X-Amz-Signature=9b1e44e0cd07532644adef3e1cbd69f51c64282b60c2316c3f5f44fea5f7d2e5",' +
                                            '"links": {}' +
                                        '}';
        string fvUploadStr = '';
        string fvAddDocToProjRespStr = '{' +
                                            '"documentId": {' +
                                                '"native": 311047751,' +
                                                '"partner": "testlitify123"' +
                                            '},' +
                                            '"filename": "Test.pdf",' +
                                            '"size": 0,' +
                                            '"folderId": {' +
                                                '"native": 148064847,' +
                                                '"partner": null' +
                                            '},' +
                                            '"projectId": {' +
                                                '"native": 4580812,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploaderId": {' +
                                                '"native": 2941,' +
                                                '"partner": null' +
                                            '},' +
                                            '"uploadDate": "2024-05-01T18:15:56.9337196Z",' +
                                            '"hashtags": [],' +
                                            '"links": {' +
                                                '"project": "/projects/4580812",' +
                                                '"self": "/documents/311047751",' +
                                                '"folder": "/folders/148064847",' +
                                                '"hashtags": "/documents/311047751/hashtags"' +
                                            '}' +
                                        '}';
        string caseSummaryStr = '{' +
                                    '"tier": null,' +
                                    '"assignedattorney": null,' +
                                    '"assignedparalegal": null,' +
                                    '"masstortcoordinator": null,' +
                                    '"datecontacted": null,' +
                                    '"practicearea": "Test Case Type",' +
                                    '"statuteoflimitation": null,' +
                                    '"personalinjurysol": null,' +
                                    '"wrongfuldeathsol": null,' +
                                    '"solnotes": null,' +
                                    '"coCounsel1": {' +
                                        '"personId": {' +
                                            '"native": 19043693,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19043693,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Saddle Rock Legal Group, LLC",' +
                                        '"middleName": null,' +
                                        '"lastName": null,' +
                                        '"fullname": "Saddle Rock Legal Group, LLC",' +
                                        '"isSingleName": true,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Saddle Rock Legal Group, LLC",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [],' +
                                        '"emails": [],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11628545,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington DC",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington DC, DC 20005"' +
                                            '},' +
                                            '{' +
                                                '"id": 11628546,' +
                                                '"line1": "655 15th Street NW, Suite 800",' +
                                                '"line2": "",' +
                                                '"city": "Washington",' +
                                                '"state": "DC",' +
                                                '"zip": "20005",' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": "",' +
                                                '"fullAddress": "655 15th Street NW, Suite 800, Washington, DC 20005"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"pictureKey": "Default78c73bf4-88a4-4317-9a2e-86ef3c4c3bc8.png",' +
                                        '"birthDate": null,' +
                                        '"deathDate": null,' +
                                        '"isDeceased": null,' +
                                        '"uniqueID": "589380d7-2c7f-44bd-9883-77b217b98e2e",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": null,' +
                                        '"notes": null,' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": null,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"saddle",' +
                                            '"rock",' +
                                            '"legal",' +
                                            '"group,",' +
                                            '"llc",' +
                                            '"saddle rock legal group, llc"' +
                                        ']' +
                                    '},' +
                                    '"coCounsel2": null,' +
                                    '"coCounsel3": null,' +
                                    '"coCounsel1FeePercentage": null,' +
                                    '"coCounsel2FeePercentage": null,' +
                                    '"6Space": null,' +
                                    '"coCounsel3FeePercentage": null,' +
                                    '"7Space": null,' +
                                    '"coCounsel": true,' +
                                    '"courtInfo": null,' +
                                    '"courtCase1": null,' +
                                    '"caption": null,' +
                                    '"dateFiled": null,' +
                                    '"localCounsel": null,' +
                                    '"localCounselFeePercentage": null,' +
                                    '"otherLitigationType": null,' +
                                    '"areYouLocalCouncil": false,' +
                                    '"staffAssignments": null,' +
                                    '"practiceAreaCaseStatus": null,' +
                                    '"litigationSubtype": "Personal Injury",' +
                                    '"coCounselReferralInformat": null,' +
                                    '"localCounselFeePercentage_1": null,' +
                                    '"caseReferredOut": false,' +
                                    '"referralFirmFeePercentage": null,' +
                                    '"referralFirm": null,' +
                                    '"referralFirm2": null,' +
                                    '"referralFirm3": null,' +
                                    '"referralToFirm": null,' +
                                    '"courtlegacy": null,' +
                                    '"activeDateFiled": null,' +
                                    '"trialDate": null,' +
                                    '"pTCDate": null,' +
                                    '"dateOf1stExposureToAsbest": null,' +
                                    '"dateOf1stDiagnosisOfAsbes": null,' +
                                    '"dateLastExposureToAsbestos": null,' +
                                    '"probateCourt": null,' +
                                    '"probateCourtDocket": null,' +
                                    '"activeInactive": null,' +
                                    '"bMLCTNO": null,' +
                                    '"complaintAmendedToAllegeNe": null,' +
                                    '"complaintAmendedForWrongful": null,' +
                                    '"complaintAmendedToAddPerso": null,' +
                                    '"trialGroup": null,' +
                                    '"complaintAmendedToAddUseP": null,' +
                                    '"complaintAmendedPlaintiffsD": null,' +
                                    '"complaintAmendedNewDisease": null,' +
                                    '"complaintAmendedWrongfulDea": null,' +
                                    '"complaintAmendedPersonalRep": null,' +
                                    '"statusConferenceHearings": null,' +
                                    '"spacer432": null,' +
                                    '"spacer21": null,' +
                                    '"spacer52": null,' +
                                    '"judge": null,' +
                                    '"matterID": null,' +
                                    '"archivedReason": null,' +
                                    '"archivedDate": null,' +
                                    '"prevailStatus": null,' +
                                    '"court1CurrentCourt": null,' +
                                    '"court2": null,' +
                                    '"caseNumber2": null,' +
                                    '"court3": null,' +
                                    '"caseNumber3": null,' +
                                    '"relationshipToDecedent": null,' +
                                    '"tolled": null,' +
                                    '"tollingStart": null,' +
                                    '"tollingEnd": null,' +
                                    '"otherArchiveReason": null,' +
                                    '"retainerFeePercentage": null,' +
                                    '"8Space": null,' +
                                    '"coCounsel4": null,' +
                                    '"coCounsel4Fee": null,' +
                                    '"referralFirm4": null,' +
                                    '"complaintUpload": null,' +
                                    '"retainer": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"aGLocalCounselAgreement": null,' +
                                    '"coCounselAgreement": null,' +
                                    '"localCounselAgreement": null,' +
                                    '"tollingAgreement": null,' +
                                    '"nonQualifyingInjury": null,' +
                                    '"doYouHaveLocalCounsel": null,' +
                                    '"clientBankruptcyInformation": null,' +
                                    '"pendingBankruptcy": null,' +
                                    '"priorBankruptcy": null,' +
                                    '"pendingBankruptcyChapter": null,' +
                                    '"pendingBankruptcyCourt": null,' +
                                    '"pendingBankruptcyCaseNo": null,' +
                                    '"clientBankruptcyAttorney": null,' +
                                    '"aGAppointedAsLitigationCo": null,' +
                                    '"aGAppointmentOrder": null,' +
                                    '"dateOfMostRecentPriorBank": null,' +
                                    '"chapterOfPriorBankruptcy": null,' +
                                    '"courtOfPriorBankruptcy": null,' +
                                    '"priorBankruptcyCaseNo": null,' +
                                    '"priorBankruptcyDischargeDat": null,' +
                                    '"bankruptcyTrustee": null,' +
                                    '"dateOfClaimedInjury": null,' +
                                    '"dateOfDiscovery": null,' +
                                    '"legacyAsbestosCaseInfo": null,' +
                                    '"injuredPersonPersonalInform": null,' +
                                    '"dateOfBirth": null,' +
                                    '"socialSecurityNumber": null,' +
                                    '"maritalStatus": null,' +
                                    '"children": null,' +
                                    '"highestEducation": null,' +
                                    '"highestDegreeObtained": null,' +
                                    '"nameOfInstitutionOfHighest": null,' +
                                    '"occupation": null,' +
                                    '"lastAnnualPayPriorToInjur": null,' +
                                    '"lastPlaceOfEmployment": null,' +
                                    '"space243": null,' +
                                    '"retainerFullyExecuted": null,' +
                                    '"decedentIfWrongfulDeathCa": null,' +
                                    '"coCounsel5": null,' +
                                    '"coCounsel5FeePercentage": null,' +
                                    '"referralFirm5": null,' +
                                    '"9Space": null,' +
                                    '"printToSmartMailroom": null,' +
                                    '"space32": null,' +
                                    '"space33": null,' +
                                    '"space53": null,' +
                                    '"space54": null,' +
                                    '"welcomeEmailSent": null,' +
                                    '"welcomeLetterSent": null,' +
                                    '"allClientDocumentsReceived": null,' +
                                    '"allRecordsOrdered": null,' +
                                    '"questionnaireStatus": null,' +
                                    '"questionnaire": {' +
                                        '"id": 311047751,' +
                                        '"orgID": 184,' +
                                        '"projectID": 4580812,' +
                                        '"filename": "Test.pdf",' +
                                        '"uploadDate": "2024-05-01T18:15:56.933Z",' +
                                        '"templateID": null,' +
                                        '"templateName": null,' +
                                        '"reportFusionID": null,' +
                                        '"reportFusionName": null,' +
                                        '"contractID": null,' +
                                        '"canEditInPlace": true,' +
                                        '"lockedByUserID": null,' +
                                        '"lockedTime": null,' +
                                        '"lockExpirationTime": null,' +
                                        '"lockedByUserFullName": null,' +
                                        '"isPending": false,' +
                                        '"contract": null' +
                                    '},' +
                                    '"authorizationsStatus": null,' +
                                    '"hIPAAAuthorization": null,' +
                                    '"otherAuthorizations": null,' +
                                    '"otherQuestionnaires": null,' +
                                    '"clientWelcomeEmail": null,' +
                                    '"clientProvidedMedicalRecord": null,' +
                                    '"duplicateProjectID": null,' +
                                    '"criteriaIssue": null,' +
                                    '"deathCertificateStatus": null,' +
                                    '"deathCertificate": null,' +
                                    '"lastWillStatus": null,' +
                                    '"estateOrderLetters": null,' +
                                    '"estateStatus": null,' +
                                    '"lastWill": null,' +
                                    '"clientNamedAsExecutor": null,' +
                                    '"clientAppointedPersonalRepr": null,' +
                                    '"causeOfDeath": null,' +
                                    '"clientMedicalRecords": null,' +
                                    '"space212": null,' +
                                    '"filedCivilCoverSheet": null,' +
                                    '"generateShortFormComplaint_1": null,' +
                                    '"draftCivilCoverSheet": null,' +
                                    '"milestonesEnabled": true,' +
                                    '"clientSRelationshipToInjur": "Work Spouse",' +
                                    '"injuredPerson": {' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"id": 19467459,' +
                                        '"orgID": 184,' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Client",' +
                                        '"lastName": "API",' +
                                        '"fullname": "Test Client API",' +
                                        '"isSingleName": false,' +
                                        '"fromCompany": null,' +
                                        '"orgMetaVersionID": 0,' +
                                        '"jobTitle": null,' +
                                        '"department": null,' +
                                        '"prefix": null,' +
                                        '"suffix": null,' +
                                        '"fullnameExtended": "Test Client API",' +
                                        '"nickname": null,' +
                                        '"initials": null,' +
                                        '"initialsFirstLast": null,' +
                                        '"personTypes": null,' +
                                        '"tags": null,' +
                                        '"isArchived": false,' +
                                        '"createdDate": null,' +
                                        '"modifiedDate": null,' +
                                        '"phones": [' +
                                            '{' +
                                                '"id": 17563433,' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563434,' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 17563435,' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"label": null,' +
                                                '"phoneLabel": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"id": 6332234,' +
                                                '"address": "test@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '},' +
                                            '{' +
                                                '"id": 6332235,' +
                                                '"address": "test1@test.com",' +
                                                '"emailLabel": null,' +
                                                '"label": null,' +
                                                '"notes": null' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"id": 11907151,' +
                                                '"line1": "123 Test Street",' +
                                                '"line2": null,' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"zip": null,' +
                                                '"label": null,' +
                                                '"addressLabel": null,' +
                                                '"notes": null,' +
                                                '"fullAddress": "123 Test Street, Test, PA"' +
                                            '}' +
                                        '],' +
                                        '"pictureUrl": "/images/Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"pictureKey": "Default16f3287b-3efd-4f65-99cf-b1750d39846d.png",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"deathDate": "2024-04-29T00:00:00Z",' +
                                        '"isDeceased": true,' +
                                        '"uniqueID": "e7f5c781-bfa2-4c46-abf1-3bc2d9d0a46d",' +
                                        '"abbreviatedName": null,' +
                                        '"ssn": "123456789",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"specialty": null,' +
                                        '"gender": null,' +
                                        '"language": null,' +
                                        '"maritalStatus": null,' +
                                        '"isTextingPermitted": null,' +
                                        '"remarket": null,' +
                                        '"driverLicenseNumber": null,' +
                                        '"isTypeClient": true,' +
                                        '"isTypeAdjuster": null,' +
                                        '"isTypeDefendant": null,' +
                                        '"isTypePlaintiff": null,' +
                                        '"isTypeAttorney": null,' +
                                        '"isTypeFirm": null,' +
                                        '"isTypeExpert": null,' +
                                        '"isTypeMedicalProvider": null,' +
                                        '"isTypeInvolvedParty": null,' +
                                        '"isTypeJudge": null,' +
                                        '"isTypeCourt": null,' +
                                        '"isTypeInsuranceCompany": null,' +
                                        '"salutation": null,' +
                                        '"barNumber": null,' +
                                        '"fiduciary": null,' +
                                        '"isMinor": null,' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"client",' +
                                            '"api",' +
                                            '"test client api",' +
                                            '"test api"' +
                                        ']' +
                                    '},' +
                                    '"pOAOrGuardianshipPapers": null,' +
                                    '"presumptiveCondition": null,' +
                                    '"jAGPerfectionLetter": null,' +
                                    '"jAGSubstantiationLetter": null,' +
                                    '"dONClaim": null,' +
                                    '"perfectionLetter": null,' +
                                    '"substantiationLetter": null,' +
                                    '"parkerDenial": null,' +
                                    '"stateOfDeath": null,' +
                                    '"appointedJudge": null,' +
                                    '"coCounselProvidedMedicalRe": null,' +
                                    '"stateEstablished": null,' +
                                    '"countyEstablished": null,' +
                                    '"tier2": null,' +
                                    '"tier2_1": null,' +
                                    '"mDLRemandJurisdiction": null,' +
                                    '"caseWorks": null,' +
                                    '"dateSentToCaseWorks": null,' +
                                    '"defendantsHairRelaxers": null,' +
                                    '"caseDevelopment": null,' +
                                    '"vendor": null,' +
                                    '"dateSentToVendor": null,' +
                                    '"vendorStatus": null,' +
                                    '"statusComments": null,' +
                                    '"statusDate": null,' +
                                    '"communicationStatus": null,' +
                                    '"comments": null,' +
                                    '"commDate": null,' +
                                    '"proofOfIdentity": null,' +
                                    '"withdrawalTrackingNumber": null,' +
                                    '"dateAmended": null,' +
                                    '"amendedComplaint": null,' +
                                    '"space582": null,' +
                                    '"space583": null,' +
                                    '"alertsNotes": null,' +
                                    '"settlementProjections": null,' +
                                    '"injuryCategory": null,' +
                                    '"projectedSettlement": null,' +
                                    '"feeCap": null,' +
                                    '"aGFeeSum": {' +
                                        '"value": null,' +
                                        '"error": null' +
                                    '}' +
                                '}';

        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(200, 'OK', sessionRespStr, null);
        SaddleRockCalloutMock customContactResp = new SaddleRockCalloutMock(200, 'OK', customContactRespStr, null);
        SaddleRockCalloutMock projectResp = new SaddleRockCalloutMock(200, 'OK', projectRespStr, null);
        SaddleRockCalloutMock initialIntakeResp = new SaddleRockCalloutMock(200, 'OK', initialIntakeStr, null);
        SaddleRockCalloutMock masstortResp = new SaddleRockCalloutMock(200, 'OK', masstortStr, null);
        SaddleRockCalloutMock docrioAuthResp = new SaddleRockCalloutMock(200, 'OK', '{"access_token": "abcdef1234"}', null);
        SaddleRockCalloutMock docrioSignedUrlResp = new SaddleRockCalloutMock(200, 'OK', docrioSignedUrlRespStr, null);
        SaddleRockCalloutMock fileContentResp = new SaddleRockCalloutMock(200, 'OK', docrioFileContentRespStr, null);
        SaddleRockCalloutMock uploadFileResp = new SaddleRockCalloutMock(200, 'OK', docrioUploadFileRespStr, null);
        SaddleRockCalloutMock fvNewDocUploadResp = new SaddleRockCalloutMock(200, 'OK', fvNewDocUploadRespStr, null);
        SaddleRockCalloutMock fvUploadResp = new SaddleRockCalloutMock(200, 'OK', fvUploadStr, null);
        SaddleRockCalloutMock fvAddDocToProjResp = new SaddleRockCalloutMock(200, 'OK', fvAddDocToProjRespStr, null);
        SaddleRockCalloutMock caseSummaryResp = new SaddleRockCalloutMock(200, 'OK', caseSummaryStr, null);

        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);
        multiCalloutMock.addRequestMock(customContactUrl, customContactResp);
        multiCalloutMock.addRequestMock(projectUrl, projectResp);
        multiCalloutMock.addRequestMock(initialIntakeUrl, initialIntakeResp);
        multiCalloutMock.addRequestMock(masstortUrl, masstortResp);
        multiCalloutMock.addRequestMock(ENDPOINTS.tokenEndpoint, docrioAuthResp);
        multiCalloutMock.addRequestMock(docrioSetting.docriosdk__API_Endpoint__c + '/files?Ids=' + testFile.Id, docrioSignedUrlResp);
        multiCalloutMock.addRequestMock('https://test.pdf', fileContentResp);
        multiCalloutMock.addRequestMock(docrioUploadFileRespStr, uploadFileResp);
        multiCalloutMock.addRequestMock(fvNewDocUploadUrl, fvNewDocUploadResp);
        multiCalloutMock.addRequestMock(fvUploadUrl, fvUploadResp);
        multiCalloutMock.addRequestMock(fvAddDocToProjUrl, fvAddDocToProjResp);
        multiCalloutMock.addRequestMock(casesummaryUrl, caseSummaryResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_External_ID__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('4580812', intakes[0].Referral_Partner_API_External_ID__c);
    }

    @isTest 
    public static void test_Error_LoginFail() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerIntake();
        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        
        string sessionRespStr = '{' +
                                    '"error": "Invalid hash"' +
                                '}';

        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(401, 'Unauthorized', sessionRespStr, null);

        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_Error__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('401 - Unauthorized', intakes[0].Referral_Partner_API_Error__c);
    }

    @isTest 
    public static void test_Error_BadRequest() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerIntake();
        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        string customContactUrl = fvSetting.Base_URL__c + '/core/custom-contacts';

        string sessionRespStr = '{' +
                                    '"accessToken": "abc1234",' +
                                    '"refreshToken": "defghi",' +
                                    '"refreshTokenExpiry": "56719877617",' +
                                    '"refreshTokenTtl": "24 hours",' +
                                    '"userId": "12345",' +
                                    '"orgId": "5293"' +
                                '}';
        string customContactRespStr = '';
        
        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(200, 'OK', sessionRespStr, null);
        SaddleRockCalloutMock customContactResp = new SaddleRockCalloutMock(400, 'Bad Request', customContactRespStr, null);

        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);
        multiCalloutMock.addRequestMock(customContactUrl, customContactResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_Error__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('400 - Bad Request', intakes[0].Referral_Partner_API_Error__c);
    }

    @isTest 
    public static void test_Error_MissingCaller() {
        // Create test flow inputs
        litify_pm__Intake__c testIntake = FV_TestDataFactory.createTestCallerIntake();
        testIntake.Caller__c = null;
        update testIntake;

        litify_docs__File_Info__c testFile = FV_TestDataFactory.createTestFileInfo();

        List<FV_CreateProjectInvocable.FlowInputs> request = new List<FV_CreateProjectInvocable.FlowInputs>();
        FV_CreateProjectInvocable.FlowInputs input = new FV_CreateProjectInvocable.FlowInputs();
        input.intakeId = testIntake.Id;
        input.retainerFileId = testFile.Id;
        //input.questionnaireFileId = testFile.Id;
        input.fileInfoIds = new List<string>{testFile.Id};

        request.add(input);

        // Set up mock
        docriosdk__Docrio_Tool_Setting__c docrioSetting = FV_TestDataFactory.createTestDocrioSetting();
        Filevine_API_Settings__c fvSetting = FV_TestDataFactory.createTestFilevineAPISetting();
        string sessionUrl = fvSetting.Base_URL__c + '/session';
        string customContactUrl = fvSetting.Base_URL__c + '/core/custom-contacts';
        string projectUrl = fvSetting.Base_URL__c + '/core/projects';

        string sessionRespStr = '{' +
                                    '"accessToken": "abc1234",' +
                                    '"refreshToken": "defghi",' +
                                    '"refreshTokenExpiry": "56719877617",' +
                                    '"refreshTokenTtl": "24 hours",' +
                                    '"userId": "12345",' +
                                    '"orgId": "5293"' +
                                '}';
        string customContactRespStr = '{' +
                                        '"personId": {' +
                                            '"native": 19467459,' +
                                            '"partner": null' +
                                        '},' +
                                        '"firstName": "Test",' +
                                        '"middleName": "Caller",' +
                                        '"lastName": "API",' +
                                        '"isSingleName": false,' +
                                        '"fullName": "Test Caller API",' +
                                        '"primaryEmail": "test@test.com",' +
                                        '"pictureUrl": "/images/Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"pictureKey": "Default675cfe78-5c32-4326-8a85-34bbf1bb5125.png",' +
                                        '"ssn": "123456789",' +
                                        '"birthDate": "1990-01-12T00:00:00Z",' +
                                        '"notes": "Best time to call - Test",' +
                                        '"personTypes": [],' +
                                        '"uniqueId": "6a820963-01b7-4bcc-a6ea-3cf2445ee94f",' +
                                        '"searchNames": [' +
                                            '"test",' +
                                            '"caller",' +
                                            '"api",' +
                                            '"test caller api",' +
                                            '"test api"' +
                                        '],' +
                                        '"phones": [' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568205,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "2222222222",' +
                                                '"rawNumber": "2222222222",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568206,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "3333333333",' +
                                                '"rawNumber": "3333333333",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"phoneId": {' +
                                                    '"native": 17568207,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"number": "4444444444",' +
                                                '"rawNumber": "4444444444",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"emails": [' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334495,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test@test.com",' +
                                                '"links": {}' +
                                            '},' +
                                            '{' +
                                                '"emailId": {' +
                                                    '"native": 6334496,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"address": "test1@test.com",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"addresses": [' +
                                            '{' +
                                                '"addressId": {' +
                                                    '"native": 11910464,' +
                                                    '"partner": null' +
                                                '},' +
                                                '"line1": "123 Test Street",' +
                                                '"city": "Test",' +
                                                '"state": "PA",' +
                                                '"fullAddress": "123 Test Street, Test, PA",' +
                                                '"links": {}' +
                                            '}' +
                                        '],' +
                                        '"hashtags": [],' +
                                        '"links": {' +
                                            '"self": "/contacts/19472883",' +
                                            '"projects": "/contacts/19472883/projects",' +
                                            '"phones": "/contacts/19472883/phones",' +
                                            '"emailAddresses": "/contacts/19472883/emailAddresses",' +
                                            '"addresses": "/contacts/19472883/addresses"' +
                                        '}' +
                                    '}';
        string projectRespStr = '{' +
                                    '"projectTypeCode": "MT3",' +
                                    '"rootDocFolderId": {' +
                                        '"native": 148064847,' +
                                        '"partner": null' +
                                    '},' +
                                    '"phaseName": "Migration for Review",' +
                                    '"clientName": "Test Client API",' +
                                    '"clientPictureURL": "/image-error.png",' +
                                    '"firstPrimaryName": "Filevine Integration",' +
                                    '"firstPrimaryUsername": "filevine128",' +
                                    '"isArchived": false,' +
                                    '"lastActivity": "2024-05-01T17:06:08.4192757Z",' +
                                    '"uniqueKey": "TestClientAPIZ4580812",' +
                                    '"projectOrClientName": "Test Client API",' +
                                    '"hashtags": [],' +
                                    '"projectEmailAddress": "TestClientAPIZ4580812@ashcraftandgerel.filevineapp.com",' +
                                    '"createdDate": "2024-05-01T17:06:08.4156183Z",' +
                                    '"projectUrl": "https://ashcraftandgerel.filevineapp.com/#/project/4580812",' +
                                    '"projectId": {' +
                                        '"native": 4580812,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectTypeId": {' +
                                        '"native": 4675,' +
                                        '"partner": null' +
                                    '},' +
                                    '"clientId": {' +
                                        '"native": 19467459,' +
                                        '"partner": null' +
                                    '},' +
                                    '"projectName": "Test Client API",' +
                                    '"phaseId": {' +
                                        '"native": 41897,' +
                                        '"partner": null' +
                                    '},' +
                                    '"links": {' +
                                        '"self": "/projects/4580812",' +
                                        '"projectType": "/projecttypes/4675",' +
                                        '"rootFolder": "/folders/148064847",' +
                                        '"client": "/contacts/19467459",' +
                                        '"contacts": "/projects/4580812/contacts"' +
                                    '}' +
                                '}';
        
        SaddleRockCalloutMock sessionResp = new SaddleRockCalloutMock(200, 'OK', sessionRespStr, null);
        SaddleRockCalloutMock customContactResp = new SaddleRockCalloutMock(200, 'OK', customContactRespStr, null);
        SaddleRockCalloutMock projectResp = new SaddleRockCalloutMock(500, 'Internal Server Error', projectRespStr, null);
        
        Map<String, HttpCalloutMock> fvResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(fvResp);
        multiCalloutMock.addRequestMock(sessionUrl, sessionResp);
        multiCalloutMock.addRequestMock(customContactUrl, customContactResp);
        multiCalloutMock.addRequestMock(projectUrl, projectResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Start test
        Test.startTest();
        FV_CreateProjectInvocable.submitToFilevineAPI(request);
        Test.stopTest();
        List<litify_pm__Intake__c> intakes = [SELECT Id, Referral_Partner_API_Error__c 
                                                FROM litify_pm__Intake__c
                                                WHERE Id = :testIntake.Id];
        System.assertEquals('500 - Internal Server Error', intakes[0].Referral_Partner_API_Error__c);
    }
}