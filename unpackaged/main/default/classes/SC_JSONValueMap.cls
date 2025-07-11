public with sharing class SC_JSONValueMap {
    public static Integer mapCondition(string value){
        switch on value {
            when 'ALS' {return 691;}
            when 'Aplastic Anemia' {return 659;}
            when 'Bile Duct Cancer' {return 651;}
            when 'Bladder Cancer' {return 20;}
            when 'Brain Cancer (CNS / Central Nervous System Cancer)' {return 377;}
            when 'Breast Cancer (female)' {return 32;}
            when 'Breast Cancer (male)' {return 32;}
            when 'Cervical Cancer' {return 484;}
            when 'Colon Cancer (Intestinal, Appendix)' {return 47;}
            when 'Congenital Cardiac Defect' {return 1622;}
            when 'Esophageal Cancer' {return 376;}
            when 'Female Infertility' {return 646;}
            when 'Hodgkins Disease (Lymphoma)' {return 334;}
            when 'Hypersensitivity Skin Disorder' {return 1176;}
            when 'Kidney Cancer' {return 91;}
            when 'Kidney disease (End stage renal (ESRD), Renal Toxicity, Chronic Kidney Disease, etc.)' {return 127;}
            when 'Laryngeal Cancer' {return 423;}
            when 'Leukemia (All types, adult or childhood)' {return 96;}
            when 'Liver Cancer' {return 97;}
            when 'Liver Disease (Cirrhosis, Fatty Liver Disease, Hepatic Steatosis, Liver Failure)' {return 1596;}
            when 'Low sperm count' {return 1091;}
            when 'Lung Cancer' {return 98;}
            when 'Lupus' {return 257;}
            when 'Male Infertility' {return 1111;}
            when 'Miscarriage / Fetal Death' {return 107;}
            when 'Multiple myeloma and myelodysplastic Syndromes' {return 375;}
            when 'Multiple sclerosis' {return 189;}
            when 'Neurological effect and/or Neurobehavioral Performance Deficit' {return 649;}
            when 'Non-Hodgkin lymphoma' {return 120;}
            // when 'None of the above' {return ;}
            when 'Oral Cancer' {return 1855;}
            when 'Other cancers' {return 125;}
            when 'Other Serious Birth Defects (Major Malformations, Neural Tube Defects, Oral Cleft Defects, Eye Defects)' {return 655;}
            when 'Ovarian Cancer' {return 130;}
            when 'Pancreatic Cancer' {return 133;}
            when 'Parkinson disease' {return 135;}
            when 'Pharyngeal Cancer' {return 571;}
            when 'Prostate Cancer' {return 374;}
            when 'Rectal Cancer' {return 1254;}
            when 'Severe tooth decay or dental related issues' {return 1626;}
            when 'Soft Tissue Cancer / Sarcoma' {return 653;}
            when 'Systemic Sclerosis' {return 1333;}
            when 'Thyroid Cancer' {return 239;}
            when else {
                System.debug('Invalid value for case conditions: ' + value);
                return null;
            }
        }
    }

    public static Integer mapInformation(string value){
        switch on value {
            when 'Military veteran' {return 1066;}
            when 'Military spouse' {return 1067;}
            when 'Civilian' {return 1068;}
            when '30 or more days in total (was NOT exposed in utero/ while pregnant with related injury)' {return 1089;}
            when '30 or more days in total (was ONLY exposed in utero/while pregnant with related injury)' {return 1089;}
            when 'Some time between 8/1/1953 and 12/31/1987' {return 1091;}
            when else {
                System.debug('Invalid value for case information: ' + value);
                return null;
            }
        }
    }

    public static string mapAgentCapacity(string value){
        switch on value {
            when 'As Legal Representative For' { return 'other';}
            when 'As Trustee of' { return 'trustee';}
            when 'As Trustee for the Estate of' { return 'administrator';}
            when else {
                System.debug('Invalid value for agent capacity: ' + value);
                return null;
            }
        }
    }

    public static string mapLocation(string value){
        switch on value {
            when 'Barracks' { return 'barracks';}
            when 'Berkeley Manor' { return 'berkeleyManor';}
            when 'Camp Geiger' { return 'campGeiger';}
            when 'Courthouse Bay' { return 'courthouseBay';}
            when 'Hadnot Point' { return 'hadnotPoint';}
            when 'Heroes Manor' { return 'other';}
            when 'Holcomb Boulevard' { return 'holcombBoulevard';}
            when 'Hospital Point' { return 'hospitalPoint';}
            when 'Hostess House' { return 'other';}
            when 'Knox Cave' { return 'other';}
            when 'Knox Landing' { return 'other';}
            when 'Knox Trailer Park' { return 'knoxTrailerPark';}
            when 'Mainside Barracks' { return 'mainsideBarracks';}
            when 'Midway Park' { return 'midwayPark';}
            when 'Montford Point/Camp Johnson' { return 'montfordPointCampJohnson';}
            when 'New River' { return 'newRiver';}
            // when 'None of the above' { return '';}
            when 'Off base housing' { return 'other';}
            when 'On base temporary housing' { return 'other';}
            when 'Onslow Beach' { return 'onslowBeach';}
            when 'Other' { return 'other';}
            when 'Paradise Point' { return 'paradisePoint';}
            when 'Peterfield Point' { return 'other';}
            when 'Rifle Range' { return 'rifleRange';}
            when 'Tarawa Terrace' { return 'tarawaTerrace';}
            when 'Watkins Grove' { return 'other';}
            when 'Watkins Village' { return 'watkinsVillage';}
            when else {
                System.debug('Invalid value for location: ' + value);
                return null;
            }
        }
    }
}