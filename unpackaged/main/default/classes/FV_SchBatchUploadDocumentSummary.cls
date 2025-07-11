global class FV_SchBatchUploadDocumentSummary implements Schedulable {
    public final string intakeId;
    public final string projectFVId;
    public final string retainerFileId;
    public final string questionnaireFileId;
    public final string callerFVId;
    public final string clientFVId;
    
    public FV_SchBatchUploadDocumentSummary(string intakeId, string projectFVId, string retainerFileId, string questionnaireFileId, string callerFVId, string clientFVId){
        this.intakeId = intakeId;
        this.projectFVId = projectFVId;
        this.retainerFileId = retainerFileId;
        this.questionnaireFileId = questionnaireFileId;
        this.callerFVId = callerFVId;
        this.clientFVId = clientFVId;
    }
    
    global void execute(SchedulableContext sc){
        System.debug('**** FV_SchBatchUploadDocumentSummary date: '+ Date.today() + ' - intakeId: ' + this.intakeId);
        
        FV_BatchUploadDocumentSummary batchJob = new FV_BatchUploadDocumentSummary(this.intakeId, this.projectFVId, this.retainerFileId, this.questionnaireFileId, this.callerFVId, this.clientFVId);
        Database.executeBatch(batchJob);

        System.abortJob(sc.getTriggerId()); 
    }
    
    public static void schedule(string intakeId, string projectFVId, string retainerFileId, string questionnaireFileId, string callerFVId, string clientFVId){
        Integer hourInteger = Datetime.now().hour();
        Integer minInteger = Datetime.now().minute();
        Integer secondInteger = Datetime.now().second() + 4;
        if(Test.isRunningTest()){
            hourInteger = 23;
            minInteger = 59;
            secondInteger = 60;
        }
        if(secondInteger > 59){
            secondInteger = secondInteger - 59;
            minInteger = minInteger + 1;
            if(minInteger > 59){
                minInteger = minInteger - 59;
                hourInteger = hourInteger + 1;
                if(hourInteger > 23){
                    hourInteger = hourInteger - 23;
                }
            }
        }

        String hour = String.valueOf(hourInteger);
        String min = String.valueOf(minInteger); 
        String ss = String.valueOf(secondInteger);
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        FV_SchBatchUploadDocumentSummary sc = new FV_SchBatchUploadDocumentSummary(intakeId, projectFVId, retainerFileId, questionnaireFileId, callerFVId, clientFVId);
        
        String name = 'FV_SchBatchUploadDocumentSummary ' + intakeId + ' Submited at: ' + String.valueOf(Datetime.now())+ ' next: '+ nextFireTime;
        System.debug(name);

        System.schedule(name, nextFireTime, sc);
        
    }
}