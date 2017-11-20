public class CaseTriggerMethods
{
    @future (callout=true)
    public static void CreateISAProviderLetter(Id settingId, Id objectId, String session)
    {
        if(settingId == null || objectId == null) return;
        
        CongaSettings.CallCongaSession (settingId, objectId, session);  
    
        Trigger_Helper.TriggerItem itemOpp = new Trigger_Helper.TriggerItem();
        itemOpp.Name = 'Opportunity';
        itemOpp.IgnoreAudit = true;
        itemOpp.IgnoreTrigger = true;
    
    
        List<Case> c = [select id, Letter_generated__c from case where id=:objectId and Letter_generated__c = false limit 1];
        
        if(c.size() == 0) return;
        
        c[0].Letter_generated__c = true;
        update c;
    
          
    }
    
    public static Case_SLA__c GetSLAConfig(List<Case_SLA__c > slas, case c, string recordTypeName)
    {
        system.debug(slas + ' - ' + recordTypeName);
    
        //find based on status
        system.debug(c.status);
        if(c.status!=null){
            if(c.Sub_category_revised__c != null && c.Category_revised__c != null){
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c)
                                && string.isNotBlank(sla.Category__c)
                                && string.isNotBlank(sla.SubCategory__c)
                                && string.isNotBlank(sla.status__c)
                                && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c ) 
                                && sla.SubCategory__c.equalsIgnoreCase(c.Sub_category_revised__c)
                                && sla.status__c.equalsIgnoreCase(c.status)
                                )
                    {
                        return sla;
                    }            
                }
            }
            
            if(c.Category_revised__c != null)
            {
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c)
                                && string.isNotBlank(sla.Category__c)
                                && string.isNotBlank(sla.status__c)
                                && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c ) 
                                && sla.status__c.equalsIgnoreCase(c.status)
                                )
                    {
                        return sla;
                    }                      
                }
            }
            

            for(Case_SLA__c sla : slas)
            {
                if(string.isNotBlank(sla.Record_Type_Name__c)
                            && string.isNotBlank(sla.status__c)
                            && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName)
                            && sla.status__c.equalsIgnoreCase(c.status)
                            )
                {
                    return sla;
                }                      
            }
        }
        
        
        
            //find based on subcategory
            if(c.Sub_category_revised__c != null && c.Category_revised__c != null)
            {
                system.debug('looking for sub and cat');
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c)
                                && string.isNotBlank(sla.Category__c)
                                && string.isNotBlank(sla.SubCategory__c)
                                && string.isBlank(sla.Status__c)
                                && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c ) 
                                && sla.SubCategory__c.equalsIgnoreCase(c.Sub_category_revised__c)
                                
                                )
                    {
                        return sla;
                    }            
                }
            }
            
            //find based on subcategory
            if(c.Category_revised__c != null)
            {
                system.debug('looking for cat');
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c) && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) 
                        && string.isNotBlank(sla.Category__c) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c )
                        && string.isBlank(sla.Status__c))                            
                    {
                        return sla;
                    }            
                }
            }
            
            for(Case_SLA__c sla : slas)
            {
                system.debug('looking for record type');
                system.debug('comparing ' + sla.Record_Type_Name__c + ' and ' + recordTypeName);
                if(string.isNotBlank(sla.Record_Type_Name__c) && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName)
                    && string.isBlank(sla.Status__c))                            
                {
                    return sla;
                }            
            }
        
        system.debug('no match');
        return null;
    }
    
    
    /*C0569*/
    public static DateTime CalculateDueDateFromDays(DateTime createdDate,Integer daysToAdd){
        FCA_Reporting__c fcaData = FCA_Reporting__c.getInstance();
        Integer closeOfBusiness =  integer.valueof(fcaData.Out_Of_Hours__c); 
    
        Integer createdHour = createdDate.hour();    
        daysToAdd = createdHour > closeOfBusiness ? daysToAdd  : daysToAdd-1;
        
        DateTime endDate = createdDate;
        
        List<Holiday> holidays = [select ActivityDate from holiday];// where ActivityDate >: system.today() and ActivityDate <: system.today().addDays(20)];
        
        while ( daysToAdd > 0 ) 
        {
            DateTime checkDate = endDate.addDays(1);
            
            //system.debug('checking ' + checkDate);
            //system.debug('day to add ' + daysToAdd);
            
            String dayOfWeek=checkDate .format('EEEE');
            //system.debug(dayOfWeek);
            
            if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
            {
                Boolean isHoliday = false;
                //system.debug('checking holidays');
                for(Holiday h : holidays)
                {
                    //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                    if(h.activityDate == checkDate.Date())
                    {
                        isHoliday = true;
                        //system.debug('found holiday');
                        break;
                    }
                }
                
                if(!isHoliday)
                {
                    daysToAdd--;
                }
            }
            
            endDate = endDate.addDays(1);
        }
        return Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 19, 0, 0);
    }
    /*C0569*/

	/*C0640*/
	public static DateTime CalculateInternalSla()
	{
		BusinessHours bizHours = [select id from businesshours where isDefault = true];  
		Integer internalSlaHours = 4;
		Long internalSlaMilliSeconds = internalSlaHours * 60 * 60 * 1000;
		
		return BusinessHours.add(bizHours.id, Datetime.Now(), internalSlaMilliSeconds); 
	}

	public static void CreateInternalAudit(string caseId, string caseOwner, string caseOwnerDepartment, DateTime internalSla, DateTime slaDue)
	{
		Internal_Case_Audit__c audit = new Internal_Case_Audit__c();
		audit.Case__c = caseId;						
		audit.New_Owner__c = caseOwner;
		audit.Team__c = caseOwnerDepartment;
		audit.Time_Case_Assigned__c = DateTime.Now();

		if(internalSla != null)
		{
			audit.Action_Due__c = internalSla;
		}
		else {
			audit.Action_Due__c = CalculateInternalSla();
		}
		
		
		updateLastInternalAudit(caseId, internalSla, slaDue);
		insert audit;		
	}

	private static void updateLastInternalAudit(string caseId, DateTime internalSla, DateTime slaDue)
	{
		List<Internal_Case_Audit__c> audits = [select id,Time_Case_Assigned__c from Internal_Case_Audit__c where Case__c=:caseId order by CreatedDate desc limit 1];
		
		List<Internal_Case_Audit__c> breachedAudits = [select id,Time_Case_Assigned__c from Internal_Case_Audit__c where Case__c=:caseId and Breached_external_SLA__c=: true order by CreatedDate desc];

		if(audits.size() > 0)
		{
			audits[0].Time_Case_Moved__c = DateTime.Now();

			system.debug('Internal SLA ' + internalSla);
			system.debug('Breached Internal ' + (Datetime.now() > internalSla));
			system.debug('Breached External ' + (Datetime.now() > slaDue));

			if(Datetime.now() > internalSla)
			{
				audits[0].Breached_Internal_SLA__c = true;
			}

			if(Datetime.now() > slaDue && !(breachedAudits.size() > 0))
			{
				audits[0].Breached_external_SLA__c = true;
			}

			BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
			long timeInMilliseconds = BusinessHours.diff(bh.id,audits[0].Time_Case_Assigned__c,audits[0].Time_Case_Moved__c);
		    double hours = timeInMilliseconds/3600000;
			double minutes = timeInMilliseconds / 60000;

			double actualMinutes = minutes - (hours.round() * 60);
        	audits[0].Time_Taken__c = hours.round() + ':' + actualMinutes.round();

			system.debug('Time taken in milliseconds :' + timeInMilliseconds); 
			system.debug('Time taken :' + timeInMilliseconds/1000); 

			update audits;
		}
	}

	/*C0640*/

    public static DateTime CalculateDueDate(DateTime createdDate)
    {
        return  CalculateDueDateFromDays(createdDate,4);
    /*
        FCA_Reporting__c fcaData = FCA_Reporting__c.getInstance();
        Integer closeOfBusiness =  integer.valueof(fcaData.Out_Of_Hours__c); 
    
        Integer createdHour = createdDate.hour();    
        Integer daysToAdd = createdHour > closeOfBusiness ? 4  : 3;
        
        DateTime endDate = createdDate;
        
        List<Holiday> holidays = [select ActivityDate from holiday];// where ActivityDate >: system.today() and ActivityDate <: system.today().addDays(20)];
        
        while ( daysToAdd > 0 ) 
        {
            DateTime checkDate = endDate.addDays(1);
            
            //system.debug('checking ' + checkDate);
            //system.debug('day to add ' + daysToAdd);
            
            String dayOfWeek=checkDate .format('EEEE');
            //system.debug(dayOfWeek);
            
            if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
            {
                Boolean isHoliday = false;
                //system.debug('checking holidays');
                for(Holiday h : holidays)
                {
                    //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                    if(h.activityDate == checkDate.Date())
                    {
                        isHoliday = true;
                        //system.debug('found holiday');
                        break;
                    }
                }
                
                if(!isHoliday)
                {
                    daysToAdd--;
                }
            }
            
            endDate = endDate.addDays(1);
        }
        return Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 19, 0, 0);*/
    }

    //private static integer StartTime = 9;
    //private static integer EndTime = 17;
    private static List<Holiday> holidays {get;set;}

    //C0638 - Added a new parameter CategoryRevised to the method below
    public static DateTime CalculateSLADueDate(String CategoryRevised, DateTime createdDate, Case_SLA__c sla, integer percentage)
    {
        //List<RecordType> rts = [SELECT developername from RecordType WHERE id=:recordTypeId];
        
        //if(rts.size()==0) return null; //if we can't find the recordtype, exit the function 
    
        //Get the SLA settings for this record type
        //List<Case_SLA__c> sla = [SELECT SLA_Duration__c
        //                            FROM Case_SLA__c
        //                            WHERE name=:rts[0].developername];
        
        if(createdDate == null) createdDate = DateTime.Now();
        
		 //C0638
        if (sla.Record_Type_Name__c == 'Payments_Processing')
		{
				If (CategoryRevised == 'Suspended Transaction')
				{
					sla.SLA_Duration__c = 16;
				}
		}
        //if(sla.size() == 0) return null;
        if(holidays == null)
            holidays = [select ActivityDate from holiday];// where ActivityDate >: system.today() and ActivityDate <: system.today().addDays(10)];
        
        system.debug(sla);
		Integer HolidayCount = 0; //C0663
        Integer minutesToAdd = (sla.SLA_Duration__c * 60 * percentage/100).intValue();
        Integer minutesMax = (sla.EndTimeHour__c.intValue() * 60) + sla.EndTimeMinute__c.intValue();
        DateTime endDate = createdDate;        
        
        system.debug('minutes to add in total:' + minutesToAdd );
        
        DateTime StartOfFirstDay = DateTime.newInstance(endDate.Year(),endDate.Month(),endDate.Day(),sla.StartTimeHour__c.intValue(),sla.StartTimeMinute__c.intValue(),0);
        DateTime EndOfFirstDay = DateTime.newInstance(endDate.Year(),endDate.Month(),endDate.Day(),sla.EndTimeHour__c.intValue(),sla.EndTimeMinute__c.intValue(),0);
        
        if(endDate > EndOfFirstDay)
        {
            endDate = DateTime.newInstance(endDate.Year(),endDate.Month(),endDate.Day(),sla.StartTimeHour__c.intValue(),sla.StartTimeMinute__c.intValue(),0).addDays(1);
        }
        
        
        if(endDate < StartOfFirstDay)
            endDate = StartOfFirstDay;
            
           
        while ( minutesToAdd  > 0 ) 
        {            
            String dayOfWeek=endDate.format('EEEE');
            //system.debug(dayOfWeek);
            
            if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
            {
                Boolean isHoliday = false;
                //system.debug('checking holidays');
                for(Holiday h : holidays)
                {
                    //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                    if(h.activityDate == endDate.Date())
                    {
                        isHoliday = true;
						HolidayCount = HolidayCount + 1; //C0663
                        //system.debug('found holiday');
                        break;
                    }
                }
                
                if(!isHoliday)
                {
                    //Can add minutes to the current day
                    Integer minutesStart = (endDate.hour() * 60 ) + endDate.Minute();                    
                    Integer minutesEndOfDay = minutesMax - minutesStart;                    
                
                    //system.debug(endDate);
                    //system.debug('minutes left:' + minutesEndOfDay );
                    //system.debug('minutes to add' + minutesToAdd  );
                
                    if(minutesToAdd <= minutesEndOfDay)
                    {
                        //system.debug('last day');
                        //system.debug(endDate);
                        //system.debug('adding:' + minutesToADd);
                        
                        endDate = endDate.addMinutes(minutesToAdd);
                        //system.debug('new date:' + endDate);
                        minutesToAdd = 0;
                    }
                    else
                    {                        
                        minutesToAdd -= minutesEndOfDay;
                        DateTime nextDay = endDate.addDays(1);                        
                        endDate = DateTime.newInstance(nextDay.year(), nextDay.month(), nextDay.day(), sla.StartTimeHour__c.intValue(),sla.StartTimeMinute__c.intValue(),0);
                    }
                }
                else
                {
                   endDate = endDate.addDays(1); 
                }
            }
            else
            {
                endDate = endDate.addDays(1);
            }
        }
        
		 //C0663
        if (sla.Record_Type_Name__c == 'Complaint')
		{
 	          If (HolidayCount > 0)
                  {
                    endDate = endDate.addDays(-HolidayCount);
                    String ComplaintdayOfWeek = endDate.format('EEEE');
                		If (ComplaintdayOfWeek.equalsIgnoreCase('saturday'))
                        {
                            endDate = endDate.addDays(2);
                        }
						else if (ComplaintdayOfWeek.equalsIgnoreCase('sunday'))
                        {
 							endDate = endDate.addDays(1);
                        }
                 }
        }

        return endDate;
    }
    
    public static void UpdateWebFormStatus(List<Case> cases){
    List<Web_Form_Data__c> webForms = new List<Web_Form_Data__c>();
    Web_Form_Data__c webForm = new Web_Form_Data__c();
    try{
    for(Case cse : cases){
    if(cse.Web_Form_Data__c!=null){    
 
    webForm.Id=cse.Web_Form_Data__c;
    webForm.Status__c='Converted to case';
    webForms.add(webForm);  
    webForm = new Web_Form_Data__c();  
 
    }    
 
    }
    if(webForms.size() > 0)
    update webForms;
    }
    catch(Exception ex){
    throw ex;
    }
    }

}