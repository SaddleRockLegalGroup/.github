public with sharing class SaddleRockMultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
    
    public SaddleRockMultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        System.debug(req.getEndpoint());
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
            } else {
                throw new SaddleRockMultiRequestMockException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }

    public class SaddleRockMultiRequestMockException extends Exception {}
}