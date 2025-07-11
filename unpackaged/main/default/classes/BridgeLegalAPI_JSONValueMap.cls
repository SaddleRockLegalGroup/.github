public with sharing class BridgeLegalAPI_JSONValueMap {
    public static String mapCancerDiagnosed(string value){
        switch on value {
            when 'ALS' {return 'aLS';}
            when 'Aplastic Anemia' {return 'aplasticAnemia';}
            when 'Bile Duct Cancer' {return 'bileDuctCancer';}
            when 'Bladder Cancer' {return 'bladderCancer';}
            when 'Brain Cancer (CNS / Central Nervous System Cancer)' {return 'brainCancer';}
            when 'Breast Cancer (female)' {return 'breastCancer';}
            when 'Breast Cancer (male)' {return 'maleBreastCancer';}
            when 'Cervical Cancer' {return 'cervicalCancer';}
            when 'Colon Cancer (Intestinal, Appendix)' {return 'colonCancerIntestinalAppendix';}
            when 'Congenital Cardiac Defect' {return 'cardiacDefects';}
            when 'Esophageal Cancer' {return 'esophagealCancer';}
            when 'Female Infertility' {return 'femaleInfertility';}
            when 'Hodgkins Disease (Lymphoma)' {return 'hodgkinsDisease';}
            when 'Hypersensitivity Skin Disorder' {return 'hypersensitivitySkinDisorders';}
            when 'Kidney Cancer' {return 'kidneyCancer';}
            when 'Kidney disease (End stage renal (ESRD), Renal Toxicity, Chronic Kidney Disease, etc.)' {return 'kidneyDisease';}
            when 'Laryngeal Cancer' {return 'laryngealCancer';}
            when 'Leukemia (All types, adult or childhood)' {return 'adultLeukemia; childhoodLeukemia';}
            when 'Liver Cancer' {return 'liverCancer';}
            when 'Liver Disease (Cirrhosis, Fatty Liver Disease, Hepatic Steatosis, Liver Failure)' {return 'hepaticSteatosisFattyLiverDisease';}
            when 'Low Sperm Count' {return 'lowSpermCount';}
            when 'Lung Cancer' {return 'lungCancer';}
            when 'Lupus' {return 'lupus';}
            when 'Male Infertility' {return 'maleInfertility';}
            when 'Miscarriage / Fetal Death' {return 'miscarriage';}
            when 'Multiple myeloma and myelodysplastic Syndromes' {return 'myelodysplasticSyndromes';}
            when 'Multiple sclerosis' {return 'multipleSclerosis';}
            when 'Neurological effect and/or Neurobehavioral Performance Deficit' {return 'neurologicalEffectAndorNeurobehavioralPerformanceDeficit';}
            when 'Non-Hodgkin Lymphoma' {return 'non-Hodgkin’sLymphoma';}
            when 'None of the above' {return 'none';}
            when 'Oral Cancer' {return 'oralCancer';}
            when 'Other cancers' {return 'otherCancers';}
            when 'Other Serious Birth Defects (Major Malformations, Neural Tube Defects, Oral Cleft Defects, Eye Defects)' {return 'birthDefects';}
            when 'Ovarian Cancer' {return 'ovarianCancer';}
            when 'Pancreatic Cancer' {return 'pancreaticCancer';}
            when 'Parkinson disease' {return 'parkinsonsDisease';}
            when 'Pharyngeal Cancer' {return 'pharyngealCancer';}
            when 'Prostate Cancer' {return 'prostateCancer';}
            when 'Rectal Cancer' {return 'rectalCancer';}
            when 'Severe tooth decay or dental related issues' {return 'severeToothLoss';}
            when 'Soft Tissue Cancer / Sarcoma' {return 'systemicSclerosisScleroderma';}
            when 'Systemic Sclerosis' {return 'systemicSclerosisScleroderma';}
            when 'Thyroid Cancer' {return 'thyroidDisease';}
            when else {
                System.debug('Invalid value for cancer diagnosed: ' + value);
                return null;
            }
        }
    }
}