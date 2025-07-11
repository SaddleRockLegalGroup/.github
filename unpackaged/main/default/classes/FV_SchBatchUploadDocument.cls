global class FV_SchBatchUploadDocument implements Schedulable {
    public final List<string> fileIds;
    public final string projectId;
    
    public FV_SchBatchUploadDocument(List<string> fileIds, string projectId){
        this.fileIds = fileIds;
        this.projectId = projectId;
    }
    
    global void execute(SchedulableContext sc){
        System.debug('**** FV_SchBatchUploadDocument date: '+ Date.today() + ' - projectId: ' + this.projectId);
        
        FV_BatchUploadDocument batchJob = new FV_BatchUploadDocument(this.fileIds, this.projectId);
        Database.executeBatch(batchJob);

        System.abortJob(sc.getTriggerId()); 
    }
    
    public static void schedule(List<string> fileIds, string projectId){
        Integer hourInteger = Datetime.now().hour();
        Integer minInteger = Datetime.now().minute();
        Integer secondInteger = Datetime.now().second() + 6;
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
        
        FV_SchBatchUploadDocument sc = new FV_SchBatchUploadDocument(fileIds, projectId);
        
        String name = 'FV_SchBatchUploadDocument ' + projectId + ' Submited at: ' + String.valueOf(Datetime.now())+ ' next: '+ nextFireTime;
        System.debug(name);

        System.schedule(name, nextFireTime, sc);
        
    }
}