// Updated by Duyen Doan 6/2/2025: Update Intake Desk incoming request model to match the new structure
public class IntakeDesk_Models {
    public class NewMatterRequest {
        public String integratorMatterId {get;set;}
        public String campaign {get;set;}
        public String integrator {get;set;}
        public String intakeVendor {get;set;}
        public String marketingVendor {get;set;}

        public Client client {get;set;}
        public InjuredParty injuredParty {get;set;}
        // public EmploymentHistory employmentHistory {get;set;}
        public List<EmergencyContact> emergencyContact {get;set;}
        public List<Exposure> exposure {get;set;}
        public List<Injury> injury {get;set;}
        public AlternativeCauseDetails alternativeCauseDetails;
        public List<MedicalFacility> medicalFacility {get;set;}
		
        public String matterIsQualified {get;set;}
        public String caseSummary {get;set;}
        public String clientPreviouslySignedWithLawFirm {get;set;}
        public String clientDiscoveredCauseFromAdvertising {get;set;}
        public String dateClientFirstSawAdvertising {get;set;}
        public String discoveryOfCauseDate {get;set;}
        public String howClientDiscoveredCause {get;set;}
        public String retainerSentDate {get;set;}
        public String retainedDate {get;set;}
        public string testingFlag {get;set;}
        public string marketingChannel {get;set;}
     
    }
    public class Client {
        public String firstName {get;set;}
        public String middleName {get;set;}
        public String lastName {get;set;}
        public String suffix {get;set;}
        public List<Address> address {get;set;}
        public String socialSecurityNumber {get;set;}
        public String dateOfBirth {get;set;}
        public String gender {get;set;}
        public String maritalStatus {get;set;}
        public String notes {get;set;}
        public String primaryEmail {get;set;}
        public String cellPhone {get;set;}
        public String homePhone {get;set;}
        public String relationshipToInjuredParty {get;set;}
        public String powerOfAttorneyType {get;set;}
        public String bestContactTime {get;set;}
        public String languagePreference {get;set;}
        public string isPowerOfAttorney {get;set;}
    }
    // public class EmploymentHistory{
    //     public String currentOccupation {get;set;}
    //     public String currentOccupationStartDate {get;set;}
    //     public String previousOccupation {get;set;}
    //     public String previousOccupationStartDate {get;set;}
    //     public String previousOccupationEndDate {get;set;}
    //     public String occupationBeforeDx {get;set;}
    //     public String militaryService {get;set;}
    // }
    public class InjuredParty {
        public String firstName {get;set;}
        public String middleName {get;set;}
        public String lastName {get;set;}
        public String suffix {get;set;}        
        public List<Address> address {get;set;}
        public String socialSecurityNumber {get;set;}
        public String dateOfBirth {get;set;}
        public String gender {get;set;}
        public String maritalStatus {get;set;}
        public String notes {get;set;}
        public String email {get;set;}
        public List<string> phone {get;set;}
        public String isDeceased {get;set;}
        public String dateOfDeath {get;set;}
        public String causeOfDeath {get;set;}
        public String stateOfDeath {get;set;}
        public String estateHasBeenOpened {get;set;}
        public String estateIsCurrentlyOpen {get;set;}
        public String clientIsRepresentativeOfEstate {get;set;}
        public String clientIsExecutorOfWill {get;set;}
        public String namedInformant {get;set;}
    }
    public class EmergencyContact {
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String suffix {get;set;}
        public String phone {get;set;}
        public String relationship {get;set;}
    }
    public class Exposure {
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String exposureIsOngoing {get;set;}
        public String exposureHasStopped {get;set;}
        public String exposureState {get;set;}
        public String residenceStateDuringExposure {get;set;}
        public ExposureDetails exposureDetails;
    }
    public class ExposureDetails {
        public Address address;
        public String usedProductAtWork;
        public String usedProductAtHome;
        public String exposureArea;
        public String applicationMethod;
        public String totalExposureYears;
        public String usesPerYear;
        public String hoursPerUse;
        public String usedProtectiveGear;
        public String protectiveGearDescription;
        public String ipPurchasedProduct;
        public String clientHasProductContainer;
        public String clientHasPhotoOfUsage;
        public String clientHasPurchaseReceipts;
        public String productContainerSize;
        public List<String> purchaseLocation;
        public String notes;
        public String exposureLocationType;
        public String exposureLocationInformation;
        public String ipWasPropertyOwner;
        public String clientHasWaterBill;
        public String waterWellType;
        public String waterWellWasTestedForPFAS;
        public String waterWellTestedDate;
        public String exposureLocationMatchedPws;
        public String locationMatchedPWS;
        public List<PwsData> pwsData;
    }
    public class PwsData {
        public String id;
        public String name;
        public String zipCodes;
        public String state;
        public String primarySource;
    }
    public class Address {
        public String street1 {get;set;}
        public String street2 {get;set;}
        public String city {get;set;}
        public String zip {get;set;}
        public String state {get;set;}
        public string isMailing {get;set;}
        public string isResidence {get;set;}
    }
    public class Provider {
        public String title;
        public String firstName;
        public String lastName;
        public String type;
    }
    public class MedicalFacility {
        public String name {get;set;}
        public String facilityType {get;set;}
        public String procedure {get;set;}
        public String address {get;set;}
        public String city {get;set;}
        public String zip {get;set;}
        public String state {get;set;}
        public String phone {get;set;}
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String notes {get;set;}
        public String nationalProviderId {get;set;}
        public List<MedicalFacilityProvider> providers {get;set;}
    }
    public class MedicalFacilityProvider {
        public String title {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String type {get;set;}
        public String nationalProviderId {get;set;}
    }
    public class Injury {
        public String type;
        public String subType;
        public String severity;
        public String onsetDate;
        public String isDiagnosed;
        public String diagnosisDate;
        public String stateOfDiagnosis;
        public String residenceStateAtDiagnosis;
        public InjuryDetails injuryDetails;
    }
    public class InjuryDetails {
        public String treatedWithChemotherapy;
        public String chemotherapyDetails;
        public String treatedWithRadiation;
        public String radiationDetails;
        public String treatedWithSurgery;
        public String surgeryDetails;
        public String yearsInRemission;
        public String isInRemission;
        public String treatedWithImmunotherapy;
    }
    public class AlternativeCauseDetails {
        public String priorDxHepatitis;
        public String priorDxHIVorAIDS;
        public String priorDxCancer;
        public String envExposureAgentOrange;
        public String hxOrganTransplant;
        public String hxImmunosuppressantDrugs;
        public String receivedBenefitsForCurrentDx;
        public String priorEnvExposureSuperfundToxicSite;
        public String priorDxEbsteinBarr;
        public String priorDxBacterialInfection;
        public String priorHxBreastImplants;
        public String priorDxDiabetes;
        public String priorDxDiabetesDetails;
        public String hxTobaccoCurrent;
        public String hxTobaccoFormer;
        public String hxTobaccoDetails;
        public String hxTobaccoTotalYears;
        public String hxTobaccoYearsStoppedPriorToDx;
        public String familyHxCancer;
        public String familyHxCancerDetails;
        public String familyHxNHL;
        public String dxHeightFt;
        public String dxHeightIn;
        public String dxWeight;
        public String dxBmi;
        public String currentHeightFt;
        public String currentHeightIn;
        public String currentWeight;
        public String currentBmi;
        public String testedBloodForPfas;
        public String testedBloodForPfasDetails;
        public String priorHxKidneyTransplant;
    }
}