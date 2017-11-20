public class MMR_FF_PersonalDetails extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public List<Applicant__c> Applicants{get;set;}
    
    
    public MMR_FF_PersonalDetails()
    {   
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_PersonalDetails') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        
        Applicants = [select id, HTBQ1__c,HTBQ2__c,HTBQ3__c from applicant__c where opportunity__c = :bopp.id order by applicant_number__c];
    }
    
    /*
    public PageReference GoPersonal()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_PersonalDetails?id=' + eventid);
    }*/
    
    public PageReference GoAddresses()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_Addresses?id=' + eventid);
    }   
    
    public PageReference GoProperty()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_PropertyDetails?id=' + eventid);
    } 
    
    public PageReference GoIncome()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_Income?id=' + eventid);
    }     
    
    /*
    public PageReference Setup_Addresses()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Addresses') + ' from account where id in ' +   AccountIds  ;
        Accs = DataBase.Query(soql);
        return null;
    }*/
    
    public PageReference Setup_Ownership()
    {
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Ownership') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        return null;
    }
    
    private void LoadProperty()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Property') + ' from Property_information__c where PersonAccount__c in' + AccountIds ;
        m_AllProperty= DataBase.Query(soql);
    }
    
    Transient List<Property_information__c> m_AllProperty;    
    public List<Property_information__c> AllProperty
    {
        get{
            if(m_AllProperty == null)
            {
                LoadProperty();
            }
            return m_AllProperty;
        }       
    }
    
    public List<Property_information__c > GetProperty(String applicantNo)
    {
        String id = Accs [integer.valueof(applicantNo)-1].id;
        system.debug('Acc Id ' + id);
        system.debug('ACc list ' + lstAccountIds );
        List<Property_information__c> lst= new List<Property_information__c >();
        for(Property_information__c p : AllProperty)
        {
            if(p.PersonAccount__c == id)
            {
                lst.add(p);
            }
        }    
    
        return lst;
    }
    
    public List<SelectOption> selApplicant
    {
        get{
            List<SelectOption> options= new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            Integer i = 1;
            for(Account a : Accs )
            {
                options.add(new SelectOption(a.id,'Applicant ' + i + ' ' +a.name));
                i++;
            }
            return options;
        }
    }

    public PageReference SaveProperty()
    {
        Boolean isNew = true;
        Property_information__c prop = new Property_information__c ();
        
        System.debug('ID:' + EditProperty.id);
        
        if(EditProperty.id != null)
        {
                      
                    
                    String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Property') + ' from Property_information__c where id= \'' + EditProperty.id + '\'';
                    
                    List<Property_information__c> props = database.query(soql);
                    
                    if(props.size() > 0)
                    {
                        prop = props[0];
                    }
                  
                    
                    isNew = false;
                    
                    system.debug('Found property id :' + EditProperty.id);
           
        }
        
        
        prop.PersonAccount__c = EditProperty.PersonAccount__c;         
        prop.First_line_of_address__c = EditProperty.First_line_of_address__c;
        prop.Date_purchased__c= EditProperty.Date_purchased__c;
        prop.ExisitingMortgageHPPLender__c= EditProperty.ExisitingMortgageHPPLender__c;
        prop.Amount_of_monthly_repayment__c= EditProperty.Amount_of_monthly_repayment__c;
        prop.IsBTLProperty__c= EditProperty.IsBTLProperty__c;                                
        prop.Amount_of_monthly_rent_received__c= EditProperty.Amount_of_monthly_rent_received__c;  
        
        system.debug(prop);
        
        
        try
        {
            upsert prop;
            EditProperty = new Property_information__c ();
            LoadProperty();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
    
    public Property_information__c EditProperty
    {
        get{
            if(EditProperty == null)
            {
                EditProperty = new Property_information__c ();
            }
            return EditProperty;
        }
        set;
    }
    
    public PageReference RemoveItem(String id)
    {
        Integer i = 0;
        Property_information__c del;
        
        for(Property_information__c p : AllProperty)
        {
            if(p.id == id)
            {
                del = AllProperty.Remove(i);
                break;   
            }        
            i++;
        }
        
        if(del != null)
        {
            delete del;
        }            
    
        
    system.debug('Remove main controller :' + id);
        return null;
    }

    private List<Account>UpdateAccountTotals(List<Account> accounts)
    {
        for(Account a : accounts)
        {
            Integer numProp = 0;
            Integer numBtl =0;
            for(Property_information__c p : AllProperty)
            {
                if(a.id == p.Personaccount__c)
                {
                    if(p.IsBTLProperty__c)
                    {
                        numBtl++;
                    }
                    else
                    {
                        numProp++;
                    }
                }
            }
            a.Other_properties_do_you_currently_own__c = string.valueof(numProp);
            a.BTL_Properties__c = string.valueof(numBtl);
        }
        return accounts;
    }
    
    private void SaveData()
    {
         try
        {
        //update num btl and num properties
        Accs = UpdateAccountTotals(Accs);    
        
        update Applicants;
        
        update Accs;
        
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    
    public PageReference Save()
    {
       SaveData();
        return null;
    }
    
    
    public boolean Email1{
        get{
            if(Email1 == null)
            {
                Email1 = !ContainsOption('Email',accs[0]);
            }
            return Email1;            
        }
        set;
    }
    public boolean Email2{
        get{
            if(Email2 == null)
            Email2 =!ContainsOption('Email',accs[1]);
            
            return Email2;
        }
        set;
    }
    public boolean Email3{
        get{
            if(Email3 == null)
            Email3 = !ContainsOption('Email',accs[2]);
            
            return Email3;
        }
        set;
    }
    public boolean Email4{
        get{
            if(Email4 == null)
            Email4 =!ContainsOption('Email',accs[3]);
            return Email4;
        }
        set;
    }
    
    public boolean Mail1{
        get{
            if(Mail1 == null)
            Mail1 = !ContainsOption('Mail',accs[0]);
            return Mail1;
        }
        set;
    }
    public boolean Mail2{
        get{
            if(Mail2 == null)
            Mail2 = !ContainsOption('Mail',accs[1]);
            return Mail2;
        }
        set;
    }

    public boolean Mail3{
        get{
            if(Mail3 == null)
            Mail3 = !ContainsOption('Mail',accs[2]);
            return Mail3;
        }
        set;
    }

    public boolean Mail4{
        get{
            if(Mail4 == null)
            Mail4 = !ContainsOption('Mail',accs[3]);
            return Mail4;
        }
        set;
    }
    
    public boolean Phone1{
        get{
            if(Phone1 == null)
            Phone1 = !ContainsOption('Phone',accs[0]);
            return Phone1;
        }
        set;
    }
    public boolean Phone2{
        get{
            if(Phone2 == null)
            Phone2 = !ContainsOption('Phone',accs[1]);
            return Phone2;
        }
        set;
    }
    public boolean Phone3{
        get{
            if(Phone3 == null)
            Phone3 = !ContainsOption('Phone',accs[2]);
            return Phone3;
        }
        set;
    }
    public boolean Phone4{
        get{
            if(Phone4 == null)
            Phone4 = !ContainsOption('Phone',accs[3]);
            return Phone4;
        }
        set;
    }

    public boolean SMS1{
        get{
            if(SMS1 == null)
            SMS1 = !ContainsOption('sms',accs[0]);
            return SMS1;
        }
        set;
    }
    public boolean SMS2{
        get{
            if(SMS2 == null)
            SMS2 = !ContainsOption('sms',accs[1]);
            return SMS2;
        }
        set;
    }
    public boolean SMS3{
        get{
            if(SMS3 == null)
            SMS3 = !ContainsOption('sms',accs[2]);
            return SMS3;
        }
        set;
    }
    public boolean SMS4{
        get{
            if(SMS4 == null)
            SMS4 = !ContainsOption('sms',accs[3]);
            return SMS4;
        }
        set;
    }
    
    
    
     public Boolean ContainsOption(String option,Account a)
    {
        system.debug('error:' + a.marketing_preference__C);
                
        if(a.marketing_preference__C == null)
            a.marketing_preference__C = '';
            update accs;
    
        return a.marketing_preference__C.containsIgnoreCase(option);
    }
    

}