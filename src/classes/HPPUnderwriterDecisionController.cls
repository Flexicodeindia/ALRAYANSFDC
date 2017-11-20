public class HPPUnderwriterDecisionController extends HPPBaseEventController
{
    public AffordabilityResults__c Affordability{get;set;} 
    public Asset_Relationship__c[] IBBAccounts{get;set;}
    public Asset_Relationship__c[] IBBAccountsPipeline{get;set;}
    public Asset_Relationship__c[] IBBAccountsLiability {get;set;}
    public HPPEventConditionHelper helper{get;set;}
    public List<Credit_Score__c> Credits{get;set;}
    public List<Case> caseList{get;set;}
    public Double Aggregation{get;set;}
    public List<Attachment> atts{get;set;}
    public List<Valuation_Notification__c> ValNotifications  {get;set;}
    public Valuation_Report__c ValReport{get;set;}
	// C0586 UW Start 
	public Decimal minimumRentalIncome{get;set;}
	public Decimal minimumRentalIncomeDeficit{get;set;}
	public Decimal PRARentalIncome{get;set;}
	public Decimal PRARentalIncomeDeficit{get;set;} 
	public Decimal PRACoverage{get;set;}
	public Decimal TotalCharges{get;set;}
	public Boolean FailsBP{get;set;}
	public Boolean isIAA{get;set;}
	// C0586 UW End
    
    public String XmlViewerUrl{
        get{
            if(XmlViewerUrl== null)
            {
                XMLViewer__c xml = [select url__c from XMLViewer__c limit 1];
                XmlViewerUrl = xml.url__c;
            }
            return XmlViewerUrl;
        }
        set;
    }
    
    public Board_Limits_v1__c Limits{get;set;}
    
    public PageReference RerunAffordability()
    {
        if(oDirector.IsMMR__c)
        {
            MMR_Affordability afford = new MMR_Affordability(Opp, ExOpp, prod);
            afford.incomeMultiplier();
            afford.affordabilityCalculation();
            afford.budgetPlanner();
            afford.saveResults();
			// C0586 Start UW
			minimumRentalIncome=afford.minimumRentalIncome;
			minimumRentalIncomeDeficit=afford.minimumRentalIncomeDeficit;
			PRARentalIncome=afford.PRARentalIncome;
			PRARentalIncomeDeficit=afford.PRARentalIncomeDeficit;
			PRACoverage=afford.PRACoverage;
			TotalCharges=afford.totalCharges;
			FailsBP=afford.failedBP;
			isIAA=Opp.Income_Assisted_Application__c;
			// C0586 End UW
            LoadAffordibility();        
        }
        else
        {
            Affordability afford = new Affordability(Opp, ExOpp, prod);
            afford.incomeMultiplier();
            afford.affordabilityCalculation();
            afford.budgetPlanner();
            afford.saveResults();
            LoadAffordibility();
        }        
        return null;
    }
    
    public void LoadAffordibility()
    {
        
    
    
    
        Affordability = [select GrossAnnualIncomeApplicant1__c,GrossAnnualIncomeApplicant2__c,GrossAnnualIncomeApplicant3__c,GrossAnnualIncomeApplicant4__c,
                                NetMonthlyIncomeApplicant1__c, NetMonthlyIncomeApplicant2__c, NetMonthlyIncomeApplicant3__c, NetMonthlyIncomeApplicant4__c,
                                IncomeMultiplier4_5Total__c, Fti__c, IncomeMultiplier5_1__c, AffordabilityPercentage__c,AffordabilityResult__c, BudgetPlannerSurplusOrDeficit__c
                                ,IncomeMultiplierResult__c ,BudgetPlannerResult__c,TotalCommitments__c ,additionalrentalincome__c ,StressedHPPRepayment__c
                                from AffordabilityResults__c
                         where opportunity__c=:opp.id order by createddate desc limit 1];
    }
    
    private void Init()
    {
        Cases = new Map<String,List<Case>>();
         
         caseList = DataHelper.GetCases(Opp.id);   
        Status = new Map<String,String>();
        RecordType recType =  [select id from recordType where sobjectType='case' and DeveloperName = 'HPP_CAA_CASE' limit 1];
        
        if(ExOpp.Number_of_cars__c == null)
        {
            ExOpp.Number_of_cars__c = 0;
            Decimal numCar = 0;
            for(account a: accounts)
            {
                if(a.number_of_cars__c != null)
                {
                    ExOpp.Number_of_cars__c += a.number_of_cars__c ;
                }
            }
        }
        
        for(Account a : Accounts)
        {
            List<Case> caseDetailList = new List<Case>();
            
            for(Case c : caseList)
            {
                if(c.ContactId == a.PersonContactId && c.recordtypeId==recType.id)
                {
                    caseDetailList.add(c);
                }
            }            
            Cases.put(a.id,caseDetailList );
            Status.put(a.id,'Approved');
        }
        
        
        Aggregation = GetTotalLiability();
       
        
    }
    
    
    public HPPUnderwriterDecisionController()
    {
        Init();
    }
    
    public Boolean IsBTL
    {
        get{
            System.debug('this is product set type ' + prodset);
        
            return prodSet.ProductSetType__c.equalsIgnoreCase('BTL'); 
        }
    }
    
    public String JsonConditions
    {
        get{
            List<JsonCondition> lstCond = new List<JsonCondition>();
            
            JsonCondition jco = new JsonCondition();
                jco .id ='';
                jco .template = ' --None-- ';
                jco .Code = '-- None --';
                lstCond.add(jco );           
            
            
            for(Special_Condition__c v : Helper.conditionsData)
            {
                JsonCondition jc = new JsonCondition();
                jc.id = v.id;
                jc.template = v.Stand_condition__c;
                jc.Code = v.Category__c + v.version__c;
                lstCond.add(jc);
            }
            return Json.serialize(lstCond);    
        }
    }
    
    public List<HPPUnderwrittingBudgetData> BudgetItems{get;set;}
    
    
    public List<Asset_Relationship__c> RemoveDuplicateAccounts(List<Asset_Relationship__c> data)
    {
        Set<String> mySet = new Set<String>();               
        List<Asset_Relationship__c> lst = new List<Asset_Relationship__c>();
        for(Asset_Relationship__c ar : data)
        {
            if(!mySet.contains(ar.Account_with_IBB__c))
            {
                lst.add(ar);
                mySet.add(ar.Account_with_IBB__c);
            }
        } 
        return lst;              
    }
    
    public void SetupIBBAccounts()
    {
        List<Asset_Relationship__c> tempIBBAccounts = [select Prospect_Customer__c,Account_with_IBB__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Available_Balance__c ,
                        Account_with_IBB__r.Absolute_balance__c,Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                      Account_with_IBB__r.IBB_Product_Name__c , Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,Account_with_IBB__r.Opportunity__r.Finance_Required__c
                       from Asset_Relationship__c
                       where  Prospect_Customer__c in :lstAccountIds
                       and    Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                       and Account_with_IBB__r.Opportunity__r.isWon = True
                       and Account_with_IBB__r.Opportunity__c !=:Opp.id
                       ];   
        IBBAccounts = RemoveDuplicateAccounts(tempIBBAccounts);
    }
    
    public void SetupIBBAccountsPipeline()
    {
        List<Asset_Relationship__c> tempIBBAccountsPipeline = [select Prospect_Customer__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Absolute_balance__c, Account_with_IBB__r.Available_Balance__c ,
                               Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                               Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,Account_with_IBB__r.Opportunity__r.Finance_Required__c
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                                      and Account_with_IBB__r.Opportunity__r.isWon = false
                                      and Account_with_IBB__r.Opportunity__r.IsClosed = false
                                      and Account_with_IBB__r.Opportunity__c !=:Opp.id
                                      //and Primary_Account_Holder__c = true
                                      ]; 
        IBBAccountsPipeline = RemoveDuplicateAccounts(tempIBBAccountsPipeline);    
    }
    
    public void SetupIBBAccountsLiability()
    {
        List<Asset_Relationship__c> tempIBBAccountsLiability = [select Prospect_Customer__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Absolute_balance__c,Account_with_IBB__r.Available_Balance__c ,
                               Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                               Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,//Account_with_IBB__r.Opportunity__r.Finance_Required__c,
                               Account_with_IBB__r.IBB_product_name__c                               
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Liability' ];    

        IBBAccountsLiability = RemoveDuplicateAccounts(tempIBBAccountsLiability);                                      
        //IBBAccountsLiability = tempIBBAccountsLiability;
    }
    
    
    public PageReference Setup()
    {
        /*mb 10/12/2015 Perminder add New board limit X2_Head_of_Credit_CRO_CEO*/
        /*Limits = [select Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c , CHief_Risk_Officer__c    from Board_Limits_v1__c order by createddate desc limit 1];*/
        Limits = [select Head_of_credit__c,Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c , CHief_Risk_Officer__c, X2_Head_of_Credit_CRO_CEO__c from Board_Limits_v1__c order by createddate desc limit 1];
        
        system.debug('Limits:'+Limits);
        
        ValReport = [select id,Property_Type__c,Property_Location_Type__c,Number_of_Bedrooms__c,Number_of_Floors__c,Property_Tenure__c,Rate_Market_Demand_for_Property__c,Unexpired_Term__c,Market_Value_Present_Condition__c,Year_Built__c,Market_Value_After_Repairs_Completion__c 
                     ,Walls__c,Roof__c,Residential_Dwelling__c,Service_Maintenance_Charges__c,Parking__c,How_Many_Parking_Spaces__c,Ground_Rent__c,Garage__c,Floor_Number__c,Fair_Market_Rental_pcm__c,Building_reinstatement_value__c
                from Valuation_Report__c where opportunity__c=:opp.id order by createddate desc  limit 1];
          
        atts = [select id, name from attachment where ParentId =:  ValReport.id];
        ValNotifications  = [select id, name, Status__c, General_Comments__c, Date_of_Valuation__c from Valuation_Notification__c where Valuation_Report__r.Opportunity__c =: opp.id ];
                            
                                
                                
                                
        SetupIBBAccounts();
        SetupIBBAccountsPipeline();
        SetupIBBAccountsLiability();
                                       
        List<Credit_score__c> creds = [select Decision_ID__c, createddate, Prospect_Customer__r.Name from Credit_Score__c where Opportunity__c=:opp.id  ];                            
        
        
        if(ExOpp.Budget_Figures__c == null)
        {
            Integer NoDependants  = 0;
            for(Account a: Accounts)
            {
                if(a.No_of_depenents__c != null)
                {
                    NoDependants += a.No_of_depenents__c.intValue();
                }  
            }
            ExOpp.Budget_Figures__c = HPPUnderwrittingBudgetHelper.MinimumText(Accounts.size(),NoDependants  );
            update ExOpp;
        }
        
        HPPUnderwrittingBudgetHelper budgetHelper = new HPPUnderwrittingBudgetHelper();
        budgetHelper.Load(Opp.id, ExOpp.Number_of_cars__c.intValue(), ExOpp.Budget_Figures__c);
        BudgetItems = budgetHelper.Items;
        
        List<Budget_Planner_Item__c> items = new List<Budget_Planner_Item__c>();
        for(HPPUnderwrittingBudgetData d : BudgetItems)
        {
            if(d.item.credit_value__c != null)
            {
                d.item.value_to_be_used__c = d.item.credit_value__c;
            }
            else
            {
                d.item.value_to_be_used__c  = d.FigureUsed;
            }  
            items.add(d.item);
        }
                
        update items;

		// C0586 Start
		minimumRentalIncome=0;
		minimumRentalIncomeDeficit=0;
		PRARentalIncome=0;
		PRARentalIncomeDeficit=0;
		PRACoverage=0;
		TotalCharges=0;
		isIAA=false;
		FailsBP=false;
		// C0586 End
        
        RerunAffordability();
        
        budgetHelper = new HPPUnderwrittingBudgetHelper();
        budgetHelper.Load(Opp.id, ExOpp.Number_of_cars__c.intValue(), ExOpp.Budget_Figures__c);
        BudgetItems = budgetHelper.Items;
        
        LoadAffordibility();
        
        
        
        
        
        Credits = new List<Credit_score__c>();
        for(Account a : accounts)
        {
            Credit_score__c score;
            for(Credit_score__c c : creds)
            {
                if(c.Prospect_Customer__c == a.id)
                {
                    if(score != null)
                    {
                        if(c.createddate > score.createddate)
                        {
                            score = c;
                        }
                    }
                    else
                    {
                        score =  c;
                    }
                }
            }
            Credits.add(score);
        }
        
        Helper = new HPPEventConditionHelper(Acc,Opp,ExOpp);
        Helper.Load();
        /*mb 10/12/2015 Perminder add New board limit X2_Head_of_Credit_CRO_CEO*/
        /*Limits = [select Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c     from Board_Limits_v1__c order by createddate desc limit 1];*/
        Limits = [select Head_of_credit__c,Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c, X2_Head_of_Credit_CRO_CEO__c      from Board_Limits_v1__c order by createddate desc limit 1];
        FiCases = [select CaseNumber, id,satisfied__c,FI_Reason__c, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='PRE' ];
        
        if(Ficases.size()==0)
            FiCases = new List<Case>();
                                                                       
        return null;
    }
    
    public Decimal TotalGross
    {
        get{
            return CheckNull(Affordability.GrossAnnualIncomeApplicant1__c) + CheckNull(Affordability.GrossAnnualIncomeApplicant2__c) + CheckNull(Affordability.GrossAnnualIncomeApplicant3__c) + CheckNull(Affordability.GrossAnnualIncomeApplicant4__c);
        }
    }
    
    public Decimal TotalNet    
    {
        get{
            return CheckNull(Affordability.NetMonthlyIncomeApplicant1__c) + CheckNull(Affordability.NetMonthlyIncomeApplicant2__c)+ CheckNull(Affordability.NetMonthlyIncomeApplicant3__c)+ CheckNull(Affordability.NetMonthlyIncomeApplicant4__c);
        }
    }  
    
    public Decimal CheckNull(Decimal value)
    {
        if(value == null)
            return 0;
        return value;
    } 
    
    
//pasted code from detail controller

        public RecordType recTypeCase {
        get {
            if (recTypeCase == null){            
                recTypeCase = [select id from recordType where  sobjectType='case' and DeveloperName = 'Further_Information' limit 1];
            }
            return recTypeCase ;
        }
        set;
    }
   
    public PageReference AddCase()
    {
        Case c = new Case();
        c.recordTypeid = recTypeCase.id ;
        c.Further_Information__c = 'Enter Information';
        c.Opportunity__c = opp.id;
        c.Subject = 'Further information for ' + Opp.Name;
        c.Description = c.Subject;
        c.Priority = 'Medium';
        c.Status = 'Open';
        c.Origin = 'Salesforce';
        c.ContactId =  Accounts[0].PersonContactId ;
        if(Opp.Seller__c != null)
        c.OwnerId = opp.Seller__c;
        c.Pre_or_Post_Case__c='PRE';
        c.Further_Info_Satisfied__c = 'No';
        insert c;
        
        Case newCase = [select id,satisfied__c, casenumber, Further_Information__c,FI_Reason__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where id=:c.id ];
        FiCases.add(newCase);
        AddFiText ='';
        SaveFurtherInfo();
        return null;
    }
    
    public PageReference SaveFI()
    {
        Boolean openCases = false;
        for(Case c : FiCases)
        {
            if(c.Further_Info_Satisfied__c == null)
                c.Further_Info_Satisfied__c = 'No';
        
            if(c.Further_Info_Satisfied__c.equalsIgnoreCase('yes'))
            {
                c.status = 'Completed';
            }
            else
            {
                openCases = true;
            }            
        }        
        update FiCases;         

        if(openCases)
            SaveFurtherInfo();
        return null;
    }
    
    public PageReference RemoveCase()
    {
        return null;
    }
    public String AddFiText {get;set;}
    public List<Case> FiCases{get;set;}
    
    public Map<String,String> Values{get;set;}
    
   /* public class ConditionTemplate
    {
        public String Id{get;set;}
        public String Name{get;set;}
    }*/
    
    public PageReference Complete()
    {
        return null;
    }
    
    public PageReference Cancel()
    {
        CurrentItem = null;
        return null;
    }
    
    public PageReference Save()
    {
        Special_condition_item__c sci = Helper.GetItem(CurrentItem.id);
        CurrentItem.Save(sci);   
        return null;
    }
    
    public PageReference Hide()
    {
        Special_condition_item__c sci = Helper.GetItem(CurrentItem.id);
        CurrentItem.Save(sci);
        CurrentItem = null;
        return null;
    }
    
    
    
    public List<SelectOption> AuthList
    {
        get{
             List<SelectOption> lst = new List<SelectOption>();
            String sAuthLevel = GetAuthLevel();
            system.debug ('This is authLevel ' + sAuthLevel);
            Integer iAuthLevel = AuthRank(sAuthLevel );
             system.debug ('This is authLevel no. ' + iAuthLevel);
             
            lst.add(new SelectOption('','-- Please select --' ));
        if(iAuthLevel <= AuthRank('Underwriter')  )
            lst.add(new SelectOption('Underwriter','Underwriter' ));
        if(iAuthLevel <= AuthRank('Lead Underwriter')  )
            lst.add(new SelectOption('Lead Underwriter','Lead Underwriter' ));
        if(iAuthLevel <= AuthRank('Head of Credit')  )
            lst.add(new SelectOption('Head of Credit','Head of Credit' ));
         /*PC Auth*/
        //if(iAuthLevel <= AuthRank('Managing Director/Head of Credit')  )
          //  lst.add(new SelectOption('CRO','CRO' ));
            
        if(iAuthLevel <= AuthRank('CRO')  )
            lst.add(new SelectOption('CRO','CRO' ));
            /*PC Auth*/
        if(iAuthLevel <= AuthRank('CEO')  )
            lst.add(new SelectOption('CEO','CEO' ));
            
        if(iAuthLevel <= AuthRank('Any 2 of Head of Credit/CEO/CRO')  )
            lst.add(new SelectOption('Any 2 of Head of Credit/CEO/CRO','Any 2 of Head of Credit/CEO/CRO' ));
            
        if(iAuthLevel <= AuthRank('Credit Committee')  )
            lst.add(new SelectOption('Credit Committee','Credit Committee' ));
        
        if(iAuthLevel <= AuthRank('Board Risk Credit Committee')  )
            lst.add(new SelectOption('Board Risk Credit Committee','Board Risk Credit Committee' ));
            
        lst.add(new SelectOption('Board','Board' ));
        
        return lst;
        
        }
    }
    
    public String SelectedCondition{get;set;}
    
    public List<SelectOption> ConditionList
    {
        get{
            List<SelectOption> lst = new List<SelectOption>(); 
            for(Special_Condition__c v : Helper.conditionsData)
            {
                SelectOption opt = new SelectOption(v.id,  v.name + ' - ' + v.category__c + v.version__c ); 
                lst.add(opt);              
            }
            return lst;
        }    
    }
    
    public Integer delCondition{get;set;}
    public Integer delFI{get;set;}
    
    public PageReference DeleteFI()
    {
        system.debug('Del FI index : ' + delFI);
    
        Case c = FICases[delFI];
        
        delete c;
        
        FiCases = [select CaseNumber,FI_Reason__c, id,satisfied__c, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='PRE' ];
    
        
        return null;
    }
    
    
    
    public PageReference DeleteCondition()
    {
        HPPEventConditionHelper.ConditionItem item =  Helper.CIList.remove(delCondition);
        Helper.DeleteItem(item.id);
        
        return null;
    }
    
    public Integer edCondition{get;set;}
    public PageReference EditCondition()
    {
        //find condition
        CurrentItem = Helper.CIList[edCondition];            
        return null;
    }
    
    private void SaveFurtherInfo()
    {
        Opp.Stagename = 'Affordability Assesment';
        
        
        if(Opp.Credit_Decision_1_Date__c == null)
        Opp.Credit_Decision_1_Date__c = Date.today();
        Opp.Credit_Decision_1_UW__c = UserInfo.getName();
        
        Opp.Credit_Decision_1__c = 'Further Information Required';        
        Opp.Status_HPP_CAA__c= 'Affordability Further Information';
        
        update ExOpp;
        update Opp;
    }
    
    private Decimal GetTotalLiability()
    {
        Decimal totalLiability = opp.Finance_required__c;
         
         Asset_Relationship__c[] IBBAccounts = [select Account_with_IBB__r.Absolute_balance__c  
                       from Asset_Relationship__c
                       where  Prospect_Customer__c in :lstAccountIds
                       and    Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                       and Account_with_IBB__r.Opportunity__r.isWon = True
                       and Account_with_IBB__r.Opportunity__c !=:Opp.id
                       ];  
                       
        IBBAccounts = RemoveDuplicateAccounts(IBBAccounts);

        Asset_Relationship__c[] IBBAccountsPipeline = [select Account_with_IBB__r.Opportunity__r.Finance_Required__c
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                                      and Account_with_IBB__r.Opportunity__r.isWon = false
                                      and Account_with_IBB__r.Opportunity__r.IsClosed = false
                                      and Account_with_IBB__r.Opportunity__c !=:Opp.id
                                      //and Primary_Account_Holder__c = true
                                      ];  
                                      
        IBBAccountsPipeline = RemoveDuplicateAccounts(IBBAccountsPipeline );                               
    
        for(Asset_Relationship__c a : IBBAccounts )
        {
            if(a.Account_with_IBB__r.Absolute_balance__c  != null)
                totalLiability += a.Account_with_IBB__r.Absolute_balance__c ;
        }
        
         for(Asset_Relationship__c a : IBBAccountsPipeline)
        {
            if(a.Account_with_IBB__r.Opportunity__r.Finance_Required__c != null)
                totalLiability += a.Account_with_IBB__r.Opportunity__r.Finance_Required__c;
        }
        
        return totalLiability;
    }
        
    public Boolean OutsideAuth
    {
        get{
        
            User u = [select Limit_of_authority__c from user where id=:UserInfo.getUserId() ];
            Integer userRank = AuthRank(u.Limit_of_authority__c);
            
            string level = GetAuthLevel();
            system.debug('level:' + level);
            
            Integer currentRank = AuthRank(level);  
            
            system.debug('Current ' + currentRank + ' userrank ' + userRank);
                  
            return currentRank > userRank;
        }
    }
    
    
    public String AuthLevel
    {
        get{
            if(AuthLevel == null)
                AuthLevel = GetAuthLevel();
            return AuthLevel;
        }
        set{}
    }
    
    public Integer AuthRank(string rank)
    {
    
        system.debug ( 'This is the rank ' + rank);
        if(rank == null)
            return 0;
        if(rank == '')
            return 0;
        if(rank.equalsIgnoreCase('Underwriter'))
            return 1;
        if(rank.equalsIgnoreCase( 'Lead Underwriter'))
            return 2;
        if(rank.equalsIgnoreCase('Head of Credit'))
            return 3;
        if(rank.equalsIgnoreCase('Managing Director'))
            return 3;
        if(rank.equalsIgnoreCase('Managing Director/Head of Credit'))
            return 3;
        if(rank.equalsIgnoreCase('CRO'))
            return 3;
        if(rank.equalsIgnoreCase('CEO'))
            return 3;
            
        if(rank.equalsIgnoreCase('Head of Credit/CEO/CRO'))    
            return 3;
            
        if(rank.equalsIgnoreCase('Any 2 of Head of Credit/CEO/CRO'))
            return 4;
        if(rank.equalsIgnoreCase('Credit Committee'))
            return 5;       
        if(rank.equalsIgnoreCase('Board Risk Credit Committee'))
            return 6;   
        if(rank.equalsIgnoreCase('Board'))
            return 7;
        return 0;                    
    }
    
    public Decimal totalLib
    {
        get{
        return GetTotalLiability();
        }
    }
    
    public String GetAuthLevel()
    {
        Decimal totalLiability = GetTotalLiability();
        
        system.debug ( 'This is the liability ' + totalLiability);
        system.debug ( 'This is the Limits ' + Limits);
        
        if(totalLiability  <= Limits.Underwriter__c)
            return 'Underwriter';         
        if(totalLiability  <= Limits.Lead_Underwriter__c)
            return 'Lead Underwriter';
        if(totalLiability  <= Limits.Head_of_credit__c)
            return 'Head of Credit';
        if(totalLiability  <= Limits.Managing_Director__c)
            return 'Head of Credit/CEO/CRO';
        if(totalLiability  <= Limits.X2_Head_of_Credit_CRO_CEO__c)
            return 'Any 2 of Head of Credit/CEO/CRO';
         //if(totalLiability  <= Limits.Chief_Risk_Officer__c)
         //   return 'CRO';
        if(totalLiability  <= Limits.Credit_Committee__c)
            return 'Credit Committee';
        if(opp.Finance_required__c <= Limits.Board_Risk_Credit_Committee__c)
            return 'Board Risk Credit Committee';
        
            return 'Board';
            
            
    }

    public HPPEventConditionHelper.ConditionItem CurrentItem{get;set;}
    
    public PageReference AddCondition()
    {
        if(SelectedCondition == null) return null;
        if(SelectedCondition == '') return null;
        Helper.AddCondition(SelectedCondition,'Pre');
        return null;
    }   
    
    public PageReference FurtherInformation()
    {
        update ExOpp;
        update Opp;  
        return null;
    }
    
    public PageReference AuthoriseOutside()
    {        
        system.debug('AuthoriseOutside called');
        if(string.isBlank(authSelected))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a limit of authority'));
            return null;
        }
        ExOpp.Limit_of_authority_list__c = authSelected;
        
        Opp.Name_of_underwritter__c = UserInfo.GetUserId();
        Opp.Authority_level_required__c = GetAuthLevel();        
        
        system.debug('Val:' + authSelected);
        system.debug('Val1:' + authSelected1);
        
        
        
        return Auth();
    }
    
    public String authSelected{get;set;}
    public String authSelected1{get;set;}
    
    private PageReference Auth()
    {
     
    //CO303 KD FTI Check
    if(!HPPHelper.CheckFTVIsValid(Opp)) return null;
    if(!HPPHelperFTI.CheckFTIIsValid(Opp)) return null;
               
        //Check that all the FI cases are satisfied
        for(Case c : FiCases)
        {
            if(c.Further_Info_Satisfied__c == null)
                c.Further_Info_Satisfied__c = 'No';
        
            if(!c.Further_Info_Satisfied__c.equalsIgnoreCase('yes'))
            {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Further information cases need to be satisfied'));
               return null;
            }
        }
        
       Opp.Name_of_underwritter__c = UserInfo.GetUserId();
       Opp.Authority_level_required__c = GetAuthLevel(); 
       /*ExOpp.Limit_of_authority_list__c = null;      */       
       
       if(Opp.Credit_Decision_1__c == null)
       {
            Opp.Credit_Decision_1__c = 'Authorised';
            Opp.Credit_Decision_1_Date__c = Date.today();
            Opp.Credit_Decision_1_UW__c = UserInfo.getName();
       }
        else
        {
            Opp.Credit_Decision_2__c = 'Authorised';
            Opp.Credit_Decision_2_Date__c = Date.today();
            Opp.Credit_Decision_2_UW__c = UserInfo.getName();       
        }                      
        update ExOpp;
        update Opp;
        CompleteEvent();        
        if(CreatedEvent != null)
        {                  
             PageReference pageRef = null;
             system.debug('URL:' + NextEventUrl);
             return new PageReference(NextEventUrl)  ;
        }        
        return null;
    }
    
    public PageReference Authorise()
    {
        if(Opp.Credit_Assessment_Rationale__c == null ||  ExOpp.Underwriter_pre_val_decision_rational__c == '')        
        {
            Opp.Credit_Assessment_Rationale__c.addError('Please enter a value');
            return null;
        }
    
        return Auth();
    }
    
    public PageReference Decline()
    {
        if(Opp.Credit_Assessment_Rationale__c == null ||  ExOpp.Underwriter_pre_val_decision_rational__c == '')        
        {
            Opp.Credit_Assessment_Rationale__c.addError('Please enter a value');
            return null;
        }
    
        if(Opp.Credit_Decision_1__c == null)
        {
            Opp.Credit_Decision_1__c = 'Declined';
            Opp.Credit_Decision_1_Date__c = Date.today();
            Opp.Credit_Decision_1_UW__c = UserInfo.getName();
        }
        else
        {
            Opp.Credit_Decision_2__c = 'Declined';
            Opp.Credit_Decision_2_Date__c = Date.today();  
            Opp.Credit_Decision_2_UW__c = UserInfo.getName();      
        }
        
        //CPDR
        Opp.Status_HPP_CAA__c = 'Affordability Declined';
        
        update ExOpp;
        update Opp;
       // CompleteEvent();        
       // return GoToNextEvent(); 
       return null;
    }    
    
    public String JsonCarFields
    {
        get{
            List<String> carBills = new List<string>();
            for(HPPUnderwrittingBudgetData item : BudgetItems)
            {
                if(item.item.budgetplannerconfig__r.car_bill__c)
                {
                    carBills.add(item.item.display_name__c);
                }
            }
            return Json.serialize(carBills);
        }
    }
    
  
    
    public PageReference SaveBudget()
    {
        List<Budget_Planner_Item__c > Items = new List<Budget_Planner_Item__c> ();
        for(HPPUnderwrittingBudgetData d : BudgetItems)
        {
            if(d.item.credit_value__c != null)
            {
                d.item.value_to_be_used__c = d.item.credit_value__c;
            }
            else
            {
                d.item.value_to_be_used__c  = d.FigureUsed;
            }        
        
            Items.add(d.item); 
        }
        update exopp;
        upsert Items;
        
        
        
        HPPUnderwrittingBudgetHelper budgetHelper = new HPPUnderwrittingBudgetHelper();
        budgetHelper.Load(Opp.id,ExOpp.Number_of_cars__c.intValue(),ExOpp.Budget_Figures__c);
        
        BudgetItems = budgetHelper.Items;
        //update BudgetItems ;
        
        
        List<Budget_Planner_Item__c > Items1 = new List<Budget_Planner_Item__c> ();
        for(HPPUnderwrittingBudgetData d : BudgetItems)
        {
            if(d.item.credit_value__c != null)
            {
                d.item.value_to_be_used__c = d.item.credit_value__c;
            }
            else
            {
                d.item.value_to_be_used__c  = d.FigureUsed;
            }        
        
            Items1.add(d.item); 
        }
        update Items1;        
        
        RerunAffordability();
        
        return null;
    }
    
    private void SaveDECases()
    {
        for(Account a : Accounts)
        {
            List<Case> c = Cases.get(a.id);
            update c;
        }
    }
    
    public PageReference SaveCases()
    {       
        SaveDECases();   
        return null;
    }
    
    public Map<String,List<Case>> Cases{get;set;}
    public Map<String,String> Status {get;set;} 
    
    
    public class JsonCondition
    {
        public String Id{get;set;}
        public String Template{get;set;}
        public String Code{get;set;}         
    }
    
   /*   public class CaseDetail
    {
        public String id{get;set;}
        public String CaseNumber {get;set;}
        public String Subject{get;set;}
        public String Detail{get;set;}
        public String Owner{get;set;}
        public String Decision{get;set;}
        public String Comment{get;set;}
        public String Satisfied{get;set;}
        public String CreditComments {get;set;}
        public String CreditAccepted{get;set;}
    }  
    */

}