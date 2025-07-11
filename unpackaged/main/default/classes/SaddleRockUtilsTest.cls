@isTest
@SuppressWarnings('PMD.EmptyCatchBlock, PMD.ApexAssertionsShouldIncludeMessage')
private class SaddleRockUtilsTest {
    //--------------------------------------------------------------------------
    // Tests
    @isTest private static void testCoverage() {
        Test.startTest();
            new SaddleRockUtils();
            System.assertNotEquals(null, SaddleRockUtils.settings);
            System.assertEquals(false, SaddleRockUtils.isRunningAsync());
        Test.stopTest();
    }
    
    @isTest private static void testCustomExceptions() {
        Test.startTest();
            System.assertNotEquals(null, new SaddleRockUtils.AssertionException());

            SaddleRockUtils.throwIf(1 == 2, new StringException('test'));
            try {
                SaddleRockUtils.throwIf(1 == 1, new StringException('nope'));
                System.assert(false, 'exception should have been thrown');
            } catch (StringException e) {
                System.assertEquals('nope', e.getMessage());
            }

            // BaseTest.testException = false;
            // t.throwIfTesting(new NullPointerException());
            // BaseTest.testException = true;
            // try {
            //     t.throwIfTesting(new NullPointerException());
            //     System.assert(false, 'should have thrown');
            // } catch (NullPointerException e) {}
        Test.stopTest();
    }
    
    @isTest private static void testMapGetCaseInsensitive() {
            Map<String,Object> m = new Map<String,Object>();
        Test.startTest();
            // errors
            try {
                SaddleRockUtils.mapGetCaseInsensitive(null, null);
                System.assert(false, 'map is required');
            } catch (SaddleRockUtils.AssertionException e) {}

            System.assertEquals(null, SaddleRockUtils.mapGetCaseInsensitive(m, null));
            System.assertEquals(null, SaddleRockUtils.mapGetCaseInsensitive(m, 'k1'));

            m.put('k1',  'v');
            System.assertEquals('v', SaddleRockUtils.mapGetCaseInsensitive(m, 'k1'));
            System.assertEquals('v', SaddleRockUtils.mapGetCaseInsensitive(m, 'K1'));

            m.put('k2',  123);
            System.assertEquals(123, SaddleRockUtils.mapGetCaseInsensitive(m, 'K2'));

            m.put(null,  true);
            System.assertEquals(true, SaddleRockUtils.mapGetCaseInsensitive(m, null));

            System.assertEquals(null, SaddleRockUtils.mapGetCaseInsensitive(m, ''));
            System.assertEquals(null, SaddleRockUtils.mapGetCaseInsensitive(m, 'bogus'));
        Test.stopTest();
    }

    @IsTest private static void testTruncate() {
        Test.startTest();
            try {
                SaddleRockUtils.truncate(null, 'test');
                System.assert(false, 'field is required');
            } catch (SaddleRockUtils.AssertionException e) {}

            System.assertEquals(null, SaddleRockUtils.truncate(Account.Name, null));
            System.assertEquals('test', SaddleRockUtils.truncate(Account.Name, 'test'));
            System.assertEquals('test', SaddleRockUtils.truncate('testing', 4));
            System.assertEquals(' t  ', SaddleRockUtils.truncate(' t        ', 4));
        Test.stopTest();
    }

    @isTest private static void testDescribeSaddleRockUtils() {
        Test.startTest();
            System.assertEquals(null, SaddleRockUtils.getSObjectType(null));
            System.assertEquals(null, SaddleRockUtils.getSObjectType('bogus'));
            System.assertEquals(Account.SObjectType, SaddleRockUtils.getSObjectType('aCcount'));

            System.assertEquals(null, SaddleRockUtils.getFields((SObjectType)null));
            System.assertNotEquals(null, SaddleRockUtils.getFields(Account.SObjectType));

            System.assertEquals(null, SaddleRockUtils.getField((String)null, null));
            System.assertEquals(null, SaddleRockUtils.getField(Account.SObjectType, null));
            System.assertEquals(null, SaddleRockUtils.getField('Account', null));
            System.assertEquals(null, SaddleRockUtils.getField((String)null, 'Name'));
            System.assertEquals(null, SaddleRockUtils.getField(Account.SObjectType, 'bogus'));
            System.assertEquals(null, SaddleRockUtils.getField(Account.SObjectType, 'owner__r.bogus'));
            System.assertEquals(null, SaddleRockUtils.getField(Account.SObjectType, 'owner.bogus'));

            System.assertEquals(Account.Name, SaddleRockUtils.getField(Account.SObjectType, 'name'));
            System.assertEquals(Account.Name, SaddleRockUtils.getField('Account', 'NAME'));
            System.assertEquals(User.Name, SaddleRockUtils.getField(Account.SObjectType, '\tOwner . Name  '));
            System.assertEquals(Contact.Id, SaddleRockUtils.getField(Account.SObjectType, 'CreatedBy.Contact.Owner.Contact.Id'));
        Test.stopTest();
    }

