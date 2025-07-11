public without sharing class UpdateIntakeStatus {
    public UpdateIntakeStatus() {}

    public static void updateStatus(String intakeId){
        litify_pm__intake__c intake = [
            select id
            from litify_pm__intake__c
            where id = :intakeId
        ];
        intake.litify_pm__Retainer_Agreement_Signed__c = System.now();
        intake.litify_pm__Status__c = 'Retainer Agreement Signed';
        update intake;
        System.debug(intake);
    }
}