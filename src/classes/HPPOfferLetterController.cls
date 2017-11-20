/* -------------------------------------------------------------------------------- */
/* C00108 / P00001 More info for productswitching                                   */
/* -------------------------------------------------------------------------------- */

public class HPPOfferLetterController extends HPPBaseEventController
{
    public Actions.IAction RCEAction{get;set;} 
    
    public HPPOfferLetterController()
    {
        RCEAction= new Actions.ActionRCE2 ();  
        
        /* C00108 start */ 
        IsProductSwitch = opp.recordtype.Name == 'ProductSwitching' ? true : false;
        /* C00108 end */
    }
    
    public PageReference Setup()
    {
        if(exopp.Offer_letter_sent__c == null)
        {
            exopp.Offer_letter_sent__c = Date.today();
            //update exopp;
        }   
         
        try
        {
            ErrorLog.Fatal('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
            
            
            //create clause items
            Standard_Clause_Helper helper = new Standard_Clause_Helper(opp.id);
            helper.run();
            
        }
        catch(Exception ex)
        {
            ErrorLog.Fatal(ex.getMessage());
        }
         
         //CallRCE();
        return null;
    }
    
    
    /* C00108 start */
    public boolean IsProductSwitch {get;set;}
    /* C00108 end */
    
    public boolean RCECalled{get;set;}
    public boolean StartRCEPolling{get;set;}
    public boolean RCEFailed{get;set;}
    
    public PageReference CallRCE()
    {
        Opp.Attachment_Offer_Letter__c = null;            
        RCEFailed =false;    
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id); 
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }                
      
        return null;
    }
    
    public Boolean RCECompleted
    {
        get{
            Opp = DataHelper.GetOpportunity(Opp.id)[0];
            if(opp.IBBQuotation__c == null)
                return false;
            
            IBBQuotation__c ibb  = [select RCERetrieved__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];
            return ibb.RCERetrieved__c;
        }        
    }
    
    public PageReference PoolRCE()
    {
        if (RCECompleted)
        {
            StartRCEPolling = false;            
        }
        return null;
    }

    /*
    public PageReference CreateFisDoc()
    {
        Opp = DataHelper.GetOpportunity(opp.id)[0];
        
        if(opp.IBBQuotation__c == null)
            return null;
        
        system.debug('Quote id ' + opp.IBBQuotation__c );
        IBBQuotation__c  quote = [select id,DealType__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];

        CongaSettings sett = new CongaSettings(prod.Conga_FIS__c);                         
        string body= sett.CallConga(quote.id);   
        
        if(sett.AttachmentId != null)
        {
            quote.Attachment_FIS__c= sett.AttachmentId;
            update quote;
        }
        return null;
    }
    */

    public PageReference CreateDoc()
    {    

    
        String congaTemplateId;
        if(opp.purpose_of_finance__c.equalsIgnoreCase('New Purchase'))
        {
            congaTemplateId = prod.Conga_Offer_Letter__c;
        }
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Refinancing'))
        {
            congaTemplateId = prod.CongaOfferLetterRefinance__c;
        }
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Equity Release'))
        {
            congaTemplateId = prod.CongaOfferLetterEquityRelease__c;
        }        
        if(productswitch)
        {
            congaTemplateId = prod.Conga_Offer_Letter_Switch__c;
        }
        
    
        CongaSettings sett = new CongaSettings(congaTemplateId);                         
        string body= sett.CallConga(Opp.id,true);   
        
        if(sett.AttachmentId != null)
        {
            opp.Attachment_Offer_Letter__c= sett.AttachmentId;
            update opp;
        }      
        
        
        
        
        
        
        return null;
    }
    
    /*
    public string FisDocLink
    {
        get{
               List<IBBQuotation__c>  quote = [select id,Attachment_FIS__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];
               
               if(quote.size() == 0)
                   return null;
               
               if(quote[0].Attachment_FIS__c != null)
               {             
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + quote[0].Attachment_FIS__c+ '"><b>FIS</b></a>';
               }
            return null;      
            }
    }
    */
    /* CAT 00748212 start */
    public String KeyFactsLink
    {
        get
        {
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
        }
    }
   /* CAT 00748212 end */
    public string DocLink
    {
        get{   
            if(DocLinkCreated)                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + opp.Attachment_Offer_Letter__c+ '"><b>Offer Letter</b></a>';
            return '';      
            }
    }    
    
    public boolean DocLinkCreated
    {
    get{ 
        return opp.Attachment_Offer_Letter__c!= null;
        }
    }
    
     public PageReference Complete()
    {       
        try
        {
            update exopp;
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'eRROR ' + ex.getMessage()   );
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        
        
        CompleteEvent();
        
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        return GoToNextEvent();         
    }   
}