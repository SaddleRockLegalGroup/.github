public with sharing class DropboxSignAPITestConnection {
    public class FlowOutputs {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='DROPBOX SIGN: Test Connection')
    public static List<FlowOutputs> testDropboxConnection(){
        try {
            DropboxSignAPIRestAPI restApi = new DropboxSignAPIRestAPI();
            DropboxSignAPIModels.HttpResponseWrapper respWrapper = restApi.testConnection();
            if(respWrapper != null){
                DropboxSignAPILogger.writeLogs();
                return returnResult(respWrapper.success, respWrapper.message);
            }
            return returnResult(false, 'Internal Server Error');
        }
        catch(Exception e){
            new DropboxSignAPILogger.Log(LoggingLevel.ERROR, 'DropboxSignAPITestConnection exception',
                e.getMessage() + '\n\n' + e.getStackTraceString());
            DropboxSignAPILogger.writeLogs();
            return returnResult(false, e.getMessage());
        }
    }

    private static List<FlowOutputs> returnResult(Boolean success, string message){
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        output.success = success;
        output.message = message;
        outputs.add(output);
        return outputs;
    }
}