public with sharing class stripeCheckout {
    public static String stripe_endpoint = 'https://api.stripe.com';
    public static String STRIPE_APIKEY = System.Label.StripeKey;


    public static void create_payment_intent(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(stripe_endpoint+'/v1/payment_intents');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization','Bearer '+STRIPE_APIKEY); 
        Map<String, String> payloadMap = new Map<String, String>{
            'amount' => '10000',
            'description' => 'salesforce payment services',
            'currency' => 'INR'
        };
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
        } catch (Exception e) {
            System.debug('e'+e);
        }
    }


    public static String create_customer(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(stripe_endpoint+'/v1/customers');
        req.setMethod('POST');
        String authHeader = 'Bearer ' + STRIPE_APIKEY;
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Map<String, String> payloadMap = new Map<String, String>{
            'name' => 'LMAO',
            'address[line1]' => '510 Townsend St',
            'address[postal_code]' => '98190',
            'address[city]' => 'san fransico',
            'address[state]'=> 'CA',
            'address[country]'=>'US'
        };
        String payload = '';
        for (String key : payloadMap.keySet()) {
            if (!String.isBlank(payload)) {
                payload += '&';
            }
            payload += key + '=' + EncodingUtil.urlEncode(payloadMap.get(key), 'UTF-8');
        }
        system.debug(payload);
        req.setBody(payload);
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('####################Customer Created: ' + res.getBody());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String custId = (String)responseMap.get('id');
            System.debug('####Customer id :'+custId);
            return custId;
        } catch (Exception e) {
            System.debug('e'+e);
            return null;
        }
    }

    @AuraEnabled
    public static String createSession(){
        //create payment intent :
        create_payment_intent();

        //create a new customer :
        String custId = create_customer();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(stripe_endpoint+'/v1/checkout/sessions');
        req.setMethod('POST');
        String authHeader = 'Bearer ' + STRIPE_APIKEY;
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Map<String, String> payloadMap = new Map<String, String>{
            'success_url' => 'https://astrea-d-dev-ed1-dev-ed.develop.lightning.force.com/lightning/n/LWC',
            'line_items[0][quantity]' => '1',
            'line_items[0][price]' => 'price_1OjxqtSIpwdiuatsX6SJCXak',
            'mode' => 'payment',
            'customer'=> custId
        };

        String payload = '';
        for (String key : payloadMap.keySet()) {
            if (!String.isBlank(payload)) {
                payload += '&';
            }
            payload += key + '=' + EncodingUtil.urlEncode(payloadMap.get(key), 'UTF-8');
        }
        system.debug(payload);
        req.setBody(payload);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('####################Customer Created: ' + res.getBody());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String checkout_url = (String)responseMap.get('url');
            System.debug('####Customer id :'+checkout_url);
            return checkout_url;
        } catch (Exception e) {
            System.debug('e'+e);
            return null;
        }

    }
}