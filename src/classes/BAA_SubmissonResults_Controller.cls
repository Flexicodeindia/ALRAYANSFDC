/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_SubmissonResults_Controller extends HPPBaseEventController
{
    public List<Case> caseList{get;set;}
    

    public BAA_SubmissonResults_Controller()
    {
        
        Cases = new Map<String,List<CaseDetail>>();
         
        caseList = DataHelper.GetCases(Opp.id);   
        Status = new Map<String,String>();
        
        for(Account a : Accounts)
        {
            
            
            List<CaseDetail> caseDetailList = new List<CaseDetail>();
            Cases.put(a.id,caseDetailList );
            Status.put(a.id,'Approved');
        }
        
        for(Case c : caseList)
        {
            for(Account a : Accounts)
            { 
                
                   
                if(c.ContactId == a.PersonContactId )
                {
                    List<CaseDetail> clist = Cases.get(a.id);
                    CaseDetail detail = new CaseDetail();
                    detail.subject = c.subject;
                    detail.detail = c.Description;
                    detail.Decision = c.referral_decision__c;
                    detail.CaseNumber= c.CaseNumber;
                    detail.Satisfied = c.satisfied__c;
                    detail.id = c.id;
                    detail.comment = c.comments__c;
                    if(detail.Decision == null)
                    {
                        detail.Decision = 'Refered';
                    }
                    
                    clist.add(detail);
                    
                    String stat = Status.get(a.id);
                    
                    if(detail.Decision.equalsIgnoreCase('declined'))
                    {
                        stat = 'Declined';
                    }
                    
                    if(detail.Decision.equalsIgnoreCase('refered') && !stat.equalsIgnoreCase('declined'))
                    {
                        stat = 'Refered';
                    }
                    Status.put(a.id,stat );
                    break;
                }
            }
        }
       // AllSatisfied();
                                
    }
    
    public Map<String,List<CaseDetail>> Cases{get;set;}
    public Map<String,String> Status {get;set;} 

    public Boolean CommentsOk{get;set;}
    
    public Boolean AllSatisfied()
    {
        Boolean Satisfied = true;
        
        for(Account a : Accounts)
        {
           
            List<CaseDetail> clist = Cases.get(a.id);
            if(clist == null)
                continue;
            if(clist.size() == 0 )
                continue;  
            
            for(CaseDetail det : clist )
            {
                if(det.satisfied == null)
                {
                    Satisfied =false;
                    continue;
                }
                if (det.satisfied.equalsIgnoreCase('no'))
                {
                    Satisfied =false;
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case  ' + det.CaseNumber + ' is not satisfied. ' ));                
                }
            }
        }
        return Satisfied ;
    }
    
    public boolean AllAccepted ()
    {
        boolean rtv = true;
        List<Case> lstCases = DataHelper.GetCases(Opp.id);  
        system.debug ('These are the cases ' + lstCases + ' - opp.id = ' + opp.id);
        for (Case cs:lstCases)
        {
            if (String.IsEmpty(cs.referral_decision__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case  ' + cs.CaseNumber + ' is not accepted. ' )); 
                rtv = false;
            }
            else if (!cs.referral_decision__c.EqualsIgnoreCase('Accept'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case  ' + cs.CaseNumber + ' is not accepted. ' )); 
                rtv = false;
            }
        }
        return rtv;
    }
    
    public boolean CheckComments()
    {
        Boolean commentsEntered= true;
        for(Account a : Accounts)
        {
           
            List<CaseDetail> clist = Cases.get(a.id);
            if(clist == null)
                continue;
            if(clist.size() == 0 )
                continue;  
            
            for(CaseDetail det : clist )
            {
                if(det.satisfied == null)
                    return false;
                if (det.satisfied.equalsIgnoreCase('no'))
                {
                    return false;
                }
                
                if(det.Comment == null | det.Comment == '')
                {         
                    commentsEntered=false;           
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a comment for case : ' + det.CaseNumber));
                }                
            }
        }
        return commentsEntered;
    }
    
    
    public void SaveCase()
    {
    
        for(Account a : Accounts)
        {
            
            List<CaseDetail> clist = Cases.get(a.id);
            if(clist == null)
                continue;
            if(clist.size() == 0 )
                continue;    
            
            for(CaseDetail det : clist )
            {
                for(Case c : caseList)
                { 
                    if(c.id == det.id)
                    {
                        c.satisfied__c = det.Satisfied;
                        if (det.Satisfied == 'Yes')
                        {
                            c.referral_decision__c = 'Accept';
                        }
                        c.comments__c= det.comment;
                        break;
                    }
                }            
            }
        } 
        update opp;
        update caseList;   
        
    }
    
    public PageReference Setup()
    {
        return CorrectPage('BAA_SubmissionResult');
        
    }
    
    
    public PageReference Save()
    {
        SaveCase();
       // AllSatisfied(); 
        return null;
    }
    
    public PageReference Complete()
    {
        if(IsCompleted)
            return null;
        
        SaveCase();
        //AllSatisfied();
        //if(AllSatisfied() && CheckComments())
        if (AllAccepted())
        {
            CompleteEvent();
        }
        
        return GoToNextEvent();
    } 
    
   
    
    public class CaseDetail
    {
        public String id{get;set;}
        public String CaseNumber {get;set;}
        public String Subject{get;set;}
        public String Detail{get;set;}
        public String Owner{get;set;}
        public String Decision{get;set;}
        public String Comment{get;set;}
        public String Satisfied{get;set;}
    }
}