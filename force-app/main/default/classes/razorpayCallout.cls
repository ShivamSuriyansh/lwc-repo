public with sharing class razorpayCallout {
    @AuraEnabled
    public static String useNamedCred() {
        String payload = '{'+
            ' "entity": "event",'+ 
            '"account_id": "acc_FoM4gv3Gn6NKrM",'+
            '"event": "banking_accounts.issued",'+
            '"contains": ['+
                '"accounts"'+
            '],'+
            '"payload": {'+
                '"accounts": {'+
                    '"virtual": {'+
                        '"account_number": "3434360450562835"'+
                    '},'+
                    '"current": ['+
                        '{'+
                            '"channel": "rbl",'+
                            '"account_number": "409000768239"'+
                        '}'+
                    ']'+
                '}'+
            '},'+
            '"created_at": 1604920603'+
        '}';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:razorPayw/v1/payments');
        req.setMethod('POST');
        req.setBody(payload);
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Res: ' + res.getBody());
        
        return res.getBody();
    }
}