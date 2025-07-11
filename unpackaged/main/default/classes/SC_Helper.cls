public with sharing class SC_Helper {
    public static string formatDateToString(Date value){
        if(value == null){
            return '';
        }
        Datetime temp = Datetime.newInstanceGMT(value.year(),value.month(),value.day(),0,0,0);
        return temp.formatGmt('yyyy-MM-dd');
    }
}