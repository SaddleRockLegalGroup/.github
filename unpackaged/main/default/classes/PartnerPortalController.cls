/**
 * @description Partner Portal Functions for Files and Intake Views
 */
public without sharing class PartnerPortalController {
    /**
     * @description Partner Intake Records for List View
     * @return List<litify_pm__Intake__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<litify_pm__Intake__c> getIntakeRecords() {
        List<String> statuses = new List<String>{'Referred Out', 'Imported'};
        List<Partner_Portal_File_Folder_Directory__mdt> folderMetadata = getFolderMetadata(); // get metadata from based on user

        if (folderMetadata.isEmpty()) { return new List<litify_pm__Intake__c>(); } // return if no config available

        String partyName = folderMetadata[0].Party_Name__c; // get party name to query intakes

        if (String.isBlank(partyName)) { return new List<litify_pm__Intake__c>(); } // return if no party name to query intakes on

        List<litify_pm__Intake__c> intakes = new List<litify_pm__Intake__c>([
            SELECT
                Id, Name, CreatedDate, litify_pm__Client__r.Name, FX_Client_Name__c, FX_Caller_Equals_Client__c, Caller_Relationship_to_Client__c, What_is_your_relationship_to_IP_pk__c,
                Injured_Party_First_Name__c, Injured_Party_Middle_Name__c, Injured_Party_Last_Name__c, Injured_Party_Suffix__c, InjuredPartyGender__c, Injured_Party_Birthdate__c, 
                Injured_Party_Date_of_Death__c, litify_pm__Incident_Date__c, Injured_Party_Ethnicity__c, Injured_Party_s_SSN__c, litify_pm__Statute_of_Limitations_Date__c, 
                Serious_Injury__c, Hold_Death_Certificate__c, IP_Address__c, litify_pm__Case_Address_1__c, litify_pm__Case_Address_2__c, litify_pm__Case_City__c, litify_pm__Case_State__c, 
                FX_Client_Billing_State__c, Street_Address_1__c, Street_Address_2__c, City__c, State__c, Zip__c, Country__c, Case_Type_Name__c, litify_pm__Case_Type__r.Name,
                litify_pm__Status__c, Sub_Status__c, Referral_Partner_Name__c, Split_Fee_Percentage__c, litify_pm__Retainer_Agreement_Signed__c, litify_pm__Referred_Out_Date__c                
            FROM litify_pm__Intake__c
            WHERE Referral_Partner_Name__c != null
                AND Referral_Partner_Name__c = :partyName
                AND litify_pm__Status__c IN :statuses
                ORDER BY litify_pm__Referred_Out_Date__c DESC
        ]);

        return intakes;
    }

    /**
     * @description Partner Metadata for File Structure
     * @return List<Partner_Portal_File_Folder_Directory__mdt>
     */
    public static List<Partner_Portal_File_Folder_Directory__mdt> getFolderMetadata() {
        String userName = UserInfo.getUserName(); // get user name for query

        // get metadata for file/folder mapping
        List<Partner_Portal_File_Folder_Directory__mdt> folderDetails = new List<Partner_Portal_File_Folder_Directory__mdt>([
            SELECT MasterLabel, Username__c, Partner_Library_Id__c, Folder_Name__c, Party_Name__c
            FROM Partner_Portal_File_Folder_Directory__mdt
            WHERE Username__c = :userName
        ]);

        return folderDetails;
    }
}