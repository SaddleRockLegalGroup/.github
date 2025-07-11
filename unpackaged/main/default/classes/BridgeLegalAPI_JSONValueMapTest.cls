@isTest
public with sharing class BridgeLegalAPI_JSONValueMapTest {
    @isTest
    public static void test_mapCancerDiagnosed() {
        Test.startTest();
        string mappedVal = BridgeLegalAPI_JSONValueMap.mapCancerDiagnosed('Thyroid Cancer');
        Test.stopTest();
        System.assertEquals('thyroidDisease', mappedVal);
    }
}