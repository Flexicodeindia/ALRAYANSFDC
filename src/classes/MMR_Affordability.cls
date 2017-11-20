/* ------------------------------------------------------------------------------------------ */
/* M00032 2013-10-22    getStressedRepayment () add 2 to benchmark rate if not BTL            */ 
/* ------------------------------------------------------------------------------------------ */
/* M00033 2013-10-22    btlPropertyIncome calculation change                                  */
/* ------------------------------------------------------------------------------------------ */
/* C00237 2014-08-19    CHange Stressed rate from 2 to 3 points                               */
/* ------------------------------------------------------------------------------------------ */
/* C0402  2015-01-27    Seperate field for BTL products to use a different rate for affordability */ 
/* ------------------------------------------------------------------------------------------ */




  public without sharing class MMR_Affordability {
  public AffordabilityResults__c affordabilityResult { get; private set; }
  //  public AffordabilityResults__c affordabilityResults { get; private set; }
  private Opportunity opportunity;
  private HPP_extended_opportunity__c extendedOpportunity;
  private IBB_Product__c product;
  private List<Budget_Planner_Item__c> BudgetItems{get;set;}
  private Integer totalNumberOfDependents = 0;
  private Decimal totalNetMonthlyIncome = 0;
  // C0586 Start
  public Boolean useApplicantsBudgetPlanner { get; set;}
  public Boolean failedBP = false;
  public Decimal IAADeficit = 0;
  public Decimal minimumRentalIncome = 0;
  public Decimal minimumRentalIncomeDeficit = 0;
  public Decimal PRARentalIncome = 0;
  public Decimal PRARentalIncomeDeficit = 0;
  public Decimal PRACoverage = 0;
  public Decimal totalCharges = 0;
  // C0586 End

  
  private List<Applicant__c> applicants {
    get {
      if (applicants == null) {
        applicants = [
          SELECT Name, Prospect_Customer__c, Applicant_Number__c,
            Prospect_Customer__r.No_of_depenents__c, Prospect_Customer__r.Net_Monthly_Income__c, Prospect_Customer__r.Gross_Annual_Income__c,
            Prospect_Customer__r.Guaranteed_bonus__c, Prospect_Customer__r.Regular_Bonus__c,  Prospect_Customer__r.Guaranteed_Commission__c,
            Prospect_Customer__r.Regular_Commission__c, Prospect_Customer__r.Guaranteed_Overtime__c, Prospect_Customer__r.Regular_Overtime__c, 
            Prospect_Customer__r.Guaranteed_Shift_Allowance__c, Prospect_Customer__r.Regular_Shift_Allowance__c, Prospect_Customer__r.Car_Allowance__c, 
            Prospect_Customer__r.Large_Town_Allowance__c, Prospect_Customer__r.Number_of_cars__c,
            
            
            Prospect_Customer__r.Gross_Annual_Income_2__c,Prospect_Customer__r.Net_Monthly_Income_2__c,
            Prospect_Customer__r.Guaranteed_bonus_2__c, Prospect_Customer__r.Regular_Bonus2__c,  Prospect_Customer__r.Guaranteed_Commission2__c,
            Prospect_Customer__r.Regular_Commission2__c, Prospect_Customer__r.Guaranteed_Overtime2__c, Prospect_Customer__r.Regular_Overtime2__c, 
            Prospect_Customer__r.Guaranteed_Shift_Allowance2__c, Prospect_Customer__r.Regular_Shift_Allowance2__c, Prospect_Customer__r.Car_Allowance2__c, 
            Prospect_Customer__r.Large_Town_Allowance2__c
            
            
            
            
          FROM Applicant__c
          WHERE Opportunity__c = :opportunity.Id
          ORDER BY Applicant_Number__c ASC NULLS LAST
        ];
      }
      return applicants;
    }
    private set;
  }
  
  private Set<Id> accountIDs {
    get {
      if (accountIDs == null) {
        accountIDs = new Set<Id>();
        for (Applicant__c applicant : applicants) {
          if (!accountIDs.contains(applicant.Prospect_Customer__c)) {
            accountIDs.add(applicant.Prospect_Customer__c);
          }
        }
      }
      return accountIDs;
    }
    private set;
  }
  
  private Board_Limits_v1__c boardLimits {
    get {
      if (boardLimits == null) {
        boardLimits = [
          SELECT Name, X2Applicants0_1Dependants__c, X2Applicants2_3Dependants__c, X2Applicants3_Dependants__c, X3Applicants0_1Dependants__c,
            X3Applicants2_3Dependants__c, X3Applicants3_Dependants__c, X4Applicants0_1Dependants__c, X4Applicants2_3Dependants__c,
            X4Applicants3_Dependants__c, WaterBP__c, ClothingBP__c, ElectricityBP__c, TVLicenceBP__c, ContentsInsuranceBP__c, BuildingInsuranceBP__c
          FROM Board_Limits_v1__c
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];
      }
      return boardLimits;
    }
    private set;
  }
  
  
  private List<Property_information__c> properties {
    get {
      if (properties == null) {
        properties = [
          SELECT Name, IsBTLProperty__c, Amount_of_monthly_rent_received__c, Amount_of_monthly_repayment__c
          FROM Property_information__c
          WHERE PersonAccount__c IN :accountIDs
            AND IsBTLProperty__c = true
        ];
      }
      return properties;
    }
    private set;
  }
  
  private Decimal BudgetPlannerItemTotal{
      get{
          if(BudgetPlannerItemTotal== null){
              AggregateResult[] groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id ];  
              BudgetPlannerItemTotal =(Decimal) groupedResults[0].get('Total');      
          }
          return BudgetPlannerItemTotal;
      }  
      set;
  }
  
  private Decimal BudgetPlannerCommitmentTotal{
      get{
          if(BudgetPlannerCommitmentTotal== null){
			// C0586 Start
			AggregateResult[] groupedResults;
			if(useApplicantsBudgetPlanner && (opportunity.IBB_Product_Type__c == 'BTL Purchase Plan' || opportunity.IBB_Product_Type__c == 'BTL Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan'))
			{
				groupedResults = [select Sum(Applicant_Total__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and budgetplannerconfig__r.IsStressed__c = false ];
			}
			else
			{
				groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and budgetplannerconfig__r.IsStressed__c = false ];// and budgetplannerconfig__r.Ignore_total_Commitment__c =false ];  
			}
			// C0586 End
                system.debug('budget object : ' + groupedResults[0]);                                     
              BudgetPlannerCommitmentTotal=(Decimal) groupedResults[0].get('Total');  
              system.debug('net query : ' + BudgetPlannerCommitmentTotal);
          }
          return BudgetPlannerCommitmentTotal;
      }  
      set;
  }
  
  
  private Decimal TotalPersonalDebts{
      get{
          if(TotalPersonalDebts== null){
              AggregateResult[] groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and budgetplannerconfig__r.Remove_from_Affordability_Income__c = true ];

              TotalPersonalDebts=(Decimal) groupedResults[0].get('Total');  
              system.debug('total debts for affordability : ' + TotalPersonalDebts)    ;
          }
          return TotalPersonalDebts;
      }  
      set;
  }
  
  
   
  
  public MMR_Affordability(Opportunity opportunity, HPP_extended_opportunity__c extOpportunity, IBB_Product__c product) {
    this.opportunity = opportunity;
    this.extendedOpportunity = extOpportunity;
    this.product = product;
    
    Integer applicant1Dependents = 0;
    Integer applicant2Dependents = 0;
    Integer applicant3Dependents = 0;
    Integer applicant4Dependents = 0;
    
    Decimal applicant1NetMonthlyIncome = 0;
    Decimal applicant2NetMonthlyIncome = 0;
    Decimal applicant3NetMonthlyIncome = 0;
    Decimal applicant4NetMonthlyIncome = 0;

	useApplicantsBudgetPlanner = false; // C0586

    DEcimal noCars=0;
    for (Applicant__c applicant : this.applicants) {
        if(applicant.Prospect_Customer__r.Number_of_cars__c != null)
        {
            noCars += applicant.Prospect_Customer__r.Number_of_cars__c;
        }
    
    
      if (applicant.Applicant_Number__c == 1) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant1Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant1NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;          
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant1NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 2) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant2Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant2NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant2NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 3) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant3Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant3NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant3NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 4) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant4Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant4NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant4NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
    }
    this.totalNumberOfDependents = applicant1Dependents + applicant2Dependents + applicant3Dependents + applicant4Dependents;
    this.totalNetMonthlyIncome = applicant1NetMonthlyIncome + applicant2NetMonthlyIncome + applicant3NetMonthlyIncome + applicant4NetMonthlyIncome;
    
    MMR_HPPBudgetPlannerHelper helper = new MMR_HPPBudgetPlannerHelper(opportunity.id);
    helper.ReCalculateTotals();
    
    
    HPPUnderwrittingBudgetHelper uwHelper = new HPPUnderwrittingBudgetHelper();
    uwHelper.Load(opportunity.id, noCars.intValue() ,null);
    List<Budget_Planner_Item__c> items = new List<Budget_Planner_Item__c> ();
   
    for(HPPUnderwrittingBudgetData bd : uwHelper.Items)
    {
        if(bd.item.Value_to_be_used__c == null)
        {
            bd.item.Value_to_be_used__c = bd.FigureUsed ;
            items.add(bd.item);
        }
    }
    update items;
    
    
    this.affordabilityResult = new AffordabilityResults__c(
      Opportunity__c = opportunity.Id, TermOfFinance__c = opportunity.Term_of_Finance__c,
      Purchase_Price_Market_Value__c = opportunity.Purchase_price_market_value__c, NumberOfApplicants__c = applicants.size(),
      FinanceRequired__c = opportunity.Finance_Required__c,  TotalNumberOfDependants__c = totalNumberOfDependents, 
      DependantsApplicant1__c = applicant1Dependents, DependantsApplicant2__c = applicant2Dependents,
      DependantsApplicant3__c = applicant3Dependents, DependantsApplicant4__c = applicant4Dependents,
      NetMonthlyIncomeApplicant1__c = applicant1NetMonthlyIncome, NetMonthlyIncomeApplicant2__c = applicant2NetMonthlyIncome,
      NetMonthlyIncomeApplicant3__c = applicant3NetMonthlyIncome, NetMonthlyIncomeApplicant4__c = applicant4NetMonthlyIncome,
      TotalNetMonthlyIncome__c = totalNetMonthlyIncome, TotalCommitments__c = 0
    );
  }
  
  public static Decimal getGrossAnnualIncome(Account account) {
  
    system.debug('Emp1 ' + account.Gross_Annual_Income__c);
    system.debug('Emp2 ' + account.Gross_Annual_Income_2__c);    
  
  
    Decimal grossAnnualIncome = account.Gross_Annual_Income__c;
    if (account.Guaranteed_bonus__c != null)
      grossAnnualIncome += account.Guaranteed_bonus__c;
    if (account.Regular_Bonus__c != null)
      grossAnnualIncome += (account.Regular_Bonus__c * 0.5);
    if (account.Guaranteed_Commission__c != null)
      grossAnnualIncome += account.Guaranteed_Commission__c;
    if (account.Regular_Commission__c != null)
      grossAnnualIncome += (account.Regular_Commission__c * 0.5);
    if (account.Guaranteed_Overtime__c != null)
      grossAnnualIncome += account.Guaranteed_Overtime__c;
    if (account.Regular_Overtime__c != null)
      grossAnnualIncome += (account.Regular_Overtime__c * 0.5);
    if (account.Guaranteed_Shift_Allowance__c != null)
      grossAnnualIncome += account.Guaranteed_Shift_Allowance__c;
    if (account.Regular_Shift_Allowance__c != null)
      grossAnnualIncome += (account.Regular_Shift_Allowance__c * 0.5);
    if (account.Car_Allowance__c != null)
      grossAnnualIncome += account.Car_Allowance__c;
    if (account.Large_Town_Allowance__c != null)
      grossAnnualIncome += account.Large_Town_Allowance__c;
    
    if(account.Gross_Annual_Income_2__c != null)    
        grossAnnualIncome += account.Gross_Annual_Income_2__c;
    if (account.Guaranteed_bonus_2__c != null)
      grossAnnualIncome += account.Guaranteed_bonus_2__c;
    if (account.Regular_Bonus2__c != null)
      grossAnnualIncome += (account.Regular_Bonus2__c * 0.5);
    if (account.Guaranteed_Commission2__c != null)
      grossAnnualIncome += account.Guaranteed_Commission2__c;
    if (account.Regular_Commission2__c != null)
      grossAnnualIncome += (account.Regular_Commission2__c * 0.5);
    if (account.Guaranteed_Overtime2__c != null)
      grossAnnualIncome += account.Guaranteed_Overtime2__c;
    if (account.Regular_Overtime2__c != null)
      grossAnnualIncome += (account.Regular_Overtime2__c * 0.5);
    if (account.Guaranteed_Shift_Allowance2__c != null)
      grossAnnualIncome += account.Guaranteed_Shift_Allowance2__c;
    if (account.Regular_Shift_Allowance2__c != null)
      grossAnnualIncome += (account.Regular_Shift_Allowance2__c * 0.5);
    if (account.Car_Allowance2__c != null)
      grossAnnualIncome += account.Car_Allowance2__c;
    if (account.Large_Town_Allowance2__c != null)
      grossAnnualIncome += account.Large_Town_Allowance2__c;
      
    system.debug('Gross Income ' + grossAnnualIncome );  
      
    return grossAnnualIncome;
  }
  
  public void incomeMultiplier() {
    Decimal highestIncome = 0;
    Decimal secondaryIncome = 0;
    
    Decimal applicant1GrossAnnualIncome = 0;
    Decimal applicant2GrossAnnualIncome = 0;
    Decimal applicant3GrossAnnualIncome = 0;
    Decimal applicant4GrossAnnualIncome = 0;
    
    for (Applicant__c applicant : applicants) {
      Decimal grossAnnualIncome = getGrossAnnualIncome(applicant.Prospect_Customer__r);
      
      if (applicant.Applicant_Number__c == 1) {
        applicant1GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 2) {
        applicant2GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 3) {
        applicant3GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 4) {
        applicant4GrossAnnualIncome = grossAnnualIncome;
      }
      
	  system.debug('Emp1 ' + applicant.Prospect_Customer__r.Gross_Annual_Income__c);
      system.debug('Emp2 ' + applicant.Prospect_Customer__r.Gross_Annual_Income_2__c); 
      system.debug('Gross Income ' + grossAnnualIncome );  
      
      //  Update the Affordability Results record
      affordabilityResult.GrossAnnualIncomeApplicant1__c = applicant1GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant2__c = applicant2GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant3__c = applicant3GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant4__c = applicant4GrossAnnualIncome;
      
      //  Update the Account record
      applicant.Prospect_Customer__r.AffordabilityGrossAnnualIncome__c = grossAnnualIncome;
      
      if (grossAnnualIncome > highestIncome) {
	    // 01088910 Don't forget secondaryIncome! - Start
        if(highestIncome>secondaryIncome)
		{
			secondaryIncome=highestIncome;
		}
		// 01088910 Don't forget secondaryIncome! - End
        highestIncome = grossAnnualIncome;
      }
      else if (grossAnnualIncome > secondaryIncome) {
        secondaryIncome = grossAnnualIncome;
      }
    }
    
    Decimal loanAmount1 = (highestIncome + secondaryIncome) * 4.5;
    Decimal loanAmount2 = (highestIncome * 5) + secondaryIncome;
    Decimal maximumLoanAmount = (loanAmount1 > loanAmount2) ? loanAmount1: loanAmount2;
    String incomeMultiplierHigherAmount = (loanAmount1 > loanAmount2) ? '4.5 Primary Applicant': '5 Primary plus 1 Joint';
    String incomeMultiplierStatus = (maximumLoanAmount >= opportunity.Finance_Required__c) ? 'Pass': 'Fail';
    
    //  Update the Affordability Results record
    affordabilityResult.IncomeMultiplier4_5Total__c = loanAmount1;
    affordabilityResult.IncomeMultiplier5_1__c = loanAmount2;
    affordabilityResult.IncomeMultiplierHigherAmount__c = incomeMultiplierHigherAmount;
    affordabilityResult.IncomeMultiplierResult__c = incomeMultiplierStatus;
    
    //  Update the Extended Opportunity record
    extendedOpportunity.IncomeMultiplier__c = incomeMultiplierHigherAmount;
  }
  
  private Decimal getBenchmarkRate(){
    Double benchmarkRate = 0.0;
    if (opportunity.Interested_in__c == 'Home Purchase Plan Premier') 
    {
        benchmarkRate = opportunity.HPP_Premier_Rate__c;
    }
    else
    {
        // LB001 start - if a BTL use the 
        if ( opportunity.Interested_in__c.equalsIgnoreCase('Buy To Let Purchase Plan' ))
        {
            if(product.Rental_Rate_BTL_Afford__c != null && product.Rental_Rate_BTL_Afford__c != 0){
                benchmarkRate = product.Rental_Rate_BTL_Afford__c;
            }else{
                benchmarkRate = product.Benchmark_rate__c;
            }
        }
        else
        {
            benchmarkRate = product.Benchmark_rate__c;
        }
        //LB001 end
    }
    return benchmarkRate;
  }
  
  private Decimal getHPPStressedRepayment() 
  {
      //CPDR fix for Premier
     //start - C0568
    Double benchmarkRate = getBenchmarkRate();
    //stop - C0568
    
    //Double benchmarkRate = product.Benchmark_rate__c;
    // CPDR fix end
    
    
    
    
    
    system.debug('Rate ' + benchmarkRate );
    
    /* M00026 don't add 2 - this is apparently something called the stressed rate and no longer required
    So the name of this method should really be changed........ 
    benchmarkRate += 2;
    */
  
    /* M00032 Apparently the above was wrong or only half right, only BTL should be not stressed */
    if ( opportunity.Interested_in__c != 'Buy To Let Purchase Plan' )
    {
         /* C00237 start
        benchmarkRate += 2;
        */
        benchmarkRate += 3;
        /* C00237 end */    
    }
    /* M00032 end */
    
    
    Double principle = opportunity.Finance_Required__c;
    Double interest = benchmarkRate;
    Double length = opportunity.Term_of_Finance__c;
    Double monthlyInterest = interest / (12 * 100);
    Double numberOfMonthsAmortized = length * 12;
    
    Decimal hppRepayment;
    
    //BRO products only look at rental rate
    if(product.product_code__c.equalsIgnorecase('BRO'))
    {
        hppRepayment = principle * monthlyInterest;
    }
    else
    {
        hppRepayment= principle * (monthlyInterest / (1 - Math.pow((1 + monthlyInterest), -numberOfMonthsAmortized)));
    }
    
     
    hppRepayment = hppRepayment.round();
    System.debug('hppRepayment => ' + hppRepayment);
    
    return hppRepayment;
  }
  
  public void affordabilityCalculation() 
  {
    //System.debug('personDebts => ' + personDebts);
    
    //  Calculate Total Person Debts
    Decimal totalPersonDebts = 0;
    
    // LB - We do need to look at debts such as HP and loans when calculating the affordability percentage
    //totalPersonDebts = TotalPersonalDebts;
    
    
    /* we dont look at the debt object anymore
    for (Person_Debts__c personDebt : personDebts) {
      System.debug('totalPersonDebts BEFORE => ' + totalPersonDebts);
      System.debug('personDebt => ' + personDebt);
      
      if (!personDebt.Will_this_debt_be_paid_off_by_this_app__c) {
        if (personDebt.Type_of_debt__c == 'Credit Card' || personDebt.Type_of_debt__c == 'Store Card' || personDebt.Type_of_debt__c == 'Mail order: account') {
          totalPersonDebts += personDebt.CardRepayment3__c;
          System.debug('personDebt.CardRepayment3__c => ' + personDebt.CardRepayment3__c);
        }
        else if (personDebt.Type_of_debt__c == 'Loan' || personDebt.Type_of_debt__c == 'Hire purchase' || personDebt.Type_of_debt__c == 'Mail order: monthly repayment' || personDebt.Type_of_debt__c == 'Personal Contract Hire (Car scheme)') {
          System.debug('personDebt.PaidOffDebt__c => ' + personDebt.PaidOffDebt__c);
          if (personDebt.PaidOffDebt__c == null || (personDebt.PaidOffDebt__c > Date.today().addYears(1))) {
            totalPersonDebts += personDebt.Monthly_repayment__c;
            System.debug('personDebt.Monthly_repayment__c => ' + personDebt.Monthly_repayment__c);
          }
        }
      }
      
      System.debug('totalPersonDebts AFTER => ' + totalPersonDebts);
    }
    
      we dont look at the debt object anymore */
    
    //  Calculate Total BTL Properties
    Decimal totalBTLPropertiesIncome = 0;
    for (Property_information__c property : properties) 
	{
      if (property.IsBTLProperty__c) {
        Decimal amountOfMonthlyRepayment = 0;
        Decimal amountOfMonthlyRentReceived = 0;
        
        if (property.Amount_of_monthly_rent_received__c != null) {
            amountOfMonthlyRentReceived = property.Amount_of_monthly_rent_received__c;
        }
        
        if (property.Amount_of_monthly_repayment__c != null) {
            amountOfMonthlyRepayment = property.Amount_of_monthly_repayment__c;
        }
        //M00033
        //Old code
        //Decimal btlPropertyIncome = (amountOfMonthlyRepayment * 1.25) - amountOfMonthlyRentReceived;
        //New code, reverse the calcualtion
        Decimal btlPropertyIncome = amountOfMonthlyRentReceived - (amountOfMonthlyRepayment * 1.25)  ;        
        //M00033 end
        
        totalBTLPropertiesIncome += btlPropertyIncome;
      }
    }
    
    Decimal hppRepayment = getHPPStressedRepayment();
    
    //  Update Affordability Results record
    affordabilityResult.StressedHPPRepayment__c = hppRepayment;
    /* M00027 start */

    //affordabilityResult.AdditionalRentalIncome__c = totalBTLPropertiesIncome;
    system.debug('BTL product type: '+opportunity.IBB_Product_Type__c);
    if ( opportunity.IBB_Product_Type__c == 'BTL Purchase Plan' || opportunity.IBB_Product_Type__c == 'BTL Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan' )
    {
        affordabilityResult.AdditionalRentalIncome__c = opportunity.Estimated_actual_monthly_rental_income__c;
    }
    else
    {
        affordabilityResult.AdditionalRentalIncome__c = totalBTLPropertiesIncome;
    }
    /* M00027 end */
    affordabilityResult.TotalMonthlyDebtRepayment__c = totalPersonDebts;
    
    //  Add to Total Commitments total
    
    affordabilityResult.TotalCommitments__c += affordabilityResult.StressedHPPRepayment__c + affordabilityResult.TotalMonthlyDebtRepayment__c;
    system.debug('Total commit ' + affordabilityResult.TotalCommitments__c);
    
    
    if (opportunity.IBB_Product_Type__c == 'BTL Purchase Plan' || opportunity.IBB_Product_Type__c == 'BTL Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan') 
	{
      // C0586 - BTL should not take repayment into account at Budget Planner stage so reset TotalCommitments back to zero
	  affordabilityResult.TotalCommitments__c = 0;
	  
	  System.debug('opportunity.Estimated_actual_monthly_rental_income__c => ' + opportunity.Estimated_actual_monthly_rental_income__c);
      Decimal affordabilityPercentage = opportunity.Estimated_actual_monthly_rental_income__c / hppRepayment;
      System.debug('affordabilityPercentage => ' + affordabilityPercentage);
      
      //  Update Affordability Results record
      /* M000026 */
      affordabilityPercentage = affordabilityPercentage * 100;
      /* M00026 end */
      affordabilityResult.AffordabilityPercentage__c = affordabilityPercentage;
    
      
      System.debug('BTL affordabilityPercentage => ' + affordabilityPercentage);
      
      // M00026 end
      affordabilityResult.AffordabilityResult__c = (affordabilityPercentage >= 125) ? 'Pass': 'Fail';
      System.debug('BTL affordabilityPercentage => ' + affordabilityResult.affordabilityResult__c);
      //  Update Extended Opportunity record
      extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
      
      
      System.debug('BTL Interested in:'+opportunity.Interested_in__c);
      
      //start - C0568
      // if ( opportunity.Interested_in__c.equalsIgnoreCase('Buy To Let Purchase Plan' ) || opportunity.Interested_in__c.equalsIgnoreCase('BTL Purchase Plan') || opportunity.Interested_in__c.equalsIgnoreCase('Buy To Let Purchase Plan Scotland' ) || opportunity.Interested_in__c.equalsIgnoreCase('BTL Purchase Plan Scotland' ) )
              Map<String,BTLAffordability__c> affordabilityParams=BTLAffordability__c.getall();
              
              double expectedRent=opportunity.Estimated_actual_monthly_rental_income__c;
              system.debug('expectedRent'+expectedRent);
              
              double i5yrProjectedBaseRate=double.valueof(affordabilityParams.get('5yrProjectedBaseRate').value__c);
              system.debug('i5yrProjectedBaseRate'+i5yrProjectedBaseRate);
              
              double StressedBaseRate=double.valueof(affordabilityParams.get('StressedBaseRate').value__c);
              system.debug('StressedBaseRate'+StressedBaseRate);
              
              double PRARentCoverageRatio=double.valueof(affordabilityParams.get('PRARentCoverageRatio').value__c);
              system.debug('expectedRent'+expectedRent);
              
              double RentCoverageRatio=double.valueof(affordabilityParams.get('RentCoverageRatio').value__c);
              system.debug('RentCoverageRatio'+RentCoverageRatio);
              
              double finalBaseRate=i5yrProjectedBaseRate>StressedBaseRate?i5yrProjectedBaseRate:StressedBaseRate;
              system.debug('finalBaseRate'+finalBaseRate);
              
              double productRate=getBenchmarkRate();
              system.debug('productRate'+productRate);
              
              double stressedRentCoverageRatio=(ProductRate + finalBaseRate) > PRARentCoverageRatio? (ProductRate + finalBaseRate) : PRARentCoverageRatio;
              system.debug('stressedRentCoverageRatio'+stressedRentCoverageRatio);
              
              //amountOfMonthlyRepayment
              Double principle = opportunity.Finance_Required__c;
              system.debug('principle '+principle );
              
              Double interest = stressedRentCoverageRatio;
              system.debug('interest '+interest );
              
              Double length = opportunity.Term_of_Finance__c;
              system.debug('length '+length );
              
              Double monthlyInterest = interest / (12 * 100);
              system.debug('monthlyInterest '+monthlyInterest );
              
              Double numberOfMonthsAmortized = length * 12;
              system.debug('numberOfMonthsAmortized '+numberOfMonthsAmortized );
              
              // C0586 - RO changes Start
              
			  double amountOfMonthlyRepayment=0;
			  if(product.product_code__c.equalsIgnorecase('BRO'))
			  {
				amountOfMonthlyRepayment = principle * monthlyInterest;
			  }
			  else
			  {
				amountOfMonthlyRepayment = principle * (monthlyInterest / (1 - Math.pow((1 + monthlyInterest), -numberOfMonthsAmortized)));
			  }
			   
              // C0586 - RO changes End

              system.debug('amountOfMonthlyRepayment'+amountOfMonthlyRepayment);

			  //integer i = 1 / 0;

			  // C0586 - UW Changes - Add in service charge etc. and save for later display
			  MMR_HPPBudgetPlannerHelper helper = new MMR_HPPBudgetPlannerHelper(opportunity.Id);
			  totalCharges=helper.GetBTLBasicBudgetPlannerCosts().setScale(2);
			  amountOfMonthlyRepayment+=totalCharges;

			  //totalCharges=0.00;
			  
			  // C0586 - UW Changes - Store for use on pages as Test 1 Minimum Rental Income & Surplus/Deficit
			  minimumRentalIncome = Decimal.valueOf(amountOfMonthlyRepayment).setScale(2);
			  minimumRentalIncomeDeficit = Decimal.valueOf(expectedRent - Double.valueOf(minimumRentalIncome)).setScale(2); // +ve = Surplus, -ve = Deficit
              
              amountOfMonthlyRepayment= amountOfMonthlyRepayment.round();
              system.debug('amountOfMonthlyRepayment'+amountOfMonthlyRepayment);
              
              //amountOfMonthlyRepayment
              
              double aquisition=(amountOfMonthlyRepayment *PRARentCoverageRatio*30/360);
              system.debug('aquisition'+aquisition);
              
              system.debug('stressedMonthlyPayment'+(amountOfMonthlyRepayment - aquisition)*RentCoverageRatio);
              
              Double NetRentalIncome = (((principle / 100)  * interest)/12);
			  Double GrossRentalIncome=(NetRentalIncome)*RentCoverageRatio;

              // C0586 - UW Changes - Store for use on pages as Test 2 PRA Rental Income & Surplus/Deficit
			  PRARentalIncome = Decimal.valueOf(GrossRentalIncome).setScale(2);
			  PRARentalIncomeDeficit = Decimal.valueOf(expectedRent - GrossRentalIncome).setScale(2); // +ve = Surplus, -ve = Deficit
			  PRACoverage = Decimal.valueOf((expectedRent/NetRentalIncome)*100).setScale(0);
              
              system.debug('GrossRentalIncome1: '+GrossRentalIncome);
              system.debug('expectedRent: '+expectedRent);
              
              if(minimumRentalIncomeDeficit>0 && expectedRent>=GrossRentalIncome){
				  system.debug('BTL - Passed No Need for IAA');
                  affordabilityResult.AffordabilityResult__c='Pass';
				  opportunity.Income_Assisted_Application__c= false;
              }
              else{
                  affordabilityResult.AffordabilityResult__c='Fail';
				  // C0586 Start
				  // Save the largest deficit value (At least one of the below will be -ve)
				  Double DeficitToSave = (minimumRentalIncomeDeficit > PRARentalIncomeDeficit) ? PRARentalIncomeDeficit : minimumRentalIncomeDeficit;
				  helper.SaveIncomeAssistedBTLDeficit(DeficitToSave*-1);
				  IAADeficit = Decimal.valueOf(GrossRentalIncome-expectedRent).setScale(2);
				  system.debug('BTL - Failed, Run again with IAA');
				  opportunity.Income_Assisted_Application__c= true;
              }
			  //integer i = 1 / 0;
			  update opportunity;
			  // C0586 End
			  
              
              affordabilityResult.StressedHPPRepayment__c=GrossRentalIncome;
              
              system.debug('AffordabilityResult__c: '+affordabilityResult.AffordabilityResult__c);
              
              
              affordabilityPercentage = ( expectedRent / GrossRentalIncome ) * 100;
              
              extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
              
              affordabilityResult.AffordabilityPercentage__c= affordabilityPercentage;
              
              system.debug('Affordability_Percentage__c : '+extendedOpportunity.Affordability_Percentage__c );

			
     
       //end - C0568
      
      
      
    }
    else {
      Decimal acceptablePercentage = 0;
      if (applicants.size() < 3) {
        if (totalNumberOfDependents < 2) {
          acceptablePercentage = boardLimits.X2Applicants0_1Dependants__c;
        }
        else if (totalNumberOfDependents < 4) {
          acceptablePercentage = boardLimits.X2Applicants2_3Dependants__c;
        }
        else {
          acceptablePercentage = boardLimits.X2Applicants3_Dependants__c;
        }
      }
      else if (applicants.size() == 3) {
        if (totalNumberOfDependents < 2) {
          acceptablePercentage = boardLimits.X3Applicants0_1Dependants__c;
        }
        else if (totalNumberOfDependents < 4) {
          acceptablePercentage = boardLimits.X3Applicants2_3Dependants__c;
        }
        else {
          acceptablePercentage = boardLimits.X3Applicants3_Dependants__c;
        }
      }
      else if (applicants.size() == 4) {
        if (totalNumberOfDependents < 2) {
          acceptablePercentage = boardLimits.X4Applicants0_1Dependants__c;
        }
        else if (totalNumberOfDependents < 4) {
          acceptablePercentage = boardLimits.X4Applicants2_3Dependants__c;
        }
        else {
          acceptablePercentage = boardLimits.X4Applicants3_Dependants__c;
        }
      }
      
      System.debug('acceptablePercentage => ' + acceptablePercentage);
      System.debug('totalNetMonthlyIncome => ' + totalNetMonthlyIncome);
      System.debug('totalPersonDebts => ' + totalPersonDebts);
      System.debug('totalBTLPropertiesIncome => ' + totalBTLPropertiesIncome);
      
      
      //Decimal debts = TotalPersonalDebts;
      
      //Decimal disposableIncome = totalNetMonthlyIncome - totalPersonDebts + totalBTLPropertiesIncome;
      Decimal disposableIncome = totalNetMonthlyIncome - TotalPersonalDebts  + totalBTLPropertiesIncome;
     
      
      System.debug('disposableIncome => ' + disposableIncome);
      Decimal affordabilityPercentage = (hppRepayment / disposableIncome) * 100;
      System.debug('affordabilityPercentage => ' + affordabilityPercentage);
      
      //  Update Affordability Results record
      affordabilityResult.AffordabilityNetMonthlyIncome__c = disposableIncome;
      affordabilityResult.AffordabilityPercentage__c = affordabilityPercentage;
      
      
      
     
      
      //  Update Extended Opportunity record
        affordabilityResult.AffordabilityResult__c = (affordabilityPercentage <= acceptablePercentage) ? 'Pass': 'Fail';
       extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
    }
  }
  
  private Board_Limits_v1__c getBoardLimitsForBudgetPlanner() {
    String boardLimitsName = '';
    
    if (applicants.size() < 3) {
      if (totalNumberOfDependents < 2) {
        boardLimitsName = '004';
      }
      else if (totalNumberOfDependents < 3) {
        boardLimitsName = '002';
      }
      else {
        boardLimitsName = '003';
      }
    }
    else if (applicants.size() == 3) {
      if (totalNumberOfDependents < 2) {
        boardLimitsName = '007';
      }
      else if (totalNumberOfDependents < 3) {
        boardLimitsName = '005';
      }
      else {
        boardLimitsName = '006';
      } 
    }
    else if (applicants.size() == 4) {
      if (totalNumberOfDependents < 2) {
        boardLimitsName = '010';
      }
      else if (totalNumberOfDependents < 3) {
        boardLimitsName = '008';
      }
      else {
        boardLimitsName = '009';
      }
    }
    
    List<Board_Limits_v1__c> boardLimits = [
      SELECT Name, BuildingInsuranceBP__c, WaterBP__c, ClothingBP__c, ElectricityBP__c, 
        ContentsInsuranceBP__c, FoodBP__c, CouncilTaxBP__c, TVLicenceBP__c
      FROM Board_Limits_v1__c
      WHERE Name = :boardLimitsName
      LIMIT 1
    ];
    Board_Limits_v1__c boardLimit = (boardLimits.size() == 1) ? boardLimits.get(0): null;
    
    return boardLimit;
  }
  
  public void budgetPlanner() {  

    Decimal netCommitments = BudgetPlannerCommitmentTotal;
    
    system.debug('Net commitment : ' +netCommitments );
    
    affordabilityResult.BudgetPlannerTotal__c = netCommitments ;    
    
    //  Add to Total Commitments total
    
    system.debug('Total commit bp : ' + affordabilityResult.TotalCommitments__c);    
	system.debug('totalNetMonthlyIncome : ' + totalNetMonthlyIncome); 
	system.debug('affordabilityResult.AdditionalRentalIncome__c : ' + affordabilityResult.AdditionalRentalIncome__c);
	affordabilityResult.TotalCommitments__c += netCommitments ;
    
    system.debug('affordabilityResult.TotalCommitments__c : ' + affordabilityResult.TotalCommitments__c); 
	affordabilityResult.BudgetPlannerResult__c = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? 'Surplus': 'Deficit';
	// C0586 Start
	failedBP = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? false: true;
    affordabilityResult.BudgetPlannerSurplusOrDeficit__c = totalNetMonthlyIncome - affordabilityResult.TotalCommitments__c;
	if(!(opportunity.IBB_Product_Type__c == 'BTL Purchase Plan' || opportunity.IBB_Product_Type__c == 'BTL Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan Scotland' || opportunity.IBB_Product_Type__c == 'Buy To Let Purchase Plan'))
	{
		affordabilityResult.BudgetPlannerSurplusOrDeficit__c += affordabilityResult.AdditionalRentalIncome__c;
	}
    // C0586 End

    //  Update the Extended Opportunity record
    extendedOpportunity.BudgetPlannerResult__c = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? 'Pass': 'Fail';

  }
  
  public boolean AffordabilityTheSame(List<string> fieldsToCheck,AffordabilityResults__c oldItem, AffordabilityResults__c newItem )
  {
      system.debug('To check :' + fieldsToCheck);
  
      for(String s : fieldsToCheck)
      {
          system.debug('Comparing ' + s+ ' => ' + oldItem.get(s) + ' : ' + newItem.get(s));
          if(oldItem.get(s) != newItem.get(s))
              return false;
      }
      
      return true;
  }
  
  public void saveResults() {
      system.debug('Saving results :' + affordabilityResult.id);
      List<AffordabilityResults__c> recent = [select AffordabilityPercentage__c, GrossAnnualIncomeApplicant1__c,GrossAnnualIncomeApplicant2__c,GrossAnnualIncomeApplicant3__c,GrossAnnualIncomeApplicant4__c, id,FinanceRequired__c,TermOfFinance__c,Purchase_Price_Market_Value__c,StressedHPPRepayment__c,BudgetPlannerTotal__c,BudgetPlannerSurplusOrDeficit__c,TotalCommitments__c ,NetMonthlyIncomeApplicant1__c,NetMonthlyIncomeApplicant2__c,NetMonthlyIncomeApplicant3__c,NetMonthlyIncomeApplicant4__c,AffordabilityResult__c from AffordabilityResults__c  where opportunity__c =: opportunity.Id order by createddate desc limit 1];
      
      List<Opportunity> o = [select isClosed from Opportunity where id=:opportunity.Id and isClosed = true];
      if(o.size() > 0) 
      {
          system.debug('NOT SAVING');
          return;
      }
    
      List<String> fieldsToCheck = new List<string>();
      fieldsToCheck.add('FinanceRequired__c');  
      fieldsToCheck.add('TermOfFinance__c');
      fieldsToCheck.add('Purchase_Price_Market_Value__c');
      fieldsToCheck.add('StressedHPPRepayment__c');      
      fieldsToCheck.add('BudgetPlannerTotal__c');
      fieldsToCheck.add('BudgetPlannerSurplusOrDeficit__c');
      fieldsToCheck.add('TotalCommitments__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant1__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant2__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant3__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant4__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant1__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant2__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant3__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant4__c');
      fieldsToCheck.add('AffordabilityPercentage__c');
      fieldsToCheck.add('AffordabilityResult__c');
      
      system.debug('Saving affordability result: '+affordabilityResult.AffordabilityResult__c);
      
      if(recent.size() > 0)
      {
          system.debug('Saving 3');
          if(!AffordabilityTheSame(fieldsToCheck,recent[0],affordabilityResult ))
          {
              system.debug('Saving 1');
              upsert affordabilityResult;
          }
      }
      else
      {
          system.debug('Saving 2');
          upsert affordabilityResult;
      }
    
    system.debug('saving Affordability_Percentage__c : '+extendedOpportunity.Affordability_Percentage__c );
    
    update extendedOpportunity;
    
    List<Account> accounts = new List<Account>();
    for (Applicant__c applicant : applicants) {
      accounts.add(applicant.Prospect_Customer__r);
    }
    update accounts;
  }
}