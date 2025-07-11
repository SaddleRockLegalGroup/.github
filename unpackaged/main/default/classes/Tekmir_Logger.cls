public with sharing class Tekmir_Logger {
    public static string relatedRecId {get; set;}

    public static final String DEBUG_PREFIX = UserInfo.getUserName() + '~ ';

    public static Tekmir_API_Settings__c settings {
        get {
            return Tekmir_API_Settings__c.getOrgDefaults();
        }
        set;
    }

    /** Use this flag to conditionally provide diagnostics */
    public static Boolean debugging { get { return (true == settings.Debugging__c); } }
        
    /** Write an error message to the log */
    public static void error(Object message) {
        debug(LoggingLevel.ERROR, message);
    }

    /** Write a warning message to the log */
    public static void warn(Object message) {
        debug(LoggingLevel.WARN, message);
    }

    /** Write an info message to the log */
    public static void info(Object message) {
        debug(LoggingLevel.INFO, message);
    }

    /** Write a debug message to the log */
    public static void debug(Object message) {
        debug(LoggingLevel.DEBUG, message);
    }

    public static void debug(LoggingLevel level, Object message) {
        if (debugging) {
            System.debug(level, DEBUG_PREFIX + message);
        }
    }

    @TestVisible static Integration_Log__c[] logs = new Integration_Log__c[]{};
    public class Log {
        Integration_Log__c theLog = new Integration_Log__c();

        public Log(LoggingLevel level, String name) {
            this(level, name, null);
        }
        public Log(LoggingLevel level, String name, Object detail) {
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

        public override String toString() {
            return theLog.Name + ' time: ' + getElapsed() + ' ms';
        }

        //---------------------------------------------------------------------
        // Helpers
        @TestVisible Decimal getElapsed() {
            return ((null == theLog.Stop__c) ? System.currentTimeMillis() : theLog.Stop__c) - theLog.Start__c;
        }
    }

    public static void writeLogs() {
        // get the user-specified log levels to save
        if(settings.Debugging__c){
            Integration_Log__c[] logsToInsert = new Integration_Log__c[]{};
            final Set<String> logLevels = new Set<String>();
            for (String l : (null == settings.Log_Levels__c) ? new String[]{} :
                settings.Log_Levels__c.split(',')) {
                logLevels.add(l.trim().toUpperCase());
            }
            for (Integration_Log__c l : logs) {
                if (logLevels.contains(l.Level__c)) {
                    logsToInsert.add(l);
                }
            }
    
            if (!logsToInsert.isEmpty()) {
                for (Integration_Log__c l : logsToInsert) {
                    l.Stop__c = (null == l.Stop__c) ? System.currentTimeMillis() : l.Stop__c;
                }
                Database.DMLOptions dmlOptions = new Database.DMLOptions();
                dmlOptions.allowFieldTruncation = true;
                Database.insert(logsToInsert, dmlOptions);
            }
            logs.clear();
        }
    }
}