public with sharing class stripeApi {
    public static string STRIPE_APIKEY = 'sk_test_51OixYESIpwdiuats0p60fqedajQe9Z2wdyudqGOOBhLj0hv0ICSa0Q3Lh7S0XQq2qmCwPwdxbg5LRrZQ9MxYB3oo00z6q4Cgjf';
    public static string CUSTOMER_ENDPOINT = 'https://api.stripe.com/v1/customers';

    public static String createCustomer() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(CUSTOMER_ENDPOINT);
        req.setMethod('POST');
        String authHeader = 'Bearer ' + STRIPE_APIKEY;
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Map<String, String> payloadMap = new Map<String, String>{
            'name' => 'Anything',
            'email' => 'anything@gmail.com',
            'description' => 'Just a customer'
        };

        // Convert payloadMap to URL-encoded string
        String payload = '';
        for (String key : payloadMap.keySet()) {
            if (!String.isBlank(payload)) {
                payload += '&';
            }
            payload += key + '=' + EncodingUtil.urlEncode(payloadMap.get(key), 'UTF-8');
        }
        req.setBody(payload);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('###############createCustomer:: ' + res.getBody());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return (String)responseMap.get('id');
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
    }


    public static paymentClass payment() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://api.stripe.com/v1/payment_intents');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization','Bearer '+STRIPE_APIKEY); 
        Map<String, String> payloadMap = new Map<String, String>{
            'currency' => 'inr',
            'payment_method' => 'pm_card_amex_threeDSecureNotSupported',
            'amount' => '500'
            // 'customer[name]' => 'John Doe', // Include customer name
            // 'customer[address][line1]' => '123 Main Street', // Include customer address
            // 'customer[address][city]' => 'City',
            // 'customer[address][state]' => 'State',
            // 'customer[address][postal_code]' => '12345',
            // 'customer[address][country]' => 'IN'
        };

        // Convert payloadMap to URL-encoded string
        String payload = '';
        for (String key : payloadMap.keySet()) {
            if (!String.isBlank(payload)) {
                payload += '&';
            }
            payload += key + '=' + EncodingUtil.urlEncode(payloadMap.get(key), 'UTF-8');
        }
        system.debug(payload);
        request.setBody(payload);

        try {
            HttpResponse res = http.send(request);
            System.debug('####################Payment: ' + res.getBody());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String paymentIntentId = (String)responseMap.get('id');
            String clientSecret = (String)responseMap.get('client_secret');
            String cardId = (String)responseMap.get('payment_method');
            return new paymentClass(paymentIntentId,clientSecret,cardId);
        } catch (Exception e) {
            System.debug('e'+e);
            return null;
        }
    }

    public static void connectingCart() {
        String customerId = createCustomer();
        paymentClass p = payment();
        System.debug('###########################p:     '+p);
        boolean isSuccess = verifyPaymentIntent(p);
        System.debug('#########################SUCCESS');
    }
    
    

    public static boolean verifyPaymentIntent(paymentClass p) {
        String[] parts = p.clientSecret.split('_secret_');
        String secret = parts.size() > 1 ? parts[0] : null;

        if (p.paymentIntentId == null) {
            System.debug('###################################NULL');
            return false;
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://api.stripe.com/v1/payment_intents/' + p.paymentIntentId + '/confirm');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer ' + STRIPE_APIKEY);
        String requestBody = 'payment_method=' + p.cardId + '&return_url=' + 'https://astrea-d-dev-ed1-dev-ed.develop.lightning.force.com/lightning/n/LWC';
        request.setBody(requestBody);
    
        try {
            HttpResponse res = http.send(request);
            System.debug('Confirm PaymentIntent Response: ' + res.getBody());
    
            // Handle the response accordingly
            if (res.getStatusCode() == 200) {
                // Payment intent confirmed successfully
                System.debug('PaymentIntent confirmed successfully');
                return true;
            } else {
                // Handle errors or additional steps based on the response
                System.debug('Error confirming PaymentIntent: ' + res.getBody());
                return false;
            }
        } catch (Exception e) {
            System.debug('Error confirming PaymentIntent: ' + e);
        }
        return null;
    }
    

    public static void checkout(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.stripe.com/v1/checkout/sessions');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+STRIPE_APIKEY); 

        String body = 'https://astrea-d-dev-ed1-dev-ed.develop.lightning.force.com/lightning/page/home' +
                      '&line_items[0][price]=price_1MotwRLkdIwHu7ixYcPLm5uZ' +
                      '&line_items[0][quantity]=2' +
                      '&mode=payment';

        req.setBody(body);
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            System.debug(responseBody);
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            System.debug(res.getBody());
        }
    }

    public Class paymentClass{
        public  String cardId;
        public  String clientSecret;
        public  String paymentIntentId;

        public paymentClass(String paymentIntent, String secret, String card){
            this.paymentIntentId  = paymentIntent;
            this.clientSecret = secret;
            this.cardId = card;
        }
    }
}