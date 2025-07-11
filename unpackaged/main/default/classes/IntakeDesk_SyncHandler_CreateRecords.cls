//Created by Scott Purcell 3/24/25

// Updated by Duyen Doan 6/2/2025
// - Update Intake Desk incoming request model to match the new structure
// - Update response data model. Returning the original request plus intake ID instead.
public class IntakeDesk_SyncHandler_CreateRecords {
    public static String intakeId 	{get;set;}
    public static Id partyId 	{get;set;}
    public static brioapi__Integration_Transaction__c transLog {get;set;}
    
    public static List<brioapi__Integration__mdt> getIntegrations(String integrationId){
        Id partyId;
        List<brioapi__Integration__mdt> integrations = new List<brioapi__Integration__mdt>();
        if(!Test.isRunningTest()){
            integrations = [SELECT Id, brioapi__Debugging__c, brioapi__Name__c FROM brioapi__Integration__mdt WHERE Id = :integrationId LIMIT 1];
        }
        else {
            brioapi__Integration__mdt test = new brioapi__Integration__mdt();
            test.brioapi__Name__c = 'intakeDesk';
            test.brioapi__Debugging__c = true;
            integrations.add(test);
        }
        return integrations;
    }
    public static brioapi__Integration_Transaction__c createIntegrationLog(List<brioapi__Integration__mdt> integrations,String rawData){
        brioapi__Integration_Transaction__c transLog = new brioapi__Integration_Transaction__c();
        transLog.Name = 'IntakeDesk_NewMatterWebhook';
        transLog.brioapi__Status__c = 'INFO';
        transLog.brioapi__Request__c = JSON.serializePretty((Map<String, Object>) JSON.deserializeUntyped(rawData));
        IntegrationTransactionJsonFormatter.parseJsonAndFormat(transLog,rawData);
        //system.debug('transLog.rawData : '+rawData );
        if(integrations.size()>0)transLog.brioapi__Vendor__c = integrations[0].brioapi__Name__c;
        return transLog;
    }
    public static void createCampaignCase(IntakeDesk_Models.NewMatterRequest requestPayload){
        List<Campaign_Case__c> newCampaignCases = new List<Campaign_Case__c>();
            if(requestPayload.exposure != null && !requestPayload.exposure.isEmpty()){
                for(IntakeDesk_Models.Exposure expo : requestPayload.exposure){
                    Campaign_Case__c newCampaignCase = new Campaign_Case__c();
                    newCampaignCase.Intake__c = intakeId;
                    newCampaignCase.Date_of_First_Exposure__c = expo.startDate != null && expo.startDate != '' ? Date.valueOf(expo.startDate) : null;
                    newCampaignCase.Date_of_Last_Exposure__c = expo.endDate != null && expo.endDate != '' ? Date.valueOf(expo.endDate) : null;
                    newCampaignCase.State_Exposure_Occurred__c = IntakeDesk_Helpers.validateState(expo.exposureState);
                    newCampaignCase.State_of_Residency_During_Occurrence__c = IntakeDesk_Helpers.validateState(expo.residenceStateDuringExposure);
                    newCampaignCases.add(newCampaignCase);
                }
            }
        insert newCampaignCases;
        system.debug('newCampaignCases: '+newCampaignCases);
    }
    public static litify_pm__Intake__c createIntake(IntakeDesk_Models.NewMatterRequest requestPayload){
        litify_pm__Intake__c newIntake = new litify_pm__Intake__c();
        newIntake.litify_pm__Client__c = partyId;
        system.debug('partyId: '+partyId);
        if(requestPayload.retainerSentDate != null)newIntake.litify_pm__Retainer_Agreement_Sent_Date__c = IntakeDesk_Helpers.convertDateOnlyStringToDateTimeInGMT(requestPayload.retainerSentDate);
        if(requestPayload.retainedDate != null)newIntake.litify_pm__Retainer_Agreement_Signed__c = IntakeDesk_Helpers.convertDateOnlyStringToDateTimeInGMT(requestPayload.retainedDate);
        if(requestPayload.discoveryOfCauseDate != null)newIntake.Discovery_Of_Cause_Date__c = Date.valueOf(requestPayload.discoveryOfCauseDate);
        if(requestPayload.howClientDiscoveredCause != null)newIntake.How_Client_Discovered_Cause__c = requestPayload.howClientDiscoveredCause;
        if(requestPayload.caseSummary != null)newIntake.litify_pm__Description__c = requestPayload.caseSummary; 
        if(requestPayload.clientPreviouslySignedWithLawFirm != null)newIntake.Working_with_another_law_firm__c = requestPayload.clientPreviouslySignedWithLawFirm;
        //06262025 CS fix to address dateClientFirstSawAdvertising being sent as a blank string
        if (requestPayload.dateClientFirstSawAdvertising != null && requestPayload.dateClientFirstSawAdvertising != '')
            newIntake.Date_Client_First_Saw_Advertising__c = Date.valueOf(requestPayload.dateClientFirstSawAdvertising);
        if(requestPayload.clientDiscoveredCauseFromAdvertising != null)newIntake.Client_Discovered_Cause_From_Advertising__c = requestPayload.clientDiscoveredCauseFromAdvertising; 
        if(requestPayload.integratorMatterId != null)newIntake.integratorMatterId__c  = requestPayload.integratorMatterId; 
        if(requestPayload.matterIsQualified != null)newIntake.Intake_Desk_Qualified__c = requestPayload.matterIsQualified; 
        newIntake.Campaign__c = IntakeDesk_Helpers.getCampaignId(requestPayload.campaign); 
        newIntake.litify_pm__Case_Type__c = IntakeDesk_Helpers.getCaseTypeId(requestPayload.campaign); 
        newIntake.Marketing_Partner__c = requestPayload.marketingVendor; 
        newIntake.Intake_Vendor__c = IntakeDesk_Helpers.getIntakeVendorId(requestPayload.intakeVendor); 
        if(newIntake.Intake_Vendor__c == null && requestPayload.integrator != null)newIntake.Intake_Vendor__c = IntakeDesk_Helpers.getIntakeVendorId(requestPayload.integrator); 
        if(requestPayload.testingFlag == 'Yes'){newIntake.Test_Intake__c = true;}else{newIntake.Test_Intake__c = false;} 
        if(requestPayload.intakeVendor == 'Intake Desk')newIntake.litify_pm__Status__c = 'Referred Out';
        if(requestPayload.marketingChannel != null)newIntake.Source_Name__c = requestPayload.marketingChannel;
        if(requestPayload.client.relationshipToInjuredParty != null)newIntake.What_is_your_relationship_to_IP_pk__c = requestPayload.client.relationshipToInjuredParty;
        
        // Check for duplicate legacy(old architecture) intakes
        IntakeDesk_Helpers.intakeDuplicateCheckerLegacy(newIntake,false);
        system.debug('Intake: '+newIntake);
        return newIntake;
    }
    public static void createParty(IntakeDesk_Models.NewMatterRequest requestPayload){
        Account newAcct = new Account();
        intakeId = '';
            if(requestPayload.client != null && requestPayload.client.lastName != null){
                List<string> nameParts = new List<string>();
                if(requestPayload.client.firstName != null && requestPayload.client.firstName != '')nameParts.add(requestPayload.client.firstName);
                if(requestPayload.client.middleName != null && requestPayload.client.middleName != '')nameParts.add(requestPayload.client.middleName);
                if(requestPayload.client.lastName != null && requestPayload.client.lastName != '')nameParts.add(requestPayload.client.lastName);
                if(requestPayload.client.firstName != null)newAcct.litify_pm__First_Name__c = requestPayload.client.firstName;
                if(requestPayload.client.middleName != null)newAcct.Middle_Name__c = requestPayload.client.middleName;
                if(requestPayload.client.lastName != null)newAcct.litify_pm__Last_Name__c = requestPayload.client.lastName;
                newAcct.Name = String.join(nameParts, ' ');
                if(requestPayload.client.suffix != null)newAcct.Suffix__c = IntakeDesk_Helpers.validateSuffix(requestPayload.client.suffix);
                if(requestPayload.client.socialSecurityNumber != null)newAcct.litify_pm__Social_Security_Number__c = requestPayload.client.socialSecurityNumber;
                if(requestPayload.client.dateOfBirth != null)newAcct.litify_pm__Date_of_birth__c = requestPayload.client.dateOfBirth != null && requestPayload.client.dateOfBirth != '' ? Date.valueOf(requestPayload.client.dateOfBirth) : null;
                if(requestPayload.client.gender != null)newAcct.litify_pm__Gender__c = IntakeDesk_Helpers.validateGender(requestPayload.client.gender);
                if(requestPayload.client.maritalStatus != null)newAcct.Marital_Status__c = IntakeDesk_Helpers.validateMaritalStatusParty(requestPayload.client.maritalStatus);
                if(requestPayload.client.notes != null)newAcct.Description = requestPayload.client.notes;
                if(requestPayload.client.primaryEmail != null)newAcct.litify_pm__Email__c = requestPayload.client.primaryEmail;
                if(requestPayload.client.cellPhone != null)newAcct.litify_pm__Phone_Mobile__c = requestPayload.client.cellPhone;
                if(requestPayload.client.homePhone != null)newAcct.litify_pm__Phone_Home__c = requestPayload.client.homePhone;
                if(requestPayload.client.bestContactTime != null)newAcct.Best_time_to_reach_client__c = requestPayload.client.bestContactTime;
                if(requestPayload.client.languagePreference != null)newAcct.language_Preference__c = requestPayload.client.languagePreference;
                if(requestPayload.client.notes != null)newAcct.Notes__c = requestPayload.client.notes;
                if(requestPayload.client.isPowerOfAttorney != null)newAcct.isPowerOfAttorney__c = requestPayload.client.isPowerOfAttorney;
                if(requestPayload.client.powerOfAttorneyType != null)newAcct.powerOfAttorneyType__c = requestPayload.client.powerOfAttorneyType;
                insert newAcct;
                partyId = newAcct.Id;
            }
        createAddress(requestPayload.client.address,partyId,'Party');
       system.debug('Party/CLient: '+newAcct);
    }

