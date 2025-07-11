public with sharing class Etech_Logger {    
    public static final String DEBUG_PREFIX = UserInfo.getUserName() + '~ ';
    
    public static Etech_API_Setting__c settings {
        get {
            return Etech_API_Setting__c.getOrgDefaults();
        }
        set;
    }
    
    @TestVisible static Integration_Log__c[] logs = new Integration_Log__c[]{};
        public class Log {
            Integration_Log__c theLog = new Integration_Log__c();
            public Log(LoggingLevel level, String name, Object detail, string relatedRecId) {
                theLog.Level__c = String.valueOf((null != level) ? level : LoggingLevel.NONE);
                theLog.Name = (null != name) ? name : '(unnamed)';
                theLog.Log__c = (null != detail) ? String.valueOf(detail) : '(no detail)';
                theLog.Intake__c = !string.isEmpty(relatedRecId) ? relatedRecId : null;            
                start();
                logs.add(theLog);
            }
            
            public void start() {
                theLog.Start__c = System.currentTimeMillis();
            }
            
            public void stop() {
                theLog.Stop__c = System.currentTimeMillis();
            }
            
            public void setRequest(HttpRequest r) {
                theLog.Request__c = (null != r) ? (r.toString()  + '\n\nBody: ' + r.getBody()) : null;
            }
            
            public void setResponse(HttpResponse r) {
                theLog.Response__c = (null != r) ? (r.toString()  + '\n\nBody: ' + r.getBody()) : null;
            }
        }
    
    public static void writeLogs() {
        // get the user-specified log levels to save
        if(settings.Debugging__c){
            if (!logs.isEmpty()) {
                for (Integration_Log__c l : logs) {
                    l.Stop__c = (null == l.Stop__c) ? System.currentTimeMillis() : l.Stop__c;
                }
                Database.DMLOptions dmlOptions = new Database.DMLOptions();
                dmlOptions.allowFieldTruncation = true;
                Database.insert(logs, dmlOptions);
            }
            logs.clear();
        }
    }
}