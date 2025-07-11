@isTest
public with sharing class SaddleRockVendorHandlerTest {
    @isTest
    public static void testAddNewVendor() {
        SaddleRockVendorHandler.FlowInputs input = new SaddleRockVendorHandler.FlowInputs();
        input.active = true;
        input.integration = 'TestIntegration';
        input.vendorName = 'Test Vendor 1';
        input.vendorSFOrgId = 'sforgid123';
        List<SaddleRockVendorHandler.FlowInputs> request = new List<SaddleRockVendorHandler.FlowInputs>();
        request.add(input);

        Test.startTest();
        SaddleRockVendorHandler.newVendor(request);
        Test.stopTest();
    }
}