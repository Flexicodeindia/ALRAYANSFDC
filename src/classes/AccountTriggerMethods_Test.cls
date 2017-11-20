/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 2012-01-25 jba/dm - create
 */
@isTest
private class AccountTriggerMethods_Test
{
    
    private void Tests1()
    {
        List<Account> inAccs = new List<Account>();
        
        Account acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB';
        acc.ShippingStreet = 'A\nB';
        acc.PersonMailingStreet = 'A\nB';

        inAccs.add(acc); 
        
        AccountTriggerMethods.populateDistrict( inAccs );
    }
    
    private void Tests2()
    {
        List<Account> inAccs = new List<Account>();
        
        Account acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB\nC';
        acc.ShippingStreet = 'A\nB\nC';
        acc.PersonMailingStreet = 'A\nB\nC';

        inAccs.add(acc); 
        
        AccountTriggerMethods.populateDistrict( inAccs );
    }
    
    private void Tests3()
    {
        List<Account> inAccs = new List<Account>();
        
        Account acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB\n34 C';
        acc.ShippingStreet = 'A\nB\n34 C';
        acc.PersonMailingStreet = 'A\nB\n34 C';

        inAccs.add(acc); 
        
        AccountTriggerMethods.populateDistrict( inAccs );
    }
    
    static testMethod void testOne()
    {
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test(); 
        testable.Tests1(); 
    }
    
    static testMethod void testTwo()
    {
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test(); 
        testable.Tests2(); 
    }
    
    static testMethod void testThree()
    {
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test(); 
        testable.Tests3(); 
    }
}