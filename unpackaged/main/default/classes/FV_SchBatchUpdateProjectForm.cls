global class FV_SchBatchUpdateProjectForm implements Schedulable {
    public final string intakeId;
    public final string projectFVId;
    
    public FV_SchBatchUpdateProjectForm(string intakeId, string projectFVId){
        this.intakeId = intakeId;
        this.projectFVId = projectFVId;
    }
    
    global void execute(SchedulableContext sc){
        System.debug('**** FV_SchBatchUpdateProjectForm date: '+ Date.today() + ' - intakeId: ' + this.intakeId);
        
        FV_BatchUpdateProjectForm batchJob = new FV_BatchUpdateProjectForm(this.intakeId, this.projectFVId);
        Database.executeBatch(batchJob);

        System.abortJob(sc.getTriggerId()); 
    }
    
    public static void schedule(string intakeId, string projectFVId){
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
        
        FV_SchBatchUpdateProjectForm sc = new FV_SchBatchUpdateProjectForm(intakeId, projectFVId);
        
        String name = 'FV_SchBatchUpdateProjectForm ' + intakeId + ' Submited at: ' + String.valueOf(Datetime.now())+ ' next: '+ nextFireTime;
        System.debug(name);

        System.schedule(name, nextFireTime, sc);
        
    }
}