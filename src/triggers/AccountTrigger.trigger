trigger AccountTrigger on Account (after insert, after update, before insert, before update) 
{
    aLog.Logger log = new aLog.Logger('AccountTrigger');
    
try
{

   

    if(Trigger_Helper.IgnoreTrigger('Account'))
        return;   
    

    /*
    String ProfileId = UserInfo.getProfileId();
    String ProfileName = null;
    if (ProfileId != null)
    {
      //Profile usrProfile = [SELECT Id, Name from Profile WHERE Id =:ProfileId LIMIT 1];
      //ProfileName = usrProfile.Name;
    } 
    */ 
    //if (ProfileName != 'System Administrator')
    //  return;
      
    if (trigger.isBefore)
    {
        
        if (trigger.isInsert)
        {
            
        
            log.Trace('Trigger: Before Insert for Account :' + trigger.new[0].id);
            log.Trace('Calling Capitalize Account');
            AccountTriggerMethods.Capitalize(trigger.new);
            log.Trace('Populating District');
            AccountTriggerMethods.populateDistrict(trigger.new);
            
            DuplicateAccount__c mcs = DuplicateAccount__c.getValues('Default'); 
            if(mcs != null  )
            {
                log.Trace('Duplicate account record type :' + mcs.ExternalRecordType__c);
                system.debug('Record type compare : trigger=' + trigger.new[0].recordtypeId + ' config=' +  mcs.ExternalRecordType__c);
            
            
                //Only check for duplicates if the system is turned on, and the account record type is not the external HPPCAA record type                
                Boolean checkDuplicate = true;
                if(mcs.ExternalRecordType__c != null)
                {
                    log.Trace('Checking external record type ' + mcs.ExternalRecordType__c + ' against account ' + trigger.new[0].recordtypeid);
                    if(mcs.ExternalRecordType__c.equalsIgnoreCase(string.valueof(trigger.new[0].recordtypeid)))
                    {
                        checkDuplicate = false;
                    }
                }                
                
                if(mcs.no_allowed__c > -1 && checkDuplicate)
                {                
                    try
                    {                
                        log.Trace('Checking for duplicate on insert');
                        Account a = trigger.new[0];
                    
                    //we need date of birth and first name.last name for the check
                    if( a.date_of_birth__c != null 
                            && a.lastname != null && a.firstname != null)
                    {
                        if(a.name != null)
                        {
                            system.debug('Name to check : ' + a.name);
                            if(a.firstname.EqualsIgnoreCase('New') && a.lastname.equalsIgnoreCase('Account'))
                            {
                                //Liabilities account insert
                                log.Info('Checking for duplicate');
                                log.Trace('Account Data:');
                                log.Trace('Insert: FirstName: ' + a.firstName + ' LastName: ' + a.lastName + ' DOB: ' + a.date_of_birth__c );
                                AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
                            }
                        }
                        else
                        {
                            //HPP CAA internal insert
                            AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
                        }    
                    }
                  }
                  catch(Exception ex)
                  {
                      throw ex;
                  }
                }
            }
            
        }
        if (trigger.isUpdate)
        {
            log.Trace('Before Update Trigger for account :' + trigger.new[0].id);
            log.Trace('Calling Capitalize Account');
            AccountTriggerMethods.Capitalize(trigger.new);
        
            DuplicateAccount__c mcs = DuplicateAccount__c.getValues('Default'); 
            if(mcs != null  )
            {
                 Boolean checkDuplicate = true;
                if(mcs.ExternalRecordType__c != null)
                {
                    if(mcs.ExternalRecordType__c.equalsIgnoreCase(string.valueof(trigger.new[0].recordtypeid)))
                    {
                        checkDuplicate = false;
                        log.Trace('Skipping duplicate check because config record type ' +mcs.ExternalRecordType__c + ' matches account record type ' + trigger.new[0].recordtypeid );
                    }
                }
            
                if(mcs.no_allowed__c > -1 && checkDuplicate)
                {
                    try
                    {
                    Account a = trigger.new[0];
                    Account b = trigger.old[0];
                    
                    log.trace('Checking for a change of lastname, firstname or date of birth');
                    
                    if(a.firstname != null && b.firstname != null & a.lastname != null && b.lastname != null && a.date_of_birth__c != null && b.date_of_birth__c != null)
                    {                        
                        if(!a.firstname.equalsIgnoreCase(b.firstname) || !a.lastname.equalsIgnoreCase(b.lastname) || a.date_of_birth__c != b.date_of_birth__c)
                        {
                            //Name of date of birth has changed, check that it's not now a duplicate
                            if(b.firstname.EqualsIgnoreCase('New') && b.lastname.equalsIgnoreCase('Account'))
                            {                            
                                log.Info('Checking for duplicate');
                                log.Trace('Account Data:');
                                log.Trace('Before: FirstName: ' + b.firstName + ' LastName: ' + b.lastName + ' DOB: ' + b.date_of_birth__c );
                                log.Trace('After: FirstName: ' + a.firstName + ' LastName: ' + a.lastName + ' DOB: ' + a.date_of_birth__c );                                
                                AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
                            }
                        }
                    }
                    else
                    {
                        log.Trace('No change detected, skipping account duplicate check');
                    }
                    }
                    catch(Exception ex)
                    {
                        log.Fatal('Unexpected error',ex);
                        throw ex;
                    }
                }
            }
        
            AccountTriggerMethods.populateDistrict(trigger.new);
            
            
            Trigger_Helper.Audit('Account',trigger.oldMap, trigger.newMap);            
        }
    }
}
catch(Exception ex)
{
    log.Fatal('Unexpected Error',ex);
}    
    
    aLog.TriggerSave();
}