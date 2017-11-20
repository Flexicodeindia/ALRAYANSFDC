/* ---------------------------------------------------------------------------------------------- */
/* C00096 2013-10-16    Cater for non card payments                                               */
/*                      Check Internal Transfer Account Exists                                    */
/*                      No sort code displayed / captured                                         */
/*                      CHeck and do something with AJE errors                                    */
/* ---------------------------------------------------------------------------------------------- */
/* C00187 2014-04-02    Internal payments none doesn't save                                       */
/* ---------------------------------------------------------------------------------------------- */


public class HPPEventContactCustomerController extends HPPBaseEventController 
{
    public String BillingStreet {get;set;}
    public String BillingCity {get;set;}
    public String BillingCounty {get;set;}
    public String BillingPostCode {get;set;}
    public String BillingCountry {get;set;}
    public String ExternalComments {get;set;}
    public String NoneComments {get;set;}
    public Decimal ValuationContribution {get;set;}
    public static Decimal TotalValuationLeftToPay {get;set;}

	//C0638
	public String CaseTypeSelected {get;set;}
    public RecordType recTypeCase 
    {
        get 
        {
            if (recTypeCase == null){            
                recTypeCase = [select id from recordType where  sobjectType='case' and DeveloperName = 'Payments_Processing' limit 1];
            }
            return recTypeCase ;
        }
        set;
	}

		private static ID caseQueueID{
		get
		{
			List<QueueSobject> queues =  [SELECT QueueId
                                           FROM   QueueSobject
                                           WHERE  Queue.Name = 'Payments' LIMIT 1];                 
            if(queues.size()>0)
			{
				return queues[0].QueueId;
			}
			else
			{
				return null;
			}
		}
		set;
	}
    //
    /** This switch handles whether the CVC Security Code will be stored in the Database, 
     * or if a manual entry will be required each time. **/
    private final static Boolean REQUIRE_MANUAL_SECURITY_CODE_ENTRY = false;
    public Boolean PaymentTaken
    {
        get
        {
            return (String.isNotBlank(exOpp.ValuationFeeReceived__c) && exOpp.ValuationFeeReceived__c == 'Yes');
        }
    }   
    
    public HPPEventContactCustomerController() 
    {    
        CardData = new List<HPP_Data.CardData>();
      
        for(Card__c c : stSecureTrading_Cards.getSecureTradingCards(Acc.Id,Acc.PersonContactId))
        {
          HPP_Data.CardData card = new HPP_Data.CardData();
          card.CardId = c.id;
          card.CardNumber = c.name;
          card.CardType = c.Card_Type__c;
        
          CardData.add(card);
        }
    }
    
    public List<HPP_Data.CardData> CardData{get;set;}
    public String CardDataJson 
    {
        get{
            return Json.serialize(CardData);
        }
    }
    
