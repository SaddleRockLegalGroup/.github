public with sharing class SaddleRockTestDataFactory {
    public static litify_docs__File_Info__c createTestFileInfo(){
        litify_docs__File_Info__c fileInfo = new litify_docs__File_Info__c();
        fileInfo.Name = 'Test document';
        fileInfo.litify_docs__Description__c = 'This is a test';
        fileInfo.litify_docs__Author__c = 'Test User';
        fileInfo.litify_docs__External_ID__c = 'test123';
        fileInfo.litify_docs__Complete__c = true;
        fileInfo.litify_docs__Delete__c = false;
        insert fileInfo;
        return fileInfo;
    }

    public static litify_pm__Intake__c createTestIntake(string firstName, string lastName) {
        Account acct = new Account();
        acct.litify_pm__First_Name__c = firstName;
        acct.litify_pm__Last_Name__c = lastName;
        insert acct;
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acct.Id;
        insert intake;
        return intake;
    }
    public static Integration__mdt generateTestIntegration(){
        Map<String, Object> mockMapping = new Map<String, Object>
        {
            'attributes' => new Map<String, Object>
            {
                'type' => 'Integration_Inbound_Payload__mdt '
            },
            'Base_SObject__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'EntityDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Intake__c'
            },
            'Name__c' => 'Test Integration',
            'Log_Level__c' => 'DEBUG, ERROR',
            'Log_Days_to_Keep__c' => 90,
            'Debugging__c' => true,
            'Active__c' => true,
            'Sync_Date_Field__c' => 'Date_Last_Modified_by_API__c'
        };
        Integration__mdt testIntegration = (Integration__mdt)JSON.deserialize(
            JSON.serialize(mockMapping), Integration__mdt.class
        );
        return testIntegration;
    }
    public static Integration_Vendor__mdt generateTestVendor(){
        Integration_Vendor__mdt test = new Integration_Vendor__mdt();
        test.OrgID__c = 'test';
        test.API_Key__c = 'testapi123';
        test.Active__c = true;
        test.Label = 'Test Vendor';
        return test;
    }
    public static Integration_Inbound_Payload__mdt[] generateTestInboundPayloadMapping(){
        Integration_Inbound_Payload__mdt[] result = new Integration_Inbound_Payload__mdt[]{};
        Map<String, Object> mockMapping = new Map<String, Object>
        {
            'attributes' => new Map<String, Object>
            {
                'type' => 'Integration_Inbound_Payload__mdt '
            },
            'SObject__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'EntityDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Intake__c'
            },
            'Target_Field__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'FieldDefinition'
                },
                'QualifiedApiName' => 'Id'
            },
            'JSON_Key__c' => 'id',
            'JSON_Type__c' => 'Field',
            'Active__c' => true,
            'JSON_Parent__c' => null
        };

        Map<String, Object> mockMapping1 = new Map<String, Object>
        {
            'attributes' => new Map<String, Object>
            {
                'type' => 'Integration_Inbound_Payload__mdt '
            },
            'SObject__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'EntityDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Intake__c'
            },
            'Target_Field__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'FieldDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Description__c'
            },
            'JSON_Key__c' => 'description',
            'JSON_Type__c' => 'Field',
            'Active__c' => true,
            'JSON_Parent__c' => null
        };

        Map<String, Object> mockMapping2 = new Map<String, Object>
        {
            'attributes' => new Map<String, Object>
            {
                'type' => 'Integration_Inbound_Payload__mdt '
            },
            'SObject__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'EntityDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Intake__c'
            },
            'Target_Field__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'FieldDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Client__c'
            },
            'JSON_Key__c' => 'client',
            'JSON_Type__c' => 'Object',
            'Active__c' => true,
            'JSON_Parent__c' => null
        };

        Map<String, Object> mockMapping3 = new Map<String, Object>
        {
            'attributes' => new Map<String, Object>
            {
                'type' => 'Integration_Inbound_Payload__mdt '
            },
            'SObject__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'EntityDefinition'
                },
                'QualifiedApiName' => 'Account'
            },
            'Target_Field__r' => new Map<String, Object>
            {
                'attributes' => new Map<String, Object>
                {
                    'type' => 'FieldDefinition'
                },
                'QualifiedApiName' => 'litify_pm__Date_of_birth__c'
            },
            'JSON_Key__c' => 'clientDateOfBirth',
            'JSON_Type__c' => 'Field',
            'Active__c' => true,
            'JSON_Parent__c' => 'client'
        };



        Integration_Inbound_Payload__mdt mapping = (Integration_Inbound_Payload__mdt)JSON.deserialize(
            JSON.serialize(mockMapping), Integration_Inbound_Payload__mdt.class
        );
        Integration_Inbound_Payload__mdt mapping1 = (Integration_Inbound_Payload__mdt)JSON.deserialize(
            JSON.serialize(mockMapping1), Integration_Inbound_Payload__mdt.class
        );
        Integration_Inbound_Payload__mdt mapping2 = (Integration_Inbound_Payload__mdt)JSON.deserialize(
            JSON.serialize(mockMapping2), Integration_Inbound_Payload__mdt.class
        );
        Integration_Inbound_Payload__mdt mapping3 = (Integration_Inbound_Payload__mdt)JSON.deserialize(
            JSON.serialize(mockMapping3), Integration_Inbound_Payload__mdt.class
        );

        result.add(mapping);
        result.add(mapping1);
        result.add(mapping2);
        result.add(mapping3);

        return result;
    }
    public static List<Integration_Setting__mdt> generateTestIntegrationSetting(){
        Integration_Setting__mdt test = new Integration_Setting__mdt();
        test.Client_ID__c = 'clientid-123';
        test.Client_Secret__c = 'clientsecret-123';
        return new List<Integration_Setting__mdt>{test};
    }
    public static void createTestDocrioSetting(){
        docriosdk__Docrio_Tool_Setting__c setting = new docriosdk__Docrio_Tool_Setting__c();
        setting.docriosdk__Connected_App_Consumer_Key__c = 'TEST-DOCRIO-KEY';
        setting.docriosdk__Connected_App_Consumer_Secret__c = 'TEST-DOCRIO-SECRET';
        setting.docriosdk__API_Endpoint__c = 'https://api.123.genesisapi.com/v1';
        setting.docriosdk__Bucket_Name__c = 'https://456-us-east-2-documents.s3.us-east-2.amazonaws.com';
        insert setting;
    }
}