@isTest
public with sharing class SC_JSONValueMapTest {
    @isTest
    public static void test_mapCondition() {
        Test.startTest();
        Integer result = SC_JSONValueMap.mapCondition('Thyroid Cancer');
        Test.stopTest();
        System.assertEquals(239, result);
    }
    @isTest
    public static void test_mapLocation() {
        Test.startTest();
        string result = SC_JSONValueMap.mapLocation('Watkins Village');
        Test.stopTest();
        System.assertEquals('watkinsVillage', result);
    }
}