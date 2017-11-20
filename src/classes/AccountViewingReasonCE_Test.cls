//2012-01-24 f4c jba/pj : Test methods for AccountViewingReasonCE
@isTest
private class AccountViewingReasonCE_Test {
    /*
    private static testMethod void TestOne() {
        Recordtype rtyp = [
            SELECT Id 
            FROM RecordType
            WHERE SObjectType = 'Opportunity'
                AND DeveloperName = 'Liabilities_Opportunites'
        ];
        
        String recTypeId = rtyp.Id;
        
        Account acc;
        try {
            acc = [
                SELECT FirstName, LastName, BillingPostalCode, Title_Other__c, EBS_ID__c
                FROM Account
                WHERE EBS_ID__c = '401304'
                LIMIT 1
            ];
        }
        catch (exception e) {}
        
        if (acc == null) {
            acc = new Account(
                FirstName = 'Test Account', LastName = 'Test Account', BillingPostalCode = 'Test Account',
                Title_Other__c = 'xyz', EBS_ID__c = '401304'
            );
            insert acc;
        }
          
        Account acc2 = new Account(
            FirstName = 'Test Account', LastName = 'Test Account', BillingPostalCode = 'Test Account',
            Title_Other__c = 'xyz', EBS_ID__c = ''
        );
        insert acc2;
            
        String accountId = acc.Id;
        String accountId2 = acc2.Id;
        
        List<Alert__c> LstAlerts = new List<Alert__c>();
        Alert__c alertRecord1 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='Security',Prospect_Customer__c =acc.Id, Active__c = true
        );
        Alert__c alertRecord2 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='Warning',Prospect_Customer__c =acc.Id, Active__c = true
        );
        Alert__c alertRecord3 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='General',Prospect_Customer__c =acc.Id, Active__c = true
        );
        Alert__c alertRecord4 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='blah',Prospect_Customer__c =acc.Id, Active__c = true
        );
        LstAlerts.add(alertRecord1);
        LstAlerts.add(alertRecord2);
        LstAlerts.add(alertRecord3);
        LstAlerts.add(alertRecord4);
        insert LstAlerts;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        AccountViewingReasonCE avr = new AccountViewingReasonCE (stdController);
        avr.IsTestRun = true;
        
        String srtgetProfileName = avr.getProfileName();
        Boolean boolgetnotPortalUser = avr.getnotPortalUser();
        PageReference PRautoRedirectPage = avr.autoRedirectPage();
        
        Audit__c objAudit = new Audit__c (
            Prospect_Customer__c = acc.Id, Field_Updated__c = 'Record Access Reason', Updated_By__c = Userinfo.getUserId()
        );
        insert objAudit;                                  
        
        PRautoRedirectPage = avr.autoRedirectPage();
        PageReference PRsubmitReason = avr.submitReason();
        PageReference PRfetchImages = avr.fetchImages();
        String sigImg = avr.getSignatureImage();
        avr.getAccountAndSignatureImages();
        String strgetImageAndSignature = avr.getImageAndSignature(accountId);
        strgetImageAndSignature = avr.getImageAndSignature(accountId2);
        String xmlString = '<?xml version="1.0" encoding="ISO-8859-1"?><statusCode>1</statusCode>';
        String strgetStatusFromXML = AccountViewingReasonCE.getStatusFromXML(xmlString);
        xmlString = '<?xml version="1.0" encoding="ISO-8859-1"?><statusCode>5</statusCode>';
        strgetStatusFromXML = AccountViewingReasonCE.getStatusFromXML(xmlString);
        xmlString = '<?xml version="1.0" encoding="ISO-8859-1"?><statusCode>7</statusCode>';
        strgetStatusFromXML = AccountViewingReasonCE.getStatusFromXML(xmlString);
    }

    private static testMethod void TestTwo() {   
        //  Recordtype rtyp = [SELECT id from RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Liabilities_Opportunites'];
        //  String recTypeId = rtyp.Id;
        Account acc = new Account(
            FirstName = 'Test Account', LastName = 'Test Account', BillingPostalCode = 'Test Account', 
            Title_Other__c = 'xyz'
        );
        insert acc;
        
        IBB_Product__c ibbProd = [
            SELECT Id 
            FROM IBB_Product__c 
            LIMIT 1
        ];
        
        string ibbProductSelected = ibbProd.Id;
        //  Opportunity theOpp = new Opportunity(AccountId=acc.Id,Name='TEST',RecordTypeId=recTypeId,StageName='Enquiry from the Customer',CloseDate=Date.Today(),IBB_Product__c=ibbProductSelected );
        //  insert theOpp;
        //  String oppid = theOpp.Id;
        
        String UserId = UserInfo.getUserId();
        String UserDivision;
        if (UserId != null) {
            User usr = [
                SELECT Id, IBB_Division__c 
                FROM User 
                WHERE Id = :UserId
            ];
            UserDivision = usr.IBB_Division__c;
        }
        
        String pageURL = '/apex/AccountViewingReason';
        PageReference pageRef = new PageReference(pageURL);
    }
    */
    
    private static List<Account> accounts;
    private static List<Audit__c> audits;
    
    private static void setupTestData(Boolean auditHistory) {
        accounts = new Account[] {
            new Account(
                Name = 'Account 01'
            )
        };
        insert accounts;
        
        if (auditHistory) {
            audits = new Audit__c[] {
                new Audit__c(
                    Prospect_Customer__c = accounts[0].Id, Field_Updated__c = 'Record Access Reason', Updated_By__c = UserInfo.getUserId()
                )
            };
            insert audits;
        }
    }
    
    /*
    private static testMethod void testWithoutAuditHistory() {
        setupTestData(false);
        
        PageReference accountViewingPage = Page.AccountViewingReason;
        accountViewingPage.getParameters().put('id', accounts[0].Id);
        Test.setCurrentPage(accountViewingPage);
        
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(accounts[0]);
        AccountViewingReasonCE controller = new AccountViewingReasonCE(stdController);
        controller.IsTestRun = true;
        controller.submitReason();
        controller.fetchImages();
        
        Test.stopTest();
        
        System.assertNotEquals(controller.lastAudit, null);
        System.assertNotEquals(controller.lastViewedBy, null);
    }
    
    private static testMethod void testWithAuditHistory() {
        setupTestData(true);
        
        PageReference accountViewingPage = Page.AccountViewingReason;
        accountViewingPage.getParameters().put('id', accounts[0].Id);
        Test.setCurrentPage(accountViewingPage);
        
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(accounts[0]);
        AccountViewingReasonCE controller = new AccountViewingReasonCE(stdController);
        controller.IsTestRun = true;
        controller.submitReason();
        controller.fetchImages();
        
        try {
            String xmlStatus = AccountViewingReasonCE.getStatusFromXML(controller.imageString);
        }
        catch (Exception ex) {
            System.debug('Unable to parse Test XML String.');
        }
        
        Test.stopTest();
        
        System.assert(controller.lastAudit != null);
        System.assert(controller.lastViewedBy != null);
    }
    */
}