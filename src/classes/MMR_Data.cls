global class MMR_Data
{
	public class KeyValue
    {
        public string Key{get;set;}
        public string Value{get;set;}
        
        public KeyValue(String keyVal, String val)
        {
            Key = keyVal;
            Value = val;
            
            if(Key == null) Key = '';
        }
    }

	public class KeyValueCountry
    {
        public string Key{get;set;}
        public string Value{get;set;}
        public Boolean IsEU{get;set;}
        
        public KeyValueCountry(String keyVal, String val, Boolean eu)
        {
            Key = keyVal;
            Value = val;
            IsEU = eu;
            
            if(Key == null)Key='';
        }
    }

	global virtual class GenericResponse
    {
        public String URL{get;set;}
        public Boolean Success{get;set;}
        public string Error{get;set;}
    }

	global class HPPDetailsDataResponse extends GenericResponse
    {
        public HPPDetailsData Data {get;set;}
    }

	global class HPPDetailsData 
    {
        public List<PrimaryApplicantData> Applicants{get;set;}
        
        public List<KeyValue> CountriesOfBirth{get;set;}
        public List<KeyValueCountry> Nationality{get;set;}
        public List<KeyValue> RelationshipTo{get;set;}
        public List<KeyValue> RelationshipToYPSA{get;set;}
        public List<KeyValue> Title{get;set;}
        public List<KeyValue> TitleYPSA{get;set;}
        public List<KeyValue> EmploymentType{get;set;}
        public List<KeyValue> EmploymentSector{get;set;}
        public List<KeyValue> VisaType{get;set;}
        public List<KeyValue> ProofID{get;set;}
        public List<KeyValue> MaritalStatus{get;set;}
        public List<KeyValue> Campaigns{get;set;}
        public List<KeyValue> HomeDetails{get;set;}
        public List<KeyValue> SourceOfIncome{get;set;}
        public List<KeyValue> CustomerType{get;set;}
        public List<KeyValue> Contact{get;set;}

		public List<KeyValue> TotalNetWorth{get;set;}
		public List<KeyValue> IntFundsFrequency{get;set;}
		public List<KeyValue> IntFundsSource{get;set;}
		public List<KeyValue> IntFundsDestination{get;set;}
		public List<KeyValue> SourceOfFunds{get;set;}
		public List<KeyValue> SourceOfWealth{get;set;}
		public List<KeyValue> SourceOfFundsCountry{get;set;}
		public List<KeyValue> EstMnthlyVolIn{get;set;}
		public List<KeyValue> EstMnthlyVolOut{get;set;}
		public List<KeyValue> EstMnthlyNumTxIn{get;set;}
		public List<KeyValue> EstMnthlyNumTxOut{get;set;}
		public List<KeyValue> EstCashWthdrwlFreq{get;set;}
		public List<KeyValue> EstCashDepositFreq{get;set;}
		public List<KeyValue> Authorisers{get;set;}

        
        public HPPDetailsData()
        {
            Applicants = new List<PrimaryApplicantData>();
            
            
            HomeDetails = new List<KeyValue>();
            CountriesOfBirth = new List<KeyValue>();
            Nationality= new List<KeyValueCountry>();
            RelationshipTo= new List<KeyValue>();
            RelationshipToYPSA= new List<KeyValue>();
            Title= new List<KeyValue>();
            TitleYPSA= new List<KeyValue>();
            EmploymentType= new List<KeyValue>();
            EmploymentSector= new List<KeyValue>();
            VisaType= new List<KeyValue>();
            ProofID= new List<KeyValue>();
            MaritalStatus = new List<KeyValue>();
            Campaigns = new List<KeyValue>();
            SourceOfIncome = new List<KeyValue>();
            CustomerType = new List<KeyValue>();
            Contact = new List<KeyValue>();

			TotalNetWorth= new List<KeyValue>();
			IntFundsFrequency= new List<KeyValue>();
			IntFundsSource= new List<KeyValue>();
			IntFundsDestination= new List<KeyValue>();
			SourceOfFunds= new List<KeyValue>();
			SourceOfWealth= new List<KeyValue>();
			SourceOfFundsCountry= new List<KeyValue>();
			EstMnthlyVolIn= new List<KeyValue>();
			EstMnthlyVolOut= new List<KeyValue>();
			EstMnthlyNumTxIn= new List<KeyValue>();
			EstMnthlyNumTxOut= new List<KeyValue>();
			EstCashWthdrwlFreq= new List<KeyValue>();
			EstCashDepositFreq= new List<KeyValue>();
			Authorisers= new List<KeyValue>();

        }
    }

	public class PrimaryApplicantData
    {
        public String Id{get;set;}
        
        public String ContactName {get;set;}
		
		public String EBS_ID_c {get;set;}
        public String required_ebs_id_c {get;set;}
        
        public String Valid{get;set;}
        
        public Boolean Possible_Duplicate_c{get;set;}
        public String Customer_Type_c {get;set;}
        public String Premier_Status_c{get;set;}
        public String Correct {get;set;}


		public String Panoptic_ID_c {get;set;}
		public String Panoptic_Score_c {get;set;}
		// public String VIP_c {get;set;} // No longer required but left to use as customer type if required 
		public String PEP_c {get;set;} 
		public String PEP_Associate_c {get;set;}		
		public String What_is_your_total_net_worth_c {get;set;}
		public String International_Fund_Transfer_Frequency_c {get;set;}
		public String International_Fund_Transfer_Source_c {get;set;}
		public String International_Fund_Transfer_Destination_c {get;set;}
		public String Source_of_Wealth_c {get;set;}
		public String Source_of_Funds_c {get;set;}
		public String Source_of_Funds_Country_c {get;set;}
		public String Estimated_Monthly_Volume_Inward_c {get;set;}
		public String Est_Monthly_Num_of_Transactions_Inward_c {get;set;}
		public String Estimated_Monthly_Volume_Outward_c {get;set;}
		public String Est_Monthly_Num_of_Transactions_Outward_c {get;set;}
		public String Estimated_Cash_Withdrawal_Frequency_c {get;set;}
		public String Estimated_Cash_Deposit_frequency_c {get;set;}


        public String DecryptedId
        {
            get{
                return CAA_Helper.DecryptData(Id);
            }
        }
        
        public PrimaryApplicantData(Account acc)
        {
            
            Id = acc.id;
            
              
            if(!CAA_Helper.IsGuestUser())
            {
                Customer_Type_c = acc.Customer_Type__c;
                Premier_Status_c = acc.Premier_Status__c; 
                required_ebs_id_c = acc.required_ebs_id__c;
            } 
			
			ContactName=acc.Contact_Name__c;
                
            
			Panoptic_ID_c=acc.Panoptic_ID__c;
			Panoptic_Score_c=acc.Panoptic_Score__c;
			 // VIP_c=acc.VIP__c; // No longer required but left to use as customer type if required 
			PEP_c= acc.PEP__c == null ? 'null' :acc.PEP__c ? 'true' : 'false' ; 
			PEP_Associate_c=acc.PEP_Associate__c; 			
			What_is_your_total_net_worth_c=acc.What_is_your_total_net_worth__c;
			International_Fund_Transfer_Frequency_c=acc.International_Fund_Transfer_Frequency__c;
			International_Fund_Transfer_Source_c=acc.International_Fund_Transfer_Source__c;
			International_Fund_Transfer_Destination_c=acc.International_Fund_Transfer_Destination__c;
			Source_of_Wealth_c=acc.Source_of_Wealth__c;
			Source_of_Funds_c=acc.Source_of_Funds__c;
			Source_of_Funds_Country_c=acc.Source_of_Funds_Country__c;
			Estimated_Monthly_Volume_Inward_c=acc.Estimated_Monthly_Volume_Inward__c;
			Est_Monthly_Num_of_Transactions_Inward_c=acc.Est_Monthly_Num_of_Transactions_Inward__c;
			Estimated_Monthly_Volume_Outward_c=acc.Estimated_Monthly_Volume_Outward__c;
			Est_Monthly_Num_of_Transactions_Outward_c=acc.Est_Monthly_Num_of_Transactions_Outward__c;
			Estimated_Cash_Withdrawal_Frequency_c=acc.Estimated_Cash_Withdrawal_Frequency__c;
			Estimated_Cash_Deposit_frequency_c=acc.Estimated_Cash_Deposit_frequency__c;
            
        }

        public Account UpdateAccount(Account acc)
        {
            PrimaryApplicantData data = this;
            acc.Panoptic_ID__c=data.Panoptic_ID_c;
			acc.Panoptic_Score__c=data.Panoptic_Score_c;
			// acc.VIP__c=data.VIP_c; // No longer required but left to use as customer type if required 
			acc.Pep__c =  data.PEP_c == 'true'; 
			acc.PEP_Associate__c=data.PEP_Associate_c;
			acc.What_is_your_total_net_worth__c=data.What_is_your_total_net_worth_c;
			acc.International_Fund_Transfer_Frequency__c=data.International_Fund_Transfer_Frequency_c;
			acc.International_Fund_Transfer_Source__c=data.International_Fund_Transfer_Source_c;
			acc.International_Fund_Transfer_Destination__c=data.International_Fund_Transfer_Destination_c;
			acc.Source_of_Wealth__c=data.Source_of_Wealth_c;
			acc.Source_of_Funds__c=data.Source_of_Funds_c;
			acc.Source_of_Funds_Country__c=data.Source_of_Funds_Country_c;
			acc.Estimated_Monthly_Volume_Inward__c=data.Estimated_Monthly_Volume_Inward_c;
			acc.Est_Monthly_Num_of_Transactions_Inward__c=data.Est_Monthly_Num_of_Transactions_Inward_c;
			acc.Estimated_Monthly_Volume_Outward__c=data.Estimated_Monthly_Volume_Outward_c;
			acc.Est_Monthly_Num_of_Transactions_Outward__c=data.Est_Monthly_Num_of_Transactions_Outward_c;
			acc.Estimated_Cash_Withdrawal_Frequency__c=data.Estimated_Cash_Withdrawal_Frequency_c;
			acc.Estimated_Cash_Deposit_frequency__c=data.Estimated_Cash_Deposit_frequency_c;
            
            return acc;      
        }
    }

	global class HPPDetailsCompleteData
    {
        public List<PrimaryApplicantData> Applicants{get;set;}
        public String EventLogId{get;set;}
		public String ApprovalUser{get;set;}
		public Boolean isEDD {get;set;}   // Indicates that an internal staff member completed Adhoc EDD questions
    }
}