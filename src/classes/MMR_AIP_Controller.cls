public class MMR_AIP_Controller extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public Opportunity Opp{get;set;}
    public Boolean PassedAffordability{get;set;}
    public Boolean DocumentCreated{get;set;}
    public String FileId {get;set;}
    
    public Transient Interfaces.ICongaSettings m_congaSettings;    
    public MMR_AIP_Controller ()
    {
         
    }    
    
    public PageReference Setup()
    {
        
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_AIP_Opp') + ' from Opportunity where id= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<Opportunity > Opps = DataBase.Query(oppSoql);
        if(Opps.size() != 1)
            return null;
            
        Opp = Opps[0];  
        
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_AIP_Applicant') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        
        UpdateDearField();
        return null;
    }   
    
    
    private void UpdateDearField()
    {
        String dear = 'Dear ';
        
        boolean first = true;
        
        for(Account a : accs)
        {
            if(first)
            {
                dear += a.Salutation+ ' ' + a.lastname;
                first = false;
                continue;
            }
        
            dear += ' and ' +  a.Salutation+ ' ' + a.lastname;
        }
        dear += ',';
        
        Opp.Dear_customer__c = dear; 
        update opp;        
    }

   
    public PageReference Save()
    {
        try
        {
        //update num btl and num properties
        
        update Accs;
        
        }
        catch(Exception ex)
        {
        
        }
        return null;
    }
    
    public PageReference Complete()
    {
        try {
          update accs;
          update Opp;
        }
        catch (Exception ex) {
          System.debug('Exception on Update exOpp : ' + ex);
          return null;
        }
    
        CompleteEvent();
        return GoToNextEvent();
  
    }
    
    private Decimal GetValue(BudgetPlannerConfig__c c,Integer depend)
    {
        if(Accs.size()==1 && !Opp.Is_Joint_Application__c)
            return c.SingleApp_ONS__c;
            
        if(depend == 0)
            return c.Joint_App_ONS__c;
            
        if(depend == 1)
            return c.Joint_App_1_Dep_ONS__c;
            
        if(depend == 2)
            return c.Joint_App_2_Dep_ONS__c;
            
        if(depend > 2)
            return c.Joint_App_3_Dep_ONS__c;
            
        
        return 0;    
    }
    
    public Decimal Diff {get;set;}
    public Decimal hppRepayment {get;set;}
    public Decimal total{get;set;}
    
    public PageReference Afford()
    {
        update opp;
        update accs;
    
        /*Integer noCars=0;
        Integer noDepend=0;
        Decimal netIncome = 0;
        
        for(Account a : Accs)
        {
            noCars += integer.valueof(a.Number_of_cars__c);
            noDepend += integer.valueof(a.No_of_depenents__c);
            netIncome += a.Net_Monthly_Income__c;
        }
        
        List<BudgetPlannerConfig__c> configs = [select id,SingleApp_ONS__c,Joint_App_ONS__c, Joint_App_1_Dep_ONS__c,Joint_App_2_Dep_ONS__c,Joint_App_3_Dep_ONS__c,Car_Bill__c from BudgetPlannerConfig__c ];
        
        total = 0;
        
        for(BudgetPlannerConfig__c c : configs )
        {
            Decimal figure=GetValue(c,noDepend); 
            if(figure == null)
                figure = 0;          
            if(c.Car_Bill__c)
            {
                figure = figure * noCars;
            }
            total += figure;            
        }
        
        //hpp payment
        Double principle = opp.Finance_Required__c;
        Double interest = 5.49;//benchmarkRate;
        Double length = opp.Term_of_Finance__c;
        Double monthlyInterest = interest / (12 * 100);
        Double numberOfMonthsAmortized = length * 12;
        
        hppRepayment = principle * (monthlyInterest / (1 - Math.pow((1 + monthlyInterest), -numberOfMonthsAmortized)));
        hppRepayment = hppRepayment.round();*/
        
        
        try{
            if ( opp.Interested_in__c.equalsIgnoreCase('Buy To Let Purchase Plan' ) || opp.Interested_in__c.equalsIgnoreCase('Buy To Let Purchase Plan Scotland' ) ){
                List<double> btlAffordResult=LiabilitiesHelperFunctions.btlAfford(opp,accs);
                
                double netIncome=btlAffordResult[2];
                hppRepayment=btlAffordResult[0];
                total=btlAffordResult[1];
                
                system.debug('response:'+btlAffordResult);
                
                diff=netIncome-total;
                
                /*double netIncome=1000;
                hppRepayment=300;
                total=500;
                diff=netIncome-total;*/
				/* C0586 */
                //passedAffordability=diff >= 0;
				System.debug ( 'This is Inc flag ' + Opp.Income_Assisted_Application__c );
				if ( diff >= 0 || Opp.Income_Assisted_Application__c == true )
				{
					passedAffordability = true;
				}
				else
				{
					passedAffordability = false;
				}
            }
            else{
                List<double> hppAffordResult=LiabilitiesHelperFunctions.hppAfford(opp,accs);
                
        
                double netIncome=hppAffordResult[2];
                hppRepayment=hppAffordResult[0];
                total=hppAffordResult[1];
                
                decimal t = total + hppRepayment;
                diff = netIncome - t;
                
                PassedAffordability = diff > 0;
            }
        }
        catch(Exception e){
            List<double> hppAffordResult=LiabilitiesHelperFunctions.hppAfford(opp,accs);
                
        
            double netIncome=hppAffordResult[2];
            hppRepayment=hppAffordResult[0];
            total=hppAffordResult[1];
            
            decimal t = total + hppRepayment;
            diff = netIncome - t;
            
            PassedAffordability = diff > 0;
        }
        
        
        
        system.debug('inside Afford(), hppRepayment:'+hppRepayment);
        
        return null;
    }
    
    public PageReference CreateDoc()
    {
        system.debug('OPP id:' + opportunityId );
        
        if(m_congaSettings == null)
        {
            IBB_Product_Set__C ps = [select Conga_AIP_MMR__c from IBB_Product_Set__C where id=:Prodset.id];
            m_congaSettings = new CongaSettings(ps.Conga_AIP_MMR__c);
        }
        
        
        string body= m_congaSettings.CallConga(opportunityId);   
        
        if(m_congaSettings.GetAttachmentId() != null)
        {
            FileId =  m_congaSettings.GetAttachmentId();
            //opp.Attachment_Welcome_Letter__c= m_congaSettings.GetAttachmentId();
            DocumentCreated = true;
            update opp;
        }      

        return null;
    }
    
    
    public PageReference Prev()
    {
        return new PageReference('/apex/mmr_aip_applicants?id=' + eventid);
    }
       
    public List<SelectOption> getTitles() {
            List<SelectOption> options = new List<SelectOption>();
             options.add(new SelectOption('Mr','Mr'));
            options.add(new SelectOption('Mrs','Mrs'));
            options.add(new SelectOption('Miss','Miss'));
            options.add(new SelectOption('Ms','Ms'));
            options.add(new SelectOption('Dr','Dr'));            
            options.add(new SelectOption('Other','Other'));
             options.add(new SelectOption('Prof','Prof'));
              options.add(new SelectOption('Sheikh','Sheikh'));
            return options;
    }
}