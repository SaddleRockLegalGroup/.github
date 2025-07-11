public with sharing class SaddleRockMetadataCallback implements Metadata.DeployCallback{
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        } 
        else {
            System.debug('fail: '+ result);
        }

    }
}