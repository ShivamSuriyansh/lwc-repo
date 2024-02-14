public with sharing class stripeApi {
    public static string STRIPE_APIKEY = 'sk_test_51OixYESIpwdiuats0p60fqedajQe9Z2wdyudqGOOBhLj0hv0ICSa0Q3Lh7S0XQq2qmCwPwdxbg5LRrZQ9MxYB3oo00z6q4Cgjf';
    public static string CUSTOMER_ENDPOINT = 'https://api.stripe.com/v1/customers';

    public static String createCustomer(){
        HttpRequest req  = new HttpRequest();
        req.setEndpoint(CUSTOMER_ENDPOINT);
        req.setMethod('POST');
        String authHeader = 'Bearer ' + STRIPE_APIKEY;
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', 'x-www-form-urlencoded');
        Map<String, Object> payloadMap = new Map<String, Object>{
            'name' => 'Anything',
            'email' => 'anything@gmail.com',
            'description' => 'Just a customer'
        };
        String payload = JSON.serialize(payloadMap);
        req.setBody(payload);


        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('Res: ' + res.getBody());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String customerId = (String)responseMap.get('id');
            return customerId;
        } catch (Exception e) {
            System.debug(e);
            return null;
        }

        
    }


    public static String payment(){
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://api.stripe.com/v1/payment_methods');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization','Bearer '+STRIPE_APIKEY); 
        Map<String, Object> payloadMap = new Map<String, Object>{
            'type' => 'card',
            'card.cvc' => 314,
            'card.exp_year' => 2026,
            'card.exp_month' => 8,
            'card.number' => '4242424242424242'
        };
        
        String payload = JSON.serialize(payloadMap);
        system.debug(payload);
        request.setBody(payload);
        try {
            HttpResponse res = http.send(request);
            System.debug('Res: ' + res.getBody());
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String cart_id = (String)responseMap.get('id');
            return cart_id;
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
    }

    public static void connectingCart(){
        String customerId  = createCustomer();
        String cardId = payment();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://api.stripe.com/v1/payment_methods/'+cardId+'/attach');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization','Bearer '+STRIPE_APIKEY);
        request.setBody('customer='+CustomerId);
        HttpResponse response = http.send(request);

        try {
            HttpResponse res = http.send(request);
            System.debug('Res: ' + res.getBody());
        } catch (Exception e) { 
            System.debug(e);
        } 
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
}