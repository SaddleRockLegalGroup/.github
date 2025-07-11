@IsTest
public class SaddleRockMetadataCallbackTest {
    @IsTest
    static void testSaddleRockCallback() {
        Metadata.DeployCallback callback = new SaddleRockMetadataCallback();
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        callback.handleResult(result, context);
    }
}