public class SerializeTekmirVariables {
    public class FlowInputs {
        @InvocableVariable public ExternalService.STAGINGSendTekmirTheMatterES_STAGINGx20x2dx20Sendx20Tekmirx20Thex20Newx20Matterx20Action_IN_body newMatterInBody;
        @InvocableVariable public ExternalService.STAGINGSendTekmirTheMatterES_STAGINGx20x2dx20Sendx20Tekmirx20Thex20Newx20Matterx20Action_OUT_2XX newMatterOut2XX;
        @InvocableVariable public ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_IN_body intakeDocInBody;
        @InvocableVariable public ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_IN_body_documents intakeDocInBodyDocuments;
        @InvocableVariable public ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_OUT_2XX intakeDocOut2XX;
        @InvocableVariable public ExternalService.TemkirDocrioDocuments_Sendx20Tekmirx20Intakex20Documents_OUT_2XX_documents intakeDocOut2xxDocuments;
    }
    public class FlowOutputs {
        @InvocableVariable public String newMatterInBodyString;
        @InvocableVariable public String newMatterOut2XXString;
        @InvocableVariable public String intakeDocInBodyString;
        @InvocableVariable public String intakeDocInBodyDocumentsString;
        @InvocableVariable public String intakeDocOut2XXString;
        @InvocableVariable public String intakeDocOut2xxDocumentsString;
        @InvocableVariable public String errorMessage;
    }

    @InvocableMethod(label='BRIO: Serialize Tekmir Variables')
    public static List<FlowOutputs> serialize(List<FlowInputs> request){
        List<FlowOutputs> result = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        try {
        output.newMatterInBodyString = request[0].newMatterInBody != null ? JSON.serialize(request[0].newMatterInBody) : null;
        output.newMatterOut2XXString = request[0].newMatterOut2XX != null ? JSON.serialize(request[0].newMatterOut2XX) : null;
        output.intakeDocInBodyString = request[0].intakeDocInBody != null ? JSON.serialize(request[0].intakeDocInBody) : null;
        output.intakeDocInBodyDocumentsString = request[0].intakeDocInBodyDocuments != null ? JSON.serialize(request[0].intakeDocInBodyDocuments) : null;
        output.intakeDocOut2XXString = request[0].intakeDocOut2XX != null ? JSON.serialize(request[0].intakeDocOut2XX) : null;
        output.intakeDocOut2xxDocumentsString = request[0].intakeDocOut2xxDocuments != null ? JSON.serialize(request[0].intakeDocOut2xxDocuments) : null;
        output.errorMessage = null;
        }
        catch(Exception e){
            output.errorMessage = e.getMessage() + '-' + e.getStackTraceString();
        }
        result.add(output);

        return result;     
    }
}