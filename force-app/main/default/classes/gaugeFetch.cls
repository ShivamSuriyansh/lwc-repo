public with sharing class gaugeFetch {
    
    @AuraEnabled(cacheable=true)
    public static decimal fetchingStudents(){
        list<studentMarks__c> stuList = [SELECT id, Marks__c from studentMarks__c];
        system.debug('Students Marks: '+stuList);
        decimal max1 = stuList[0].Marks__c;
        for(studentMarks__c s : stuList){
            max1 = Math.max(max1,s.Marks__c);
        }
        return max1;
    }
}