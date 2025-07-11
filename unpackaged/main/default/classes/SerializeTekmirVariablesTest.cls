@isTest 
public class SerializeTekmirVariablesTest {
    @isTest
    public static void test_serialize() {
        // Create test data
        SerializeTekmirVariables.FlowInputs input = new SerializeTekmirVariables.FlowInputs();
        input.newMatterInBody = new ExternalService.STAGINGSendTekmirTheMatterES_STAGINGx20x2dx20Sendx20Tekmirx20Thex20Newx20Matterx20Action_IN_body();
        input.newMatterOut2XX = new ExternalService.STAGINGSendTekmirTheMatterES_STAGINGx20x2dx20Sendx20Tekmirx20Thex20Newx20Matterx20Action_OUT_2XX();
        input.intakeDocInBody = new ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_IN_body();
        input.intakeDocInBodyDocuments = new ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_IN_body_documents();
        input.intakeDocOut2XX = new ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_OUT_2XX();
        input.intakeDocOut2xxDocuments = new ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_OUT_2XX_documents();

        List<SerializeTekmirVariables.FlowInputs> inputs = new List<SerializeTekmirVariables.FlowInputs>{input};

        // Call the method
        Test.startTest();
        List<SerializeTekmirVariables.FlowOutputs> outputs = SerializeTekmirVariables.serialize(inputs);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, outputs.size());
        SerializeTekmirVariables.FlowOutputs output = outputs[0];
        System.assertNotEquals(null, output.newMatterInBodyString);
        System.assertNotEquals(null, output.newMatterOut2XXString);
        System.assertNotEquals(null, output.intakeDocInBodyString);
        System.assertNotEquals(null, output.intakeDocInBodyDocumentsString);
        System.assertNotEquals(null, output.intakeDocOut2XXString);
        System.assertNotEquals(null, output.intakeDocOut2xxDocumentsString);
        System.assertEquals(null, output.errorMessage);
    }

    @isTest
    public static void test_serialize_with_null_values() {
        // Create test data with null values
        SerializeTekmirVariables.FlowInputs input = new SerializeTekmirVariables.FlowInputs();
        input.newMatterInBody = null;
        input.newMatterOut2XX = null;
        input.intakeDocInBody = null;
        input.intakeDocInBodyDocuments = null;
        input.intakeDocOut2XX = null;
        input.intakeDocOut2xxDocuments = null;

        List<SerializeTekmirVariables.FlowInputs> inputs = new List<SerializeTekmirVariables.FlowInputs>{input};

        // Call the method
        Test.startTest();
        List<SerializeTekmirVariables.FlowOutputs> outputs = SerializeTekmirVariables.serialize(inputs);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, outputs.size());
        SerializeTekmirVariables.FlowOutputs output = outputs[0];
        System.assertEquals(null, output.newMatterInBodyString);
        System.assertEquals(null, output.newMatterOut2XXString);
        System.assertEquals(null, output.intakeDocInBodyString);
        System.assertEquals(null, output.intakeDocInBodyDocumentsString);
        System.assertEquals(null, output.intakeDocOut2XXString);
        System.assertEquals(null, output.intakeDocOut2xxDocumentsString);
        System.assertEquals(null, output.errorMessage);
    }
}