    public static void createAddress(List<IntakeDesk_Models.Address> addresses,Id parentRecordId,String parentRecordType){
        List<srlg_Address__c>adrList = new List<srlg_Address__c>();
        if(addresses.size()>0){
            for(IntakeDesk_Models.Address addr: addresses){
                srlg_Address__c adr = new srlg_Address__c();
                if(addr.street1 != null)adr.Client_Address__Street__s = addr.street1; 
                if(addr.street2 != null)adr.Client_Address__Street__s += '\r\n' + addr.street2; 
                if(addr.city != null)adr.Client_Address__City__s = addr.city; 
                if(addr.zip != null)adr.Client_Address__PostalCode__s = addr.zip;
                if(addr.state != null)adr.Client_Address__StateCode__s = addr.state;
                if(addr.isMailing != null)adr.Is_Mailing__c = addr.isMailing;
                if(addr.isResidence != null)adr.Is_Residence__c = addr.isResidence;
                if(intakeId != null && intakeId != '')adr.Intake__c = intakeId;
                if(parentRecordType == 'Party')adr.Client__c = parentRecordId;
                else if(parentRecordType == 'Exposure')adr.Exposure__c = parentRecordId;
                else if(parentRecordType == 'Intake')adr.Intake__c = parentRecordId;
                else if(parentRecordType == 'Location')adr.Location__c = parentRecordId;
                else if(parentRecordType == 'InjuredParty')adr.Injured_Party__c = parentRecordId;
                adrList.add(adr);
            }
            insert adrList;
        }
        system.debug('Addresses: '+adrList);
    }
    public static String createInjuredParty(IntakeDesk_Models.NewMatterRequest requestPayload){
        srlg_Injured_Party__c  iParty = new srlg_Injured_Party__c();
        
        system.debug('injured party: '+requestPayload.injuredParty);
        if(requestPayload.injuredParty != null && requestPayload.injuredParty.firstName != null){
            iParty.First_Name__c = requestPayload.injuredParty.firstName;
            if(requestPayload.injuredParty.middleName != null)iParty.Middle_Name__c = requestPayload.injuredParty.middleName;
            if(requestPayload.injuredParty.lastName != null)iParty.Last_Name__c = requestPayload.injuredParty.lastName;
            if(requestPayload.injuredParty.suffix != null)iParty.Suffix__c = IntakeDesk_Helpers.validateSuffix(requestPayload.injuredParty.suffix);
            if(requestPayload.injuredParty.socialSecurityNumber != null)iParty.Social_Security_Number__c = requestPayload.injuredParty.socialSecurityNumber;
            if(requestPayload.injuredParty.dateOfBirth != null)iParty.Date_Of_Birth__c = Date.valueOf(requestPayload.injuredParty.dateOfBirth);
            if(requestPayload.injuredParty.gender != null)iParty.Gender__c = requestPayload.injuredParty.gender;
            if(requestPayload.injuredParty.maritalStatus != null)iParty.Marital_Status__c = requestPayload.injuredParty.maritalStatus;
            if(requestPayload.injuredParty.notes != null)iParty.Notes__c = requestPayload.injuredParty.notes;
            if(requestPayload.injuredParty.email != null)iParty.Email__c = requestPayload.injuredParty.email;
            if(requestPayload.injuredParty.isDeceased != null)iParty.Is_Deceased__c = requestPayload.injuredParty.isDeceased;
            if(requestPayload.injuredParty.dateOfDeath != null)iParty.Date_Of_Death__c = Date.valueOf(requestPayload.injuredParty.dateOfDeath);
            if(requestPayload.injuredParty.causeOfDeath != null)iParty.Cause_Of_Death__c = requestPayload.injuredParty.causeOfDeath;
            if(requestPayload.injuredParty.stateOfDeath != null)iParty.State_Of_Death__c = requestPayload.injuredParty.stateOfDeath;
            if(requestPayload.injuredParty.estateHasBeenOpened != null)iParty.Estate_Has_Been_Opened__c = requestPayload.injuredParty.estateHasBeenOpened;
            if(requestPayload.injuredParty.estateIsCurrentlyOpen != null)iParty.Estate_is_Currently_Open__c = requestPayload.injuredParty.estateIsCurrentlyOpen;
            if(requestPayload.injuredParty.clientIsRepresentativeOfEstate != null)iParty.Client_Is_Representative_Of_Estate__c = requestPayload.injuredParty.clientIsRepresentativeOfEstate;
            if(requestPayload.injuredParty.clientIsExecutorOfWill != null)iParty.Client_Is_Executor_Of_Will__c = requestPayload.injuredParty.clientIsExecutorOfWill;
            if(requestPayload.injuredParty.namedInformant != null)iParty.Named_Informant__c = requestPayload.injuredParty.namedInformant;

            if(intakeId != null && intakeId != '')iParty.Intake__c = intakeId;


            insert iParty;

            if(requestPayload.injuredParty.address != null && requestPayload.injuredParty.address.size() > 0){                
                createAddress(requestPayload.injuredParty.address,iParty.Id,'InjuredParty');
            }

            return iParty.Id;
        }
        system.debug('Injured Party: '+iParty);
        return '';
    }
    public static void createEmergencyContact(IntakeDesk_Models.NewMatterRequest requestPayload){
        List<srlg_Emergency_Contact__c> eContacts = new List<srlg_Emergency_Contact__c>();
        //List<IntakeDesk_Models.EmergencyContact> emergencyContacts = new List<IntakeDesk_Models.EmergencyContact>();
        for(IntakeDesk_Models.EmergencyContact eCon:requestPayload.emergencyContact){
            srlg_Emergency_Contact__c newEcon = new srlg_Emergency_Contact__c();
            if(intakeId != null)newEcon.Intake__c = intakeId;
          	if(eCon.firstName != null)newEcon.First_Name__c = eCon.firstName; 
            if(eCon.lastName != null)newEcon.Last_Name__c = eCon.lastName; 
            if(eCon.suffix != null)newEcon.Suffix__c = IntakeDesk_Helpers.validateSuffix(eCon.suffix);
            if(eCon.phone != null)newEcon.Phone__c = eCon.phone; 
			if(eCon.relationship != null)newEcon.Relationship__c = eCon.relationship;
            if(newEcon.First_Name__c != null)econtacts.add(newEcon);
        }
        insert econtacts;
        system.debug('emergency contacts: '+econtacts);
    }
    public static void createExposure(IntakeDesk_Models.NewMatterRequest requestPayload){
        // Handle PWS data first
        Map<String, IntakeDesk_Models.PwsData> intakeDeskPwsData = new Map<String, IntakeDesk_Models.PwsData>();
        Map<String, Id> sfPwsIdMap = new Map<String, Id>();
        List<Zip_Code_Qualification__c> newPwsList = new List<Zip_Code_Qualification__c>();
        for(IntakeDesk_Models.Exposure exp: requestPayload.exposure){
            if(exp.exposureDetails.pwsData != null && exp.exposureDetails.pwsData.size() > 0){
                for(IntakeDesk_Models.PwsData pwsData : exp.exposureDetails.pwsData){
                    intakeDeskPwsData.put(pwsData.id, pwsData);
                }                
            }
        }
        if(intakeDeskPwsData != null && intakeDeskPwsData.keySet().size() > 0){
            List<Zip_Code_Qualification__c> sfPWS = [SELECT Id, PWS_Id__c FROM Zip_Code_Qualification__c WHERE PWS_Id__c IN :intakeDeskPwsData.keySet()];
            for(Zip_Code_Qualification__c pws : sfPWS){
                sfPwsIdMap.put(pws.PWS_Id__c, pws.Id);
            }
            for(IntakeDesk_Models.Exposure exp: requestPayload.exposure){
                if(exp.exposureDetails.pwsData != null && exp.exposureDetails.pwsData.size() > 0){
                    for(IntakeDesk_Models.PwsData pwsData : exp.exposureDetails.pwsData){
                        if(!sfPwsIdMap.containsKey(pwsData.id)){
                            Zip_Code_Qualification__c newPws = new Zip_Code_Qualification__c();
                            newPws.PWS_Id__c = pwsData.id;
                            newPws.PWS_Name__c = pwsData.name;
                            newPws.PWS_Zip_Code__c = pwsData.zipCodes;
                            newPws.PWS_State__c = pwsData.state;
                            newPws.PWS_Primary_Source__c = pwsData.primarySource;
                            newPwsList.add(newPws);
                            sfPwsIdMap.put(pwsData.id, null);
                            intakeDeskPwsData.put(pwsData.id, pwsData);
                        }
                    }
                }
            }

            if(newPwsList.size() > 0){
                insert newPwsList;
                List<Zip_Code_Qualification__c> sfPWSIncludingNew = [SELECT Id, PWS_Id__c FROM Zip_Code_Qualification__c WHERE PWS_Id__c IN :intakeDeskPwsData.keySet()];
                for(Zip_Code_Qualification__c pws : sfPWSIncludingNew){
                    sfPwsIdMap.put(pws.PWS_Id__c, pws.Id);
                }
            }
        }

        // Create exposures
        List<srlg_Exposure__c>exposures = new List<srlg_Exposure__c>();
        //List<IntakeDesk_Models.Exposure> exposure = new List<IntakeDesk_Models.Exposure>();
        List<List<Exposure_Zip_Code_Qualification__c>> exposureZipQualsList = new List<List<Exposure_Zip_Code_Qualification__c>>();
        for(IntakeDesk_Models.Exposure exp: requestPayload.exposure){
          	if(exp.startDate != null){
                srlg_Exposure__c newExp = new srlg_Exposure__c();
                newExp.Intake__c = intakeId;
                newExp.Start_Date__c = Date.valueOf(exp.startDate);
                if(exp.endDate != null)newExp.End_Date__c = Date.valueOf(exp.endDate); 
                if(exp.exposureState != null){
                    newExp.Exposure_State__c = exp.exposureState;
                    newExp.Exposure_Location_Address__StateCode__s = exp.exposureState;
                }
                if(exp.exposureIsOngoing != null)newExp.Exposure_Is_Ongoing__c = exp.exposureIsOngoing; 
                if(exp.exposureHasStopped != null)newExp.Exposure_Has_Stopped__c = exp.exposureHasStopped; 
                if(exp.residenceStateDuringExposure != null)newExp.Residence_State_During_Exposure__c = exp.residenceStateDuringExposure; 
                if(exp.exposureDetails.usedProductAtWork != null)newExp.Used_Product_At_Work__c = exp.exposureDetails.usedProductAtWork;
                if(exp.exposureDetails.usedProductAtHome != null)newExp.Used_Product_At_Home__c = exp.exposureDetails.usedProductAtHome; 
                if(exp.exposureDetails.exposureArea != null)newExp.Exposure_Area__c = exp.exposureDetails.exposureArea; 
                if(exp.exposureDetails.applicationMethod != null)newExp.Application_Method__c = exp.exposureDetails.applicationMethod; 
                if(exp.exposureDetails.totalExposureYears != null)newExp.Total_Exposure_Years__c = Double.valueOf(exp.exposureDetails.totalExposureYears); 
                if(exp.exposureDetails.usesPerYear != null)newExp.Uses_Per_Year__c = Double.valueOf(exp.exposureDetails.usesPerYear); 
                if(exp.exposureDetails.hoursPerUse != null)newExp.Hours_Per_Use__c = Double.valueOf(exp.exposureDetails.hoursPerUse); 
                if(exp.exposureDetails.usedProtectiveGear != null)newExp.Used_Protective_Gear__c = exp.exposureDetails.usedProtectiveGear; 
                if(exp.exposureDetails.protectiveGearDescription != null)newExp.Protective_Gear_Description__c = exp.exposureDetails.protectiveGearDescription; 
                if(exp.exposureDetails.ipPurchasedProduct != null)newExp.Ip_Purchased_Product__c = exp.exposureDetails.ipPurchasedProduct; 
                if(exp.exposureDetails.clientHasProductContainer != null)newExp.Client_Has_Product_Container__c = exp.exposureDetails.clientHasProductContainer; 
                if(exp.exposureDetails.clientHasPhotoOfUsage != null)newExp.Client_Has_Photo_of_Usage__c = exp.exposureDetails.clientHasPhotoOfUsage; 
                if(exp.exposureDetails.clientHasPurchaseReceipts != null)newExp.Client_Has_Purchase_Receipts__c = exp.exposureDetails.clientHasPurchaseReceipts; 
                if(exp.exposureDetails.productContainerSize != null)newExp.Product_Container_Size__c = exp.exposureDetails.productContainerSize; 
                //newExp.Purchase_Location__c = exp.exposureDetails.purchaseLocation; 
                if(exp.exposureDetails.notes != null)newExp.Notes__c = exp.exposureDetails.notes;
                if(exp.exposureDetails.exposureLocationType != null)newExp.Location_Type__c = exp.exposureDetails.exposureLocationType;
                if(exp.exposureDetails.exposureLocationInformation != null)newExp.Exposure_Location_Information__c = exp.exposureDetails.exposureLocationInformation;
                if(exp.exposureDetails.ipWasPropertyOwner != null)newExp.Property_Owner__c = exp.exposureDetails.ipWasPropertyOwner;
                if(exp.exposureDetails.clientHasWaterBill != null)newExp.Water_Bill__c = exp.exposureDetails.clientHasWaterBill;
                if(exp.exposureDetails.waterWellType != null)newExp.Water_Well_Type__c = exp.exposureDetails.waterWellType;
                if(exp.exposureDetails.waterWellWasTestedForPFAS != null)newExp.Water_Test__c = exp.exposureDetails.waterWellWasTestedForPFAS;
                if(exp.exposureDetails.waterWellTestedDate != null)newExp.Water_Well_Tested_Date__c = Date.valueOf(exp.exposureDetails.waterWellTestedDate);
                if(exp.exposureDetails.exposureLocationMatchedPws != null)newExp.Exposure_Location_Matched__c = exp.exposureDetails.exposureLocationMatchedPws;
                // 06302025 CS Adding alternate mapping for Exposure_Location_Matched__c
                if(exp.exposureDetails.locationMatchedPWS != null)newExp.Exposure_Location_Matched__c = exp.exposureDetails.locationMatchedPWS;
                // 06232025 CS Update to set Case Type Routing on exposure
                if (requestPayload.campaign == 'PFAS') {
                    newExp.Case_Type_Routing__c = 'PFAS';
                } else if (requestPayload.campaign == 'Round Up' || requestPayload.campaign == 'Roundup') {
                    newExp.Case_Type_Routing__c = 'Round Up';
                }
                if(exp.exposureDetails.address.street1 != null)newExp.Exposure_Location_Address__Street__s = exp.exposureDetails.address.street1; 
                if(exp.exposureDetails.address.street2 != null)newExp.Exposure_Location_Address__Street__s += '\r\n' + exp.exposureDetails.address.street2; 
                if(exp.exposureDetails.address.city != null)newExp.Exposure_Location_Address__City__s = exp.exposureDetails.address.city; 
                if(exp.exposureDetails.address.zip != null)newExp.Exposure_Location_Address__PostalCode__s = exp.exposureDetails.address.zip; 
                if(exp.exposureDetails.address.state != null)newExp.Exposure_Location_Address__StateCode__s = exp.exposureDetails.address.state;                

                List<Exposure_Zip_Code_Qualification__c> exposureZipQuals = new List<Exposure_Zip_Code_Qualification__c>();
                if(exp.exposureDetails.pwsData != null && exp.exposureDetails.pwsData.size() > 0){
                    for(IntakeDesk_Models.PwsData pwsData : exp.exposureDetails.pwsData){
                        Exposure_Zip_Code_Qualification__c exposQual = new Exposure_Zip_Code_Qualification__c();
                        // exposQual.Exposure__c = newExp.Id; // exposure Id will be set after exposure is inserted
                        exposQual.Zip_Code_Qualification__c = sfPwsIdMap.get(pwsData.id);
                        exposureZipQuals.add(exposQual);
                        System.debug(exposQual.Zip_Code_Qualification__c);
                    }
                    exposureZipQualsList.add(exposureZipQuals);
                }
                else {
                    exposureZipQualsList.add(null); // Add null to maintain the same index for exposureZipQualsList
                }
                exposures.add(newExp);
            }
        }
        if(exposures.size() > 0){
            List<Exposure_Zip_Code_Qualification__c> exposureZipQualsToBeCreated = new List<Exposure_Zip_Code_Qualification__c>();
            Database.SaveResult[] saveExposuresResultList = Database.insert(exposures, true);
            for (Integer i = 0; i< saveExposuresResultList.size(); i++) {
                Database.SaveResult sr = saveExposuresResultList[i];
                if(exposureZipQualsList[i] != null){
                    for(Exposure_Zip_Code_Qualification__c zipQual : exposureZipQualsList[i]){
                        zipQual.Exposure__c = sr.getId();
                        System.debug('### ' + zipQual.Zip_Code_Qualification__c);
                        exposureZipQualsToBeCreated.add(zipQual);
                    }
                }
            }
            if(exposureZipQualsToBeCreated.size() > 0){
                insert exposureZipQualsToBeCreated;
            }
        }
    }
  
