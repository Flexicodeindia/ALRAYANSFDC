trigger CaseTrigger on Case (before update, before insert, after insert) 
{

if (Trigger_Helper.IgnoreTrigger('Case'))
    return;

    List<Id> lstOppIds = new List<Id>();
    Set<Id> setCasIds = new Set<Id>();
    Map<Id, Case> mapCasOpp = new Map<Id, Case>();
    List<Opportunity> liOpp = new List<Opportunity>();
    List<Case> liCases = new List<Case>();
    String ProfileId = UserInfo.getProfileId();
    String ProfileName = null;
    Boolean allApproved;
    Boolean allDeclined;
    
    try
    {
        RecordType complaintType = [select id from recordType where developername ='Complaint' and sobjectType='case' limit 1];
        
        Map<String,FCAReporting__c> fcaReporting=FCAReporting__c.getall();
        
        integer fcaWarn=integer.valueof(fcaReporting.get('FCA_Danger').value__c);
        integer fcaDanger=integer.valueof(fcaReporting.get('FCA_Warn').value__c);
        
        if(trigger.isBefore && trigger.isInsert)
        {
            for (Case c: Trigger.new){
                if(c.recordTypeId == complaintType.id){
                    c.FCA_Reportable_Date__c = CaseTriggerMethods.CalculateDueDate(system.now());
                    c.FCA_Date_Warn__c = Date.valueOf(CaseTriggerMethods.CalculateDueDateFromDays(system.now(),fcaWarn));
                    c.FCA_Date_Danger__c = Date.valueOf(CaseTriggerMethods.CalculateDueDateFromDays(system.now(),fcaDanger));
                }
                    
            }
        }
    }
    catch(Exception ex)
    {
       
    }
    
    
    
    if (ProfileId != null)
    {
     // Profile usrProfile = [SELECT Id, Name from Profile WHERE Id =:ProfileId LIMIT 1];
     // ProfileName = usrProfile.Name;
    }  
    //if (ProfileName != 'System Administrator')
    //  return;
    
    
    
   
   
    BusinessHours bizHours = [select id from businesshours where isDefault = true];            
    Map<String, Case_SLA__c> recordTypes= Case_SLA__c.getAll();            
    List<RecordType> recTypes = [select id,name,developername from recordtype where Developername in :recordTypes.keySet()];
          
     /* we don't need this as it's been replaced with a new version that takes into account bank holidays */      
     /*        
    //Calculate the datetime the SLA is due, based on minutes allowed during business hours        
    if(trigger.isUpdate && trigger.isBefore )
    {
        for (Case c: Trigger.new)
        {
            for(RecordType rt : recTypes)
            {
                if(rt.id == c.recordtypeid && c.Case_SLA__c != null)
                {
                    Integer minutes = c.Case_SLA__c.intValue();                
                      
                    c.SLA_Due__c = MyBusinessHours.AddMinutes(c.createddate,minutes);                
                    break;
                }                    
            }
        }    
    }  
    */  
    
    Map<ID,RecordType> caseRecTypes = new Map<ID,RecordType>( [select id,developername from recordtype where sObjectType='Case']);
    
    
    List<Case_SLA__c> lstSla = [SELECT name, SLA_Duration__c, StartTimeHour__c, StartTimeMinute__c, EndTimeHour__c, EndTimeMinute__c,SubCategory__c,Category__c,Record_Type_Name__c,Status__c FROM Case_SLA__c];
    if(trigger.IsBefore) //run for new cases and edited cases, if the slas date is null
    {   
        for (Case c: Trigger.new)
        {
            //if a date has already been calculated, we ignore it
            //if(c.SLA_Due__c != null) continue; 
        
            if(caseRecTypes.containsKey(c.recordTypeId))
            {               
                RecordType rt = caseRecTypes.get(c.recordTypeId);
                
                Case_SLA__c sla = CaseTriggerMethods.GetSLAConfig(lstSla,c,rt.developername);
                system.debug('SLA is ' + sla);
                if(sla == null) continue;
                
                
                //for(Case_SLA__c sla : lstSla )
                //{
                //    if(sla.name.equalsIgnoreCase(rt.developername))
                //    {
                //if this is a CASH ISA record type, check for 
                        if(c.SLA_Due__c == null)
                        {
                            system.debug('SLA is null, attempting to calculate a due date');
                            Datetime dt = c.createdDate == null ? Datetime.Now() : c.createdDate;
                            Long milliSeconds = 1000 * 60 * 60 * sla.SLA_Duration__c.longValue();
                        
                            //c.SLA_Due__c = BusinessHours.add(bizHours.id, dt, milliSeconds);
							//C0638 - Added c.Category_revised__c to all CalculateSLADueDate method below
                            c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c, c.createddate,sla, 100);
                            c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.createddate,sla, 75);
                            c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.createddate,sla, 90);
                        }
                        else if(rt.developername.equalsIgnoreCase('Cash_ISA') && c.Expected_date_of_Transfer__c != null)
                        {
                            //change the SLA to 8 * 3 hours
                            //sla.SLA_Duration__c = 24;
                            c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.Expected_date_of_Transfer__c ,sla, 100);
                            c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.Expected_date_of_Transfer__c ,sla, 75);
                            c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.Expected_date_of_Transfer__c ,sla, 90);
                        }
                        else if(!rt.developername.equalsIgnoreCase('Cash_ISA') && c.Date_to_be_actioned__c != null){
                            c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.Date_to_be_actioned__c ,sla, 100);
                            c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.Date_to_be_actioned__c ,sla, 75);
                            c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.Date_to_be_actioned__c ,sla, 90);
                        }
                        else{
                            //same as SLA due = null, first if statement
                            Datetime dt = c.createdDate;
                            Long milliSeconds = 1000 * 60 * 60 * sla.SLA_Duration__c.longValue();
                        
                            //c.SLA_Due__c = BusinessHours.add(bizHours.id, dt, milliSeconds);
                            c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.createddate,sla, 100);
                            c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.createddate,sla, 75);
                            c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.Category_revised__c,c.createddate,sla, 90);
                        }			
                        
                        break;
                    //}
                //}
                               
            }

			
        }
    }
    
    
    
    //TODO: need to refactor this
    if(trigger.isAfter && trigger.isInsert)
    {
    
        system.debug('creating document after insert');
    
        Map<String,ISA_Provider_Address__c> addresses = ISA_Provider_Address__c.getall();
    
        for (Case c: Trigger.new){
    
    
        if(string.isNotBlank(c.ISA_transfer_in_out_account_number__c) && !c.Letter_generated__c)
                {
                    if(addresses.containsKey('DocuGen Setting Name'))
                    {                
                        List<congasettings__c> lstSetting= [select id from congasettings__c where name =:addresses.get('DocuGen Setting Name').address__c limit 1];
                        
                        if(lstSetting.size() == 1)
                        {
                            CaseTriggerMethods.CreateISAProviderLetter(lstSetting[0].id, c.id, UserInfo.getSessionId());
                        }
                    }
                }
                
            }
            CaseTriggerMethods.UpdateWebFormStatus(trigger.new);
    }
    
    //update ISA provider address
    if(trigger.isBefore && trigger.isUpdate)
    {
        Map<String,ISA_Provider_Address__c> addresses = ISA_Provider_Address__c.getall();
    
        for (Case c: Trigger.new){
            if(string.isNotBlank(c.ISA_Provider__c))
            {
                if(addresses.containsKey(c.ISA_Provider__c))   
                    c.ISA_Provider_Address__c = addresses.get(c.ISA_Provider__c).address__c.replace('BR()','\n');   
                    
                if(string.isNotBlank(c.ISA_transfer_in_out_account_number__c) && !c.Letter_generated__c)
                {
                    if(addresses.containsKey('DocuGen Setting Name'))
                    {                
                        List<congasettings__c> lstSetting= [select id from congasettings__c where name =:addresses.get('DocuGen Setting Name').address__c limit 1];
                        
                        if(lstSetting.size() == 1)
                        {
                            if(c.id != null)
                            {
                                c.Letter_generated__c = true;
                                CongaSettings.CallCongaFuture(lstSetting[0].id, c.id, UserInfo.getSessionId());
                            }
                        }
                    }
                }
            }
        }
    }
      
    if(trigger.isBefore){
        if(trigger.isUpdate){
            Trigger_Helper.Audit('Case',trigger.oldMap, trigger.newMap);		
      
		/*C0640*/
		try
		{
		// Do not create internal SLA Audit for cases created before this date - 20th Oct 2017	

		 for (Case c: Trigger.new)
		 {
			DateTime thresholdDate = DateTime.newInstance(2017, 10, 20);
				
			if((c.CreatedDate != null && c.CreatedDate > thresholdDate) && (Datetime.now() > thresholdDate))
			{
				for(Integer i = 0; i < Trigger.new.size(); i++)
				{
					String beforeValue = trigger.old[i].Case_Owner__c;
					String afterValue = trigger.new[i].Case_Owner__c;

					System.debug('Case Owner C before: ' + beforeValue + ' after: ' + afterValue);

					if( (afterValue != null) &&
					 (beforeValue == null || (beforeValue != null  && !beforeValue.equalsIgnoreCase(afterValue))))
					 {
						System.debug('Creating internal audit log for case: ' + trigger.new[i].id );
						c.Internal_SLA__c = CaseTriggerMethods.CalculateInternalSla();
						CaseTriggerMethods.CreateInternalAudit(c.Id,
						 trigger.new[i].Case_Owner__c,
						 trigger.new[i].Case_Owner_Department__c,
						 trigger.old[i].Internal_SLA__c,
						 c.SLA_Due__c);	
					}
				}
			}	
		  }
		}
		
		catch(Exception e)
		{ 
			system.debug('Error creating Internal Audit Logs'); 
		}

		/*C0640*/
		}



        //if(trigger.isInsert)
        {
            //------------------------------------------------------------------
            //Fetch Entitlement based on Contact and populate into Entitlemeny field
            //set<ID> ids = Trigger.new.keySet(); //weird! this line is not compiling
            List<Id> liIds = new List<Id>();
            
            for (Case c: Trigger.new){
                if (c.Legacy_Data_Load__c == false)
                {
                   liIds.add(c.accountId);
                   
                   if(trigger.isUpdate) 
                   {
                     lstOppIds.add(c.Opportunity__c);
                     setCasIds.add(c.Id);
                     mapCasOpp.put(c.Opportunity__c,c);
                   }  
                }                
                
                
                
                if(c.ClosedDate != null && c.Total_Resolution_Time__c == null)
                {
                    Long miliseconds = BusinessHours.diff(bizHours.Id, c.CreatedDate, c.ClosedDate);    
                                Long minutes = miliseconds/1000/60;
                            
                                c.Total_Resolution_Time__c = minutes;                
                }
                
                
                
                //update duration
                if(c.ClosedDate != null && c.SLA_Due__c != null )
                {
                    for(RecordType rt : recTypes)
                    {
                        if(rt.id == c.recordtypeid)
                        {
                            Long milliSecondsOver = BusinessHours.diff(bizHours.Id, c.SLA_Due__c, c.ClosedDate);
                            Long hoursOver = milliSecondsOver/1000/60/60;
                            //c.Hours_Past_SLA__c = hoursOver;
                            
                            system.debug('hoursOver:' +hoursOver  );
                            
                            decimal minutesLEft = (milliSecondsOver/1000/60) - (hoursOver * 60);
                            decimal mins = minutesLEft ;
                            
                            c.Hours_Past_SLA__c = hoursOver;
                            
                            if(mins > 0)
                                c.Hours_Past_SLA__c += (100/mins);
                                 
                            break;
                        }                    
                    }             
                }                
            }
            if (liIds.size()==0) return;
            List<Entitlement> liEnt = [select id,accountid from Entitlement where AccountId in :liIds];
            for(Case c: Trigger.new){
                for(integer i=0; i<liEnt.size();i++){
                    if(liEnt.get(i).accountId == c.accountId)
                    {
                        c.EntitlementId = liEnt.get(i).Id;
                    }
                }    
            }
            //------------------------------------------------------------------
            
            //Check for the date
            for(Case c: Trigger.New)
            {
                DateTime dt = IBBUtil.GetNextBusinessDay(integer.valueOf(c.SSDT__c),DateTime.now());
                c.SSDT1__c = dt;
                system.debug('ss##'+c.SSDT__c + '-' + dt + '-' +c.CreatedDate);
            }
            
            
        }
        if(trigger.isUpdate){
          //Update Account Referred if case status = 
          //if (c.Status == 'Approval Rejection' || c.Status == 'Approved' || c.Status == 'Rejected' )
          liOpp = [select id,accountid,Status_HPP_CAA__c from Opportunity where Id in :lstOppIds and (StageName = 'Account Referred' or Status_HPP_CAA__c='Account Referred')];
          liCases = [select id, Referral_Decision__c, Opportunity__c from Case where Opportunity__c in :lstOppIds and Opportunity__c != null];
          if (liOpp != null && liOpp.Size() > 0)
          {
            for (Opportunity opp: liOpp)
            {
              system.debug('** Cas status **' + mapCasOpp.get(opp.Id).Referral_Decision__c);
              allApproved = (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Accept'); 
              allDeclined = (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Decline');  
              if (liCases != null && liCases.size() > 0)
              {
                for (Case cas: liCases)
                {
                  if (cas.Opportunity__c == opp.Id && !setCasIds.contains(cas.Id) )
                  {
                    allApproved = (cas.Referral_Decision__c == 'Accept') && allApproved; 
                    allDeclined = (cas.Referral_Decision__c == 'Decline') && allDeclined;
                  }
                } 
                //if (allApproved){ opp.StageName = 'Account Approved'; 
                //if (allDeclined) opp.StageName = 'Account declined';
                if (allApproved) opp.Status_HPP_CAA__c = 'Account Approved'; 
                if (allDeclined) opp.Status_HPP_CAA__c  = 'Account declined';
              }
              else
              {
               if (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Accept')
                   opp.Status_HPP_CAA__c   = 'Account Approved';
                  //opp.StageName = 'Account Approved';
               //else if (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Decline') opp.StageName = 'Account declined';  
               else if (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Decline') opp.Status_HPP_CAA__c  = 'Account declined';  
              }
            }
            update liOpp;
          }
          
        }
             // populate the case owner custom lookup
            for(Case c : trigger.new){
                  if(c.OwnerId != null){
                    String caseOwnerId = c.OwnerId;
                    if(caseOwnerId.startsWith('005')){
                        c.Case_Owner__c = c.OwnerId;
                    }
                  }
            }   
     }
    
 
}