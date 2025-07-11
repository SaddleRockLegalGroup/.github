public class PostInstallScripts {
    public static final String strKey = 'Xp2s5v8y/B?D(G+K';

    public static void copyQuestionsAndQuestionnaires() {
        List<litify_pm__Question__c> l_questions = [SELECT Id, External_Id__c FROM litify_pm__Question__c];
        Blob key = Blob.valueOf(strKey);
        for(litify_pm__Question__c item : l_questions) {
            Blob data = Blob.valueOf(item.Id);
            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
            item.External_Id__c = EncodingUtil.base64Encode(encrypted);
        }   
        update l_questions;
        List<litify_pm__Questionnaire__c> l_questioners = [SELECT Id, External_Id__c FROM litify_pm__Questionnaire__c];
        for(litify_pm__Questionnaire__c item : l_questioners) {
            Blob data = Blob.valueOf(item.Id);
            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
            item.External_Id__c = EncodingUtil.base64Encode(encrypted);
        }   
        update l_questioners;
    }
    
    public static void updateQuestionnaries(Set<Id> s_ids) {
        Blob keyEncode = Blob.valueOf(strKey);
        Map<String, Id> m_questions = new Map<String,Id>();
        for(litify_pm__Question__c item: [SELECT Id, External_Id__c FROM litify_pm__Question__c WHERE External_Id__c != null]) {
            Blob encrypted = EncodingUtil.base64Decode(item.External_Id__c);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', keyEncode, encrypted);
            String decryptedStr = decrypted.tostring();
            m_questions.put(decryptedStr, item.Id);
        }   
        Map<String, Id> m_questioners = new Map<String,Id>();
        for(litify_pm__Questionnaire__c item: [SELECT Id, External_Id__c FROM litify_pm__Questionnaire__c WHERE External_Id__c != null]) {
            Blob encrypted = EncodingUtil.base64Decode(item.External_Id__c);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', keyEncode, encrypted);
            String decryptedStr = decrypted.tostring();
            m_questioners.put(decryptedStr, item.Id);
        } 
        List<litify_pm__Questionnaire__c> l_questionnaires = [SELECT Id, litify_pm__questions__c , litify_pm__SObject_Modifications__c  FROM litify_pm__Questionnaire__c];
        if (s_ids != null && s_ids.size() > 0) {
            l_questionnaires = [SELECT Id, litify_pm__questions__c , litify_pm__SObject_Modifications__c  FROM litify_pm__Questionnaire__c WHERE Id IN : s_ids];
        }
        for(litify_pm__Questionnaire__c item : l_questionnaires) {
            for(String key : m_questions.keySet()) {
                if (item.litify_pm__questions__c != null) {
                    item.litify_pm__questions__c = item.litify_pm__questions__c.replaceAll(key, m_questions.get(key));
                }
                if (item.litify_pm__SObject_Modifications__c != null) {
                    item.litify_pm__SObject_Modifications__c = item.litify_pm__SObject_Modifications__c.replaceAll(key, m_questions.get(key));
                }
            }
            for(String key : m_questioners.keySet()) {
                if (item.litify_pm__questions__c != null) {
                    item.litify_pm__questions__c = item.litify_pm__questions__c.replaceAll(key, m_questioners.get(key));
                }
                if (item.litify_pm__SObject_Modifications__c != null) {
                    item.litify_pm__SObject_Modifications__c = item.litify_pm__SObject_Modifications__c.replaceAll(key, m_questioners.get(key));
                }
            }
            
        }
        update l_questionnaires;
    }
    public static void updateQuestionnaries() {
        updateQuestionnaries(null);
    }
    
    
    public static void updateTeamMembers () {
        List<litify_pm__Default_Matter_Team_Member__c> l_teams = [
                                                                    SELECT Id, 
                                                                    litify_pm__Default_Matter_Team__r.Name, 
                                                                    litify_pm__User__c, 
                                                                    litify_pm__Role__r.Name 
                                                                    FROM litify_pm__Default_Matter_Team_Member__c   
                                                                    WHERE litify_pm__Default_Matter_Team__r.Name IN 
                                                                    ('Workers Compensation','SSD','Personal Injury','Mass Tort')
                                                                 ];
        User wcAttorney = [SELECT ID FROM USER WHERE  LastName= 'Attorney' AND FirstName = 'Workers Compensation'];
        User wcParalegal = [SELECT ID FROM USER WHERE LastName = 'Paralegal' AND FirstName = 'Workers Compensation'];
        User ssdAttorney = [SELECT ID FROM USER WHERE LastName = 'Attorney' AND FirstName = 'SSD'];
        User ssdParalegal = [SELECT ID FROM USER WHERE LastName = 'Paralegal' AND FirstName = 'SSD'];
        User piAttorney = [SELECT ID FROM USER WHERE LastName = 'Attorney' AND FirstName = 'Personal Injury'];
        User piParalegal = [SELECT ID FROM USER WHERE LastName = 'Paralegal' AND FirstName = 'Personal Injury'];
        User mtAttorney = [SELECT ID FROM USER WHERE LastName = 'Attorney' AND FirstName = 'Mass Tort'];
        User mtParalegal = [SELECT ID FROM USER WHERE LastName = 'Paralegal' AND FirstName = 'Mass Tort'];
        for(litify_pm__Default_Matter_Team_Member__c item : l_teams) {
            if (item.litify_pm__Default_Matter_Team__r.Name == 'Workers Compensation') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = wcAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = wcParalegal.Id;
                }
            }
            else if (item.litify_pm__Default_Matter_Team__r.Name == 'SSD') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = ssdAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = ssdParalegal.Id;
                }
            }
            else if (item.litify_pm__Default_Matter_Team__r.Name == 'Personal Injury') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = piAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = piParalegal.Id;
                }
            }
            else if (item.litify_pm__Default_Matter_Team__r.Name == 'Mass Tort') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = mtAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = mtParalegal.Id;
                }
            }
        }
        update l_teams;
    }
    
    public static void createUserStructurePIEssentials() {
        List<Profile> l_profiles = [
                                    SELECT Id, Name FROM Profile WHERE Name IN (
                                                                                'Litify Intakes Agent',
                                                                                'Litify Intakes Manager',
                                                                                'Litify Attorney',
                                                                                'Litify Paralegal/Case Manager',
                                                                                'Litify Accountant'
                                                                                )
                                    ];
        Map<String, Id> m_pofiles = new Map<String, Id>();
        for(Profile item : l_profiles) {
            m_pofiles.put(item.Name, item.Id);
        }
        
         List<UserRole> l_roles = [SELECT Id, Name FROM UserRole];
        Map<String, Id> m_roles = new Map<String, Id>();
        for(UserRole item : l_roles) {
            m_roles.put(item.Name, item.Id);
        }
        List<String> l_str = Userinfo.getUserName().split('@');
        List<User> l_users = new List<User>();
        // intake agent 
        User intakeAgent = new User(LastName = 'Intakes',
                            FirstName='Agent',
                            Alias = 'inag',
                            Email = Userinfo.getUserEmail(),
                            Username = 'intake.agent@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Intakes Agent'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            UserRoleId = m_roles.get('Intake Agent'),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(intakeAgent);
        //ssd attorney
        User ssdAttorney = new User(LastName = 'Attorney',
                            FirstName='SSD',
                            Department = 'SSD',
                            Alias = 'ssat',
                            Email = Userinfo.getUserEmail(),
                            Username = 'ssd.attorney@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Attorney'),
                            UserRoleId = m_roles.get('Attorney'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(ssdAttorney);
        //ssd paralegal
        User ssdParalegal = new User(LastName = 'Paralegal',
                            FirstName='SSD',
                            Department = 'SSD',
                            Alias = 'sspa',
                            Email = Userinfo.getUserEmail(),
                            Username = 'ssd.paralegal@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Paralegal/Case Manager'),
                            UserRoleId = m_roles.get('Paralegal'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(ssdParalegal);
        ///Mass Tourt attorney
        User mtAttorney = new User(LastName = 'Attorney',
                            FirstName='Mass Tort',
                            Department = 'Mass Tort',
                            Alias = 'mtat',
                            Email = Userinfo.getUserEmail(),
                            Username = 'mt.attorney@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Attorney'),
                            UserRoleId = m_roles.get('Attorney'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(mtAttorney);
        //Mass Tourt paralegal
        User mtParalegal = new User(LastName = 'Paralegal',
                            FirstName='Mass Tort',
                            Department = 'Mass Tort',
                            Alias = 'mtpa',
                            Email = Userinfo.getUserEmail(),
                            Username = 'mt.paralegal@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Paralegal/Case Manager'),
                            UserRoleId = m_roles.get('Paralegal'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(mtParalegal);
        
        //PI  attorney
        User piAttorney = new User(LastName = 'Attorney',
                            FirstName='Personal Injury',
                            Department = 'Personal Injury',
                            Alias = 'piat',
                            Email = Userinfo.getUserEmail(),
                            Username = 'pi.attorney@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Attorney'),
                            UserRoleId = m_roles.get('Attorney'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(piAttorney);
        //PI paralegal
        User piParalegal = new User(LastName = 'Paralegal',
                            FirstName='Personal Injury',
                            Department = 'Personal Injury',
                            Alias = 'pipa',
                            Email = Userinfo.getUserEmail(),
                            Username = 'pi.paralegal@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Paralegal/Case Manager'),
                            UserRoleId = m_roles.get('Paralegal'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(piParalegal);
        
        //WC  attorney
        User wcAttorney = new User(LastName = 'Attorney',
                            FirstName='Workers Compensation',
                            Department = 'Workers Compensation',
                            Alias = 'wcat',
                            Email = Userinfo.getUserEmail(),
                            Username = 'wc.attorney@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Attorney'),
                            UserRoleId = m_roles.get('Attorney'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(wcAttorney);
        //WC paralegal
        User wcParalegal = new User(LastName = 'Paralegal',
                            FirstName='Workers Compensation',
                            Department = 'Workers Compensation',
                            Alias = 'wcpa',
                            Email = Userinfo.getUserEmail(),
                            Username = 'wc.paralegal@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Paralegal/Case Manager'),
                            UserRoleId = m_roles.get('Paralegal'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(wcParalegal);
        
        //Accountant
        User accountant = new User(LastName = 'Accountant',
                            FirstName='Manager',
                            Alias = 'acma',
                            Email = Userinfo.getUserEmail(),
                            Username = 'ac.manager@'+l_str[1],
                            ProfileId = m_pofiles.get('Litify Accountant'),
                            UserRoleId = m_roles.get('Accountant'),
                            TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        l_users.add(accountant);
        
        Database.SaveResult[] srList = Database.insert(l_users, false);
        
        List<GroupMember> l_groupMembers =new List<GroupMember>(); 
        for(Group item: [SELECT id,Name FROM Group WHERE Name IN ('Worker Compensation','SSD','Personal Injury','Mass Tort')]) {
            if (item.Name == 'Worker Compensation') {
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = wcAttorney.Id
                    )
                );
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = wcParalegal.Id
                    ) 
                );
            }
            else if (item.Name == 'SSD') {
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = ssdAttorney.Id
                    ) 
                );
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = ssdParalegal.Id
                    ) 
                );
            }
            else if (item.Name == 'Personal Injury') {
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = piAttorney.Id
                    ) 
                );
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = piParalegal.Id
                    ) 
                );
            }
            else if (item.Name == 'Mass Tort') {
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = mtAttorney.Id
                    ) 
                );
                l_groupMembers.add(
                    new GroupMember(
                        GroupId = item.Id,
                        UserOrGroupId = mtParalegal.Id
                    ) 
                );
            }
        }
        insert l_groupMembers;
        
        /*List<litify_pm__Default_Matter_Team_Member__c> l_teams = [
                                                                    SELECT Id, 
                                                                    litify_pm__Default_Matter_Team__r.Name, 
                                                                    litify_pm__User__c, 
                                                                    litify_pm__Role__r.Name 
                                                                    FROM litify_pm__Default_Matter_Team_Member__c   
                                                                    WHERE litify_pm__Default_Matter_Team__r.Name IN 
                                                                    ('Worker Compensation','SSD','Personal Injury','Mass Tort')
                                                                 ];
        for(litify_pm__Default_Matter_Team_Member__c item : l_teams) {
            if (item.litify_pm__Default_Matter_Team__r.Name == 'Worker Compensation') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = wcAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = wcParalegal.Id;
                }
            }
            else if (item.litify_pm__Default_Matter_Team__r.Name == 'SSD') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = ssdAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = ssdParalegal.Id;
                }
            }
            else if (item.litify_pm__Default_Matter_Team__r.Name == 'Personal Injury') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = piAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = piParalegal.Id;
                }
            }
            else if (item.litify_pm__Default_Matter_Team__r.Name == 'Mass Tort') {
                if (item.litify_pm__Role__r.Name == 'Attorney') {
                    item.litify_pm__User__c = mtAttorney.Id;
                }
                else if (item.litify_pm__Role__r.Name == 'Paralegal') {
                    item.litify_pm__User__c = mtParalegal.Id;
                }
            }
        }
        update l_teams;
*/        
    }
}