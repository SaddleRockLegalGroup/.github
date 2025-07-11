/**
 * @description Partner Portal Functions Intake List Views
 */
public without sharing class IntakeDeskLWCReportController {
    /**
     * @description Intake Records for List View based on
     * Intake Desk | QC - EOF/Dupe/DQ Report
     * @return List<litify_pm__Intake__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<litify_pm__Intake__c> getIntakeDeskQCReport() {
        List<String> reviewType = new List<String>{'EOF - ID', 'EOF - ID/D&C', 'EOF - DQ/Dupe', 'Passed', 'Failed'}; // Intake_Desk_Review__c
        List<String> issueType = new List<String>{'EOF', 'Duplicate', 'DQ'}; // QC_Type__c
        List<String> statuses = new List<String>{'New', 'In Progress'}; // Intake_Desk_Status__c
        List<String> intakeDeskActions = new List<String>{'Update Status', 'Correction/Clarification'};
        List<litify_pm__Intake__c> intakes = new List<litify_pm__Intake__c>([
            SELECT
                Id, Name, CreatedDate, QC_Type__c, Intake_Vendor__c, Intake_VendorName__c, FX_Intake_Desk_ID__c, litify_pm__First_Name__c, litify_pm__Last_Name__c,
                Case_Type_Name_del__c, litify_pm__Status__c, Sub_Status__c, Intake_Desk_Review__c, fx_Intake_Desk_Action__c, ID_EOF_Reason__c, FX_Full_Name__c, Automated_QC_Notes__c,
                Intake_Desk_Status__c, Intake_Note__c, litify_pm__Referred_Out_Date__c, litify_pm__Turn_Down_Reason__c, Referral_Partner_Name__c, Intake_Desk_Qualified__c,
                Test_Intake__c
            FROM litify_pm__Intake__c
            WHERE Intake_Desk_Review__c IN :reviewType
                AND (Intake_Desk_Status__c IN :statuses OR Intake_Desk_Status__c = null)
                AND QC_Type__c IN :issueType
                AND Test_Intake__c = FALSE
                AND fx_Intake_Desk_Action__c IN :intakeDeskActions
                AND Intake_Desk_Qualified__c != 'No'
                ORDER BY litify_pm__Referred_Out_Date__c DESC
        ]);

        return intakes;
    }

    /**
     * @description Intake Records for List View based on
     * Intake Desk | API Failures Report
     * @return List<brioapi__Integration_Transaction__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<brioapi__Integration_Transaction__c> getIntakeDeskAPIFailureReport() {
        List<brioapi__Integration_Transaction__c> integrations = new List<brioapi__Integration_Transaction__c>([
            SELECT
                Id, CreatedDate, Name, External_ID__c, brioapi__Vendor__c, FX_Intake_Vendor__c, brioapi__Status__c, brioapi__Request__c, brioapi__Response__c, Audited__c
            FROM brioapi__Integration_Transaction__c
            WHERE brioapi__Status__c = 'Error'
                AND (Name LIKE '%Single%' OR Name LIKE '%IntakeDesk%')
                AND Audited__c = FALSE
                AND (NOT brioapi__Vendor__c LIKE '%Etech%')
                AND (NOT brioapi__Vendor__c LIKE '%Brio%')
                ORDER BY Id DESC
        ]);

        return integrations;
    }

    @AuraEnabled
    public static String updateIntakeStatus(String intakeId, String status) {
        try {
            litify_pm__Intake__c intakeToUpdate = new litify_pm__intake__c();
            intakeToUpdate.Id = intakeId;
            intakeToUpdate.Intake_Desk_Status__c = status;
            update intakeToUpdate;

            return 'Success';
        } catch (Exception e) {
            return 'Error';
        }
    }

    /**
     * @description Intake Records for List View based on
     * Intakes with missing Docs OR Payload
     * @return List<litify_pm__Intake__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<litify_pm__Intake__c> getIntakeDeskMissingDocReport() {
        List<litify_pm__Intake__c> intakes = new List<litify_pm__Intake__c>([
            SELECT
                Id, Name, CreatedDate, Intake_VendorName__c, FX_Type_of_Payload_to_Resend__c, FX_Caller_First_Name__c, FX_Caller_Last_Name__c, litify_pm__Email__c,
                FX_Status_and_Sub_Status__c, Intake_Desk_Qualified__c, brioapi__API_External_ID__c, litify_pm__Status__c, Count_of_Signed_Retainers__c, litify_pm__Referred_Out_Date__c
            FROM litify_pm__Intake__c
            WHERE (Intake_VendorName__c = 'Intake Desk' OR brioapi__API_External_ID__c LIKE '%intakeDesk%')
                AND litify_pm__Status__c = 'Referred Out'
                AND (Intake_Desk_Qualified__c = NULL OR Count_of_Signed_Retainers__c = 0)
                ORDER BY litify_pm__Referred_Out_Date__c DESC
        ]);

        return intakes;
    }
}