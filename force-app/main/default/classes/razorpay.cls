public with sharing class razorpay {

    private static final String AUTH_ENDPOINT = 'https://auth.razorpay.com/authorize';
    private static final String CLIENT_ID = 'rzp_test_XYvCtBLCqV7xCt';
    private static final String CLIENT_SECRET = 'KuY1MHeIFGzMYGveTUYWWHJg';
    private static final String REDIRECT_URI = 'https://astrea-d-dev-ed1-dev-ed.develop.my.salesforce.com/services/authcallback/razorPay';

    public static String generateCustomId() {
        Long timestamp = DateTime.now().getTime();
        String randomPart = String.valueOf(Math.rint(Math.random() * 100000));

        return timestamp + randomPart;
    }
    public static String generateRandomState() {
        Integer stateLength = 10;
        String allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

        String randomState = '';
        for (Integer i = 0; i < stateLength; i++) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), allowedChars.length());
            randomState += allowedChars.substring(randomIndex, randomIndex + 1);
        }

        return randomState;
    }
    //to create an order use : POST https://api.razorpay.com/v1/orders 
    //payload : amount , currency ,reciept , payment_capture
    //http response : res.json(); 

    @AuraEnabled
    public static string authUrl(){
        String state = generateRandomState();
        String authUrl = AUTH_ENDPOINT +
            '?client_id=' + CLIENT_ID +
            '&response_type=code' +
            '&redirect_uri='+REDIRECT_URI+
            '&scope=read_only'+
            '&state='+state;
            
        return authUrl;
    }

    public static void send(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.razorpay.com/v1/payment_links');

        string apiKey = 'rzp_test_ueMKZnzvdJcxo6';
        string apiSecret = '9eALtJehPVNctR1GJPo2malm';
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(apiKey + ':' + apiSecret));
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        Map<String, Object> payloadMap = new Map<String, Object>{
            'amount' => 1000,
            'currency' => 'INR',
            'receipt' => generateCustomId(),
            'payment_capture' => true  // Set it to true or false based on your requirement
        };
        
        
        String payload = JSON.serialize(payloadMap);
        req.setBody(payload);

        try {
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Res: ' + res.getBody());
        } catch (Exception e) {
        system.debug(e);
        }

    }
}

/*
new Map<String, Object>{  
            'amount' => 1000,
            'currency' => 'INR',
            'reciept' => generateCustomId(),
            'payment_capture' =>null
         };*/