trigger ValuationReportTrigger on Valuation_Report__c (after update) {

if(Trigger_Helper.IgnoreTrigger('Valuation_Report__c'))
        return;

Trigger_Helper.Audit('Valuation_Report__c',trigger.oldMap, trigger.newMap); 

for(Valuation_Report__c  r : Trigger.new)
{
    if(r.Date_of_Report__c == null)
        break;


    Event__c eve = [select id from event__c where name ='Awaiting Valuation'];
    List<Eventlog__c> logs = [select id, opportunity__c, event__c from eventlog__c 
                            where opportunity__c =: r.opportunity__c
                            and  IsExpired__c = false and EventStatus__c = 'Open'
                            and Event__c =: eve.id
                             ];  
                             
                                  

    List<HPP_extended_opportunity__c> ex = [select Valuation_attached__c, Valuation_received__c , opportunity__c,id 
                                            from HPP_extended_opportunity__c
                                            where opportunity__c =: r.opportunity__c ];
                                            
     List<Opportunity> opp = [select id,ProductEventDirector__c 
                         from opportunity
                         where id =: r.opportunity__c ];
    if(opp.size() == 0)
        break;                      
              
                                           
    if(logs.size() > 0)
    {
        IBBEvents director = new IBBEvents(opp[0].ProductEventDirector__c);
        Boolean returnValue = director.CompleteEvent(logs[0], opp[0]);  
        
        ex[0].Valuation_attached__c = true;
        ex[0].Valuation_received__c = date.today();
        
        update ex;
        update logs;        
    }                                       
    break;
    
    
   
        
}
}