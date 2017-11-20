public class IBBUtil{

    static List<BusinessHours> liStdBusHrs = [select id from businesshours where isDefault = true];
    public static DateTime GetNextBusinessDay(integer paramDay, DateTime paramDateTime){
    	System.debug('*** -- Into GetNextBusinessDay with paramDay = ' + paramDay + ' -- ***');
       DateTime dt;
       system.debug('##GetNextBusinessDay'+ paramDateTime);
       dt = BusinessDay(paramDay, paramDateTime); 
       return dt;
    }
    
    private static DateTime BusinessDay(integer day, DateTime paramDateTime){
        dateTime dt = paramDateTime; 
        system.debug('## BusinessDay day='+day+' dt='+ dt + ' paramDateTime='+ paramDateTime);
        boolean isBuDay = false;
        
        if ( day==null )
        {
        	date now = datetime.now().date();
        	system.debug(now);
        	date weekStart = now.toStartofWeek();
        	system.debug(weekStart);
        	
        	day = now.daysBetween(weekStart);
        	system.debug(day);
        	day = weekStart.daysBetween(now);
        	system.debug(day);
        	
        	/* because weekStart returns the MONDAY ! */
        	day++;
        	if ( day >= 7 ) day -= 7; // day %= 7;
        	 
        	system.debug(' DAY WAS NULL - DEFAULTING FROM SYSTEM!! day= '+day);        	
        }
        
        if (day==0){
            //dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+1, 17,0,0);
            if (!IsHoliday(dt.Date()+1)){
                dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+1, 17,0,0);
            }
            else if (!IsHoliday(dt.Date()+2)){
                dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+2, 17,0,0);
            }
        }
        else if (day==6){
            //dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+1, 17,0,0);
            if (!IsHoliday(dt.Date()+2)){
                dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+2, 17,0,0);
            }
            else if (!IsHoliday(dt.Date()+3)){
                dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+3, 17,0,0);
            }
        }
        else{
        	
        	system.debug(' WEEKDAY, NOT 0 OR 6 ');
            if (!IsHoliday(dt.Date())){
            	
        		system.debug(' dt.hour()='+dt.hour());
            	if ( dt.hour() >= 17 ) // If after 17:00 then needs to be "next working day"
            	{
            		integer nextday = ( day == 5 ) ? 3 : 1; // If now Friday, skip 2 extra days
            		
        			system.debug(' initial nextday='+nextday);
            		while ( IsHoliday(dt.Date()+nextday) )
            		{
            			nextday++;
            			
            			// FOR DEBUGING - SAFETY NET
            			if ( nextday > 7 ) break;
            		}
        			system.debug(' final nextday='+nextday);
                	dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+nextday, 17,0,0);            		
            	}
            	else
            	{
                	dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day(), 17,0,0);
            	}
            }
            else if (!IsHoliday(dt.Date()+1)){
                dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+1, 17,0,0);
            }
            else if (!IsHoliday(dt.Date()+2)){
                dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()+2, 17,0,0);
            }
            //dt = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day(), 17,0,0);
        }
        return dt;   
        /*if ((day==0) && (liStdBusHrs[0].SundayStartTime!=null)){
            isBuDay = true;
            }
        else if ((day==1) && (liStdBusHrs[0].MondayStartTime!=null)){
            isBuDay = true;
            }    
        else if ((day==2) && (liStdBusHrs[0].TuesdayStartTime!=null)){
            isBuDay = true;
            }
        else if ((day==3) && (liStdBusHrs[0].WednesdayStartTime!=null)){
            isBuDay = true;
            }
        else if ((day==4) && (liStdBusHrs[0].ThursdayStartTime!=null)){
            isBuDay = true;
            }
        else if ((day==5) && (liStdBusHrs[0].FridayStartTime!=null)){
            isBuDay = true;
            }
        else if ((day==6) && (liStdBusHrs[0].SaturdayStartTime!=null)){
            isBuDay = true;
            }
        */            
        //return isBuDay;
    }
    
    private static boolean IsHoliday(Date paramDate){
        boolean isHoliday = false;
        integer i=0;
        List<Holiday> liHolidays= [select ActivityDate from holiday];
        /*if (liHolidays.contains(paramDate)){
            isHoliday = true;
        }*/
        for (Holiday holi: liHolidays){
            if (holi.activityDate==paramDate){
                i = i+1;
                system.debug('holi#'+holi.activityDate);
            }
        }
        if (i>0){
           isHoliday=true; 
        }
            
        return isHoliday;             
    }


}