    @IsTest static void testGetFieldValue() {
        Account a = new Account(
            name = 'n0',
            owner = new User(
                Alias = 'u0',
                Contact = new Contact(
                    Email = 'me@test.com'
                )
            )
        );

        Test.startTest();
            try {
                SaddleRockUtils.getFieldValue(null, null);
                System.assert(false, 'field is required');
            } catch (SaddleRockUtils.AssertionException e) {}

            try {
                SaddleRockUtils.getFieldValue(a, 'Test');
                System.assert(false, 'invalid field');
            } catch (SObjectException e) {}

            System.assertEquals('n0', SaddleRockUtils.getFieldValue(a, 'NAME '));
            System.assertEquals('u0', SaddleRockUtils.getFieldValue(a, ' Owner \t . aLIas '));
            System.assertEquals('me@test.com', SaddleRockUtils.getFieldValue(a, 'Owner.conTACt.email'));
        Test.stopTest();
    }
        
    @IsTest static void testGetPickListValues() {
        Test.startTest();
            System.assertEquals(true, SaddleRockUtils.getPickListValues(null).IsEmpty());
            System.assertEquals(true, SaddleRockUtils.getPickListValues(Account.Id).IsEmpty());
            System.assertEquals(false, SaddleRockUtils.getPickListValues(Account.Type).IsEmpty());
        Test.stopTest();
    }

    @IsTest static void testIsPickListValue() {
        Test.startTest();
            Set<String> accountTypes = SaddleRockUtils.getPickListValues(Account.Type);
            for (String t : accountTypes) {
                System.assertEquals(true, SaddleRockUtils.isPicklistValue(t, Account.Type));
                System.assertEquals(true, SaddleRockUtils.isPicklistValue(t.toUpperCase(), Account.Type));
                System.assertEquals(true, SaddleRockUtils.isPicklistValue(t.toLowerCase(), Account.Type));
            }

            System.assertEquals(false, SaddleRockUtils.isPicklistValue(null, Account.Type));
            System.assertEquals(false, SaddleRockUtils.isPicklistValue('', Account.Type));
            System.assertEquals(false, SaddleRockUtils.isPicklistValue('some bogus value', Account.Type));
        Test.stopTest();
    }

    @IsTest static void testAllArePicklistValues() {
        String[] accountTypes = new List<String>(SaddleRockUtils.getPickListValues(Account.Type));

        Test.startTest();
            System.assertEquals(true, SaddleRockUtils.allArePicklistValues(new String[] {}, Account.Type));
            System.assertEquals(false, SaddleRockUtils.allArePicklistValues(new String[] {'bogus'}, Account.Type));
            System.assertEquals(true, SaddleRockUtils.allArePicklistValues(accountTypes, Account.Type));
            if (!accountTypes.isEmpty()) {
                System.assertEquals(true, SaddleRockUtils.allArePicklistValues(new String[] {accountTypes[0].toUpperCase()}, Account.Type));
                System.assertEquals(true, SaddleRockUtils.allArePicklistValues(new String[] {accountTypes[0].toLowerCase()}, Account.Type));
            }
        Test.stopTest();
    }

    @IsTest static void testLog() {
        Test.startTest();
            // default settings
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // nothing to write
            SaddleRockUtils.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new SaddleRockUtils.Log(null, 'none1');
            SaddleRockUtils.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            new SaddleRockUtils.Log(LoggingLevel.FINE, 'fine1');
            SaddleRockUtils.writeLogs();
            System.assertEquals(0, [SELECT Count() FROM Integration_Log__c]);

            // REST log
            new SaddleRockUtils.Log(LoggingLevel.DEBUG, 'debug1');
            SaddleRockUtils.Log l = new SaddleRockUtils.Log(LoggingLevel.ERROR, 'error1', 'sum1');
            l.setRequest(null);
            l.setResponse(null);
            l.start();
            l.stop();
            SaddleRockUtils.writeLogs();
            System.assertEquals(2, [SELECT Count() FROM Integration_Log__c]);
            System.assertEquals(1, [SELECT Count() FROM Integration_Log__c WHERE Name = 'error1'
                AND Level__c = 'ERROR' AND Start__c != null AND Stop__c != null AND Duration__c != null]);

            new SaddleRockUtils.Log(LoggingLevel.DEBUG, null).toString();
            new SaddleRockUtils.Log(LoggingLevel.DEBUG, null).getElapsed();
        Test.stopTest();
    }
}