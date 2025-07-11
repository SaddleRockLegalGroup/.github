@isTest
public with sharing class CleanupSandbox_MetadataTest {
    @isTest(SeeAllData=true)
    public static void testToggleTrigger(){
        // Set up mock
        string getTriggerInfoRespStr = '{' +
                                            '"attributes": {' +
                                                '"type": "ApexTrigger",' +
                                                '"url": "/services/data/v51.0/tooling/sobjects/ApexTrigger/01qDn000000NQGaIAO"' +
                                            '},' +
                                            '"Id": "01qDn000000NQGaIAO",' +
                                            '"NamespacePrefix": null,' +
                                            '"Name": "dlrs_litify_pm_IntakeTrigger",' +
                                            '"TableEnumOrId": "litify_pm__Intake__c",' +
                                            '"UsageBeforeInsert": true,' +
                                            '"UsageAfterInsert": true,' +
                                            '"UsageBeforeUpdate": true,' +
                                            '"UsageAfterUpdate": true,' +
                                            '"UsageBeforeDelete": true,' +
                                            '"UsageAfterDelete": true,' +
                                            '"UsageIsBulk": false,' +
                                            '"UsageAfterUndelete": true,' +
                                            '"ApiVersion": 51.0,' +
                                            '"Status": "Inactive",' +
                                            '"IsValid": true,' +
                                            '"BodyCrc": 7.18597762E8,' +
                                            '"Body": "",' +
                                            '"LengthWithoutComments": 246,' +
                                            '"CreatedDate": "2023-07-06T16:06:53.000+0000",' +
                                            '"CreatedById": "005Dn0000066Va8IAE",' +
                                            '"LastModifiedDate": "2024-07-18T17:03:34.000+0000",' +
                                            '"LastModifiedById": "005Dn0000066Va8IAE",' +
                                            '"SystemModstamp": "2024-07-18T17:03:34.000+0000",' +
                                            '"ManageableState": "unmanaged",' +
                                            '"Metadata": {' +
                                                '"apiVersion": 51.0,' +
                                                '"packageVersions": [' +
                                                    '{' +
                                                        '"majorNumber": 2,' +
                                                        '"minorNumber": 17,' +
                                                        '"namespace": "dlrs"' +
                                                    '},' +
                                                    '{' +
                                                        '"majorNumber": 31,' +
                                                        '"minorNumber": 3,' +
                                                        '"namespace": "litify_pm"' +
                                                    '}' +
                                                '],' +
                                                '"status": "Inactive",' +
                                                '"urls": null' +
                                            '},' +
                                            '"FullName": "dlrs_litify_pm_IntakeTrigger",' +
                                            '"EntityDefinitionId": "01IDn000003ju4Y"' +
                                        '}';
        string postContainerRespStr = '{' +
                                            '"id": "1dcU7000000DkHxIAK",' +
                                            '"success": true,' +
                                            '"errors": [],' +
                                            '"warnings": [],' +
                                            '"infos": []' +
                                        '}';
        string postTriggerMemberRespStr = '{' +
                                            '"id": "401U700000A0rcwIAB",' +
                                            '"success": true,' +
                                            '"errors": [],' +
                                            '"warnings": [],' +
                                            '"infos": []' +
                                        '}';
        string postContainerAsyncRespStr = '{' +
                                            '"id": "1drU7000002EZj8IAG",' +
                                            '"success": true,' +
                                            '"errors": [],' +
                                            '"warnings": [],' +
                                            '"infos": []' +
                                        '}';
        string getContainerAsyncRespStr = '{' +
                                            '"attributes": {' +
                                                '"type": "ContainerAsyncRequest",' +
                                                '"url": "/services/data/v51.0/tooling/sobjects/ContainerAsyncRequest/1drU7000002EZj8IAG"' +
                                            '},' +
                                            '"Id": "1drU7000002EZj8IAG",' +
                                            '"IsDeleted": false,' +
                                            '"CreatedDate": "2024-07-18T17:03:32.000+0000",' +
                                            '"CreatedById": "005Dn0000066Va8IAE",' +
                                            '"LastModifiedDate": "2024-07-18T17:03:35.000+0000",' +
                                            '"LastModifiedById": "005Dn0000066Va8IAE",' +
                                            '"SystemModstamp": "2024-07-18T17:03:35.000+0000",' +
                                            '"MetadataContainerId": "1dcU7000000DkHxIAK",' +
                                            '"MetadataContainerMemberId": null,' +
                                            '"ErrorMsg": null,' +
                                            '"IsRunTests": false,' +
                                            '"State": "Completed",' +
                                            '"IsCheckOnly": false,' +
                                            '"DeployDetails": {' +
                                                '"allComponentMessages": [' +
                                                    '{' +
                                                        '"changed": true,' +
                                                        '"columnNumber": null,' +
                                                        '"componentType": "ApexTrigger",' +
                                                        '"created": false,' +
                                                        '"createdDate": "2024-07-18T17:03:35.074+0000",' +
                                                        '"deleted": false,' +
                                                        '"fileName": "triggers/dlrs_litify_pm_IntakeTrigger.trigger",' +
                                                        '"forPackageManifestFile": false,' +
                                                        '"fullName": "dlrs_litify_pm_IntakeTrigger",' +
                                                        '"id": "01qDn000000NQGaIAO",' +
                                                        '"knownPackagingProblem": false,' +
                                                        '"lineNumber": null,' +
                                                        '"problem": null,' +
                                                        '"problemType": null,' +
                                                        '"requiresProductionTestRun": true,' +
                                                        '"success": true,' +
                                                        '"warning": false' +
                                                    '}' +
                                                '],' +
                                                '"componentFailures": [],' +
                                                '"componentSuccesses": [' +
                                                    '{' +
                                                        '"changed": true,' +
                                                        '"columnNumber": null,' +
                                                        '"componentType": "ApexTrigger",' +
                                                        '"created": false,' +
                                                        '"createdDate": "2024-07-18T17:03:35.074+0000",' +
                                                        '"deleted": false,' +
                                                        '"fileName": "triggers/dlrs_litify_pm_IntakeTrigger.trigger",' +
                                                        '"forPackageManifestFile": false,' +
                                                        '"fullName": "dlrs_litify_pm_IntakeTrigger",' +
                                                        '"id": "01qDn000000NQGaIAO",' +
                                                        '"knownPackagingProblem": false,' +
                                                        '"lineNumber": null,' +
                                                        '"problem": null,' +
                                                        '"problemType": null,' +
                                                        '"requiresProductionTestRun": true,' +
                                                        '"success": true,' +
                                                        '"warning": false' +
                                                    '}' +
                                                '],' +
                                                '"runTestResult": null' +
                                            '}' +
                                        '}';

        SaddleRockCalloutMock getTriggerInfoResp = new SaddleRockCalloutMock(200, 'OK', getTriggerInfoRespStr, null);
        SaddleRockCalloutMock postContainerResp = new SaddleRockCalloutMock(201, 'Created', postContainerRespStr, null);
        SaddleRockCalloutMock postTriggerMemberResp = new SaddleRockCalloutMock(201, 'Created', postTriggerMemberRespStr, null);
        SaddleRockCalloutMock postContainerAsyncResp = new SaddleRockCalloutMock(201, 'Created', postContainerAsyncRespStr, null);
        SaddleRockCalloutMock getContainerAsyncResp = new SaddleRockCalloutMock(200, 'OK', getContainerAsyncRespStr, null);

        ApexTrigger tgr = [SELECT Id, Body, ApiVersion FROM ApexTrigger WHERE Name = 'dlrs_litify_pm_IntakeTrigger' AND Status != 'Inactive'];

        String baseUrl = URL.getOrgDomainURL().toExternalForm() + '/services/data/v' + tgr.ApiVersion.setScale(1) + '/';
        Map<String, SaddleRockCalloutMock> resp = new Map<String,SaddleRockCalloutMock>();
        SaddleRockMultiRequestMock multiSaddleRockCalloutMock = new SaddleRockMultiRequestMock(resp);
        multiSaddleRockCalloutMock.addRequestMock(baseUrl + 'tooling/sobjects/ApexTrigger/' + tgr.Id, getTriggerInfoResp);
        multiSaddleRockCalloutMock.addRequestMock(baseUrl + 'tooling/sobjects/MetadataContainer/', postContainerResp);
        multiSaddleRockCalloutMock.addRequestMock(baseUrl + 'tooling/sobjects/ApexTriggerMember/', postTriggerMemberResp);
        multiSaddleRockCalloutMock.addRequestMock(baseUrl + 'tooling/sobjects/ContainerAsyncRequest/', postContainerAsyncResp);
        multiSaddleRockCalloutMock.addRequestMock(baseUrl + 'tooling/sobjects/ContainerAsyncRequest/1drU7000002EZj8IAG', getContainerAsyncResp);

        Test.setMock(HttpCalloutMock.class, multiSaddleRockCalloutMock);

        // Start test
        Test.startTest();
        CleanupSandbox_MetadataContainerHelper.toggleTrigger('dlrs_litify_pm_IntakeTrigger', 'Inactive');
        Test.stopTest();
    }
}