public with sharing class CaseHelperController {


    public list<String> caseRecordTypes{get;set;} //holds all the case record types that the logged-in user has access too

    public CaseHelperController(ApexPages.StandardController controller) {

       setAvailableRecordTypesForCase(Case.SObjectType);  
       
    }

    public void setAvailableRecordTypesForCase(Schema.SObjectType objType)     
    {
        caseRecordTypes = new list<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes
        if (infos.size() > 1) {
            for (RecordTypeInfo ri : infos) {
               if (ri.isAvailable() 
               // Ignore the Master Record Type, whose Id always ends with 'AAA'.
               // We check the Id because Name can change depending on the user's language.
                && !String.valueOf(ri.getRecordTypeId()).endsWith('AAA')) {
                  
                    addRecordTypeToList(ri.getName(),ri.getRecordTypeId());
                
                }
            }
        } else {// Otherwise there's just the Master record type, so add it in, since it MUST always be available
        
            addRecordTypeToList(infos[0].getName(), infos[0].getRecordTypeId());
        }
 
    }

    //converts record to json format and adds to list
    void addRecordTypeToList(String name, String id)
    {
        Map<String, String> recordTypeMap = new Map<String, String>();      
        recordTypeMap.put('name',name );
        recordTypeMap.put('id',id );
        caseRecordTypes.add(JSON.serialize(recordTypeMap));
    }

    @RemoteAction
    public static Contact getInternalStaffContact() { //returns the internal staff contact & associated account id

       List<Contact> contacts = [SELECT id, accountId FROM Contact where account.name = 'Al Rayan Bank Staff' and User_lookup__c =:UserInfo.getUserId() limit 1];
     
       if(contacts.size()>0){
       
          return contacts[0];  
       
       }else {      
           return null;
       }
    }
    
    @RemoteAction
    public static string getWebFormFieldIdOfCase() {     
    	WebFormFieldIdOnCase__c WebFormFieldIdOnCase = WebFormFieldIdOnCase__c.getValues('WebFormFieldIdOnCase');
    	if(WebFormFieldIdOnCase.WebFormFieldId__c!=null)
    		return WebFormFieldIdOnCase.WebFormFieldId__c;
    	else
        	return null;
    }
}