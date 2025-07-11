@IsTest
private class NumVerifyValidationTest {
    
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        
        public MockHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }

    @TestSetup
    static void setup() {
        // No DML here to avoid uncommitted work issues in tests
    }

    @IsTest
    static void testValidPhoneNumber() {
        String mockResponse = '{"valid": true, "international_format": "+12025550123", "country_code": "US", "carrier": "Verizon", "line_type": "mobile"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));
        
        Test.startTest();
        List<NumVerifyValidation.PhoneValidationResponse> results = 
            NumVerifyValidation.validatePhoneNumber(new List<String>{'2025550123'});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        NumVerifyValidation.PhoneValidationResponse result = results[0];
        System.assertEquals(true, result.isValid, 'Phone number should be valid');
        System.assertEquals('+12025550123', result.internationalFormat, 'International format should match');
        System.assertEquals('US', result.countryCode, 'Country code should match');
        System.assertEquals('Verizon', result.carrier, 'Carrier should match');
        System.assertEquals('mobile', result.lineType, 'Line type should match');
    }

    @IsTest
    static void testInvalidPhoneNumber() {
        String mockResponse = '{"valid": false, "number": "123"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockResponse));
        
        Test.startTest();
        List<NumVerifyValidation.PhoneValidationResponse> results = 
            NumVerifyValidation.validatePhoneNumber(new List<String>{'123'});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isValid, 'Phone number should be invalid');
    }

    @IsTest
    static void testApiError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400, 'Bad Request'));
        
        Test.startTest();
        List<NumVerifyValidation.PhoneValidationResponse> results = 
            NumVerifyValidation.validatePhoneNumber(new List<String>{'2025550123'});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isValid, 'Should return false for API error');
    }

    @IsTest
    static void testNullInput() {
        Test.startTest();
        List<NumVerifyValidation.PhoneValidationResponse> results = 
            NumVerifyValidation.validatePhoneNumber(null);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isValid, 'Should return false for null input');
    }

    @IsTest
    static void testExceptionHandling() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'Invalid JSON'));
        
        Test.startTest();
        List<NumVerifyValidation.PhoneValidationResponse> results = 
            NumVerifyValidation.validatePhoneNumber(new List<String>{'2025550123'});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isValid, 'Should return false when exception occurs');
    }
}