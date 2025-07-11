public with sharing class FV_PayloadBuilder {
    public static final Filevine_API_Settings__c API_SETTING { 
        get {
            Filevine_API_Settings__c API_SETTING = Filevine_API_Settings__c.getOrgDefaults();
            return API_SETTING;
        }
    }

    public static List<Map<string,object>> buildEmergencyContactPayload(litify_pm__Intake__c intake) {
        List<Map<string,object>> emergencyContact = new List<Map<string,object>>();
        string fullName = intake.Caller__r.Emergency_Contact_Name__c;
        emergencyContact.add(new Map<string,object>{
            'selector' => 'firstName',
            'action' => 'UPDATE',
            'value' => fullName.substringBefore(' ')
        });
        emergencyContact.add(new Map<string,object>{
            'selector' => 'lastName',
            'action' => 'UPDATE',
            'value' => fullName.substringAfter(' ')
        });
        emergencyContact.add(new Map<string,object>{
            'selector' => 'custom.notes',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.Emergency_Contact_Relationship__c
        });
        if(intake.Caller__r.Emergency_Contact_Phone__c != null){
            emergencyContact.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.Caller__r.Emergency_Contact_Phone__c
                }
            });
        }
        return emergencyContact;
    }

    public static List<Map<string,object>> buildCallerPayload(litify_pm__Intake__c intake, string fvEmergencyContactId){
        List<Map<string,object>> caller = new List<Map<string,object>>();
        caller.add(new Map<string,object>{
            'selector' => 'deathdate',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.Date_of_Death__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'firstName',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.litify_pm__First_Name__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'middleName',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.Middle_Name__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'lastName',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.litify_pm__Last_Name__c
        });

        if(intake.Caller__r.litify_pm__Email__c != null){
            caller.add(new Map<string,object>{
                'selector' => 'emails',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'address' => intake.Caller__r.litify_pm__Email__c,
                    'label' => 'Primary'
                }
            });
        }

        if(intake.Caller__r.Secondary_Email__c != null){
            caller.add(new Map<string,object>{
                'selector' => 'emails',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'address' => intake.Caller__r.Secondary_Email__c,
                    'label' => 'Secondary'
                }
            });
        }
        
        if(intake.Caller__r.litify_pm__Phone_Mobile__c != null){
            caller.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.Caller__r.litify_pm__Phone_Mobile__c,
                    'label' => 'Mobile'
                }
            });
        }
        
        if(intake.Caller__r.litify_pm__Phone_Home__c != null){
            caller.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.Caller__r.litify_pm__Phone_Home__c,
                    'label' => 'Home'
                }
            });
        }
        
        if(intake.Caller__r.litify_pm__Phone_Work__c != null){
            caller.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.Caller__r.litify_pm__Phone_Work__c,
                    'label' => 'Work'
                }
            });
        }
        
        if(intake.Caller__r.BillingStreet != null
        && intake.Caller__r.BillingCity != null
        && intake.Caller__r.BillingState != null
        && intake.Caller__r.BillingPostalCode != null){
            caller.add(new Map<string,object>{
                'selector' => 'addresses',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'line1' => intake.Caller__r.BillingStreet,
                    'city' => intake.Caller__r.BillingCity,
                    'state' => intake.Caller__r.BillingState,
                    'zip' => intake.Caller__r.BillingPostalCode,
                    'label' => 'Primary'
                }
            });
        }
        
        caller.add(new Map<string,object>{
            'selector' => 'custom.notes',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.Best_time_to_reach_client__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'birthdate',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.litify_pm__Date_of_birth__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'custom.ssn',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.litify_pm__Social_Security_Number__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'custom.bestTimeToCall',
            'action' => 'UPDATE',
            'value' => intake.Caller__r.Best_time_to_reach_client__c
        });
        caller.add(new Map<string,object>{
            'selector' => 'custom.bestWayToReachClient',
            'action' => 'UPDATE',
            'value' => FV_Helpers.mapBestWayToReach(intake.Preferred_Method_of_Contact__c)
        });
        if(fvEmergencyContactId != null && fvEmergencyContactId != ''){
            caller.add(new Map<string,object>{
                'selector' => 'custom.emergencyContact',
                'action' => 'ADD',
                'value' =>new Map<string,object>{
                    'relatedPersonID' => fvEmergencyContactId
                }
            });
        }
        caller.add(new Map<string,object>{
            'selector' => 'personTypes',
            'action' => 'UPDATE',
            'value' => 2755
        });
        return caller;
    }

    public static List<Map<string,object>> buildClientPayload(litify_pm__Intake__c intake){
        List<Map<string,object>> client = new List<Map<string,object>>();
        client.add(new Map<string,object>{
            'selector' => 'deathdate',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.Date_of_Death__c
        });
        client.add(new Map<string,object>{
            'selector' => 'firstName',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.litify_pm__First_Name__c
        });
        client.add(new Map<string,object>{
            'selector' => 'middleName',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.Middle_Name__c
        });
        client.add(new Map<string,object>{
            'selector' => 'lastName',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.litify_pm__Last_Name__c
        });
        if(intake.litify_pm__Client__r.litify_pm__Email__c != null){
            client.add(new Map<string,object>{
                'selector' => 'emails',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'address' => intake.litify_pm__Client__r.litify_pm__Email__c,
                    'label' => 'Primary'
                }
            });
        }
        if(intake.litify_pm__Client__r.Secondary_Email__c != null){
            client.add(new Map<string,object>{
                'selector' => 'emails',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'address' => intake.litify_pm__Client__r.Secondary_Email__c,
                    'label' => 'Secondary'
                }
            });
        }
        if(intake.litify_pm__Client__r.litify_pm__Phone_Mobile__c != null){
            client.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.litify_pm__Client__r.litify_pm__Phone_Mobile__c,
                    'label' => 'Mobile'
                }
            });
        }
        if(intake.litify_pm__Client__r.litify_pm__Phone_Home__c != null){
            client.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.litify_pm__Client__r.litify_pm__Phone_Home__c,
                    'label' => 'Home'
                }
            });
        }
        if(intake.litify_pm__Client__r.litify_pm__Phone_Work__c != null){
            client.add(new Map<string,object>{
                'selector' => 'phones',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'number' => intake.litify_pm__Client__r.litify_pm__Phone_Work__c,
                    'label' => 'Work'
                }
            });
        }
        if(intake.litify_pm__Client__r.BillingStreet != null
        && intake.litify_pm__Client__r.BillingCity != null
        && intake.litify_pm__Client__r.BillingState != null
        && intake.litify_pm__Client__r.BillingPostalCode != null){
            client.add(new Map<string,object>{
                'selector' => 'addresses',
                'action' => 'ADD',
                'value' => new Map<string,object>{
                    'line1' => intake.litify_pm__Client__r.BillingStreet,
                    'city' => intake.litify_pm__Client__r.BillingCity,
                    'state' => intake.litify_pm__Client__r.BillingState,
                    'zip' => intake.litify_pm__Client__r.BillingPostalCode,
                    'label' => 'Primary'
                }
            });
        }
        
        client.add(new Map<string,object>{
            'selector' => 'custom.notes',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.Best_time_to_reach_client__c
        });
        client.add(new Map<string,object>{
            'selector' => 'birthdate',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.litify_pm__Date_of_birth__c
        });
        client.add(new Map<string,object>{
            'selector' => 'custom.ssn',
            'action' => 'UPDATE',
            'value' => intake.litify_pm__Client__r.litify_pm__Social_Security_Number__c
        });
        client.add(new Map<string,object>{
            'selector' => 'personTypes',
            'action' => 'UPDATE',
            'value' => 2755
        });
        return client;
    }

    public static Map<string,object> buildProjectPayload(litify_pm__Intake__c intake, string fvCallerId){
        Map<string,object> project = new Map<string,object>{
            'clientId' => new Map<string, string>{
                'native' => fvCallerId
            },
            'projectTypeId' => new Map<string, string>{
                'native' => API_SETTING.Project_Type_ID__c
            },
            'projectName' => intake.litify_pm__Client__r.Name
        };
        return project;
    }

    public static Map<string,object> buildCaseSummaryPayload(litify_pm__Intake__c intake, string projectFVId, string callerFVId, string clientFVId, string retainerFileId, string questionnaireFileId){
        Map<string,object> caseSummary = new Map<string,object>{
            'practicearea' => intake.litify_pm__Case_Type__r.Name,
            'litigationSubtype' => intake.Caller__c == intake.litify_pm__Client__c ? 'Personal Injury' : 
                                    (intake.Is_your_loved_one_still_living__c == 'No' ? 'Wrongful Death' : 'Personal Injury (Guardian/POA)'),
            'clientSRelationshipToInjur' => intake.What_is_your_relation_to_this_individual__c,
            'injuredPerson' => new Map<string,object>{
                'id' => intake.Caller__c == intake.litify_pm__Client__c ? callerFVId : clientFVId
            },
            'milestonesEnabled' => true,
            'coCounsel' => true,
            'coCounsel1' => new Map<string,object>{
                'id' => 19043693
            },
            'areYouLocalCouncil' => false,
            'caseReferredOut' => false,
            'retainer' => new Map<string,object>{
                'id' => retainerFileId
            },
            'questionnaire' => new Map<string,object>{
                'id' => questionnaireFileId
            },
            'coCounsel1FeePercentage' => '57',
            'coCounsel2FeePercentage' => '5',
            'coCounsel2' => new Map<string,object>{
                'id' => 19458975
            }
        };
        if(intake.Is_your_loved_one_still_living__c == 'No'){
            caseSummary.put('decedentIfWrongfulDeathCa', new Map<string,object>{
                'id' => clientFVId
            });
        }
        return caseSummary;
    }

    public static Map<string,object> buildInitialIntakePayload(litify_pm__Intake__c intake, string projectFVId){
        Date milDOB = intake.Camp_Lejuene__r.Military_Personnel_DOB__c;
        Time defaultTime = Time.newInstance(0, 0, 0, 0);
        Datetime milDOBDateTime = milDOB != null ? Datetime.newInstanceGmt(milDOB, defaultTime) : null;
        Map<string,object> initialIntake = new Map<string,object>{
            'coCounselId' => intake.Id,
            'casetype' => 'Camp Lejeune',
            'relationship' => FV_Helpers.mapRelationship(intake.What_is_your_relation_to_this_individual__c),
            'hasAnEstateBeenOpened' => FV_Helpers.yesNoToBoolean(intake.Client_Estate_Opened__c),
            'isTheEstateCurrentlyOpen' => FV_Helpers.yesNoToBoolean(intake.Estate_Currently_Open__c),
            'doYouHaveACopyOfTheDeat' => FV_Helpers.yesNoToBoolean(intake.Hold_Death_Certificate__c),
            'allLocationsLivedWorkedOr' => intake.Camp_Lejuene__r.While_at_Camp_Lejeune_please_indicated__c,
            'haveYouEverSmokedCigarette' => intake.Camp_Lejuene__r.Smoking_Check__c,
            'doYouCurrentlySmokeCigaret' => FV_Helpers.yesNoToBoolean(intake.Camp_Lejuene__r.Do_you_currently_smoke_cigarettes__c),
            'haveYouEverSmokedCigarette_1' => FV_Helpers.yesNoToBoolean(intake.Camp_Lejuene__r.Have_you_ever_smoked_cigarettes_in_the_p__c),
            'forHowLongDidYouSmoke' => intake.Camp_Lejuene__r.If_yes_for_how_long_have_smoked__c,
            'howManyCigarettesPerDay' => intake.Camp_Lejuene__r.How_many_cigarettes_do_you_smoke_per_day__c,
            'whenDidYouBeginSmoking' => intake.Camp_Lejuene__r.If_yes_when_did_you_begin_smoking__c,
            'whenDidYouStopSmoking' => intake.Camp_Lejuene__r.When_did_you_stop_smoking__c,
            'doYouHaveAnyDocumentsRela' => intake.Camp_Lejuene__r.Documents_related_to_Camp_Lejeune__c,
            'ifCivilianWhatWasTheNatu' => intake.Camp_Lejuene__r.Nature_Of_Presence_At_Camp_Lejeune__c,
            'militaryDetails' => intake.Camp_Lejuene__r.Branch_discharge_status_and_rank__c,
            'fullNameOfMilitaryService' => intake.Camp_Lejuene__r.Military_Stationed_Family_Mem_Full_Name__c,
            'branchOfService' => intake.Camp_Lejuene__r.Branch_of_Service__c,
            'dischargeStatus' => intake.Camp_Lejuene__r.Discharge_Status__c,
            'rank' => intake.Camp_Lejuene__r.Rank_at_the_time_of_discharge__c,
            'tier1Diagnosis' => intake.Camp_Lejuene__r.Tier_1_Injury_Matrix__c,
            'tier2Diagnosis' => intake.Camp_Lejuene__r.Tier_2_Injury_Matrix__c,
            'tier3Diagnosis' => intake.Camp_Lejuene__r.Tier_3_Injury_Matrix__c,
            'tier4Diagnosis' => intake.Camp_Lejuene__r.Tier_4_Injury_Matrix__c,
            'treatingDoctors' => intake.Camp_Lejuene__r.List_Dx_treating_doctor_names_spec__c,
            'treatingFacilities' => intake.Camp_Lejuene__r.Treatment_Facilities_Name_and_Addresses__c,
            'militaryPersonnelSSN' => intake.Camp_Lejuene__r.NEW_Military_Personnel_SSN__c,
            'militaryPersonnelDOB' => milDOBDateTime,
            'militaryPersonnelPlaceOfBi' => intake.Camp_Lejuene__r.Military_Personnel_Place_of_Birth__c,
            'serviceNumber' => intake.Camp_Lejuene__r.Military_Personnel_Active_SN__c,
            'militaryPersonnelAliveOrDe' => intake.Camp_Lejuene__r.Military_Personnel_Alive_or_Deceased__c,
            'diagnosisdriver' => intake.Camp_Lejuene__r.Cancer_disease_syndrome_fertility_issue__c,
            'casedescription' => intake.litify_pm__Description__c
        };
        return initialIntake;
    }

    public static Map<string,object> buildMassTortInfo(litify_pm__Intake__c intake, string projectFVId){
        List<string> massTortDocs = new List<string>();
        if(intake.Camp_Lejuene__r.Have_Medical_Records__c == 'Yes'){
            massTortDocs.add('Medical Records');
        }
        if(intake.Camp_Lejuene__r.Have_Military_Records__c == 'Yes'){
            massTortDocs.add('Official Military Personnel File');
        }
        Map<string,object> massTortInfo = new Map<string,object>{
            'masstortcasetype' => 'Camp Lejeune Q Review',
            'doYouHaveAnyOfTheFollowi' => massTortDocs,
            'endDateOfExposure' => intake.Camp_Lejuene__r.Last_Date_at_Camp_Lejuene__c,
            'startDateOfExposure' => intake.Camp_Lejuene__r.First_Date_at_Camp_Lejuene__c,
            'statusWhenStationedAtCamp' => FV_Helpers.mapStatusWhenStationedAtCamp(intake.Camp_Lejuene__r.Military_veteran_mil_spouse_or_civ__c)
        };
        return massTortInfo;
    }
}