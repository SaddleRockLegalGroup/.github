public with sharing class IntakeDesk_Helpers {
    public static DateTime convertDateOnlyStringToDateTimeInGMT(string dateStr){
        if(dateStr == null || dateStr == '')return null;

        Date myDate = Date.valueOf(dateStr);
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime dt = DateTime.newInstanceGmt(myDate, myTime);

        Timezone tz = Timezone.getTimeZone('America/Denver'); // Use Saddlerock timezone
        Integer offSet = tz.getOffset(dt);
        Integer offSetHours = offSet/3600000;
        DateTime gmtDateTime = dt.addHours(offSetHours*(-1));

        return gmtDateTime;
    }

    public static Id getIntakeVendorId(String name){
        List<Intake_Vendor__c> vendors = [Select Id From Intake_Vendor__c Where Name=: name Limit 1];
        if(vendors.size()>0)return vendors[0].Id;return null;
    }
    public static Id getCampaignId(String name){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(name == 'Roundup' && !runningInASandbox)name = 'Round Up';
        List<Campaign__c> campaigns = [Select Id From Campaign__c Where Name=: name Limit 1];
        if(campaigns.size()>0)return campaigns[0].Id;return null;
    }
    public static Id getCaseTypeId(String name){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(name == 'Roundup' && !runningInASandbox)name = 'Round Up';
        List<litify_pm__Case_Type__c> caseTypes = [Select Id From litify_pm__Case_Type__c Where Name=: name Limit 1];
        if(caseTypes.size()>0)return caseTypes[0].Id;return null;
    }

    public static string validateSuffix(string value){
        List<string> suffixList = new List<string>{'Jr','Sr','II','III','IV','Jr.','Sr.','V','VI','VII','VIII','IX','X','N/A'};
        if(!suffixList.contains(value)){return 'N/A';}return value;
    }
    public static string validateGender(string value){
        List<string> suffixList = new List<string>{'Male', 'Female', 'Other', 'I prefer not to say', 'Unsure', 'Unknown'};
        if(!suffixList.contains(value)){return 'Unknown';}return value;
    }
    public static string validateMaritalStatusParty(string value){
        List<string> maritalStatusList = new List<string>{'Single', 'Married', 'Divorced', 'Widowed'};
        if(!maritalStatusList.contains(value)){return '';}return value;
    }
    /*public static string validateMaritalStatusInjured(string value){
        List<string> maritalStatusList = new List<string>{'Married', 'Single', 'Separated', 'Divorced', 'Unknown'};
        if(!maritalStatusList.contains(value)){
            return '';
        }
        return value;
    }*/
    public static string validateState(string value){
        List<string> stateList = new List<string>{'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','AS','DC','FM','GU','MH','MP','PW','PR','VI','ZB','Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming','District of Columbia','None of the Above'};
        if(!stateList.contains(value)){return 'None of the Above';}return value;
    }
    public static string validateFacilityType(string value){
        List<string> typeList = new List<string>{'Doctor\'s Office', 'Hospital', 'Urgent Care Center', 'Family Planning / Fertility Clinic', 'Laboratory Testing Facility', 'Rehabilitation Facility', 'Telehealth', 'Other', 'Unknown'};
        if(!typeList.contains(value)){return 'Unknown';}return value;
    }

    public static void intakeDuplicateCheckerLegacy(litify_pm__Intake__c intake, Boolean shouldUpdate){
        Id intakeId = intake.Id;
        system.debug('IntakeDesk_Helpers.intakeDuplicateChecker.intake: '+intake.Injured_Party_First_Name__c + '   lastname: '+intake.Injured_Party_Last_Name__c+ '   caseTypeName: '+intake.Case_Type_Name_del__c+'   Id: '+intake.Id);
        List<litify_pm__Intake__c> intakes = [SELECT Id, litify_pm__First_Name__c, litify_pm__Last_Name__c, Checked_For_Duplicates__c,
                                              Injured_Party_First_Name__c, Potential_Duplicate_Record_Count__c, Potential_Duplicate_IntakeId__c,
                                              Intake_Record_URL_Link__c, Injured_Party_Last_Name__c, Case_Type_Name_del__c, Campaign__c, Campaign__r.Name
                                       FROM litify_pm__Intake__c
                                       WHERE ( (Injured_Party_First_Name__c != NULL
                                                AND Injured_Party_First_Name__c = :intake.Injured_Party_First_Name__c
                                                AND Injured_Party_Last_Name__c != NULL
                                                AND Injured_Party_Last_Name__c = :intake.Injured_Party_Last_Name__c)
                                            OR
                                               (litify_pm__First_Name__c != NULL
                                                AND litify_pm__First_Name__c = :intake.litify_pm__First_Name__c
                                                AND litify_pm__Last_Name__c != NULL
                                                AND litify_pm__Last_Name__c = :intake.litify_pm__Last_Name__c) )
                                       AND Campaign__c = :intake.Campaign__c
                                       AND Id != :intakeId
                                       ORDER BY CreatedDate DESC];

        system.debug('intakes.size(): '+intakes);
        if (intakes.size() > 0) {
            system.debug('intakes.size(): '+intakes.size());

            String intakeIdsString = '';
            Integer i = 1;
            for (litify_pm__Intake__c intake1 : intakes) {
                if (i == intakes.size()) { intakeIdsString += intake1.Id; }
                else { intakeIdsString += intake1.Id + ', '; }

                i++;
            }

            intake.Potential_Duplicate_IntakeId__c = intakeIdsString;
            intake.Intake_Desk_Review__c  = 'Needs Review';
            intake.QC_Type__c = 'Duplicate';
            if (intake.Campaign__r?.Name == 'PFAS') { intake.Intake_Desk_Status__c = 'New'; }
            if (intake.Automated_QC_Notes__c == null) {
                if(intake.Potential_Duplicate_Record_Count__c != null) {
                    intake.Potential_Duplicate_Record_Count__c = intake.Potential_Duplicate_Record_Count__c + 1;
                    if (intake.Campaign__r?.Name != 'PFAS') { 
                        intake.Automated_QC_Notes__c = 'Duplicate Found: Please review before proceeding with QC Process.'; 
                    }
                }
            } else {
                if(intake.Potential_Duplicate_Record_Count__c != null){
                    intake.Potential_Duplicate_Record_Count__c  = intake.Potential_Duplicate_Record_Count__c + 1;
                }else{
                    intake.Potential_Duplicate_Record_Count__c  = 1;
                    system.debug('here');
                }

                intake.Automated_QC_Notes__c = 'Duplicate Found: Please review before proceeding with QC Process.'+intake.Automated_QC_Notes__c;
            }
            system.debug('IntakeDesk_Helpers.intakeDuplicateCheckerintake.Automated_QC_Notes__c: '+intake.Automated_QC_Notes__c);
        }
        system.debug('here');
        
        if (intake.Campaign__r?.Name == 'PFAS') { intake.Intake_Desk_Review__c  = 'Needs Review'; }
        intake.Checked_For_Duplicates__c = true;
        IntakeTriggerHandler.runOnce = true;
        if (shouldUpdate || intake.Campaign__r?.Name == 'PFAS') { update intake; }
    }
  /*  public static string convertStateCodeToState(string value) {
        if(value == null) return null;
        if(value == 'AA')  return 'Armed Forces Americas';
        if(value == 'AE')  return 'Armed Forces Europe';
        if(value == 'AK')  return 'Alaska';
        if(value == 'AL')  return 'Alabama';
        if(value == 'AP')  return 'Armed Forces Pacific';
        if(value == 'AR')  return 'Arkansas';
        if(value == 'AS')  return 'American Samoa';
        if(value == 'AZ')  return 'Arizona';
        if(value == 'CA')  return 'California';
        if(value == 'CO')  return 'Colorado';
        if(value == 'CT')  return 'Connecticut';
        if(value == 'DC')  return 'District of Columbia';
        if(value == 'DE')  return 'Delaware';
        if(value == 'FL')  return 'Florida';
        if(value == 'FM')  return 'Federated Micronesia';
        if(value == 'GA')  return 'Georgia';
        if(value == 'GU')  return 'Guam';
        if(value == 'HI')  return 'Hawaii';
        if(value == 'IA')  return 'Iowa';
        if(value == 'ID')  return 'Idaho';
        if(value == 'IL')  return 'Illinois';
        if(value == 'IN')  return 'Indiana';
        if(value == 'KS')  return 'Kansas';
        if(value == 'KY')  return 'Kentucky';
        if(value == 'LA')  return 'Louisiana';
        if(value == 'MA')  return 'Massachusetts';
        if(value == 'MD')  return 'Maryland';
        if(value == 'ME')  return 'Maine';
        if(value == 'MH')  return 'Marshall Islands';
        if(value == 'MI')  return 'Michigan';
        if(value == 'MN')  return 'Minnesota';
        if(value == 'MO')  return 'Missouri';
        if(value == 'MP')  return 'Northern Mariana Islands';
        if(value == 'MS')  return 'Mississippi';
        if(value == 'MT')  return 'Montana';
        if(value == 'NC')  return 'North Carolina';
        if(value == 'ND')  return 'North Dakota';
        if(value == 'NE')  return 'Nebraska';
        if(value == 'NH')  return 'New Hampshire';
        if(value == 'NJ')  return 'New Jersey';
        if(value == 'NM')  return 'New Mexico';
        if(value == 'NV')  return 'Nevada';
        if(value == 'NY')  return 'New York';
        if(value == 'OH')  return 'Ohio';
        if(value == 'OK')  return 'Oklahoma';
        if(value == 'OR')  return 'Oregon';
        if(value == 'PA')  return 'Pennsylvania';
        if(value == 'PR')  return 'Puerto Rico';
        if(value == 'PW')  return 'Palau';
        if(value == 'RI')  return 'Rhode Island';
        if(value == 'SC')  return 'South Carolina';
        if(value == 'SD')  return 'South Dakota';
        if(value == 'TN')  return 'Tennessee';
        if(value == 'TX')  return 'Texas';
        if(value == 'UM')  return 'United States Minor Outlying Islands';
        if(value == 'UT')  return 'Utah';
        if(value == 'VA')  return 'Virginia';
        if(value == 'VI')  return 'US Virgin Islands';
        if(value == 'VT')  return 'Vermont';
        if(value == 'WA')  return 'Washington';
        if(value == 'WI')  return 'Wisconsin';
        if(value == 'WV')  return 'West Virginia';
        if(value == 'WY')  return 'Wyoming';
        return value;
    }*/

    public static string convertJSONToTextSummary(string jsonStr){
        String summaryTxt = '';
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        for(string key : jsonMap.keySet()){
            String value = String.valueOf(jsonMap.get(key));
            if(value != null && value.startsWith('{')){
                // Handle nested JSON object
                Map<String, Object> nestedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(jsonMap.get(key)));
                summaryTxt += '\n' + key.toUpperCase() + ':\n';
                for(String nestedKey : nestedMap.keySet()){
                    summaryTxt += nestedKey + ': ' + String.valueOf(nestedMap.get(nestedKey)) + '\n';
                }
            }
            else if(value != null && jsonMap.get(key) instanceof List<Object>){
                // Handle JSON array
                List<Object> valueList = (List<Object>) jsonMap.get(key);
                for(Object item : valueList){
                    if(item instanceof Map<String, Object>){
                        Map<String, Object> itemMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(item));
                        for(String itemKey : itemMap.keySet()){
                            summaryTxt += itemKey + ': ' + String.valueOf(itemMap.get(itemKey)) + '\n';
                        }
                    }
                    else {
                        summaryTxt += key + ': ' + String.valueOf(item) + '\n';
                    }
                }
            }
            else {
                summaryTxt += key + ': ' + value + '\n';
            }
        }
        return summaryTxt;
    }
}