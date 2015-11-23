public with sharing class AWSIoTClient extends AWSSigV4Client {
    /**
     * iotdata service name
     */
    private final String IOTDATA_SERVICE = 'iotdata';
    
    /**
     * prefix for endpoint.
     */
    private String prefix;
    
    /**
     * @param accessKeyId AWS Access Key ID
     * @param accessKeySecret AWS Access Key Secret.
     * @param region target region.
     * @param prefix prefix for endpoint.
     */
    public AWSIoTClient(String accessKeyId, String accessKeySecret, String region, String prefix) {
        super(accessKeyId, accessKeySecret, region);
        this.prefix = prefix;
    }
    
    /**
     * Publish for AWS IoT topic.
     * @param topicName topic name for publish.
     * @param payload payload for publish.
     * @return String http response for publish rest api.
     */
    public String publish(
        String topicName,
        Map<String, Object> payLoad
    ) {
        Map<String, String> params = new Map<String, String>{};
        
        List<String> signedHeaders = new List<String>{
            'host', 'x-amz-date'
        };
        
        String jsonBody = Json.serialize(payLoad);
        String resource_path = '/topics/' + topicName;
        String hostname = this.prefix + '.iot.' + this.region + '.amazonaws.com';
        
        return this.call(
            IOTDATA_SERVICE,
            hostname,
            signedHeaders,
            params,
            resource_path,
            jsonBody,
            'POST'
        );
    }
}