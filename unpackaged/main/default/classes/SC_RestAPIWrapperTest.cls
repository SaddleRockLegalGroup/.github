@isTest
private class SC_RestAPIWrapperTest {
    private static SC_APIModels.Constant CONSTANT = new SC_APIModels.Constant();

    @isTest
    static void testCreateCase_Success() {
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
        
        string mockUrl = simplyConvertSetting.Base_URL__c + '/cases' ;

        // Set up mock callout response
        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(200, 'OK', '{"message" : "Created case 82118","data":{"uuid":"test_uuid"}}', null);
        multiCalloutMock.addRequestMock(mockUrl, mockResponse);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Call the method under test
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);
        
        // Start test
        Test.startTest();
        Map<String, Object> result = restApi.createCase(caseRequest);
        Test.stopTest();

        // Assert the result
        System.assertEquals(true, result.get('success'), 'Success should be true');
        //System.assertEquals('test_uuid', result.get('data'), 'UUID should match');
    }
    
    @isTest
    static void testCreateCase_ErrorResponse() {
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
        
        string mockUrl = simplyConvertSetting.Base_URL__c + '/cases' ;

        // Set up mock callout response
        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(500, 'Internal Server Error', '{"error":"Internal server error"}', null);
        multiCalloutMock.addRequestMock(mockUrl, mockResponse);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Call the method under test
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);

        // Start test
        Test.startTest();
        Map<String, Object> result = restApi.createCase(caseRequest);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals(false, result.get('success'), 'Success should be false');
    }
    
    @isTest
    static void testCreateCase_Exception() {
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();    
        
        // Start test
        Test.startTest();
        try{
            Map<String, Object> result = restApi.createCase(null);
        }catch(System.Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCase_Success() {
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
        
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string mockUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId ;
        
        // Set up mock callout response
        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(200, 'OK', '{"message" : "Updated case 82118","data":{"uuid":"test_uuid"}}', null);
        multiCalloutMock.addRequestMock(mockUrl, mockResponse);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Call the method under test
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);
        
        // Start test
        Test.startTest();
        Map<string,object> result = restApi.updateCase(caseRequest,caseId);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals(true, result.get('success'), 'Success should be true');
        //System.assertEquals('test_uuid', result.get('data'), 'UUID should match');
    }

    @isTest
    static void testUpdateCase_ErrorResponse() {
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
        
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string mockUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId ;
        
        // Set up mock callout response
        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(500, 'Internal Server Error', '{"error":"Internal server error"}', null);
        multiCalloutMock.addRequestMock(mockUrl, mockResponse);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        // Call the method under test
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);
        
        // Start test
        Test.startTest();
        Map<string,object> result = restApi.updateCase(caseRequest,caseId);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals(false, result.get('success'), 'Success should be false');
    }

    @isTest
    static void testUpdateCaseReferral_Success() {
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
        litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
        
        string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
        string mockUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/referral';

        // Set up mock callout response
        Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
        SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
        SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(200, 'OK', '{"message" : "Updated case 82118","data":{"uuid":"test_uuid"}}', null);
        multiCalloutMock.addRequestMock(mockUrl, mockResponse);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        
        // Call the method under test
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);
        
        // Start test
        Test.startTest();
        Map<string,object> result = restApi.updateCaseReferrall(caseRequest,caseId);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals(true, result.get('success'), 'Success should be true');
        //System.assertEquals('test_uuid', result.get('data'), 'UUID should match');
    }

    @isTest
    static void testUpdateCaseReferral_ErrorResponse() {
            Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
            litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
            
            string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
            string mockUrl = simplyConvertSetting.Base_URL__c + '/cases/' + caseId + '/referral';
            
            // Set up mock callout response
            Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
            SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);
            SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(500, 'Internal Server Error', '{"error":"Internal server error"}', null);
            multiCalloutMock.addRequestMock(mockUrl, mockResponse);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            
            // Call the method under test
            SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
            SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);
            
            // Start test
            Test.startTest();
            Map<string,object> result = restApi.updateCaseReferrall(caseRequest,caseId);
            Test.stopTest();
            
            // Assert the result
            System.assertEquals(false, result.get('success'), 'Success should be false');
    }

    @isTest
    static void testUploadDocument_Success() {
        Simply_Convert_API_Setting__c simplyConvertSetting = SC_TestDataFactory.createTestSimplyConvertSetting();
            //litify_pm__Intake__c intake = SC_TestDataFactory.createTestIntake();
            
            string caseId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
            String fileMeta = 'test_file_meta';
            String fileName = 'test_file.pdf';
            Blob fileContent = Blob.valueOf('Test file content');
            string mockUrl = simplyConvertSetting.Base_URL__c  + '/cases/' + caseId + '/documents';
            
            // Set up mock callout response
            Map<String, HttpCalloutMock> simplyConvertResp = new Map<String,HttpCalloutMock>();
            SaddleRockMultiRequestMock multiCalloutMock = new SaddleRockMultiRequestMock(simplyConvertResp);    
            SaddleRockCalloutMock mockResponse = new SaddleRockCalloutMock(500, 'Internal Server Error', '{"message":"Document Uploaded"}', null);
            multiCalloutMock.addRequestMock(mockUrl, mockResponse);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);

            // Call the method under test
            SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
            //SC_APIModels.CaseResource caseRequest = BuildCaseReferrallRequest(intake);
            
            // Start test
            Test.startTest();
            Map<string,object> result = restApi.uploadDocument(caseId, fileMeta, fileName, fileContent);
            Test.stopTest();
    }
    
    private static SC_APIModels.CaseResource BuildCaseReferrallRequest(litify_pm__Intake__c intake){
        SC_APIModels.CaseResource UpdateCaseReferrallRequest = new SC_APIModels.CaseResource();
        UpdateCaseReferrallRequest.referred_from_company_uuid = 'bc006f4c46e12c2f83268977b065f27476248b6b';
        UpdateCaseReferrallRequest.referred_to_company_uuid = 'fc9d1751c6a1256a2ba8822ddb3437e6f1a01731';
        UpdateCaseReferrallRequest.litigation_id = 116;
        UpdateCaseReferrallRequest.status_id = 8;
        UpdateCaseReferrallRequest.bot_language = 'en-US';
        UpdateCaseReferrallRequest.tags = new List<string>{'f784cb45db2960bd856995ac392f83393dff4ff4'};
        
        UpdateCaseReferrallRequest.birthday_injured = SC_Helper.formatDateToString(intake.litify_pm__Client__r.litify_pm__Date_of_birth__c);
        UpdateCaseReferrallRequest.city = intake.Caller__r.BillingCity;
        UpdateCaseReferrallRequest.city_address_injured = intake.litify_pm__Client__r.BillingCity;
        UpdateCaseReferrallRequest.death_date = SC_Helper.formatDateToString(intake.litify_pm__Client__r.Date_of_Death__c);
        UpdateCaseReferrallRequest.email = intake.Caller__r.litify_pm__Email__c;
        UpdateCaseReferrallRequest.email2 = intake.Caller__r.Secondary_Email__c;
        UpdateCaseReferrallRequest.email_injured = intake.litify_pm__Client__r.litify_pm__Email__c;
        UpdateCaseReferrallRequest.fname = intake.Caller__r.litify_pm__First_Name__c;
        UpdateCaseReferrallRequest.fname_injured = intake.litify_pm__Client__r.litify_pm__First_Name__c;
        UpdateCaseReferrallRequest.lname = intake.Caller__r.litify_pm__Last_Name__c;
        UpdateCaseReferrallRequest.lname_injured = intake.litify_pm__Client__r.litify_pm__Last_Name__c;
        UpdateCaseReferrallRequest.marital_status = intake.Caller__r.Marital_Status__c;
        UpdateCaseReferrallRequest.mname = intake.Caller__r.Middle_Name__c;
        UpdateCaseReferrallRequest.mname_injured = intake.litify_pm__Client__r.Middle_Name__c;
        UpdateCaseReferrallRequest.phone = intake.Caller__r.litify_pm__Phone_Mobile__c;
        UpdateCaseReferrallRequest.phone2 = intake.Caller__r.litify_pm__Phone_Home__c;
        UpdateCaseReferrallRequest.phone3 = intake.Caller__r.litify_pm__Phone_Other__c;
        UpdateCaseReferrallRequest.phone_injured = intake.litify_pm__Client__r.litify_pm__Phone_Mobile__c;
        UpdateCaseReferrallRequest.ssn = intake.Caller__r.litify_pm__Social_Security_Number__c;
        UpdateCaseReferrallRequest.ssn_injured = intake.litify_pm__Client__r.litify_pm__Social_Security_Number__c;
        UpdateCaseReferrallRequest.state = intake.Caller__r.BillingState;
        UpdateCaseReferrallRequest.state_address_injured = intake.litify_pm__Client__r.BillingState;
        UpdateCaseReferrallRequest.street1 = intake.Caller__r.BillingStreet;
        UpdateCaseReferrallRequest.street1_address_injured = intake.litify_pm__Client__r.BillingStreet;
        UpdateCaseReferrallRequest.suffix = intake.Caller__r.Suffix__c;
        UpdateCaseReferrallRequest.suffix_injured = intake.litify_pm__Client__r.Suffix__c;
        UpdateCaseReferrallRequest.zip = intake.Caller__r.BillingPostalCode;
        UpdateCaseReferrallRequest.zip_address_injured = intake.litify_pm__Client__r.BillingPostalCode;

        UpdateCaseReferrallRequest.relation = intake.Calling_on_behalf_of_you_or_loved_one__c == 'Self' ? 'myself' : intake.What_is_your_relation_to_this_individual__c;
        UpdateCaseReferrallRequest.state_injured = intake.State__c;
        UpdateCaseReferrallRequest.details = intake.litify_pm__Description__c + '\n' + intake.Camp_Lejuene__r.NE_NPD_Details__c;
        UpdateCaseReferrallRequest.sol_trigger_date = SC_Helper.formatDateToString(intake.litify_pm__Statute_of_Limitations_Date__c);
        
        UpdateCaseReferrallRequest.conditions = new List<Integer>();
        //UpdateCaseReferrallRequest.api_casesafe_id = intake.API_Casesafe_Id__c;
        string issue = intake.Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c;
        if(!string.isBlank(issue) && !string.isEmpty(issue)){
            List<string> issues = issue.split(';');
            for(string i : issues){
                Integer cvIssue = SC_JSONValueMap.mapCondition(i);
                if(cvIssue != null){
                    UpdateCaseReferrallRequest.conditions.add(cvIssue);
                }
            }
        }

        UpdateCaseReferrallRequest.information = new List<Integer>();
        Integer info1 = SC_JSONValueMap.mapInformation(intake.Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c);
        Integer info2 = SC_JSONValueMap.mapInformation(intake.Camp_Lejuene__r.How_long_did_you_stay_at_Camp_Lejuene__c);
        Integer info3 = (UpdateCaseReferrallRequest.relation == 'myself' 
        || intake.Does_caller_have_authority_to_sign__c == 'Yes'
        || intake.Confirm_if_caller_is_next_of_kin__c == 'The caller is the formal next of kin (when through all levels and they are the next in line)')
        ? 1056 : null;
        Integer info4 = SC_JSONValueMap.mapInformation(intake.Camp_Lejuene__r.Estimate_Dates_at_Camp_Lejuene__c);
        if(info1 != null){
            UpdateCaseReferrallRequest.information.add(info1);
        }
        if(info2 != null){
            UpdateCaseReferrallRequest.information.add(info2);
        }
        if(info3 != null){
            UpdateCaseReferrallRequest.information.add(info3);
        }
        if(info4 != null){
            UpdateCaseReferrallRequest.information.add(info4);
        }

        UpdateCaseReferrallRequest.meta = new SC_APIModels.Meta();
        UpdateCaseReferrallRequest.meta.emergencyContactName = intake.Caller__r.Emergency_Contact_Name__c;
        UpdateCaseReferrallRequest.meta.emergencyContactPhone = intake.Caller__r.Emergency_Contact_Phone__c;
        UpdateCaseReferrallRequest.meta.agentCapacity = SC_JSONValueMap.mapAgentCapacity(intake.Signing_authority_as__c);
        UpdateCaseReferrallRequest.meta.campDates = new List<Map<string,object>>();
        Map<string,object> campDate = new Map<string,object>{
            'dateTime' => intake.Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c,
            'dateTime1' => intake.Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c
        };
        UpdateCaseReferrallRequest.meta.campDates.add(campDate);

        UpdateCaseReferrallRequest.meta.campLocations = new Map<string,object>();
        string campLoc = intake.Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c;
        if(!string.isBlank(campLoc) && !string.isEmpty(campLoc)){
            List<string> campLocs = campLoc.split(';');
            List<string> convertedLocs = new List<string>();
            for(string l : campLocs){
                string cvLoc = SC_JSONValueMap.mapLocation(l);
                if(cvLoc != null){
                    convertedLocs.add(cvLoc);
                }
            }
            for(string loc : CONSTANT.campLocationList){
                if(convertedLocs != null && convertedLocs.contains(loc)){
                    UpdateCaseReferrallRequest.meta.campLocations.put(loc, 'true');
                }
                else {
                    UpdateCaseReferrallRequest.meta.campLocations.put(loc, 'false');
                }
            }
        }

        UpdateCaseReferrallRequest.external_data = new Map<string,object>();
        UpdateCaseReferrallRequest.external_data.put('litify_1519', new Map<string,string>{
            'id' => intake.Id
        });

        return UpdateCaseReferrallRequest;
    }
}