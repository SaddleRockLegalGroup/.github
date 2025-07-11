public class Tekmir_Models {
    public class NewMatterRequest {
        public String integratorMatterId {get;set;}
        public String campaign {get;set;}
        public String integrator {get;set;}
        public String intakeVendor {get;set;}
        public String marketingVendor {get;set;}

        public Client client {get;set;}
        public InjuredParty injuredParty {get;set;}
        public List<EmergencyContact> emergencyContact {get;set;}
        public List<Exposure> exposure {get;set;}
        public List<Injury> injury {get;set;}
        public Map<String,Object> alternativeCauseDetails {get;set;}
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
        public Boolean testingFlag {get;set;}
        public string marketingChannel {get;set;}

        // public Map<string,object> employmentHistory {get;set;} // Not in Tekmir Swagger Doc but in mapping workbook and sample data
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
        // public String notes {get;set;}
        public String primaryEmail {get;set;}
        public String cellPhone {get;set;}
        public String homePhone {get;set;}
        public String relationshipToInjuredParty {get;set;}
        public String isPowerOfAttorney {get;set;}
        public String powerOfAttorneyType {get;set;}
        // public String bestContactTime {get;set;}
        // public String languagePreference {get;set;}
    }
    public class InjuredParty {
        public String firstName {get;set;}
        public String middleName {get;set;}
        public String lastName {get;set;}
        public String suffix {get;set;}
        public List<Address> address {get;set;}
        public String socialSecurityNumber {get;set;}
        public String dateOfBirth {get;set;}
        public String gender {get;set;}
        // public String maritalStatus {get;set;}
        // public String notes {get;set;}
        // public String email {get;set;}
        // public List<string> phone {get;set;}
        public String isDeceased {get;set;}
        public String dateOfDeath {get;set;}
        // public String causeOfDeath {get;set;}
        public String stateOfDeath {get;set;}
        public String estateHasBeenOpened {get;set;}
        public String estateIsCurrentlyOpen {get;set;}
        public String clientIsRepresentativeOfEstate {get;set;}
        public String clientIsExecutorOfWill {get;set;}
        // public String namedInformant {get;set;}
    }
    public class EmergencyContact {
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String suffix {get;set;}
        public String phone {get;set;}
        public String relationship {get;set;}
    }
    public class Exposure {
        public String product {get;set;}
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String exposureIsOngoing {get;set;}
        public String exposureHasStopped {get;set;}
        public String exposureState {get;set;}
        public String residenceStateDuringExposure {get;set;}
        public Map<String,Object> exposureDetails {get;set;}
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
    public class MedicalFacility {
        public String name {get;set;}
        public String facilityType {get;set;}
        public String address {get;set;}
        public String city {get;set;}
        public String zip {get;set;}
        public String state {get;set;}
        public String phone {get;set;}
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String nationalProviderId {get;set;}
        // public String notes {get;set;}
        public List<MedicalFacilityProvider> providers {get;set;}
    }
    public class MedicalFacilityProvider {
        public String title {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String nationalProviderId {get;set;}
        // public String type {get;set;}
    }
    public class Injury {        
        public String type {get;set;}
        public String subType {get;set;}
        public String severity {get;set;}
        public String isDiagnosed {get;set;}
        public String diagnosisDate {get;set;}
        public String stateOfDiagnosis {get;set;}
        public String residenceStateAtDiagnosis {get;set;}
        public Map<String,Object> injuryDetails {get;set;} // Additional details about the injury, if any
    }
    public class NewMatterResponse {
        public String integratorMatterId {get;set;}
        public String matterId {get;set;}
        public String campaign {get;set;}
    }
    public class NewDocument {
        public String integratorDocumentId {get;set;}
        public String relatedIntegratorMatterId {get;set;}
        public String fileType {get;set;} // e.g. "pdf", "docx"
        public String fileName {get;set;}
        public String contentType {get;set;} // e.g. "application/pdf", "application/msword"
        public String fileUrl {get;set;} // URL to the document
        public String fileUrlExpirationTimestamp {get;set;} // ISO 8601 format
        public String clientCompletedAtDate {get;set;} // Date when the client completed the document
    }
    public class HttpResponseWrapper {
        public Boolean success {get;set;}
        public string data {get;set;}
    }
}