    public static void createInjury(IntakeDesk_Models.NewMatterRequest requestPayload){
        List<srlg_Injury__c > injuries = new List<srlg_Injury__c >();
        system.debug('requestPayload.Injury: '+requestPayload.Injury);
        //List<IntakeDesk_Models.Injury> idInjuries = new List<IntakeDesk_Models.Injury>();
        for(IntakeDesk_Models.Injury injury : requestPayload.Injury){
            srlg_Injury__c inj = new srlg_Injury__c();
            inj.Intake__c = intakeId;
            if(injury.type != null)inj.Type__c = injury.type;
            if(injury.subType != null)inj.SubType__c = injury.subType; 
            if(injury.severity != null)inj.Severity__c = injury.severity; 
            if(injury.onsetDate != null)inj.Onset_Date__c = Date.valueOf(injury.onsetDate); 
            if(injury.isDiagnosed != null)inj.Is_Diagnosed__c = injury.isDiagnosed; 
            if(injury.diagnosisDate != null)inj.Diagnosis_Date__c = Date.valueOf(injury.diagnosisDate); 
            if(injury.stateOfDiagnosis != null)inj.State_Of_Diagnosis__c = injury.stateOfDiagnosis; 
            if(injury.residenceStateAtDiagnosis != null)inj.Residence_State_At_Diagnosis__c = injury.residenceStateAtDiagnosis;
            if(injury.injuryDetails.treatedWithChemotherapy != null)inj.Treated_With_Chemotherapy__c = injury.injuryDetails.treatedWithChemotherapy; 
            if(injury.injuryDetails.chemotherapyDetails != null)inj.Chemotherapy_Details__c = injury.injuryDetails.chemotherapyDetails;
            if(injury.injuryDetails.treatedWithRadiation != null)inj.Treated_With_Radiation__c = injury.injuryDetails.treatedWithRadiation; 
            if(injury.injuryDetails.radiationDetails != null)inj.Radiation_Details__c = injury.injuryDetails.radiationDetails; 
            if(injury.injuryDetails.treatedWithSurgery != null)inj.Treated_With_Surgery__c = injury.injuryDetails.treatedWithSurgery; 
            if(injury.injuryDetails.surgeryDetails != null)inj.Surgery_Details__c = injury.injuryDetails.surgeryDetails; 
            if(injury.injuryDetails.yearsInRemission != null)inj.Years_In_Remission__c = Double.valueOf(injury.injuryDetails.yearsInRemission);
            if(injury.injuryDetails.isInRemission != null)inj.Remission_Check__c = injury.injuryDetails.isInRemission;
            if(injury.injuryDetails.treatedWithImmunotherapy != null)inj.Treated_With_Immunotherapy__c = injury.injuryDetails.treatedWithImmunotherapy;
            // 06232025 CS Update to set Case Type Routing on injury
            if (requestPayload.campaign == 'PFAS') {
                inj.Case_Type_Routing__c = 'PFAS';
            } else if (requestPayload.campaign == 'Round Up' || requestPayload.campaign == 'Roundup') {
                inj.Case_Type_Routing__c = 'Round Up';
            }
            if(inj.Type__c != null)injuries.add(inj);
             
         }
        insert injuries;
        system.debug('injuries: '+injuries);
    }
    public static String createAlternativeCauseDetails(IntakeDesk_Models.NewMatterRequest requestPayload){
        srlg_Alternative_Cause_Detail__c acd = new srlg_Alternative_Cause_Detail__c ();
        if(requestPayload.alternativeCauseDetails.priorDxHepatitis != null)acd.priorDxHepatitis__c = requestPayload.alternativeCauseDetails.priorDxHepatitis; 
        if(requestPayload.alternativeCauseDetails.priorDxHIVorAIDS != null)acd.priorDxHIVorAIDS__c = requestPayload.alternativeCauseDetails.priorDxHIVorAIDS;
        if(requestPayload.alternativeCauseDetails.priorDxCancer != null)acd.priorDxCancer__c = requestPayload.alternativeCauseDetails.priorDxCancer; 
        if(requestPayload.alternativeCauseDetails.envExposureAgentOrange != null)acd.envExposureAgentOrange__c = requestPayload.alternativeCauseDetails.envExposureAgentOrange; 
        if(requestPayload.alternativeCauseDetails.hxOrganTransplant != null)acd.hxOrganTransplant__c = requestPayload.alternativeCauseDetails.hxOrganTransplant;
        if(requestPayload.alternativeCauseDetails.hxImmunosuppressantDrugs != null)acd.hxImmunosuppressantDrugs__c = requestPayload.alternativeCauseDetails.hxImmunosuppressantDrugs; 
        if(requestPayload.alternativeCauseDetails.receivedBenefitsForCurrentDx != null)acd.receivedBenefitsForCurrentDx__c = requestPayload.alternativeCauseDetails.receivedBenefitsForCurrentDx; 
        if(requestPayload.alternativeCauseDetails.priorEnvExposureSuperfundToxicSite != null)acd.priorEnvExposureSuperfundToxicSite__c = requestPayload.alternativeCauseDetails.priorEnvExposureSuperfundToxicSite; 
        if(requestPayload.alternativeCauseDetails.priorDxEbsteinBarr != null)acd.priorDxEbsteinBarr__c = requestPayload.alternativeCauseDetails.priorDxEbsteinBarr; 
        if(requestPayload.alternativeCauseDetails.priorDxBacterialInfection != null)acd.priorDxBacterialInfection__c = requestPayload.alternativeCauseDetails.priorDxBacterialInfection; 
        if(requestPayload.alternativeCauseDetails.priorHxBreastImplants != null)acd.priorHxBreastImplants__c = requestPayload.alternativeCauseDetails.priorHxBreastImplants; 
        if(requestPayload.alternativeCauseDetails.priorDxDiabetes != null)acd.priorDxDiabetes__c = requestPayload.alternativeCauseDetails.priorDxDiabetes; 
        if(requestPayload.alternativeCauseDetails.priorDxDiabetesDetails != null)acd.priorDxDiabetesDetails__c = requestPayload.alternativeCauseDetails.priorDxDiabetesDetails; 
        if(requestPayload.alternativeCauseDetails.hxTobaccoCurrent != null)acd.hxTobaccoCurrent__c = requestPayload.alternativeCauseDetails.hxTobaccoCurrent;
        if(requestPayload.alternativeCauseDetails.hxTobaccoFormer != null)acd.hxTobaccoFormer__c = requestPayload.alternativeCauseDetails.hxTobaccoFormer; 
        if(requestPayload.alternativeCauseDetails.hxTobaccoDetails != null)acd.hxTobaccoDetails__c = requestPayload.alternativeCauseDetails.hxTobaccoDetails; 
        if(requestPayload.alternativeCauseDetails.hxTobaccoTotalYears != null)acd.hxTobaccoTotalYears__c = requestPayload.alternativeCauseDetails.hxTobaccoTotalYears;
        if(requestPayload.alternativeCauseDetails.hxTobaccoYearsStoppedPriorToDx != null)acd.hxTobaccoYearsStoppedPriorToDx__c = requestPayload.alternativeCauseDetails.hxTobaccoYearsStoppedPriorToDx;
        if(requestPayload.alternativeCauseDetails.familyHxCancer != null)acd.familyHxCancer__c = requestPayload.alternativeCauseDetails.familyHxCancer;
        if(requestPayload.alternativeCauseDetails.familyHxCancerDetails != null)acd.familyHxCancerDetails__c = requestPayload.alternativeCauseDetails.familyHxCancerDetails; 
        if(requestPayload.alternativeCauseDetails.familyHxNHL != null)acd.familyHxNHL__c = requestPayload.alternativeCauseDetails.familyHxNHL;
        if(requestPayload.alternativeCauseDetails.dxHeightFt != null)acd.dxHeightFt__c =  Double.valueOf(requestPayload.alternativeCauseDetails.dxHeightFt);
        if(requestPayload.alternativeCauseDetails.dxHeightIn != null)acd.dxHeightIn__c = Double.valueOf(requestPayload.alternativeCauseDetails.dxHeightIn); 
        if(requestPayload.alternativeCauseDetails.dxWeight != null)acd.dxWeight__c = Double.valueOf(requestPayload.alternativeCauseDetails.dxWeight); 
        if(requestPayload.alternativeCauseDetails.dxBmi != null)acd.dxBmi__c = Double.valueOf(requestPayload.alternativeCauseDetails.dxBmi);
        if(requestPayload.alternativeCauseDetails.currentHeightFt != null)acd.currentHeightFt__c = Double.valueOf(requestPayload.alternativeCauseDetails.currentHeightFt);
        if(requestPayload.alternativeCauseDetails.currentHeightIn != null)acd.currentHeightIn__c = Double.valueOf(requestPayload.alternativeCauseDetails.currentHeightIn);
        if(requestPayload.alternativeCauseDetails.currentWeight != null)acd.currentWeight__c = Double.valueOf(requestPayload.alternativeCauseDetails.currentWeight);
        if(requestPayload.alternativeCauseDetails.currentBmi != null)acd.currentBmi__c = Double.valueOf(requestPayload.alternativeCauseDetails.currentBmi);
        if(requestPayload.alternativeCauseDetails.testedBloodForPfas != null)acd.Tested_Blood__c = requestPayload.alternativeCauseDetails.testedBloodForPfas; 
        if(requestPayload.alternativeCauseDetails.testedBloodForPfasDetails != null)acd.Test_Blood_Details__c = requestPayload.alternativeCauseDetails.testedBloodForPfasDetails;
        //CS 06192025 Adding hx kidney transplant field
        if(requestPayload.alternativeCauseDetails.priorHxKidneyTransplant != null)acd.Kidney_Transplant_Prior_To_Dx__c = requestPayload.alternativeCauseDetails.priorHxKidneyTransplant;
        // 06232025 CS Update to set Case Type Routing on exposure
        if (requestPayload.campaign == 'PFAS') {
            acd.Case_Type_Routing__c = 'PFAS';
        } else if (requestPayload.campaign == 'Round Up' || requestPayload.campaign == 'Roundup') {
            acd.Case_Type_Routing__c = 'Round Up';
        }
        
        acd.Intake__c = intakeId;
        if(requestPayload.alternativeCauseDetails != null)insert acd;
        return acd.Id;
    }
    public static void createMedicalFacility(IntakeDesk_Models.NewMatterRequest requestPayload){
        //List<IntakeDesk_Models.MedicalFacility> medicalFacility = new List<IntakeDesk_Models.MedicalFacility>();
        List<CM_Location__c> newCMLocations = new List<CM_Location__c>();
        List<List<srlg_Provider__c>> providersTempList = new List<List<srlg_Provider__c>>();

        if(requestPayload.medicalFacility != null && !requestPayload.medicalFacility.isEmpty()){
            system.debug('requestPayload.medicalFacility.size(): '+requestPayload.medicalFacility.size());
            for(IntakeDesk_Models.MedicalFacility mFacility : requestPayload.medicalFacility){
                CM_Location__c facilityLoc = new CM_Location__c();
                if(intakeId != null)facilityLoc.Intake__c = intakeId;
                if(mFacility.name != null)facilityLoc.Name = mFacility.name != null ? mFacility.name.left(80) : '';
                if(mFacility.name != null){
                    facilityLoc.Name_of_Location__c = mFacility.name;
                    newCMLocations.add(facilityLoc);
                }
                //06302025 CS Change for Facility Type. If a valid picklist value, map to picklist, if not a valid picklist value map to notes
                if(mFacility.facilityType != null) {
                    String validatedFacilityType = IntakeDesk_Helpers.validateFacilityType(mFacility.facilityType);
                    facilityLoc.Facility_Type__c = validatedFacilityType;
                    if (validatedFacilityType == 'Unknown' && mFacility.facilityType != 'Unknown') {
                        facilityLoc.Notes__c = mFacility.facilityType;
                    }
                }
                if(mFacility.procedure != null)facilityLoc.Procedure__c = mFacility.procedure;
                if(mFacility.address != null)facilityLoc.Business_CompoundAddress__Street__s = mFacility.address;
                if(mFacility.city != null)facilityLoc.Business_CompoundAddress__City__s = mFacility.city;
                if(mFacility.zip != null)facilityLoc.Business_CompoundAddress__PostalCode__s  = mFacility.zip;
                if(mFacility.state != null)facilityLoc.Business_CompoundAddress__StateCode__s = mFacility.state;
                if(mFacility.phone != null)facilityLoc.Primary_Phone__c = mFacility.phone;
                if(mFacility.startDate != null)facilityLoc.Start_Date__c = mFacility.startDate != null && mFacility.startDate != '' ? Date.valueOf(mFacility.startDate) : null;
                if(mFacility.endDate != null)facilityLoc.End_Date__c = mFacility.endDate != null && mFacility.endDate != '' ? Date.valueOf(mFacility.endDate) : null;
                //if(mFacility.notes != null)facilityLoc.Notes__c = mFacility.notes;
                if(mFacility.nationalProviderId != null)facilityLoc.National_Provider_Identifier_Number__c = mFacility.nationalProviderId;
              
                if(mFacility.providers != null && !mFacility.providers.isEmpty()){
                    List<srlg_Provider__c> relProvidersToAdd = new List<srlg_Provider__c>();
                	for(IntakeDesk_Models.MedicalFacilityProvider prov : mFacility.providers){
                        srlg_Provider__c provider = new srlg_Provider__c();
                        if(prov.title != null)provider.Title__c = prov.title;
                        if(prov.firstName != null)provider.First_Name__c = prov.firstName;
                        if(prov.lastName != null)provider.Last_Name__c = prov.lastName;
                        if(prov.type != null)provider.Type__c = prov.type; 
                        if(prov.nationalProviderId != null)provider.National_Provider_Identifier_Number__c = prov.nationalProviderId; 
                        //06232025 CS Update to set Intake lookup on Provider records
                        if(intakeId != null)provider.Intake__c = intakeId;
                        if(provider.First_Name__c != null)relProvidersToAdd.add(provider);
                    }
                    providersTempList.add(relProvidersToAdd);
                }
                else {
                    providersTempList.add(null); // Add null to maintain the same index for providersTempList
                }
            }

            List<srlg_Provider__c> providersToBeCreated = new List<srlg_Provider__c>();
            Database.SaveResult[] saveCMLocationResultList = Database.insert(newCMLocations, true);
            for (Integer i = 0; i< saveCMLocationResultList.size(); i++) {
                Database.SaveResult sr = saveCMLocationResultList[i];
                if(providersTempList[i] != null){
                    for(srlg_Provider__c provider : providersTempList[i]){
                        provider.CM_Location__c = sr.getId();
                        providersToBeCreated.add(provider);
                    }
                }
            }
            if(providersToBeCreated.size() > 0){
                insert providersToBeCreated;
            }
        }
        system.debug('newCMLocations: '+newCMLocations);
    }
}