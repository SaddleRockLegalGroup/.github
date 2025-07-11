global class FV_BatchUpdateProjectForm implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    private string intakeId;
    private string projectFVId;

    public FV_BatchUpdateProjectForm(string intakeIdParam, string projectFVIdParam) {
        intakeId = intakeIdParam;
        projectFVId = projectFVIdParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id
                                        , Caller__c
                                        , litify_pm__Client__c
                                        , litify_pm__Case_Type__r.Name
                                        , Is_your_loved_one_still_living__c
                                        , What_is_your_relation_to_this_individual__c
                                        , Confirm_if_caller_is_next_of_kin__c
                                        , Client_Estate_Opened__c
                                        , Estate_Currently_Open__c
                                        , Hold_Death_Certificate__c
                                        , Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c
                                        , Camp_Lejuene__r.Smoking_Check__c
                                        , Camp_Lejuene__r.Do_you_currently_smoke_cigarettes__c
                                        , Camp_Lejuene__r.Have_you_ever_smoked_cigarettes_in_the_p__c
                                        , Camp_Lejuene__r.If_yes_for_how_long_have_smoked__c
                                        , Camp_Lejuene__r.How_many_cigarettes_do_you_smoke_per_day__c
                                        , Camp_Lejuene__r.If_yes_when_did_you_begin_smoking__c
                                        , Camp_Lejuene__r.When_did_you_stop_smoking__c
                                        , Camp_Lejuene__r.Documents_related_to_Camp_Lejeune__c
                                        , Camp_Lejuene__r.Nature_Of_Presence_At_Camp_Lejeune__c
                                        , Camp_Lejuene__r.Branch_discharge_status_and_rank__c
                                        , Camp_Lejuene__r.Military_Stationed_Family_Mem_Full_Name__c
                                        , Camp_Lejuene__r.Branch_of_Service__c
                                        , Camp_Lejuene__r.Discharge_Status__c
                                        , Camp_Lejuene__r.Rank_at_the_time_of_discharge__c
                                        , Camp_Lejuene__r.Tier_1_Injury_Matrix__c
                                        , Camp_Lejuene__r.Tier_2_Injury_Matrix__c
                                        , Camp_Lejuene__r.Tier_3_Injury_Matrix__c
                                        , Camp_Lejuene__r.Tier_4_Injury_Matrix__c
                                        , Camp_Lejuene__r.List_Dx_treating_doctor_names_spec__c
                                        , Camp_Lejuene__r.Treatment_Facilities_Name_and_Addresses__c
                                        , Camp_Lejuene__r.NEW_Military_Personnel_SSN__c
                                        , Camp_Lejuene__r.Military_Personnel_DOB__c
                                        , Camp_Lejuene__r.Military_Personnel_Place_of_Birth__c
                                        , Camp_Lejuene__r.Military_Personnel_Active_SN__c
                                        , Camp_Lejuene__r.Military_Personnel_Alive_or_Deceased__c
                                        , Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c
                                        , litify_pm__Description__c
                                        , Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c
                                        , Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c
                                        , Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c
                                        , Camp_Lejuene__r.Have_Medical_Records__c
                                        , Camp_Lejuene__r.Have_Military_Records__c
                                        FROM litify_pm__Intake__c
                                        WHERE Id = :intakeId
                                        LIMIT 1]) ;   
    }
    global void execute(Database.BatchableContext BC, List<litify_pm__Intake__c> scope){
        System.debug('###FV_BatchUpdateProjectForm is running###');
        litify_pm__Intake__c intake = scope[0];
        FV_RestAPIWrapper restApi = new FV_RestAPIWrapper();
        FV_Models.HttpResponseWrapper loginInfoResp = FV_RestAPIWrapper.createSession();
        if(loginInfoResp.success){
            FV_Models.LoginRespModel loginInfo = (FV_Models.LoginRespModel) JSON.deserialize(loginInfoResp.data, FV_Models.LoginRespModel.class);
            // 5. PROJECT: Update project form - Initial Intake
            Map<string,object> initialIntake = FV_PayloadBuilder.buildInitialIntakePayload(intake, projectFVId);
            FV_Models.HttpResponseWrapper initialIntakeResp = restApi.updateProjectForm(projectFVId, 'initialintake', initialIntake, loginInfo);
            // 6. PROJECT: Update project form - Mass Tort Info
            Map<string,object> massTortInfo = FV_PayloadBuilder.buildMassTortInfo(intake, projectFVId);
            FV_Models.HttpResponseWrapper massTortInfoResp = restApi.updateProjectForm(projectFVId, 'masstortinfo', massTortInfo, loginInfo);
        }
        else {
            new FV_Logger.Log(LoggingLevel.ERROR, 'FV_BatchUpdateProjectForm', loginInfoResp.data);
        }
        FV_Logger.writeLogs();
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.abortJob(a.id);
    }
}