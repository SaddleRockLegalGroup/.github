public with sharing class FV_Helpers {
    public static Boolean yesNoToBoolean(string value){
        if(string.isBlank(value)){
            return false;
        }
        if(value == 'Yes' || value == 'yes'){
            return true;
        }
        return false;
    }

    public static string mapStatusWhenStationedAtCamp(string value){
        if(string.isBlank(value)){
            return null;
        }
        switch on value.toLowerCase() {
            when 'military veteran' {
                return 'Member of the Armed Forces';
            }
            when 'military spouse' {
                return 'Civilian Military Dependent';
            }
            when 'civilian' {
                return 'Civilian';
            }
            when else {
                return '';
            }
        }
    }

    public static string mapBestWayToReach(string value){
        if(string.isBlank(value)){
            return null;
        }
        if(value.containsIgnoreCase('call')){
            return 'Call';
        }
        else if(value.containsIgnoreCase('text')){
            return 'Text';
        }
        else if(value.containsIgnoreCase('email')){
            return 'Email';
        }
        else if(value.containsIgnoreCase('any')){
            return 'Any';
        }
        else {
            return null;
        }
    }

    public static string mapRelationship(string value){
        if(string.isBlank(value)){
            return null;
        }
        switch on value.toLowerCase() {
            when 'mother' {
                return 'Mother';
            }
            when 'father' {
                return 'Father';
            }
            when 'sister' {
                return 'Sister';
            }
            when 'brother' {
                return 'Brother';
            }
            when 'daughter' {
                return 'Daughter';
            }
            when 'son' {
                return 'Son';
            }
            when 'grandmother' {
                return 'Grandmother';
            }
            when 'grandfather' {
                return 'Grandfather';
            }
            when else {
                return 'Other';
            }
        }
    }
}