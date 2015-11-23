public with sharing abstract class AWSSigV4Client extends AWSClient {

    public AWSSigV4Client(String accessKeyId, String accessKeySecret, String region) {
        super(accessKeyId, accessKeySecret, region);
    }

    /**
     * Signature Version4のAPIコールの共通メソッド
     */
    protected String call(
        String service,
        String hostname,
        List<String> signedHeaders,
        Map<String, String> params,
        String resource,
        String jsonBody,
        String method
    ) {
        DateTime dt = DateTime.now();
        String credentialScope = dt.formatGmt('YYYYMMdd') + '/' +
                                 this.region + '/' + service + '/aws4_request';

        String stringToSign = this.createStringToSign(
            'AWS4-HMAC-SHA256',
            dt,
            credentialScope,
            this.createHashedCanonicalRequest(
                'SHA256',
                'POST',
                resource,
                params,
                new Map<String, String>{
                    'Host' => hostname,
                    'x-amz-date' => dt.formatGmt('YYYYMMdd') + 'T' + dt.formatGmt('HHmmss') + 'Z'
                },
                signedHeaders,
                jsonBody
            )
        );

        String signature = this.createSignature(
            'hmacSHA256',
            dt,
            region,
            service,
            Blob.valueOf(stringToSign)
        );

        HttpRequest req = new HttpRequest();
        req.setHeader('Host', hostname);
        req.setHeader(
            'x-amz-date',
            dt.formatGmt('YYYYMMdd') + 'T' + dt.formatGmt('HHmmss') + 'Z'
        );

        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Content-Length', String.valueOf(jsonBody.length()));

        req.setHeader(
            'Authorization',
            'AWS4-HMAC-SHA256 Credential=' + this.getAccessKeyId() + '/' + credentialScope + ',' +
            'SignedHeaders=' + String.join(Utility.getLowerCaseSortedList(signedHeaders), ';') + ',' +
            'Signature=' + signature
        );
        req.setEndpoint('https://' + hostname + resource);
        req.setMethod(method);

        req.setBody(jsonBody);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }

    /**
     * HashedCanonicalRequestを作成
     */
    private String createHashedCanonicalRequest(
        String algorithm,
        String method,
        String url,
        Map<String, String> params,
        Map<String, String> headers,
        List<String> signedHeaders,
        String payload
    ) {
        String signature = '';
        signature += method + Constants.LF;
        signature += url + Constants.LF;
        signature += Utility.getSortedParam(params) + Constants.LF;
        signature += Utility.createCanonicalHeaders(headers) + Constants.LF;
        signature += String.join(Utility.getLowerCaseSortedList(signedHeaders), ';').toLowerCase() + Constants.LF;
        signature += EncodingUtil.convertToHex(
                        Crypto.generateDigest(
                            algorithm,
                            Blob.valueOf(payload)
                        )
                     );
        return EncodingUtil.convertToHex(
            Crypto.generateDigest(
                algorithm,
                Blob.valueOf(signature)
            )
        ).toLowerCase();
    }
    /**
     * StringToSignを作成
     */
    private String createStringToSign(
        String algorithm,
        DateTime requestDateTime,
        String credentialScope,
        String hashedCanonicalRequest
    ) {
        String stringToSign = algorithm + Constants.LF;
        stringToSign +=
           requestDateTime.formatGmt('YYYYMMdd') + 'T' +
           requestDateTime.formatGmt('HHmmss') + 'Z' + Constants.LF;
        stringToSign += credentialScope + Constants.LF;
        stringToSign += hashedCanonicalRequest;
        return stringToSign;
    }

    /**
     * Signature生成
     */
    private String createSignature(
        String algorithm,
        DateTime requestDateTime,
        String region,
        String service,
        Blob stringToSign
    ) {
        //system.debug(stringToSign.toString());
        Blob kDate = Crypto.generateMac(
            algorithm,
            Blob.valueOf(requestDateTime.formatGmt('YYYYMMdd')),
            Blob.valueOf('AWS4' + this.getAccessKeySecret())
        );
        Blob kRegion = Crypto.generateMac(
            algorithm,
            Blob.valueOf(region),
            kDate
        );
        Blob kService = Crypto.generateMac(
            algorithm,
            Blob.valueOf(service),
            kRegion
        );

        Blob kSigning = Crypto.generateMac(
            algorithm,
            Blob.valueOf('aws4_request'),
            kService
        );

        return EncodingUtil.convertToHex(
            Crypto.generateMac(
                algorithm,
                stringToSign,
                kSigning
            )
        );
    }


}