public with sharing class SC_APIModels {
    public class Meta {
        public string militaryPersonFirstName {get;set;}
        public string militaryPersonMiddleName {get;set;}
        public string militaryPersonLastName {get;set;}
        public string militaryPersonSuffix {get;set;}
        public string agentCapacity {get;set;}
        public string gender {get;set;}
        public List<Map<string,object>> campDates {get;set;} //dateTime, dateTime1
        public string otherCancer {get;set;}
        public string otherInjury {get;set;}
        public Map<string,object> campLocations {get;set;}
        public string otherDiagnosis {get;set;}
        public string emergencyContactName {get;set;}
        public string emergencyContactEmail {get;set;}
        public string emergencyContactPhone {get;set;}
    }
    public class CaseResource {
        public string referral {get;set;}
        public string referred_to_company_uuid {get;set;}
        public string referred_from_company_uuid {get;set;}
        public Integer litigation_id {get;set;}
        public Integer status_id {get;set;}
        public string fname {get;set;}
        public string mname {get;set;}
        public string lname {get;set;}
        public string suffix {get;set;}
        public string email {get;set;}
        public string email2 {get;set;}
        public string phone {get;set;}
        public string phone2 {get;set;}
        public string phone3 {get;set;}
        public string street1 {get;set;}
        public string street2 {get;set;}
        public string city {get;set;}
        public string state {get;set;}
        public string zip {get;set;}
        public string ssn {get;set;}
        public string relation {get;set;}
        public string marital_status {get;set;}
        public string fname_injured {get;set;}
        public string mname_injured {get;set;}
        public string lname_injured {get;set;}
        public string suffix_injured {get;set;}
        public string birthday_injured {get;set;}
        public string death_date {get;set;}
        public string email_injured {get;set;}
        public string phone_injured {get;set;}
        public string street1_address_injured {get;set;}
        public string street2_address_injured {get;set;}
        public string city_address_injured {get;set;}
        public string state_address_injured {get;set;}
        public string zip_address_injured {get;set;}
        public string state_injured {get;set;}
        public string ssn_injured {get;set;}
        public string sol_trigger_date {get;set;}
        public string bot_language {get;set;}
        public List<Integer> conditions {get;set;}
        public List<Integer> information {get;set;}
        public string details {get;set;}
        public Meta meta {get;set;}
        public List<string> tags {get;set;}
        public Map<string,object> external_data {get;set;}
        //public string api_casesafe_id {get;set;} 
    }
    public class Constant {
        public List<string> campLocationList {
            get {
                return new List<string>{
                      'barracks'
                    , 'berkeleyManor'
                    , 'campGeiger'
                    , 'courthouseBay'
                    , 'hadnotPoint'
                    , 'holcombBoulevard'
                    , 'hospitalPoint'
                    , 'knoxTrailerPark'
                    , 'mainsideBarracks'
                    , 'midwayPark'
                    , 'montfordPointCampJohnson'
                    , 'newRiver'
                    , 'onslowBeach'
                    , 'other'
                    , 'paradisePoint'
                    , 'rifleRange'
                    , 'tarawaTerrace'
                    , 'watkinsVillage'
                };
            }
        }
    }
}