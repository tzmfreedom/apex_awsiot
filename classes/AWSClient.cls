public with sharing abstract class AWSClient {
    /**
     * default region
     */
    protected final String DEFAULT_REGION = 'us-east-1';
    
    /**
     * Access Key Id
     */
    private String accessKeyId;
    
    /**
     * Access Key Secret
     */
    private String accessKeySecret;
    
    /**
     * region
     */
    protected String region;
    
    public AWSClient(String accessKeyId, String accessKeySecret, String region) {
        this.accessKeyId = accessKeyId;
        this.accessKeySecret = accessKeySecret;
        this.region = region;
    }
    
    protected String getAccessKeyId() {
        return this.accessKeyId;
    }
    
    protected String getAccessKeySecret() {
        return this.accessKeySecret;
    }
}