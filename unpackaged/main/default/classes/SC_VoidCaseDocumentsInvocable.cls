public with sharing class SC_VoidCaseDocumentsInvocable {
    public class FlowInputs {
        @InvocableVariable(label='Simply Convert Case UUID' required=true) public string caseId;
    }

    @InvocableMethod(label='SIMPLY CONVERT API: VOID CASE DOCUMENTS')
    public static void voidCaseDocument(List<FlowInputs> request){
        string caseId = request[0].caseId;     
        executeVoid(caseId);   
    }

    @future(callout=true)
    private static void executeVoid(string caseId){
        SC_RestAPIWrapper restApi = new SC_RestAPIWrapper();
        try{
            Map<string,object> caseResp = restApi.voidDocument(caseId);
            if(caseResp != null && Boolean.valueOf(caseResp.get('success'))){
                Map<string,object> updatedCaseReq = new Map<string,object>();
                updatedCaseReq.put('status_id', 17);
                Map<string,object> updatedCaseRes = restApi.updateCaseUsingMap(updatedCaseReq, caseId);
                if( updatedCaseRes == null || (updatedCaseRes != null && !Boolean.valueOf(updatedCaseRes.get('success')))){
                    new SC_Logger.Log(LoggingLevel.ERROR, 'SC_VoidCaseDocumentsInvocable', 'Failed to update status_id of case ' + caseId + ' to 17. Details: ' + updatedCaseRes.get('data'));
                }
            }
            else {
                new SC_Logger.Log(LoggingLevel.ERROR, 'SC_VoidCaseDocumentsInvocable', 'Failed to void documents of case ' + caseId);
            }

            SC_Logger.writeLogs();
        }
        catch(Exception e){
            System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
            new SC_Logger.Log(LoggingLevel.ERROR, 'SC_VoidCaseDocumentsInvocable', e.getMessage() + '\n\n' + e.getStackTraceString());
            SC_Logger.writeLogs();
        }
    }
}