    public String InternalAccounts
    {
        get
        {
            return Json.Serialize(HPPHelper.InternalAccounts(Acc.EBS_ID__c));        
        }       
    }

        
    @RemoteAction
    public static HPP_Data.GenericResponse TakeOtherPayment(ID oppID, HPP_Data.TakeOtherPaymentData data)
    {
        HPP_Data.TakePaymentResponse response = new HPP_Data.TakePaymentResponse ();
        
        Opportunity opp = [select id,name from opportunity where id=:OppId]; 
        HPP_extended_opportunity__c exOpp = [select id,name,ValuationFeeReceived__c,Admin_Fee_Received_Full__c,AdminFeeReceived__c,AdminFeeValue__c,Payment_Method__c,Date_admin_fee_paid__c,ValuationPrice__c,ValuationType__c  
                                          from HPP_extended_opportunity__c where opportunity__c =: OppId];
        
        Exopp.Payment_confirmed_by_other_method__c = data.ConfirmedOther;           
        if(string.isNotBlank(Exopp.ValuationFeeReceived__c) && Exopp.ValuationFeeReceived__c.equalsIgnoreCase('Yes'))
        {
            response.Errors.add('Payment has already been taken');        
            return response;
        }
        
        exOpp.Payment_Method__c = data.Method;
        exOpp.Payment_none_comments__c = data.NoneComments;
        exOpp.Other_payment_method__c = data.OtherPaymentMethod;
        exOpp.Payment_confirmed_by_other_method__c = false;
        
        HPPFinanceData.OverridePaymentMethod = data.Method.equalsIgnoreCase('Other') ? 'Other payment method' : data.Method;
        HPPFinanceData.OverrideOtherPaymentMethod = data.OtherPaymentMethod;
        
        
        if (data.Method.equalsIgnoreCase('Other') && data.OtherPaymentMethod.equalsIgnoreCase('Internal Transfer'))
        {
            if (string.isBlank(data.InternalAccount))
            {         
                response.Errors.add('No internal account number has been specified.');        
                return response;
            }
            else
            {
                exOpp.Other_payment_account_no__c = data.InternalAccount;
                HPPOpportunityMiddlewareMethods.OverrideInternalAccountPayment = data.InternalAccount;
            }
        }
        else if (data.Method.equalsIgnoreCase('None'))
        {
            exOpp.Payment_confirmed_by_other_method__c = true;
        }
        
        Actions.ActionAddJournalEntryValuation journalEntry = new Actions.ActionAddJournalEntryValuation();
        
        IBBEvents.CompleteEventArgs args;
        Boolean AJESuccess = true;
        if(!Data.Method.equalsIgnoreCase('None'))
        {    
            args = journalEntry.RunAction(OppId);
            AJESuccess = args.ReturnValue.equalsIgnoreCase ('SUCCESS');
        } 
       
        if (AJESuccess)
        {
            response.PaymentOk = true;
            exOpp.ValuationFeeReceived__c = 'Yes';
            //exOpp.Valuation_fee_amount__c = exOpp.ValuationPrice__c;
            exOpp.Valuation_fee_amount__c = TotalValuationLeftToPay;
            exOpp.Date_valuation_fee_paid__c = system.today();
            update exOpp;            
            response.AJEOk = true;
            response.Success = true;
        }
        else
        {
            response.Errors.add('The transaction has failed in EBS. ' + args.ErrorMessage);              
        }

        return response;    
    }    
    
    @RemoteAction 
    public static HPP_Data.TakePaymentResponse TakePayment(HPP_Data.TakePaymentData data)
    {
        HPP_Data.TakePaymentResponse response = new HPP_Data.TakePaymentResponse ();
        
        Opportunity opp = [select id,name, Initial_Payment_Amount__c from opportunity where id=:data.OppId]; 
        HPP_extended_opportunity__c exOpp = [select id,name,ValuationFeeReceived__c,Admin_Fee_Received_Full__c,AdminFeeReceived__c,AdminFeeValue__c,Payment_Method__c ,Date_admin_fee_paid__c,ValuationPrice__c,ValuationType__c
                                          from HPP_extended_opportunity__c where opportunity__c =: data.OppId];    
        
        if(string.isNotBlank(Exopp.ValuationFeeReceived__c) && Exopp.ValuationFeeReceived__c.equalsIgnoreCase('Yes'))
        {
            response.Errors.add('Payment has already been taken');        
            return response;
        }
        
        Card__c selectedCard = stSecureTrading_Cards.selectCard(data.SelectedCardId);
        exOpp.Payment_Method__c = 'Card';
        HPPFinanceData.OverridePaymentMethod = 'Card';

        //response = stSecureTrading_TakePayment.TakeInternalCardPayment(exOpp.ValuationPrice__c, selectedCard, opp, response,new Actions.ActionAddJournalEntryValuation());
        response = stSecureTrading_TakePayment.TakeInternalCardPayment(opp.Initial_Payment_Amount__c, selectedCard, opp, response,new Actions.ActionAddJournalEntryValuation());
        
        if(!response.success) return response;
        
        //If the payment was taken successfully we update the status on the opportunity, even if the AJE failed
        if(response.PaymentOk)
        {
            exOpp.ValuationFeeReceived__c = 'Yes';
            //exOpp.Valuation_fee_amount__c = exOpp.ValuationPrice__c;
            exOpp.Valuation_fee_amount__c = TotalValuationLeftToPay;
            exOpp.Date_valuation_fee_paid__c = system.today();
            update exOpp;
        }        
        return response;        
    }
    
    @RemoteAction
    public static HPP_Data.GenericResponse CompleteTheEvent(ID oppID, String eventLogId)
    {
        HPP_Data.GenericResponse response = new HPP_Data.GenericResponse();
        Boolean completeEvent = true;        
        
        if(!completeEvent) return response;
        
        String newEventUrl = HPPHelper.CompleteEvent(eventLogId);    
        if(!string.isBlank(newEventUrl))
        {
            response.Success = true;
            response.Url =  newEventUrl;
        }
        return response;
    }
    
