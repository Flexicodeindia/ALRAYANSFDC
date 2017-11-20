public virtual class HPPBaseEventController{
    private static aLog.Logger Log = new aLog.Logger('HPPBaseEventController');
    public String eventId 
    {
        get 
        {
            if (eventId == null)
            {
                eventId = ApexPages.currentPage().getParameters().get('id');
            }
            return eventId ;
        }
        set;
    }
    
    public String oppId
    {
        get 
        {
            if (oppId== null)
            {
                oppId= ApexPages.currentPage().getParameters().get('oppId');
            }
            return oppId;
        }
        set;
    }    
    
    public Boolean ProductSwitch
    {
        get{
            return Opp.recordtype.developername.equalsIgnoreCase('ProductSwitching');            
        }
    }
    
    public String opportunityId{get;set;}    
    public I_IBBEvents director {get;set;}
    public Integer CurApp{get;set;}
    public HPPBaseEventHelper.EventType TypeofEvent{get;set;}
    
    public HPP_extended_opportunity__c exOpp
    {
        get{
            if(exOpp == null)
            {
                exOpp = DataHelper.GetHPPExtendedOpportunityByOpp(string.valueof(opportunityId))[0];
            }
            return exOpp;
        }
        set;
        
    }
    public IBB_Product__c Prod {get;set;}  
    public List<Account> Accounts {get;set;}  
    public List<Applicant__c> Applicants {get;set;}
        
    public EventLog__c EventLog{get;set;}
    public Event__c Event{get;set;}   
    
    public Opportunity Opp
    {
        get{
            return BaseOpportunity;
        }
        set{
            BaseOpportunity = value;
        }
    }
    
    
    public Opportunity BaseOpportunity{get;set;}
     
    public boolean IsCompleted{get;set;}
    public IBB_Product_set__c prodSet{get;set;}  
    public String NextEventUrl {get;set;}  
    
    /*private Boolean UserAuthorised()
    {
        User u = [select UserRoleId from user where id=: UserInfo.getUserId()];
        
        if(Event.Allowed_Roles__c == null)
            return true;
        
         List<String> roleIds= 
              (List<String>)JSON.deserialize(Event.Allowed_Roles__c, List<String>.class);
        
        if(roleIds.size() == 0)
            return true;
        
        //Get event roles 
        List<UserRole> userRoles = [select id from userrole where id in: roleIds];
        
        for(UserRole ur : userRoles)
        {
            if(ur.id == u.UserRoleId)
                return true;
        }
        return false;
    }
    */

    public Boolean IsUserAuthorised
    {
        get{
            return HPPBaseEventHelper.UserAuthorised(Event);
        }
    }    
    
    public PageReference CorrectPage(String page)
    {
        if(!ISCorrectPage(page))
        {
            return new PageReference(event.CustomPageLocation__c + '?id=' + EventLog.id);
        }
        
        if(!IsUserAuthorised)
            return new PageReference('/apex/eventsecurity' + '?id=' + EventLog.id);
        
        return null;
    }

    public Boolean IsCorrectPage(String page)
    {
        system.debug('Checking Page :' + page);
            //check page is the correct page
          
 
            
            if(Event.CustomPageLocation__c != null & page==null)
                return false;
            
            if(Event.CustomPageLocation__c != null & page!= null)
            {
                String currentPage = '/apex/' + page;
                system.debug('C: ' + currentPage + ' , P: ' + page);
                
                return currentPage.equalsIgnoreCase(Event.CustomPageLocation__c);                 
            }
            return false;
    }

    public Account Acc
    {
        get
        {           
            if(Accounts.Size() == 0) return null;
            
            if(Accounts.size() < Curapp)
            {
                Curapp = Accounts.size();                
            }
            
            return Accounts[CurApp-1];
        }
    }
    
    private void LoadEvent()
    {
        IsCompleted = false;
        List<EventLog__c> listEvent = DataHelper.GetEventLog(eventId );
        if(listEvent.size() == 0)
        return;
        
        EventLog = listEvent[0];        
        Event = DataHelper.GetEvent(EventLog.Event__r.id)[0];
        if(EventLog.eventstatus__c != 'Open')
        {
            IsCompleted = true;         
        }  
    }  
    
    public ProductEventDirector__c oDirector{get;set;}
    
    public HPPBaseEventController() 
    {    
        //If an eventid is passed, get the opportunity from the event.  Otherwise look for the opportunity id in the querystring
        //String opportunityId;
        

        Accounts = new List<Account>();
        if(eventId == null)
        {   
            if(oppId == null)
                return;     
            opportunityId = oppId;                       
        }    
        else
        {
            LoadEvent();
            if(EventLog == null)
                return;              
                
            opportunityId= EventLog .Opportunity__c;
        }
        
        Logger.debug('OPP id : ' + opportunityId);
               
        opportunity oo = [select id,ProductEventDirector__c from opportunity where id=:opportunityId ];
        director = new IBBEvents(oo.ProductEventDirector__c);        
        oDirector = DataHelper.GetDirector(oo.ProductEventDirector__c)[0];
        
        TypeofEvent = HPPBaseEventHelper.GetEventType(oDirector.BaseController__c);       
                     
        BaseOpportunity = HPPBaseEventHelper.LoadOpportunity(TypeofEvent,opportunityId) ;//   DataHelper.GetOpportunity(opportunityId)[0];
        
        system.debug(BaseOpportunity);
        
        
        
        
        //Load product     
        system.debug('load product : ' + opp.IBB_Product__c);
        if(opp.IBB_Product__c != null)
        {
        prod = DataHelper.GetProduct(opp.IBB_Product__c)[0];          
        }
        
        if(TypeofEvent == HPPBaseEventHelper.EventType.HPP)        
        prodSet = [select Conga_Welcome_Letter__c, Max_No_of_Applicants__c, ProductSetType__c, IDD_Document__c,name,Conga_Application_Form__c,Conga_AIP_Letter__c  from IBB_Product_Set__c where name=: opp.interested_in__c limit 1 ];
        
        //if(TypeofEvent == EventType.MMR || TypeofEvent == EventType.BAA)
        
        
        

        //String oppid=Opp.id;

        Applicants = DataHelper.GetApplicants(Opp.Id);
        
        for(Integer i = 0; i< Applicants.Size();i++)
        {       
                Account applicant = DataHelper.GetAccount(Applicants [i].Prospect_Customer__c)[0];
                Applicants[i].Prospect_Customer__r = applicant;
                Accounts.add(applicant);

        }
        opp.Number_of_People_Applying__c  = Accounts.size();
        CurApp = 1;
    }
    
    public List<SelectOption> getNumApplicants() 
    {    
        List<SelectOption> options = new List<SelectOption>();               
        for(Integer i =0; i<prodSet.Max_No_of_Applicants__c; i++)
        {
               options.add(new SelectOption(string.valueof(i+1),string.valueof(i+1)));    
        }
        return options;
    }  
    
        public RecordType recType {
        get {
            if (recType == null){            
                recType = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'ProspectCustomer' limit 1];
            }
            return recType;
        }
        set;
    }  
    
    public EventLog__c CreatedEvent {get;set;}
    
    
    public boolean IsCredit
    {
        get 
        {
            if (IsCredit== null)
            {
                String b= ApexPages.currentPage().getParameters().get('credit');
                if(b == null) IsCredit = false;     
                
                try
                {
                    IsCredit = boolean.valueof(b);
                }
                catch(exception ex)
                {
                
                }
                           
            }
            return IsCredit;
        }
        set;
    }     
    
    public List<String> lstAccountIds
    {
        get{
            List<String> ids = new List<String>();
            for(Account tempApplicant: Accounts)
            {
               ids.add(tempApplicant.id);                           
            }
            return ids;
        }
    }
    
    public String AccountIds  
    {
        get
        {
            String accountIds  = '(';
            boolean firstItem = true;
            
            for(Account tempApplicant: Accounts)
            {
                if(firstItem)
                {
                    firstItem = false;
                }
                else
                {
                    accountIds  += ',';   
                }        
                accountIds  += '\'' + tempApplicant.id+ '\'';
                           
            }
            accountIds  += ')';
            return accountIds;
        }
    }
    
    public PageReference GoToNextEvent()
    {
        system.debug('Created Event ' + CreatedEvent);
        if(CreatedEvent == null)
            return null;
        
        system.debug('Redirect page ' + NextEventUrl);    
        return new PageReference(NextEventUrl);
    }
    
    public boolean CompleteEvent()
    {       
        //Check required fields
        system.debug('Checking required fields');
        if(!CheckRequriedFields())
        {
            system.debug('CheckRequriedFields - fields requried');
            return null;
        }
    
        IsCompleted =true;             
        //IBBEvents director = new IBBEvents(opp.ProductEventDirector__c);
        
        //check    
        Boolean returnValue = director.CompleteEvent(EventLog, opp);  
        if(!returnValue)return null;
                
                
        CreatedEvent = director.GetCreatedEvent(); 
        system.debug('Created Event : ' + CreatedEvent);
        system.debug('Error : ' + director.ErrorMessage());
        
        if(director.GetCreatedEventLocation() != null)
        {
            NextEventUrl  = director.GetCreatedEventLocation() + '?id=' +CreatedEvent.id;
        }
        else
        {
            NextEventUrl  = '/apex/HPPBOEvent?id=' + CreatedEvent.id;
        }
        
        
        system.debug('Director.Created Event ' + director.GetCreatedEvent());
        system.debug('Created Event ' + CreatedEvent );
        
        return returnValue; 
    }  
    
    public boolean CheckRequriedFields()
    {            
        
        if(Event.RequiredFields__c  == null)
        return true;

        system.debug('required fields value : ' + Event.RequiredFields__c);
    
        List<HPPObjects.RequiredFields> fields =  
              (List<HPPObjects.RequiredFields>)JSON.deserialize(Event.RequiredFields__c , List<HPPObjects.RequiredFields>.class);
                  
        Boolean hasError = false;       
        system.debug('fields to check : ' + fields.size())  ;         
        for(HPPObjects.RequiredFields rf : fields)
        {
            //Boolean isValid= false;
            system.debug('Checking field ' + rf.ObjectName + '.' + rf.Field);
            if(!CheckFieldRequired(rf.Field,rf.ObjectName))
            {
                String msg ;
                
                if(rf.Message!= null)
                {
                    msg = rf.Message;
                }
                else
                {
                    msg = rf.field + ' on ' + rf.objectName + ' is required' ;
                }
            
            
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,msg );
                
                ApexPages.addMessage(myMsg );
                hasError = true;
            }
        }                 
                  
        return !hasError;
    }
    
    public boolean CheckFieldRequired(string field,string objectname)
    {
        system.debug('CheckFieldRequired: field=> ' + field + ' object=> ' + objectname);
        if(ObjectName.equalsIgnoreCase('opportunity'))
        {
            return CheckOppField(field);
        }
            
        if(ObjectName.equalsIgnoreCase('account'))
        {
            return CheckAccField(field);
        }
            
        if(ObjectName.equalsIgnoreCase('HPP_extended_opportunity__c'))
        {
            return CheckExOppField(field);
        }
        return false;
    }
    
    
    public boolean CheckOppField(String field)
    {
        system.debug('Object value of field ' +  field + ' = ' +Opp.get(field) );
        return Opp.get(field) != null;        
    }
    
    public boolean CheckAccField(String field)
    {
        system.debug('Object value of field ' +  field + ' = ' +Acc.get(field) );
        return Acc.get(field) != null;        
    }
    
    public boolean CheckExOppField(String field)
    {
        system.debug('Object value of field ' +  field + ' = ' +ExOpp.get(field) );
        return ExOpp.get(field) != null;        
    }        
    
    public List<Account> GetAccount(string id,string query )
    {
        List<SOQLQuery__c> q = SOQLQuery__c.getall().values();
        SOQLQuery__c found = null;
        
        for(SOQLQuery__c s : q)
        {
            if(s.name.equalsIgnoreCase(query))
            {
                found = s;
                break;
            }            
        }
               
        if(found == null)
            return DataHelper.GetAccount(id);
            
            
        String soql = LiabilitiesHelperFunctions.SoqlQuery(found);
        soql += ' where id = ' + id;
        return DataBase.Query(soql);
        
    }
    
    public List<Account> GetAccount(Integer applicant, string query)
    {
        return GetAccount(Accounts [applicant-1].id,query);
    }
    public List<Account> GetAccount(string query)
    {
        return GetAccount(Accounts [Curapp].id,query);
    }
    
    
    
    
    
 
}