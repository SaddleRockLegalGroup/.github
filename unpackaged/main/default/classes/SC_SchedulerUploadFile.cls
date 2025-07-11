global class SC_SchedulerUploadFile implements Schedulable {
    public final string clientName;
    public final string caseId;
    public final string fileInfoId;
    public final string type;
    
    public SC_SchedulerUploadFile(string clientName, string caseId, string fileInfoId, string type){
        this.clientName = clientName;
        this.caseId = caseId;
        this.fileInfoId = fileInfoId;
        this.type = type;
    }
    
    global void execute(SchedulableContext sc){
        System.debug('**** SC_SchedulerUploadFile date: '+ Date.today());
        
        SC_BatchUploadFile batchJob = new SC_BatchUploadFile(this.clientName, this.caseId, this.fileInfoId, this.type);
        Database.executeBatch(batchJob);

        System.abortJob(sc.getTriggerId()); 
    }
    
    public static void schedule(string clientName, string caseId, string fileInfoId, string type){
        Integer hourInteger = Datetime.now().hour();
        Integer minInteger = Datetime.now().minute();
        Integer secondInteger = Datetime.now().second() + 2;
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
        
        SC_SchedulerUploadFile sc = new SC_SchedulerUploadFile(clientName, caseId, fileInfoId, type);
        
        String name = 'SC_SchedulerUploadFile ' + fileInfoId + ' Submited at: ' + String.valueOf(Datetime.now())+ ' next: '+ nextFireTime;
        System.debug(name);

        System.schedule(name, nextFireTime, sc);
        
    }
}