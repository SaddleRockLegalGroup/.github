public with sharing class Tekmir_DataHandler {
    public Tekmir_Models.NewMatterRequest buildJsonPayload(string intakeId, Integer saltIdTestmode, Boolean testMode) {
        Tekmir_Models.NewMatterRequest matterRequest = new Tekmir_Models.NewMatterRequest();
        List<litify_pm__Intake__c> intakes = [SELECT Id
, Date_Client_First_Saw_Advertising__c
, Client_Discovered_Cause_From_Advertising__c
, FX_Id__c
, FX_Qualified__c
, Campaign__r.Name
, litify_pm__Source__r.Name
, Intake_Vendor__r.Name
, Intake_Vendor__c
, Test_Intake__c
, litify_pm__Retainer_Agreement_Sent_Date__c
, litify_pm__Retainer_Agreement_Signed__c
, Discovery_Of_Cause_Date__c
, How_Client_Discovered_Cause__c
, litify_pm__Description__c
, Working_with_another_law_firm__c
, Source_Name__c
, What_is_your_relationship_to_IP_pk__c
, Do_you_have_legal_POA_documents__c
, Power_Of_Attorney_Type__c
, litify_pm__Turn_Down_Details__c

, litify_pm__Client__r.litify_pm__First_Name__c
, litify_pm__Client__r.Middle_Name__c
, litify_pm__Client__r.litify_pm__Last_Name__c
, litify_pm__Client__r.Suffix__c
, litify_pm__Client__r.litify_pm__Phone_Mobile__c
, litify_pm__Client__r.litify_pm__Phone_Home__c
, litify_pm__Client__r.litify_pm__Email__c
, litify_pm__Client__r.litify_pm__Social_Security_Number__c
, litify_pm__Client__r.litify_pm__Date_of_birth__c
, litify_pm__Client__r.litify_pm__Gender__c
, litify_pm__Client__r.Marital_Status__c

, (SELECT
First_Name__c
, Middle_Name__c
, Last_Name__c
, Suffix__c
, Social_Security_Number__c
, Date_Of_Birth__c
, Gender__c
, Is_Deceased__c
, Date_Of_Death__c
, State_Of_Death__c
, Estate_Has_Been_Opened__c
, Estate_Is_Currently_Open__c
, Client_Is_Representative_Of_Estate__c
, Client_Is_Executor_Of_Will__c
, (SELECT Id
, Fx_Street_1__c
, Fx_Street_2__c
, Client_Address__City__s
, Client_Address__StateCode__s
, Client_Address__PostalCode__s
, Is_Mailing__c
, Is_Residence__c
FROM Addresses__r)
FROM Injured_Parties__r)

, (SELECT
First_Name__c
, Last_Name__c
, Suffix__c
, Phone__c
, Relationship__c
FROM Emergency_Contacts__r)

, (SELECT
Start_Date__c
, End_Date__c
, Exposure_Is_Ongoing__c
, Exposure_Has_Stopped__c
, Exposure_State__c
, Residence_State_During_Exposure__c
, Hours_Per_Use__c
, Uses_Per_Year__c
, Total_Exposure_Years__c
, Exposure_Area__c
, Purchase_Location__c
, Application_Method__c
, Used_Product_At_Home__c
, Used_Product_At_Work__c
, IP_Purchased_Product__c
, Used_Protective_Gear__c
, Protective_Gear_Description__c
, Street_1__c
, Street_2__c
, Exposure_Location_Address__City__s
, Exposure_Location_Address__StateCode__s
, Exposure_Location_Address__PostalCode__s
, Location_Type__c
, Exposure_Location_Information__c
, Property_Owner__c
, Water_Bill__c
, Water_Well_Type__c
, Water_Test__c
, Water_Well_Tested_Date__c
, Exposure_Location_Matched__c
, Pws_Id__c
, Pws_Provider_Name__c
, Pws_Zip_Codes__c
, Pws_State__c
, Pws_Primary_Source__c
, (SELECT Id
, Zip_Code_Qualification__r.PWS_Id__c
, Zip_Code_Qualification__r.PWS_Name__c
, Zip_Code_Qualification__r.PWS_Zip_Code__c
, Zip_Code_Qualification__r.PWS_State__c
, Zip_Code_Qualification__r.PWS_Primary_Source__c
FROM Exposure_Zip_Code_Qualifications__r)
FROM Exposures__r)

, (SELECT
Type__c
, SubType__c
, Severity__c
, Diagnosis_Date__c
, State_Of_Diagnosis__c
, Residence_State_At_Diagnosis__c
, Treated_With_Surgery__c
, Surgery_Details__c
, Treated_With_Radiation__c
, Radiation_Details__c
, Treated_With_Chemotherapy__c
, Treated_With_Immunotherapy__c
, Chemotherapy_Details__c
, Years_In_Remission__c
, Remission_Check__c
FROM Injuries__r
WHERE Type__c != 'None of the Above')

, (SELECT
envExposureAgentOrange__c
, familyHxCancer__c
, familyHxNHL__c
, hxImmunosuppressantDrugs__c
, hxOrganTransplant__c
, hxTobaccoCurrent__c
, hxTobaccoFormer__c
, priorDxCancer__c
, priorDxDiabetes__c
, priorDxEbsteinBarr__c
, priorDxHepatitis__c
, priorDxHIVorAIDS__c
, priorEnvExposureSuperfundToxicSite__c
, priorHxBreastImplants__c
, Tested_Blood__c
, Test_Blood_Details__c
, Kidney_Transplant_Prior_To_Dx__c
FROM Alternative_Cause_Details__r)

, (SELECT
Business_CompoundAddress__Street__s
, Business_CompoundAddress__City__s
, Business_CompoundAddress__StateCode__s
, Business_CompoundAddress__PostalCode__s
, Facility_Type__c
, Procedure__c
, Start_Date__c
, End_Date__c
, Name_of_Location__c
, Primary_Phone__c
, National_Provider_Identifier_Number__c
, (SELECT 
Title__c
, First_Name__c
, Last_Name__c
, National_Provider_Identifier_Number__c
FROM Providers__r)
FROM Case_Locations__r)

, litify_pm__Case_Type__r.Name
, Is_your_loved_one_still_living__c
, Calling_on_behalf_of_you_or_loved_one__c
FROM litify_pm__Intake__c
WHERE Id = :intakeId
LIMIT 1];

        if(intakes != null && intakes.size() > 0) {
            litify_pm__Intake__c intake = intakes[0];
            matterRequest.dateClientFirstSawAdvertising = String.valueOf(intake.Date_Client_First_Saw_Advertising__c);
            matterRequest.clientDiscoveredCauseFromAdvertising = intake.Client_Discovered_Cause_From_Advertising__c;
            matterRequest.integratorMatterId = testMode ? intake.FX_Id__c + '-' + String.valueOf(saltIdTestmode) : intake.FX_Id__c;
            matterRequest.matterIsQualified = intake.FX_Qualified__c == 'QUALIFIED' ? 'Yes' : 'No';
            matterRequest.campaign = intake.Campaign__r.Name;
            matterRequest.marketingVendor = intake.litify_pm__Source__r.Name;
            matterRequest.intakeVendor = intake.Intake_Vendor__r.Name;
            matterRequest.integrator = 'Saddle Rock';
            matterRequest.testingFlag = intake.Test_Intake__c;
            matterRequest.retainerSentDate = intake.litify_pm__Retainer_Agreement_Sent_Date__c != null ? intake.litify_pm__Retainer_Agreement_Sent_Date__c.formatGMT('yyyy-MM-dd') : null;
            matterRequest.retainedDate = intake.litify_pm__Retainer_Agreement_Signed__c != null ? intake.litify_pm__Retainer_Agreement_Signed__c.formatGMT('yyyy-MM-dd') : null;
            matterRequest.discoveryOfCauseDate = String.valueOf(intake.Discovery_Of_Cause_Date__c);
            matterRequest.howClientDiscoveredCause = intake.How_Client_Discovered_Cause__c;
            //06182025 CS update caseSummary to send Turn Down Details if dq'd, else description
            matterRequest.caseSummary = intake.FX_Qualified__c == 'DISQUALIFIED'
                ? intake.litify_pm__Turn_Down_Details__c
                : intake.litify_pm__Description__c;
            matterRequest.clientPreviouslySignedWithLawFirm = intake.Working_with_another_law_firm__c;
            matterRequest.marketingChannel = intake.Source_Name__c;

            // Client Info
            matterRequest.client = new Tekmir_Models.Client();
            matterRequest.client.firstName = intake.litify_pm__Client__r.litify_pm__First_Name__c;
            matterRequest.client.middleName = intake.litify_pm__Client__r.Middle_Name__c;
            matterRequest.client.lastName = intake.litify_pm__Client__r.litify_pm__Last_Name__c;
            //CS 06182025 Updating so suffix value is only sent if the value is NOT N/A
            matterRequest.client.suffix = intake.litify_pm__Client__r.Suffix__c == 'N/A' 
                ? '' 
                : intake.litify_pm__Client__r.Suffix__c;
            matterRequest.client.cellPhone = intake.litify_pm__Client__r.litify_pm__Phone_Mobile__c;
            matterRequest.client.homePhone = intake.litify_pm__Client__r.litify_pm__Phone_Home__c;
            matterRequest.client.primaryEmail = intake.litify_pm__Client__r.litify_pm__Email__c;

            matterRequest.client.socialSecurityNumber = intake.litify_pm__Client__r.litify_pm__Social_Security_Number__c;
            matterRequest.client.dateOfBirth = String.valueOf(intake.litify_pm__Client__r.litify_pm__Date_of_birth__c);
            matterRequest.client.gender = intake.litify_pm__Client__r.litify_pm__Gender__c;
            matterRequest.client.maritalStatus = intake.litify_pm__Client__r.Marital_Status__c;
            matterRequest.client.relationshipToInjuredParty = intake.What_is_your_relationship_to_IP_pk__c;
            matterRequest.client.isPowerOfAttorney = intake.Do_you_have_legal_POA_documents__c;
            matterRequest.client.powerOfAttorneyType = intake.Power_Of_Attorney_Type__c;

            // Client Address
            matterRequest.client.address = new List<Tekmir_Models.Address>();
            List<srlg_Address__c> clientAddresses = [SELECT Id
                                                    , Fx_Street_1__c
                                                    , Fx_Street_2__c
                                                    , Client_Address__City__s
                                                    , Client_Address__StateCode__s
                                                    , Client_Address__PostalCode__s
                                                    , Is_Mailing__c
                                                    , Is_Residence__c
                                                    FROM srlg_Address__c
                                                    WHERE Client__c = :intake.litify_pm__Client__c AND Intake__c = :intakeId];
            if(clientAddresses != null && clientAddresses.size() > 0) {
                for(srlg_Address__c srlgAddress : clientAddresses){
                    Tekmir_Models.Address address = new Tekmir_Models.Address();
                    address.street1 = srlgAddress.Fx_Street_1__c;
                    address.street2 = srlgAddress.Fx_Street_2__c;
                    address.city = srlgAddress.Client_Address__City__s;
                    address.state = srlgAddress.Client_Address__StateCode__s;
                    address.zip = srlgAddress.Client_Address__PostalCode__s;
                    address.isMailing = srlgAddress.Is_Mailing__c;
                    address.isResidence = srlgAddress.Is_Residence__c;
                    matterRequest.client.address.add(address);
                }
            }

            // Injured Party Info
            if(intake.Calling_on_behalf_of_you_or_loved_one__c == 'Loved one' && intake.Injured_Parties__r != null && intake.Injured_Parties__r.size() > 0){
                matterRequest.injuredParty = new Tekmir_Models.InjuredParty();
                srlg_Injured_Party__c injuredParty = intake.Injured_Parties__r[0]; // Assuming first injured party is the main one
                matterRequest.injuredParty.firstName = injuredParty.First_Name__c;
                matterRequest.injuredParty.middleName = injuredParty.Middle_Name__c;
                matterRequest.injuredParty.lastName = injuredParty.Last_Name__c;
                //CS 06182025 Updating so suffix value is only sent if the value is NOT N/A
                matterRequest.injuredParty.suffix = injuredParty.Suffix__c == 'N/A' 
                    ? '' 
                    : injuredParty.Suffix__c;
                matterRequest.injuredParty.socialSecurityNumber = injuredParty.Social_Security_Number__c;
                matterRequest.injuredParty.dateOfBirth = String.valueOf(injuredParty.Date_Of_Birth__c);
                matterRequest.injuredParty.gender = injuredParty.Gender__c;
                matterRequest.injuredParty.isDeceased = intake.Is_your_loved_one_still_living__c == 'Yes' ? 'No' : 'Yes';
                matterRequest.injuredParty.dateOfDeath = String.valueOf(injuredParty.Date_Of_Death__c);
                matterRequest.injuredParty.stateOfDeath = injuredParty.State_Of_Death__c;
                matterRequest.injuredParty.estateHasBeenOpened = injuredParty.Estate_Has_Been_Opened__c;
                matterRequest.injuredParty.estateIsCurrentlyOpen = injuredParty.Estate_Is_Currently_Open__c;
                matterRequest.injuredParty.clientIsRepresentativeOfEstate = injuredParty.Client_Is_Representative_Of_Estate__c;
                matterRequest.injuredParty.clientIsExecutorOfWill = injuredParty.Client_Is_Executor_Of_Will__c;
                
                // Injured Party Address
                matterRequest.injuredParty.address = new List<Tekmir_Models.Address>();
                if(injuredParty.Addresses__r != null && injuredParty.Addresses__r.size() > 0){
                    for(srlg_Address__c srlgAddress : injuredParty.Addresses__r){
                        Tekmir_Models.Address address = new Tekmir_Models.Address();
                        address.street1 = srlgAddress.Fx_Street_1__c;
                        address.street2 = srlgAddress.Fx_Street_2__c;
                        address.city = srlgAddress.Client_Address__City__s;
                        address.state = srlgAddress.Client_Address__StateCode__s;
                        address.zip = srlgAddress.Client_Address__PostalCode__s;
                        address.isMailing = srlgAddress.Is_Mailing__c;
                        address.isResidence = srlgAddress.Is_Residence__c;
                        matterRequest.injuredParty.address.add(address);
                    }
                }
            }

            // Emergency Contact Info
            matterRequest.emergencyContact = new List<Tekmir_Models.EmergencyContact>();
            if(intake.Emergency_Contacts__r != null && intake.Emergency_Contacts__r.size() > 0){
                for(srlg_Emergency_Contact__c emergencyContact : intake.Emergency_Contacts__r){
                    Tekmir_Models.EmergencyContact contact = new Tekmir_Models.EmergencyContact();
                    contact.firstName = emergencyContact.First_Name__c;
                    contact.lastName = emergencyContact.Last_Name__c;
                    //CS 06182025 Updating so suffix value is only sent if the value is NOT N/A
                    contact.suffix = emergencyContact.Suffix__c == 'N/A' 
                        ? '' 
                        : emergencyContact.Suffix__c;
                    contact.phone = emergencyContact.Phone__c;
                    contact.relationship = emergencyContact.Relationship__c;
                    matterRequest.emergencyContact.add(contact);
                }
            }

            // Exposure Info
            matterRequest.exposure = new List<Tekmir_Models.Exposure>();
            if(intake.Exposures__r != null && intake.Exposures__r.size() > 0){
                for(srlg_Exposure__c exposure : intake.Exposures__r){
                    Tekmir_Models.Exposure exp = new Tekmir_Models.Exposure();
                    exp.product = intake.litify_pm__Case_Type__r.Name;
                    exp.startDate = String.valueOf(exposure.Start_Date__c);
                    exp.endDate = String.valueOf(exposure.End_Date__c);
                    exp.exposureIsOngoing = exposure.Exposure_Is_Ongoing__c;
                    exp.exposureHasStopped = exposure.Exposure_Has_Stopped__c;
                    exp.exposureState = exposure.Exposure_State__c != null ? exposure.Exposure_State__c : exposure.Exposure_Location_Address__StateCode__s;
                    exp.residenceStateDuringExposure = exposure.Residence_State_During_Exposure__c;
                    exp.exposureDetails = new Map<String, Object>{
                        'hoursPerUse' => String.valueOf(exposure.Hours_Per_Use__c),
                        'usesPerYear' => String.valueOf(exposure.Uses_Per_Year__c),
                        'totalExposureYears' => String.valueOf(exposure.Total_Exposure_Years__c),
                        'exposureArea' => exposure.Exposure_Area__c,
                        'purchaseLocation' => exposure.Purchase_Location__c,
                        'applicationMethod' => exposure.Application_Method__c,
                        'usedProductAtHome' => exposure.Used_Product_At_Home__c,
                        'usedProductAtWork' => exposure.Used_Product_At_Work__c,
                        'ipPurchasedProduct' => exposure.IP_Purchased_Product__c,
                        'usedProtectiveGear' => exposure.Used_Protective_Gear__c,
                        'protectiveGearDescription' => exposure.Protective_Gear_Description__c,
                        'exposureLocationType' => exposure.Location_Type__c,
                        'exposureLocationInformation' => exposure.Exposure_Location_Information__c,
                        'ipWasPropertyOwner' => exposure.Property_Owner__c,
                        'clientHasWaterBill' => exposure.Water_Bill__c,
                        'waterWellType' => exposure.Water_Well_Type__c,
                        'waterWellWasTestedForPFAS' => exposure.Water_Test__c,
                        'waterWellTestedDate' => exposure.Water_Well_Tested_Date__c,
                        'exposureLocationMatchedPws' => exposure.Exposure_Location_Matched__c,
                        'address' => new Map<string,object> {
                            'street1' => exposure.Street_1__c,
                            'street2' => exposure.Street_2__c,
                            'city' => exposure.Exposure_Location_Address__City__s,
                            'state' => exposure.Exposure_Location_Address__StateCode__s,
                            'zip' => exposure.Exposure_Location_Address__PostalCode__s
                        }
                    };
                    if(exposure.Exposure_Zip_Code_Qualifications__r != null && exposure.Exposure_Zip_Code_Qualifications__r.size() > 0) {
                        List<Map<String, Object>> exposurePws = new List<Map<String, Object>>();
                        for(Exposure_Zip_Code_Qualification__c zipQual : exposure.Exposure_Zip_Code_Qualifications__r) {
                            exposurePws.add(new Map<String, Object>{
                                'id' => zipQual.Zip_Code_Qualification__r.PWS_Id__c,
                                'name' => zipQual.Zip_Code_Qualification__r.PWS_Name__c,
                                'zipCodes' => zipQual.Zip_Code_Qualification__r.PWS_Zip_Code__c,
                                'state' => zipQual.Zip_Code_Qualification__r.PWS_State__c,
                                'primarySource' => zipQual.Zip_Code_Qualification__r.PWS_Primary_Source__c
                            });
                        }
                        exp.exposureDetails.put('pwsData', exposurePws);
                    }

                    matterRequest.exposure.add(exp);
                }
            }

            // Injury Info
            matterRequest.injury = new List<Tekmir_Models.Injury>();
            if(intake.Injuries__r != null && intake.Injuries__r.size() > 0){
                for(srlg_Injury__c injury : intake.Injuries__r){
                    Tekmir_Models.Injury inj = new Tekmir_Models.Injury();
                    inj.type = injury.Type__c;
                    inj.subType = injury.SubType__c;
                    inj.severity = injury.Severity__c;
                    inj.isDiagnosed = 'Yes';
                    inj.diagnosisDate = String.valueOf(injury.Diagnosis_Date__c);
                    inj.stateOfDiagnosis = injury.State_Of_Diagnosis__c;
                    inj.residenceStateAtDiagnosis = injury.Residence_State_At_Diagnosis__c;
                    inj.injuryDetails = new Map<String, Object>{
                        'treatedWithSurgery' => injury.Treated_With_Surgery__c,
                        'surgeryDetails' => injury.Surgery_Details__c,
                        'treatedWithRadiation' => injury.Treated_With_Radiation__c,
                        'radiationDetails' => injury.Radiation_Details__c,
                        'treatedWithChemotherapy' => injury.Treated_With_Chemotherapy__c,
                        'treatedWithImmunotherapy' => injury.Treated_With_Immunotherapy__c,
                        'chemotherapyDetails' => injury.Chemotherapy_Details__c,                        
                        'yearsInRemission' => injury.Years_In_Remission__c,
                        'isInRemission' => injury.Remission_Check__c
                    };
                    matterRequest.injury.add(inj);
                }
            }

            // Alternative Cause Details
            if(intake.Alternative_Cause_Details__r != null && intake.Alternative_Cause_Details__r.size() > 0) {
                srlg_Alternative_Cause_Detail__c altCauseDetail = intake.Alternative_Cause_Details__r[0]; // Assuming first alternative cause detail is the main one
                matterRequest.alternativeCauseDetails = new Map<String, Object>{
                    'testedBloodForPfas' => altCauseDetail.Tested_Blood__c,
                    'testedBloodForPfasDetails' => altCauseDetail.Test_Blood_Details__c,
                    'envExposureAgentOrange' => altCauseDetail.envExposureAgentOrange__c,
                    'familyHxCancer' => altCauseDetail.familyHxCancer__c,
                    'familyHxNHL' => altCauseDetail.familyHxNHL__c,
                    'hxImmunosuppressantDrugs' => altCauseDetail.hxImmunosuppressantDrugs__c,
                    'hxOrganTransplant' => altCauseDetail.hxOrganTransplant__c,
                    'hxTobaccoCurrent' => altCauseDetail.hxTobaccoCurrent__c,
                    'hxTobaccoFormer' => altCauseDetail.hxTobaccoFormer__c,
                    'priorDxCancer' => altCauseDetail.priorDxCancer__c,
                    'priorDxDiabetes' => altCauseDetail.priorDxDiabetes__c,
                    'priorDxEbsteinBarr' => altCauseDetail.priorDxEbsteinBarr__c,
                    'priorDxHepatitis' => altCauseDetail.priorDxHepatitis__c,
                    'priorDxHIVorAIDS' => altCauseDetail.priorDxHIVorAIDS__c,
                    'priorEnvExposureSuperfundToxicSite' => altCauseDetail.priorEnvExposureSuperfundToxicSite__c,
                    'priorHxBreastImplants' => altCauseDetail.priorHxBreastImplants__c,
                    //06182025 CS adding new element for kidney transplant
                    'priorHxKidneyTransplant' => altCauseDetail.Kidney_Transplant_Prior_To_Dx__c
                };
            }

            // Medical Facility Info
            matterRequest.medicalFacility = new List<Tekmir_Models.MedicalFacility>();
            if(intake.Case_Locations__r != null && intake.Case_Locations__r.size() > 0) {
                for(CM_Location__c location : intake.Case_Locations__r){
                    Tekmir_Models.MedicalFacility facility = new Tekmir_Models.MedicalFacility();
                    facility.address = location.Business_CompoundAddress__Street__s;
                    facility.city = location.Business_CompoundAddress__City__s;
                    facility.state = location.Business_CompoundAddress__StateCode__s;
                    facility.zip = location.Business_CompoundAddress__PostalCode__s;
                    facility.facilityType = location.Facility_Type__c;
                    //CS 06182025 - removing procedure from MedFacility payload
                    //facility.procedure = location.Procedure__c;
                    facility.nationalProviderId = location.National_Provider_Identifier_Number__c;
                    facility.startDate = String.valueOf(location.Start_Date__c);
                    facility.endDate = String.valueOf(location.End_Date__c);
                    facility.name = location.Name_of_Location__c;
                    facility.phone = location.Primary_Phone__c;

                    facility.providers = new List<Tekmir_Models.MedicalFacilityProvider>();
                    for(srlg_Provider__c provider : location.Providers__r) {
                        Tekmir_Models.MedicalFacilityProvider mfProvider = new Tekmir_Models.MedicalFacilityProvider();
                        mfProvider.title = provider.Title__c;
                        mfProvider.firstName = provider.First_Name__c;
                        mfProvider.lastName = provider.Last_Name__c;
                        mfProvider.nationalProviderId = provider.National_Provider_Identifier_Number__c;
                        facility.providers.add(mfProvider);
                    }
                    matterRequest.medicalFacility.add(facility);
                }
            }
        }
        
        return matterRequest;
    }
}