    @RemoteAction
    public static HPP_Data.SaveNewCardResponse SaveCard(HPP_Data.CardData card)
    {
        return stSecureTrading_Cards.SaveCard(card,REQUIRE_MANUAL_SECURITY_CODE_ENTRY); 
    }
  
    @RemoteAction
    public static EncryptedCard selectEncryptedCard(String cardID) 
    {
        return stSecureTrading_Cards.selectEncryptedCard(cardID);
    }
    
	//C0638
	public PageReference CreateCase()
	{
		Case newcase = new Case();
		newcase.RecordTypeId = recTypeCase.Id;
		newcase.Origin = 'Salesforce';
		newcase.Category_revised__c = 'Suspended Transaction';
		newcase.Priority = 'Meduim';
		newcase.Referral_Decision__c = CaseTypeSelected;
		newcase.Opportunity__c = Opp.Id;
		newcase.Location_of_submitter__c = 'Head Office';
		newcase.Status = 'Awaiting Allocation';
		ID qID = caseQueueID;
		if(qID!=null)
		{
			newcase.OwnerId = qID;
		}

		if (CaseTypeSelected == 'Suspended-Cancel')
        {
            newcase.Sub_category_revised__c= 'Cancel Transaction';
			newcase.Subject = 'Suspended card payment should be cancelled';
        }
		else if (CaseTypeSelected == 'Suspended-Release')
        {
		    newcase.Sub_category_revised__c = 'Release Transaction';
			newcase.Subject = 'Suspended card payment should be Released';
		}

		insert newcase;
		return null;
	}

    public PageReference autoRun() {
        system.debug('HPPEventContactCustomerController.autoRun Entry');
        IBBDependentObjectFactory.CreateAJEStubsValuation(opp);
        
        
        //Check string values for quote characters
        
        if(exOpp.Payment_none_comments__c != null)
        {
            NoneComments = exOpp.Payment_none_comments__c.replace('\'','\\\'');
            ExternalComments = exOpp.Payment_none_comments__c.replace('\'','\\\'');
        }    
        
        if(Acc.BillingStreet != null)
            BillingStreet = Acc.BillingStreet.replace('\'','\\\'');
        if(Acc.BillingCity != null)
            BillingCity = Acc.BillingCity.replace('\'','\\\'');
        if(Acc.BillingState != null)
            BillingCounty = Acc.BillingState.replace('\'','\\\'');
        if(Acc.BillingPostalCode != null)
            BillingPostCode = Acc.BillingPostalCode.replace('\'','\\\'');
        if(Acc.BillingCountry != null)
            BillingCountry = Acc.BillingCountry.replace('\'','\\\'');
        
        
        // Logic to calculate Valuation fields
        Opportunity baseOpp = [SELECT Id, Initial_Payment_Amount__c, IBB_Product__r.Valuation_Type__c, IBB_Product__r.Valuation_Contribution_Amount__c, Valuation_Refund_Amount__c FROM Opportunity WHERE Id=:exOpp.Opportunity__c];

        if (baseOpp.IBB_Product__r.Valuation_Type__c == 'Waivered') {
            ValuationContribution = exOpp.ValuationPrice__c;
            TotalValuationLeftToPay = 0.0;
        }
        else if (baseOpp.IBB_Product__r.Valuation_Type__c == 'Discounted') {
            ValuationContribution = baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c;
            TotalValuationLeftToPay = exOpp.ValuationPrice__c - ValuationContribution;
            if (TotalValuationLeftToPay < 0) { TotalValuationLeftToPay = 0.0; } // Default negative values to 0
        }
        else {
            ValuationContribution = baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c;
            TotalValuationLeftToPay = exOpp.ValuationPrice__c;
        }

        baseOpp.Valuation_Refund_Amount__c = 0.0;
        if (baseOpp.IBB_Product__r.Valuation_Type__c == 'Refunded') {
            if (exOpp.ValuationPrice__c >= baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c) {
               baseOpp.Valuation_Refund_Amount__c = baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c;
            }
            else {
                baseOpp.Valuation_Refund_Amount__c = exOpp.ValuationPrice__c;
            }
        }

        if (!PaymentTaken) {
            // Update Opportunity
            baseOpp.Initial_Payment_Amount__c = TotalValuationLeftToPay;
            update baseOpp;
        }

        return null;
    }
}