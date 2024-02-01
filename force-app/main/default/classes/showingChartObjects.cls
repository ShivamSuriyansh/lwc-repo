public with sharing class showingChartObjects {
    

    @AuraEnabled(cacheable=true)
    public static Data get_no_of_objects(date startDate , date endDate){
        system.debug('date: '+startDate+' ' +endDate);
        Map<String, Integer> totalCount = new Map<String, Integer>();
        Integer oppCount = [SELECT COUNT() FROM Opportunity WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate];
        Integer accCount = [SELECT COUNT() FROM Account WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate];
        Integer conCount = [SELECT COUNT() FROM Contact WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate];
        Integer leadsCount = [SELECT COUNT() FROM Lead WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate];
        Integer campaignCount = [SELECT COUNT() FROM Campaign WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate];
    
        totalCount.put('Account', accCount);
        totalCount.put('Contact', conCount);
        totalCount.put('Opportunity', oppCount);
        totalCount.put('Leads', leadsCount);
        totalCount.put('Campaign', campaignCount);
    
        System.debug('data: ' + totalCount);
    
        List<Integer> counts = new List<Integer>{totalCount.get('Account'), totalCount.get('Contact'), totalCount.get('Opportunity'), totalCount.get('Leads'), totalCount.get('Campaign')};
        List<String> names = new List<String>{'Account', 'Contact', 'Opportunity', 'Leads', 'Campaign'};
    
        return new Data(names, counts);
    }
    

    public class Data{
        @AuraEnabled
        public List<string> objNames { get; set; }
        @AuraEnabled
        public List<integer> objCounts { get; set; }

        public Data(list<string> names ,list<integer> count){
            this.objNames = names;
            this.objCounts = count;
        }
    }
}