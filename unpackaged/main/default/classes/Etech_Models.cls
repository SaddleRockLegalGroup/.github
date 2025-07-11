public with sharing class Etech_Models {
    /*
    {
	"IntakeExternalId": "a0CUJ00003kHUcR2AW", -- salesforceId of Intake
	"CampaignCaseExternalId": "a3RUJ000000fkrh2AA", --IGNORE/EXCLUDE
	"ClientExternalId": "001UJ00000dVLmcYAG", --salesforceId of Client
	"First_Name": "David", --clientFirstName
	"Last_Name": "Reyes",  --clientLastName
	"Phone_Number": "5094811987", --clientMobilePhone
	"Email_Address": "davidsr044@gmail.com", - clientEmail
	"Postal_Code": "", -clientBillingPostalCode
	"Case_Type": "Round Up", --litify_pm__Case_Type__r.Name
	"Campaign_Name": "Round Up" --Campaign__r.Name
    }
    */
    public class RequestModel {
        public String IntakeExternalId { get; set; } // salesforceId of Intake
        public String CampaignCaseExternalId { get; set; } // IGNORE/EXCLUDE
        public String ClientExternalId { get; set; } // salesforceId of Client
        public String First_Name { get; set; } // clientFirstName
        public String Last_Name { get; set; } // clientLastName
        public String Phone_Number { get; set; } // clientMobilePhone
        public String Email_Address { get; set; } // clientEmail
        public String Postal_Code { get; set; } // clientBillingPostalCode
        public String Case_Type { get; set; } // litify_pm__Case_Type__r.Name
        public String Campaign_Name { get; set; } // Campaign__r.Name
    }
    /*
    {
	"Message": "Record is created",
	"RecordId": "13055",
	"Errors": []
    }
    */
    public class ResponseModel {
        public String Message { get; set; } // e.g., "Record is created"
        public String RecordId { get; set; } // e.g., "13055"
        public List<String> Errors { get; set; } // e.g., []
    }
    public class ResponseWrapperModel {
        public Boolean success { get; set; } // Indicates if the operation was successful
        public String data { get; set; } // Contains the response data or error message
    }
}