@isTest(SeeAllData=false)
private with sharing class PostInstallScriptsTest {
	@testSetup static void setup(){
        List<litify_pm__question__c> l_questions = new List<litify_pm__question__c>();
    	litify_pm__question__c question1 = new litify_pm__question__c();
        question1.litify_pm__Answer_Type__c = 'STRING';
        question1.litify_pm__Question_Label__c = 'How did you hear about our firm?';
        question1.External_Id__c = 'a0C3u00000h7A0xEAE';
        l_questions.add(question1);
        litify_pm__question__c question2 = new litify_pm__question__c();
        question2.litify_pm__Answer_Type__c = 'STRING';
        question2.litify_pm__Question_Label__c = 'What Type of Case is this?';
        question2.External_Id__c = 'a0C3u00000h7A0xEAE';
        l_questions.add(question2);
        insert l_questions;
        Map<String,Object> m_questionnaire = new Map<String, Object>();
        m_questionnaire.put('first_question_node','44767a83c740');
        
        Map<String,Object> m_questionnaireNode = new Map<String, Object>();
        m_questionnaireNode.put('44767a83c740',new Map<String, Object>{
            'name'=> 'List, Empathize, Understand',
              'description'=> 'Node 1',
              'check_cqc'=> false,
                'questions' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'question_id'=> question1.Id,
                            'required'=>true,
                            'label'=>'How did you hear about our firm?',
                            'sobjectModification'=>''
                    },
                    new Map<String, Object>{
                        'question_id'=> question2.Id,
                            'required'=>true,
                            'label'=>'What Type of Case is this?',
                            'sobjectModification'=>''
                    }
                }
        });
        m_questionnaire.put('question_nodes',m_questionnaireNode);
        litify_pm__questionnaire__c q = new litify_pm__questionnaire__c();
        q.Name = 'Test Questionnaire';
        q.litify_pm__Is_Active__c = true;
        q.litify_pm__Is_Available_On_Intake__c = true;
        q.litify_pm__questions__c = JSON.serialize(m_questionnaire);
        q.litify_pm__SObject_Modifications__c = JSON.serialize(m_questionnaire);
        q.External_Id__c = 'a0C3u00000h7A0xEAE';
        insert q;
    }
    @isTest static void questionnaireUpdateCheck() {
        PostInstallScripts.copyQuestionsAndQuestionnaires();
        litify_pm__questionnaire__c q = [SELECT Id, litify_pm__questions__c FROM litify_pm__questionnaire__c LIMIT 1];
        Test.startTest();
       	PostInstallScripts.updateQuestionnaries();
        PostInstallScripts.updateQuestionnaries(new set<Id>{q.Id});
        Test.stopTest();
         q = [SELECT Id, litify_pm__questions__c FROM litify_pm__questionnaire__c LIMIT 1];
        System.assert(q.litify_pm__questions__c != null);
    }
    
    @isTest static void createUsers() {
        Test.startTest();
       	PostInstallScripts.createUserStructurePIEssentials();
        Test.stopTest();
    }
    
    @isTest static void createUsersAndGroups() {
        PostInstallScripts.createUserStructurePIEssentials();
        Test.startTest();
        PostInstallScripts.updateTeamMembers();
        Test.stopTest();
    }
}