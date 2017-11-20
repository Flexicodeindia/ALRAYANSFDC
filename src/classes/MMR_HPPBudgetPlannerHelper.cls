public class MMR_HPPBudgetPlannerHelper
{
    private String m_oppId;
    public MMR_HPPBudgetPlannerHelper(String oppId)
    {
        m_oppId = oppId;
    }
    
    /*
    public void ReCalculateTotals()
    {
        /*
         List<Budget_Planner_Item__c>    BudgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where account__c in (select Prospect_Customer__c 
                                             from Applicant__c 
                                             where opportunity__c=:m_oppId ) ];
                                             
        ReCalculateTotals(BudgetItems );
    }
    */
    
    public void ReCalculateTotals()
    {
    
    
        List<Budget_Planner_Item__c> CombinedBudgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId ];
                        
                        
                        
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c order by order__c ];

        system.debug('Item Count : ' + config.size());

        for(BudgetPlannerConfig__c c : config)
        {
            budget_planner_item__c found;
            for(Budget_Planner_item__c item: CombinedBudgetItems )
            {
                if(item.budgetPlannerConfig__c == c.id)
                {
                    system.debug('Found item : ' + item.name );
                    found = item;
                    break;
                }
            }
            
            //create item if it does not exist against the opportunity
            if(found == null)
            {
                system.debug('New Item ' + c.name);
                found = new budget_planner_item__c();
                found.opportunity__c = m_oppId ;
                found.budgetplannerconfig__c = c.id;
                CombinedBudgetItems.add(found);
            }
        }
        //Integer i = 1/0;
        upsert CombinedBudgetItems; 
    }

	// C0586 Start
	public void SaveIncomeAssistedBTLDeficit(double Deficit)
	{
		System.debug('IAA BTL Deficit:'+Deficit);
		List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c where name = 'Income Assisted BTL Deficit' ];
		Id BPConfigID;
		for(BudgetPlannerConfig__c	c: config)
		{
			BPConfigID = c.Id;
			System.debug('BTL IAA Config ID:'+c.Id+' - Name:'+c.Name);
		}	
		List<Budget_Planner_Item__c> budgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId and budgetplannerconfig__r.id=:BPConfigID ];
		for(Budget_Planner_Item__c i: budgetItems)
		{
			System.debug('Item ID:'+i.Id);
			i.Value_to_be_used__c = Deficit;
			i.Applicant_Total__c = Deficit;
		}
		upsert budgetItems;
		//Integer i = 1/0;
		
	}

	public Decimal GetBTLBasicBudgetPlannerCosts() // C0586 - UW changes
	{
		// Gets the values of 'Service Charge', "Maintenance Charge', and 'Ground Rent' from the Budget Planner and returns the total
		
		Decimal BTLBasicBudgetPlannerCosts = 0;
		List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c where name in ('Ground Rent','Service Charge','Maintenance Charge') ];

		List<Budget_Planner_Item__c> budgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name,Value_to_be_used__c
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId];

		for(BudgetPlannerConfig__c	c: config)
		{
			for(Budget_Planner_Item__c i: budgetItems)
			{
				if(i.BudgetPlannerConfig__c==c.Id)
				{
					BTLBasicBudgetPlannerCosts+= i.Value_to_be_used__c; // Or i.Applicant_Total__c
				}
			}
		}	
		
		//Integer i = 1/0;
		return BTLBasicBudgetPlannerCosts;
	
		
	}
	// C0586 End

}