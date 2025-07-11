@isTest
public with sharing class SC_APIModelsTest {
    @isTest
    public static void test_Models() {
        SC_APIModels.Meta meta = new SC_APIModels.Meta();
        meta.militaryPersonFirstName = 'Test';
        meta.militaryPersonMiddleName = 'T';
        meta.militaryPersonLastName = 'Test';
        meta.militaryPersonSuffix = 'Jr';
        meta.agentCapacity = 'other';
        meta.gender = 'Male';
        meta.campDates = new List<Map<string,object>>();
        meta.otherCancer = 'N/A';
        meta.otherInjury = 'N/A';
        meta.campLocations = new Map<string,object>();
        meta.otherDiagnosis = 'N/A';
        meta.emergencyContactName = 'Test';
        meta.emergencyContactEmail = 'test@email.com';
        meta.emergencyContactPhone = '1111111111';

        SC_APIModels.Constant constant = new SC_APIModels.Constant();
        List<string> locations = constant.campLocationList;
    }
    @isTest
    static void test_CaseResource() {
        SC_APIModels.CaseResource resource = new SC_APIModels.CaseResource();
        System.assertNotEquals(null, resource, 'CaseResource object is null');
        
        // Test data for each field
        resource.referral = 'Referral Test';
        resource.referred_to_company_uuid = 'Referred To Company UUID Test';
        resource.referred_from_company_uuid = 'Referred From Company UUID Test';
        resource.litigation_id = 123;
        resource.status_id = 456;
        resource.fname = 'First Name Test';
        resource.mname = 'Middle Name Test';
        resource.lname = 'Last Name Test';
        resource.suffix = 'Suffix Test';
        resource.email = 'test@example.com';
        resource.email2 = 'test2@example.com';
        resource.phone = '123-456-7890';
        resource.phone2 = '456-789-0123';
        resource.phone3 = '789-012-3456';
        resource.street1 = 'Street 1 Test';
        resource.street2 = 'Street 2 Test';
        resource.city = 'City Test';
        resource.state = 'State Test';
        resource.zip = '12345';
        resource.ssn = '123-45-6789';
        resource.relation = 'Relation Test';
        resource.marital_status = 'Marital Status Test';
        resource.fname_injured = 'Injured First Name Test';
        resource.mname_injured = 'Injured Middle Name Test';
        resource.lname_injured = 'Injured Last Name Test';
        resource.suffix_injured = 'Injured Suffix Test';
        resource.birthday_injured = '2024-01-01';
        resource.death_date = '2023-12-31';
        resource.email_injured = 'injured@example.com';
        resource.phone_injured = '987-654-3210';
        resource.street1_address_injured = 'Injured Street 1 Test';
        resource.street2_address_injured = 'Injured Street 2 Test';
        resource.city_address_injured = 'Injured City Test';
        resource.state_address_injured = 'Injured State Test';
        resource.zip_address_injured = '54321';
        resource.state_injured = 'Injured State Test';
        resource.ssn_injured = '987-65-4321';
        resource.sol_trigger_date = '2023-01-01';
        resource.bot_language = 'Bot Language Test';
        resource.conditions = new List<Integer>{1, 2, 3};
        resource.information = new List<Integer>{4, 5, 6};
        resource.details = 'Details Test';
        resource.meta = new SC_APIModels.Meta();
        resource.tags = new List<String>{'Tag1', 'Tag2'};
        resource.external_data = new Map<String, Object>{'Key1' => 'Value1', 'Key2' => 'Value2'};
        //resource.api_casesafe_id = 'API CaseSafe ID Test';
        
        // Assert the values
        System.assertEquals('Referral Test', resource.referral);
        System.assertEquals('Referred To Company UUID Test', resource.referred_to_company_uuid);
        System.assertEquals('Referred From Company UUID Test', resource.referred_from_company_uuid);
        System.assertEquals(123, resource.litigation_id);
        System.assertEquals(456, resource.status_id);
        System.assertEquals('First Name Test', resource.fname);
        System.assertEquals('Middle Name Test', resource.mname);
        System.assertEquals('Last Name Test', resource.lname);
        System.assertEquals('Suffix Test', resource.suffix);
        System.assertEquals('test@example.com', resource.email);
        System.assertEquals('test2@example.com', resource.email2);
        System.assertEquals('123-456-7890', resource.phone);
        System.assertEquals('456-789-0123', resource.phone2);
        System.assertEquals('789-012-3456', resource.phone3);
        System.assertEquals('Street 1 Test', resource.street1);
        System.assertEquals('Street 2 Test', resource.street2);
        System.assertEquals('City Test', resource.city);
        System.assertEquals('State Test', resource.state);
        System.assertEquals('12345', resource.zip);
        System.assertEquals('123-45-6789', resource.ssn);
        System.assertEquals('Relation Test', resource.relation);
        System.assertEquals('Marital Status Test', resource.marital_status);
        System.assertEquals('Injured First Name Test', resource.fname_injured);
        System.assertEquals('Injured Middle Name Test', resource.mname_injured);
        System.assertEquals('Injured Last Name Test', resource.lname_injured);
        System.assertEquals('Injured Suffix Test', resource.suffix_injured);
        System.assertEquals('2024-01-01', resource.birthday_injured);
        System.assertEquals('2023-12-31', resource.death_date);
        System.assertEquals('injured@example.com', resource.email_injured);
        System.assertEquals('987-654-3210', resource.phone_injured);
        System.assertEquals('Injured Street 1 Test', resource.street1_address_injured);
        System.assertEquals('Injured Street 2 Test', resource.street2_address_injured);
        System.assertEquals('Injured City Test', resource.city_address_injured);
        System.assertEquals('Injured State Test', resource.state_address_injured);
        System.assertEquals('54321', resource.zip_address_injured);
        System.assertEquals('Injured State Test', resource.state_injured);
        System.assertEquals('987-65-4321', resource.ssn_injured);
        System.assertEquals('2023-01-01', resource.sol_trigger_date);
        System.assertEquals('Bot Language Test', resource.bot_language);
        System.assertEquals(new List<Integer>{1, 2, 3}, resource.conditions);
        System.assertEquals(new List<Integer>{4, 5, 6}, resource.information);
        System.assertEquals('Details Test', resource.details);
        System.assertNotEquals(null, resource.meta, 'Meta object should not be null');
        System.assertEquals(new List<String>{'Tag1', 'Tag2'}, resource.tags);
        System.assertEquals(new Map<String, Object>{'Key1' => 'Value1', 'Key2' => 'Value2'}, resource.external_data);
        //System.assertEquals('API CaseSafe ID Test', resource.api_casesafe_id);
    }
}