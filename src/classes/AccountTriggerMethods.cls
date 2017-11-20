public without sharing class AccountTriggerMethods 
{
    public static void Capitalize(List<Account> inAccs)
    {
        if(inAccs == null)
        return;
    
         // C0592 - Null check values before passing to function
		 for (Account a : inAccs)
         {
             if(a.firstname!=null)
			 {
				a.firstname = CapitalizeField(a.firstname);
			 }
			 if(a.lastname!=null)
			 {
				a.lastname= CapitalizeField(a.lastname);
			 }
			if (a.middle_name__pc!=null)
			{
				a.middle_name__pc= CapitalizeField(a.middle_name__pc);
			}
            if(a.BillingPostalCode!=null)
			{
				a.BillingPostalCode= UpperCaseField(a.BillingPostalCode);
			}
			if(a.ShippingPostalCode!=null)
			{
				a.ShippingPostalCode=UpperCaseField(a.ShippingPostalCode);
			}
			if(a.PersonMailingPostalCode!=null)
			{
				a.PersonMailingPostalCode= UpperCaseField(a.PersonMailingPostalCode);
			}
         }
    }
    
    public static String UpperCaseField(String obj)
    {
        if(obj == null)return obj;
        
        return obj.toUpperCase();
    }
    
    public static String CapitalizeField(String obj)
    {
        if(obj == null)return obj;
        
        return obj.capitalize();
    }

    public static void CheckDuplicate(Account inAcc, integer noAllowed)
    {
        List<Account> acc = [select firstname, lastname, middle_name__pc, date_of_birth__c from Account
                       where firstname =:inAcc.firstname and lastname =:inAcc.lastname 
                           and middle_name__pc =: inAcc.middle_name__pc
                           and date_of_birth__c =: inAcc.date_of_birth__c
                    ];
                    
                   
                    
        if(acc.size() >  noAllowed)
        {
            inAcc.addError('Duplicate account found.  Could not create account. ');
        }         
    }



      public static void populateDistrict(List<Account> inAccs)
      {
               
            String[] splitAddress;
            String splitChar = '\n';
            for (Account a : inAccs)
            {
                  if (a.BillingStreet != null)
                  {
                        string address = '';
                        if (a.BillingStreet.contains(splitChar))
                        {
                              splitAddress = a.BillingStreet.split(splitChar);
                         
                              a.BillingStreet = splitAddress[0];
                              a.Customer_Address_District__c = splitAddress[1];
                              //a.Customer_Address_Additional__c = splitAddress[2]; 
                              string additional = '';                              
                              
                              system.debug('In populateDistrict 1 ' + a.BillingStreet);
                              system.debug('In populateDistrict 2 ' + a.Customer_Address_district__c);
                              //system.debug('In populateDistrict 3 ' + a.Customer_Address_Additional__c);
                              
                              if(splitAddress.size() > 2)
                              {
                                additional = splitAddress[2];
                                system.debug('In populateDistrict 4 ');
                                for(integer j=0;j<splitAddress.size();j++)
                                {
                                    string addr = splitAddress[j];
                                    addr = addr.replace('\r','');
                                    
                                    address = address + addr + ' ';
                                } 
                                system.debug('In populateDistrict 3a ' + additional);
                                system.debug('In populateDistrict 5 ' + address);
                                a.BillingStreet = a.BillingStreet.replace('\r', '');
                                a.Customer_Address_district__c = a.Customer_Address_district__c.replace('\r', '');
                                a.BillingStreet = a.BillingStreet + ' ' + a.Customer_Address_district__c;
                                a.Customer_Address_district__c = additional;
                                
                                system.debug('In populateDistrict A ' + a.BillingStreet);
                                system.debug('In populateDistrict B ' + a.Customer_Address_District__c );  
                                //integer b = 1 / 0;
                                //a.Customer_Address_District__c = address;
                                integer num = a.BillingStreet.Length();
                                if (num > 32)
                                {
                                    a.BillingStreet = a.BillingStreet.Substring(0,32);
                                }
                                
                                num = a.Customer_Address_District__c.Length();
                                if (num > 32)
                                {
                                    a.Customer_Address_District__c = a.Customer_Address_District__c.Substring(0,32);
                                }
                               
                                
                                //system.debug('In populateDistrict A ' + a.BillingStreet);
                                //system.debug('In populateDistrict B ' + a.Customer_Address_District__c );  
                                //integer c = 1 / 0;                                                                               
                                
                                //Integer lastIndex=0; 
                                
                                //Find the last index of numbers 0-9
                                //for(Integer c = 0;c<10;c++)
                                //{
                                //    string s = string.valueOf(c);
                                //    integer index = address.lastIndexOf(s);
                                //    if( index> lastIndex)
                                //    {
                                //        lastIndex = index;
                                //    }
                                //}
                                
                                //if (lastIndex > 0)
                                //{
                                //    a.BillingStreet = address.substring(0,lastIndex + 1);
                                //    a.Customer_Address_District__c = address.substring(lastIndex + 1 ); 
                                //}
                                //else
                                //{
                                    
                                //    a.Customer_Address_District__c = address; 
                                //}
                                
                                //string billingStreet = a.BillingStreet;
                                //string districtAddress = a.Customer_Address_District__c;
                                //integer len = billingStreet.Trim().length();
                                //system.debug ('In populateDistrict A - ' + districtAddress);
                                //system.debug ('In populateDistrict B - ' + billingStreet);
                                //system.debug ('In populateDistrict C - ' + string.valueof(len));
                                //system.debug ('In populateDistrict D - ' + districtAddress.substring(0, billingStreet.Trim().length()));
                                
                                //if ( billingStreet.Length() < districtAddress.Length())
                                //{
                                //    if(districtAddress.substring(0, billingStreet.Trim().length()) == billingStreet.trim())  
                                //    {
                                       
                                //        a.Customer_Address_District__c = a.Customer_Address_District__c.substring(billingStreet.length());
                                //    }
                                //}
                                                   
                                                        
                              }                           
                        }
                  }
                  if (a.ShippingStreet != null)
                  {
                         string address = '';
                        if (a.ShippingStreet.contains(splitChar))
                        {
                              splitAddress = a.ShippingStreet.split(splitChar);
                              a.ShippingStreet = splitAddress[0]; 
                              a.Customer_Previous_Address_District__c = splitAddress[1];
                              string additional = ''; 
                              /*
                              for(Integer i = 2; i < splitAddress.size(); i++ )
                              {
                                    a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c + ', ' + splitAddress[i];
                              }
                              */
                              if(splitAddress.size() > 2)
                              {
                                additional = splitAddress[2];
                                for(integer j=0;j<splitAddress.size();j++)
                                {
                                    string addr = splitAddress[j];
                                    addr = addr.replace('\r','');
                                    
                                    address = address + addr + ' ';
                                }                                                                                   
                                
                                Integer lastIndex=0; 
                                //Find the last index of numbers 0-9
                                for(Integer c = 0;c<10;c++)
                                {
                                    string s = string.valueOf(c);
                                    integer index = address.lastIndexOf(s);
                                    if( index> lastIndex)
                                    {
                                        lastIndex = index;
                                    }
                                }
                                
                                a.ShippingStreet = a.ShippingStreet.replace('\r', '');
                                a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c.replace('\r', '');
                                a.ShippingStreet= a.ShippingStreet + ' ' + a.Customer_Previous_Address_District__c ;
                                a.Customer_Previous_Address_District__c = additional;
                                
                                
                                integer num = a.ShippingStreet.Length();
                                if (num > 32)
                                {
                                    a.ShippingStreet= a.ShippingStreet.Substring(0,32);
                                }
                                
                                num = a.Customer_Previous_Address_District__c.Length();
                                if (num > 32)
                                {
                                    a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c.Substring(0,32);
                                }
                                
                                /*
                                if (lastIndex > 0)
                                {
                                    a.ShippingStreet= address.substring(0,lastIndex + 1);
                                    a.Customer_Previous_Address_District__c = address.substring(lastIndex + 1 );  
                                }
                                else
                                {
                                    a.Customer_Previous_Address_District__c = address; 
                                } 
                                
                                string shippingStreet = a.ShippingStreet;
                                string districtAddress = a.Customer_Previous_Address_District__c;
                                
                                if ( shippingStreet.Length() < districtAddress.Length())
                                {
                                    if(districtAddress.substring(0, shippingStreet.Trim().length()) == shippingStreet.trim())  
                                    {
                                        a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c.substring(shippingStreet.length());
                                    } 
                                }
                                */                          
                              }                                
                        }
                  }
                  if (a.PersonMailingStreet != null)
                  {
                        string address = '';
                        if (a.PersonMailingStreet.contains(splitChar))
                        {
                              splitAddress = a.PersonMailingStreet.split(splitChar);
                              a.PersonMailingStreet = splitAddress[0];
                              a.Customer_Prev_Previous_Address_District__c = splitAddress[1];
                              string additional = ''; 
                              /*
                              for(Integer i = 2; i < splitAddress.size(); i++ )
                              {
                                    a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c + ', ' + splitAddress[i];
                              }  
                              */ 
                              if(splitAddress.size() > 2)
                              {
                                additional = splitAddress[2];
                                for(integer j=0;j<splitAddress.size();j++)
                                {
                                    string addr = splitAddress[j];
                                    addr = addr.replace('\r','');
                                    
                                    address = address + addr + ' ';
                                }  
                                
                                
                                a.PersonMailingStreet = a.PersonMailingStreet.replace('\r', '');
                                a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c.replace('\r', '');
                                a.PersonMailingStreet = a.PersonMailingStreet + ' ' + a.Customer_Prev_Previous_Address_District__c ;
                                a.Customer_Prev_Previous_Address_District__c = additional;
                                
                               
                                integer num = a.PersonMailingStreet .Length();
                                if (num > 32)
                                {
                                    a.PersonMailingStreet = a.PersonMailingStreet.Substring(0,32);
                                }
                                
                                num = a.Customer_Prev_Previous_Address_District__c.Length();
                                if (num > 32)
                                {
                                    a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c.Substring(0,32);
                                }
                                                                                                                 
                                
                                /*
                                Integer lastIndex=0; 
                                //Find the last index of numbers 0-9
                                for(Integer c = 0;c<10;c++)
                                {
                                    string s = string.valueOf(c);
                                    integer index = address.lastIndexOf(s);
                                    if( index> lastIndex)
                                    {
                                        lastIndex = index;
                                    }
                                }
                                if(lastIndex > 0)
                                {
                                    a.PersonMailingStreet = address.substring(0,lastIndex + 1);
                                    a.Customer_Prev_Previous_Address_District__c = address.substring(lastIndex + 1 );
                                } 
                                else
                                {
                                    a.Customer_Prev_Previous_Address_District__c = address;
                                }
                                
                                string mailingStreet = a.PersonMailingStreet;
                                string districtAddress = a.Customer_Prev_Previous_Address_District__c;
                               
                                if ( mailingStreet.Length() < districtAddress.Length())
                                {
                                    if(districtAddress.substring(0, mailingStreet.Trim().length()) == mailingStreet.trim())  
                                    {
                                        a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c.substring(mailingStreet.length());
                                    }
                                }
                                */  
                                                                
                              }                            
                        }
                  }
            }
      }

	  public static String UpdateEBSCustomer(Account acc, String webLogId)
	  {
		Debug__c log = new Debug__c();
		String processedResponse;
		
		System.debug('Account to update: ' + acc);
		  
		WebLogClass wlClass = new WebLogClass();
		List<Web_Integration_Log__c> webLogs = [Select AccountId__c, AccountwithIBBId__c, ApplicantId__c, AssetRelationshipId__c, CreatedById, CreatedDate, Debug_Log__c, IsDeleted, 
		  										IntegrationTaskPerformed__c, LastModifiedById, LastModifiedDate, OpportunityId__c, OwnerId, 
		  										ConnectionReceivedId, Id, Request_Action__c, Request_Body__c, Request_Log_Date_Time__c, Request_Object_Type__c, Request_Output__c, 
		  										Request_Status__c, Response_Action__c, Response_Body__c, Response_Log_Date_Time__c, Response_Message_Name__c, Response_Object_Type__c, 
		  										Response_Output__c, Response_Status__c, ConnectionSentId, SystemModstamp, Name from Web_Integration_Log__c Where Id =: webLogId];			  
		Web_Integration_Log__c webLog = webLogs[0];		  
		webLog.AccountId__c = acc.id;
		wlClass.webLogsToUpsert.add(webLog); 
		  
	  	Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', wlClass.webLogsToUpsert[0].Id);
        params.put('inId', acc.id);
        params.put('inObjectType', 'Account');
        params.put('inObjectResponseType', 'Account');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'MaintainCustomerDetails');
        params.put('inAction', 'MaintainCustomerDetails');
        params.put('inXmlMsgName', 'MaintainCustomerDetails');
        params.put('inXmlResponseMsgName', 'AddNewCustomerAllInformation');
        
        String returnString = WebServiceClass.sendRequest(params, wlClass, null, log);
		System.debug('UpdateEBSCustomer: Response - '  + returnString);
        if (returnString != null){
            processedResponse = OpportunityTriggerMethods.getStatusFromXML(returnString);
            //XMLMethods.sendResponseConfirmation(wlId, processedResponse, 'AddNewCustomer', wlClass);
        }
		
        System.debug('*** -- processedResponse = ' + processedResponse + ' -- ***');
        if ('FAILED'.equalsIgnoreCase(processedResponse))
		{
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS FAILED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
            //TODO: What to do in the event of a failure
        }
		else if ('BUFFERED'.equalsIgnoreCase(processedResponse))
		{
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS BUFFERED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
        }	
		
		return processedResponse;

	  }
}