global without sharing class NumVerifyValidation {
    public class PhoneValidationResponse {
        @InvocableVariable(label='Is Valid' required=true) 
        public Boolean isValid;
        @InvocableVariable(label='International Format') 
        public String internationalFormat;
        @InvocableVariable(label='Country Code') 
        public String countryCode;
        @InvocableVariable(label='Carrier') 
        public String carrier;
        @InvocableVariable(label='Line Type') 
        public String lineType;
    }

    @InvocableMethod(label='Validate Phone Number' description='Validates a single phone number synchronously')
    public static List<PhoneValidationResponse> validatePhoneNumber(List<String> phoneNumbers) {
        System.debug(':pushpin: Validating phone number: ' + phoneNumbers);
        
        if (phoneNumbers == null || phoneNumbers.isEmpty() || String.isBlank(phoneNumbers[0])) {
            System.debug(':warning: No valid phone number provided');
            return new List<PhoneValidationResponse>{createErrorResponse()};
        }

        String phoneNumber = phoneNumbers[0];
        String accessKey = getAccessKey();
        if (String.isBlank(accessKey)) {
            System.debug(':warning: No valid access key found');
            return new List<PhoneValidationResponse>{createErrorResponse()};
        }

        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://apilayer.net/api/validate?access_key=' + accessKey + 
                              '&number=' + EncodingUtil.urlEncode(phoneNumber, 'UTF-8') + 
                              '&format=1');
            request.setMethod('GET');
            request.setTimeout(120000);

            HttpResponse response = new Http().send(request);
            System.debug(':pushpin: API response: ' + response.getStatusCode() + ' - ' + response.getBody());
            
            return new List<PhoneValidationResponse>{processResponse(response)};
        } catch (Exception e) {
            System.debug(':exclamation: Error validating phone number: ' + e.getMessage());
            return new List<PhoneValidationResponse>{createErrorResponse()};
        }
    }

    private static String getAccessKey() {
        try {
            return [SELECT NumVerifyAccessKey__c 
                    FROM Twilio_Num_Verify__mdt 
                    WHERE DeveloperName = 'AccessKey' 
                    LIMIT 1].NumVerifyAccessKey__c;
        } catch (Exception e) {
            System.debug(':exclamation: Failed to fetch access key: ' + e.getMessage());
            return null;
        }
    }

    private static PhoneValidationResponse processResponse(HttpResponse response) {
        PhoneValidationResponse result = new PhoneValidationResponse();
        try {
            if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                result.isValid = (Boolean) jsonResult.get('valid');
                result.internationalFormat = (String) jsonResult.get('international_format');
                result.countryCode = (String) jsonResult.get('country_code');
                result.carrier = (String) jsonResult.get('carrier');
                result.lineType = (String) jsonResult.get('line_type');
            } else {
                result.isValid = false;
                System.debug(':warning: API returned status: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug(':exclamation: Response processing error: ' + e.getMessage());
            result.isValid = false;
        }
        return result;
    }

    private static PhoneValidationResponse createErrorResponse() {
        PhoneValidationResponse result = new PhoneValidationResponse();
        result.isValid = false;
        return result;
    }
}