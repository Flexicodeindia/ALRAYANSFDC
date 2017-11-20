public class HPPUnderwrittingBudgetHelper
{
    public List<HPPUnderwrittingBudgetData> Items{get;set;}     
    private Integer NoDependants{get;set;}
    private Integer NoApplicants{get;set;}
    private Integer NoCars{get;set;}
    
   
      
    
    public void Load(String oppId, Integer NoCars,String budgetToUse)
    {
        
        List<Applicant__c> Accounts = [select Prospect_Customer__r.No_of_depenents__c,Prospect_Customer__r.number_of_cars__c
                                     from applicant__c
                                    where Opportunity__c =: oppId ];
        NoApplicants = Accounts.Size();
        NoDependants = 0;

		
		// C0597 HPP-BTL Start
		Boolean isBTL = false;
		Opportunity oppo = [select IBB_Product_Type__c from Opportunity where ID=:oppId limit 1];
		if ( oppo.IBB_Product_Type__c == 'BTL Purchase Plan' || oppo.IBB_Product_Type__c == 'BTL Purchase Plan Scotland' || oppo.IBB_Product_Type__c == 'Buy To Let Purchase Plan Scotland' || oppo.IBB_Product_Type__c == 'Buy To Let Purchase Plan' )
		{
			isBTL = true;
		}
		// C0597 HPP-BTL Start
        
        for(Applicant__c a: Accounts)
        {
            if(a.Prospect_Customer__r.No_of_depenents__c != null)
            {
                NoDependants += a.Prospect_Customer__r.No_of_depenents__c.intValue();
            }  
        }
        
        
        if(budgetToUse == null)
            budgetToUse = MiniumText();
        
        
        if(NoCars == null || NoCars < 1)
            NoCars = 1;
       
        
        
     
        
        List<Budget_Planner_Item__c> BudgetItems = [select name,Credit_Value__c , bdm_comments__c,Account_Value__c, opportunity__c,Applicant_Total__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name,
                                     budgetplannerconfig__r.SingleApp__c, budgetplannerconfig__r.Joint_App__c,
                                     budgetplannerconfig__r.Joint_App_1_Dep__c, budgetplannerconfig__r.Joint_App_2_Dep__c,
                                     budgetplannerconfig__r.Joint_App_3_Dep__c, budgetplannerconfig__r.car_bill__c,
                                     budgetplannerconfig__r.IsStressed__c,Value_to_be_used__c
                         from budget_planner_item__c 
                        where opportunity__c =:oppId order by  budgetplannerconfig__r.order__c ];
         
          
                 
        Items = new List<HPPUnderwrittingBudgetData>();
                                             
        for(Budget_Planner_Item__c item : BudgetItems)
        {
            HPPUnderwrittingBudgetData data = new HPPUnderwrittingBudgetData();
            data.Item = item;
            data.Minimum = Minimum(item,budgetToUse  );
            if(data.Minimum == null)
                data.Minimum = 0;
                
                
                
            if(item.budgetplannerconfig__r.Car_Bill__c)
            {
                system.debug('car Bill ' + item.display_name__c + ' ' + NoCars);
                data.Minimum = data.Minimum  * NoCars;
            }
            
            if(data.item.Applicant_Total__c == null)
                data.item.Applicant_Total__c = 0;
            
            Decimal min = data.Minimum * 0.75; 
            
            if(data.item.Applicant_Total__c < min && data.Minimum > 0 )
            {
                data.FigureUsed = data.Minimum;
            }
            else
            {
                data.FigureUsed = data.item.Applicant_Total__c;
            } 
            
            
            
            if(item.budgetplannerconfig__r.IsStressed__c && !isBTL) // C0597 HPP-BTL Do Not update HPP BP item with StressedHPPPayment result
            {
                List<AffordabilityResults__c> ar = [select StressedHPPRepayment__c 
                                                from AffordabilityResults__c 
                                                where Opportunity__c =:oppid 
                                                order by createddate desc limit 1
                                                 ];
                if(ar.size() > 0)
                {                                 
                    data.FigureUsed = ar[0].StressedHPPRepayment__c ;
                    data.Minimum = ar[0].StressedHPPRepayment__c ;
                    data.item.Applicant_Total__c = ar[0].StressedHPPRepayment__c ;
                }
            }
            
            
            Items.add(data);           
        }                                                                               
    }
    
    
    public static String MinimumText(Integer NoApplicants, Integer NoDependants)
    {
         if(NoApplicants == 1)
            return 'Single App';
            
        if(NoDependants == 0)
            return 'Joint App';
            
        if(NoDependants == 1)
            return 'Joint App + 1 dependent';
            
        if(NoDependants == 2)
            return 'Joint App + 2 dependent';
            
        if(NoDependants > 2)
            return 'Joint App 3 or more dependents';                        
        return 'Single App';   
    }
    
    public String MiniumText()
    {
        return MinimumText(NoApplicants ,NoDependants );
    
    /*
        if(NoApplicants == 1)
            return 'Single App';
            
        if(NoDependants == 0)
            return 'Joint App';
            
        if(NoDependants == 1)
            return 'Joint App + 1 dependent';
            
        if(NoDependants == 2)
            return 'Joint App + 2 dependent';
            
        if(NoDependants > 2)
            return 'Joint App 3 or more dependents';                        
        return 'Single App';  
        */ 
    
    }
    
    public Decimal Minimum(Budget_Planner_Item__c item, String budgetToUse)
    {
        if(budgetToUse== 'Single App')
            return item.budgetplannerconfig__r.SingleApp__c;
            
        if(budgetToUse== 'Joint App')
            return item.budgetplannerconfig__r.Joint_App__c;
            
        if(budgetToUse== 'Joint App + 1 dependent')
            return item.budgetplannerconfig__r.Joint_App_1_Dep__c;
            
        if(budgetToUse== 'Joint App + 2 dependent')
            return item.budgetplannerconfig__r.Joint_App_2_Dep__c;
            
        if(budgetToUse== 'Joint App 3 or more dependents')
            return item.budgetplannerconfig__r.Joint_App_3_Dep__c;                        
        return 0;    
    }
    
    
}