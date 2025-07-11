/**
 * A utility class for app-wide constants, exceptions, and utility functions.
 * <ul>
 *  <li>diagnostic features such as debug and assert</li>
 *  <li>field truncation</li>
 * </ul>
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.ExcessivePublicCount')
public inherited sharing class SaddleRockUtils {
    public static string integrationId {get; set;}
    public static string intakeRecId {get; set;}
    public static string transRequest {get;set;}
    public static string transResponse {get;set;}
    public static string transStatus {get;set;}
    public static string transName {get;set;}
    public static string transVendor {get;set;}
    //--------------------------------------------------------------------------
    // Constants
    /** the prefix to use on all log calls */
    public static final String DEBUG_PREFIX = UserInfo.getUserName() + '~ ';

    /** The namespace prefix, including '__', if this class is in a managed package */
    public static String namespacePrefix {
        get {
            if (null == namespacePrefix) {
                final String className = SaddleRockUtils.class.getName();
                namespacePrefix = className.contains('.') ? (className.substringBefore('.') + '__') : '';
            }
            return namespacePrefix;
        }
        private set;
    }
    
    //--------------------------------------------------------------------------
    // Properties
    public static Integration__mdt settings {
        get {
            if(Test.isRunningTest()){
                return SaddleRockTestDataFactory.generateTestIntegration();
            }
            return [SELECT Id, Name__c, Log_Level__c, Log_Days_to_Keep__c, Debugging__c, Active__c, Sync_Date_Field__c 
            FROM Integration__mdt 
            WHERE Id = :integrationId
            LIMIT 1];
        }
        set;
    }
    
    //--------------------------------------------------------------------------
    // Methods
    /** @return true if the current execution context is asynchronous */
    public static Boolean isRunningAsync() {
        return System.isFuture() || System.IsBatch() || System.isQueueable();
    }


    //--------------------------------------------------------------------------
    // Exceptions
    /** base class for all BRIO exceptions */
    public abstract class BrioException extends Exception {
    }
    
    /** a failed assertion */
    public class AssertionException extends BrioException {
    }

    public static void throwIf(Boolean condition, Exception e) {
        if (true == condition) {
            throw e;
        }
    }

    //--------------------------------------------------------------------------
    // Diagnostics
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
    
    /** Assert a condition; throws on failure when debugging */
    public static void assert(Boolean condition) {
        assert(condition, null);
    }
    
    /** Assert equality; throws on failure when debugging */
    public static void assertEquals(Object v1, Object v2) {
        assertEquals(v1, v2, null);
    }
    /** Assert equality; throws on failure when debugging */
    public static void assertEquals(Object v1, Object v2, Object message) {
        assert(v1 == v2, message);
    }
    
    /** Assert inequality; throws on failure when debugging */
    public static void assertNotEquals(Object v1, Object v2) {
        assertNotEquals(v1, v2, null);
    }
    /** Assert inequality; throws on failure when debugging */
    public static void assertNotEquals(Object v1, Object v2, Object message) {
        assert(v1 != v2, message);
    }
    
    /** Assert a condition; throws on failure when debugging*/
    public static void assert(Boolean condition, Object message) {
        if (debugging && !condition) {
            throw new AssertionException(String.valueOf(message));
        }
    }
    
    public static Object mapGetCaseInsensitive(Map<String,Object> m, String k) {
        assertNotEquals(null,  m, 'map is required');
        for (String mk : m.keySet()) {
            if (mk == k) {
                return m.get(mk);
            }
        }
        return null;
    }

    /**
     * Truncate a field on an object to the max length of the field.
     * Example:
     *    // if Foo__c max length is 10, 'v' is a string and 'v's length
     *    // is longer than allowed for Foo__c, the returned value will
     *    // be truncated
     *    truncate(MyObj__c.Foo__c, v);
     *
     * @param f the field
     * @param v the value to be truncated
     * @return the truncated value
     */
    public static Object truncate(SObjectField f, Object v) {
        assertNotEquals(null, f, 'field is required');
        final Set<DisplayType> stringTypes = new Set<DisplayType> {
            DisplayType.Email, DisplayType.EncryptedString, DisplayType.MultiPicklist, DisplayType.Phone,
            DisplayType.Picklist, DisplayType.String, DisplayType.TextArea, DisplayType.URL
        };
        return stringTypes.contains(f.getDescribe().getType()) ? 
            truncate(String.valueOf(v), f.getDescribe().getLength()) : v;
    }
    public static String truncate(String v, Integer maxLen) {
        assert(maxLen >= 0, 'maxLen >= 0 is required');
        if ((null != v) && (v.length() > maxLen)) {
                v = v.left(Math.max(0, maxLen));
        }

        return v;
    }

    //--------------------------------------------------------------------------
    // SObject and SObjectField methods (these are expensive calls, so we'll cache them)
    private static Map<String,SObjectType> globalDescribe;
    private static Map<String,DescribeSObjectResult> sObjectDescribeCache = new Map<String,DescribeSObjectResult>();
    private static Map<String,Map<String,SObjectField>> sObjectFields = new Map<String,Map<String,SObjectField>>();

    public static SObjectType getSObjectType(String objType) {
        DescribeSObjectResult describe = getDescribe(objType);
        return (null == describe) ? null : describe.getSObjectType();
    }
    
    public static DescribeSObjectResult getDescribe(SObjectType t) {
        return getDescribe(String.valueOf(t));
    }
    public static DescribeSObjectResult getDescribe(String s) {
        s = s?.toLowerCase();
        if (String.isNotBlank(s) && !sObjectDescribeCache.containsKey(s)) {
            if (null == globalDescribe) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            if (globalDescribe.containsKey(s)) {
                sObjectDescribeCache.put(s, globalDescribe.get(s).getDescribe());
            }
        }
        return sObjectDescribeCache.get(s);
    }

    public static Map<String,SObjectField> getFields(SObjectType t) {
        return getFields(String.valueOf(t));
    }
    public static Map<String,SObjectField> getFields(String s) {
        s = s?.toLowerCase();
        if ((null != s) && !sObjectFields.containsKey(s)) {
            sObjectFields.put(s, getDescribe(s).fields.getMap());
        }
        return sObjectFields.get(s);
    }

    public static SObjectField getField(SObjectType objType, String fieldPath) {
        return getField(String.valueOf(objType), fieldPath);
    }
    public static SObjectField getField(String objType, String fieldPath) { // NOPMD
        SObjectField f;
        if (String.isNotBlank(objType) && String.isNotBlank(fieldPath)) {
            fieldPath = fieldPath.deleteWhitespace().toLowerCase();
            if (!fieldPath.contains('.')) {
                f = getFields(objType).get(fieldPath);
            } else {
                String relationship = fieldPath.substringBefore('.');
                if (String.isNotBlank(relationship)) {
                    relationship = relationship.endsWith('__r') ? relationship.replace('__r', '__c') : (relationship + 'Id');
                    f = getFields(objType).get(relationship);
                    if (null != f) { // NOPMD
                        SObjectType parentType = f.getDescribe().getReferenceTo()[0];
                        f = getField(parentType, fieldPath.substringAfter('.'));
                    }
                }
            }
        }
        return f;
    }

    // return the value for the specified field; support "dot notation"
    public static Object getFieldValue(SObject obj, String field) {
        assert(String.isNotBlank(field), 'field is required');

        Integer sep;
        field = field.deleteWhitespace();
        while ((null != obj) && (sep = field.indexOf('.')) > 0) {
            obj = obj.getSObject(field.substring(0, sep));
            field = field.subString(sep + 1);
        }
        
        return (null == obj) ? null : obj.get(field);
    }
      
    public static Set<String> getPickListValues(SObjectField field) {
        Set<String> results = new Set<String>();
        if (null != field) {
            for (PicklistEntry e : field.getDescribe().getPickListValues()) {
                results.add(e.getValue());
            }
        }
        return results;
    }

    public static Boolean isPicklistValue(String value, SObjectField field) {
        for (String v : getPickListValues(field)) {
            if (v == value) {
                return true;
            }
        }
        return false;
    }

    // return true if all values are in the specified picklist. These can
    // be an array of strings or the values() of an enum
    public static Boolean allArePicklistValues(Object[] values, SObjectField field) {
        assertNotEquals(null, values, 'values required');

        Set<String> picklistValues = new Set<String>();
        for (String v : getPickListValues(field)) {
            picklistValues.add(v.toLowerCase());
        }

        for (Object objType : values) {
            if (!picklistValues.contains(String.valueOf(objType).toLowerCase())) {
                return false;
            }
        }

        return true;
    }

    /**
     * Logging, includes timing request/result tracking for callouts.
     *
     * Multiple start/stops are not allowed. "getElapsed" will 
     * always return the difference between the last stop (or last call to "getElapsed",
     * if not explicitely called), and the last start (when constructed, if not 
     * explicitely called)
     */
    @TestVisible static Integration_Log__c[] logs = new Integration_Log__c[]{};
    public class Log {
        //---------------------------------------------------------------------
        // Properties
        Integration_Log__c theLog = new Integration_Log__c();

        //---------------------------------------------------------------------
        // Methods
        public Log(LoggingLevel level, String name) {
            this(level, name, null);
        }
        public Log(LoggingLevel level, String name, Object detail) { // NOPMD
            theLog.Level__c = String.valueOf((null != level) ? level : LoggingLevel.NONE);
            theLog.Name = (null != name) ? name : '(unnamed)';
            theLog.Log__c = (null != detail) ? String.valueOf(detail) : '(no detail)';
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
        Integration_Transaction__c trans = new Integration_Transaction__c();
        if(!string.isEmpty(transName) && !string.isBlank(transName)){
            trans.Name = transName;
            trans.Request__c = transRequest;
            trans.Response__c = transResponse;
            trans.Intake__c = !string.isEmpty(intakeRecId) ? intakeRecId : null;
            trans.Status__c = transStatus;
            trans.Vendor__c = transVendor;
            System.debug(trans);
        }

        Database.DMLOptions dmlOptionsTrans = new Database.DMLOptions();
        dmlOptionsTrans.allowFieldTruncation = true;
        Database.insert(trans, dmlOptionsTrans);


        // get the user-specified log levels to save
        if(settings.Debugging__c){
            Integration_Log__c[] logsToInsert = new Integration_Log__c[]{};
            final Set<String> logLevels = new Set<String>();
            for (String l : (null == settings.Log_Level__c) ? new String[]{} :
                settings.Log_Level__c.split(',')) {
                logLevels.add(l.trim().toUpperCase());
            }
            for (Integration_Log__c l : logs) {
                if (logLevels.contains(l.Level__c)) {
                    l.Integration_Transaction__c = (trans != null && !string.isEmpty(trans.Id)) ? trans.Id : null;
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
    
            // auto-clean up old logs
            if (Schema.sObjectType.Integration_Log__c.isAccessible() && Schema.sObjectType.Integration_Log__c.isDeletable() ){
                if (null != settings.Log_Days_to_Keep__c) {
                    final Datetime cutoff = Datetime.now().addDays((Integer)-settings.Log_Days_to_Keep__c);
                    delete [SELECT Id FROM Integration_Log__c WHERE CreatedDate < :cutoff];
                }
            }
        }
        
    }

    public static String getClassName(Object o) {
        return String.valueOf(o).split(':')[0];
    }

    //--------------------------------------------------------------------------
    // Helpers
    @testVisible private SaddleRockUtils() { // prevent construction
        return;
    }
}