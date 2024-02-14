public with sharing class linkedInCallout {
    public static String signInLinkedIn(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LinkedIn/v2/userinfo');
        req.setHeader('Content-Type','application/JSON');
        req.setMethod('GET');
        String userId = '';
        try{
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug('response: '+res.getBody()+' '+res.getStatusCode());
            Map<String,Object> response = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            userId = (String)response.get('sub');
            System.debug(userId);
            return userId;
        }catch(Exception e){
            System.debug('Error: '+e);
        }
        return null;
    }

    @AuraEnabled
    public static void postToLinkedIn(String Message){
        String userId = signInLinkedIn();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LinkedIn/v2/ugcPosts');
        req.setMethod('POST');
        req.setHeader('X-Restli-Protocol-Version','2.0.0');
        req.setHeader('Content-Type','application/JSON');
        string authorId = 'urn:li:person:'+userId;

        Map<String, Object> payloadMap = new Map<String, Object>{
            'author' => authorId,
            'lifecycleState' => 'PUBLISHED',
            'specificContent' => new Map<String, Object>{
                'com.linkedin.ugc.ShareContent' => new Map<String, Object>{
                    'shareCommentary' => new Map<String, Object>{
                        'text' => Message
                    },
                    'shareMediaCategory' => 'NONE'
                }
            },
            'visibility' => new Map<String, Object>{
                'com.linkedin.ugc.MemberNetworkVisibility' => 'PUBLIC'
            }
        };
        
        String jsonString = JSON.serialize(payloadMap);


        req.setBody(jsonString);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug('response: '+res.getBody()+' '+res.getStatusCode());
        } catch (Exception e) {
            system.debug('Error: '+e);
        }
    }
}