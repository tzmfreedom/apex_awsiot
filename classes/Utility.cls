/**
 * Utility
 */
public with sharing class Utility {
    /**
     * ユーティリティクラスのためインスタンス化不可能
     */
    private Utility(){

    }

    /**
     * key=value&...でつないだ文字列を返却
     * @param mapParam 対象文字列=>文字列マップ
     * @return key=value&...でつないだ文字列
     */
    public static String getParam(Map<String,String> mapParam){
        if (mapParam == null || mapParam.keySet().isEmpty()) {
            return '';
        }
        String param = '';
        for(String key: mapParam.keySet()){
            param += key + '=' + EncodingUtil.urlEncode(mapParam.get(key),'UTF-8') + '&';
        }
        return param.substring(0,param.length() - 1);
    }


    public static String nullToBlank(String target) {
        if (target == null) {
            return '';
        }
        return target;
    }

    public static List<String> getSortedList(Set<String> keys) {
        List<String> sortedList = new List<String>();
        sortedList.addAll(keys);
        sortedList.sort();
        return sortedList;
    }

    /**
     * key=value&...でつないだ文字列を返却
     * @param mapParam 対象文字列=>文字列マップ
     * @return key=value&...でつないだ文字列
     */
    public static String getSortedParam(Map<String,String> mapParam){
        if (mapParam == null || mapParam.keySet().isEmpty()) {
            return '';
        }
        String param = '';
        List<String> sortedKey = getSortedList(mapParam.keySet());
        for(String key: sortedKey){
            param += percentEncodeRfc3986(key) + '=' + percentEncodeRfc3986(mapParam.get(key)) + '&';
        }
        return param.substring(0,param.length() - 1);
    }

    public static String percentEncodeRfc3986(String s) {
        return EncodingUtil.urlEncode(s, 'UTF-8')
                    .replace('+', '%20')
                      .replace('*', '%2A')
                      .replace('%7E', '~');
    }

    /**
     * CanonicalHeaders文字列を生成
     * @param Map<String, String> headers 対象のHTTPヘッダマップ
     * @return String CanonicalHeaders文字列
     */
    public static String createCanonicalHeaders(Map<String, String> headers) {
        if (headers == null || headers.keySet().isEmpty()) {
            return '';
        }

        Map<String, String> lowerCaseHeaders = new Map<String, String>();
        for (String key : headers.keySet()) {
            lowerCaseHeaders.put(key.toLowerCase(), headers.get(key));
        }
        String param = '';
        List<String> sortedKey = getSortedList(lowerCaseHeaders.keySet());
        for(String key: sortedKey){
            param += key + ':' + lowerCaseHeaders.get(key).trim() + '\n';
        }
        return param;
    }

    /**
     * LowerCaseでソートしたリストを生成
     * @param keys 生成元文字列
     * @param return
     */
    public static List<String> getLowerCaseSortedList(List<String> keys) {
        List<String> sortedKeys = new List<String>();
        for (String key : keys) {
            sortedKeys.add(key.toLowerCase());
        }
        sortedKeys.sort();
        return sortedKeys;
    }

    public static String encodeUrlsafeBase64(Blob target) {
        String ret = EncodingUtil.base64Encode(target);
        ret = ret.replace('+', '-');
        ret = ret.replace('/', '_');
        ret = ret.replace('=', '');
        return ret;
    }

    public static Blob decodeUrlsafeBase64(String target) {
        String ret = target;
        ret = ret.replace('-', '+');
        ret = ret.replace('_', '/');
        return EncodingUtil.base64Decode(ret);
    }
}