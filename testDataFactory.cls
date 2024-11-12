/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup testGroup = new CollaborationGroup(Name = 'Test' + Constants.INVENTORY_ANNOUNCEMENTS,
                                                             CollaborationType = 'Public');
        return testGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> testProductList = new List<Product2>();
        for(integer i=0; i<cnt; i++){
            Product2 testProduct = new Product2(Name = 'Test ' + i,IsActive=True, Initial_Inventory__c = 10);
            //modular arithmetic e.g. Math.mod(5, 4) = 1; mod(4, 4) = 0;
            integer familyIndex = Math.mod(i, 4);
            testProduct.Family = Constants.PRODUCT_FAMILY[familyIndex].getValue();
            testProductList.add(testProduct);
        }
 
        return testProductList;
    }
    
    

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
    //  related to the provided Products
    //  with all the required fields populated
    //  and IsActive = true
    //  and belonging to the standard Pricebook
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> testPricebookEntryList = new List<PricebookEntry>();
        for(Product2 prod : prods){
            PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id = prod.id,
                                                                   Pricebook2Id= constants.STANDARD_PRICEBOOK_ID,
                                                                   IsActive=true, 
                                                                  UnitPrice = 10);
           testPricebookEntryList.add(testPricebookEntry);
        }
        return testPricebookEntryList;
        
    }


    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
       List<Account> testAccountList = new List<Account>();
        for (integer i=0;i<cnt; i++){
            Account testAccount = new Account(Name = 'Test Account' + i);
            testAccountList.add(testAccount);
        }
       return testAccountList;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> testContactList = new List<Contact>();
                   
            for (integer i=0; i<cnt; i++){
                integer acctIndex = Math.mod(i, accts.size());
                Contact testContact = new Contact(FirstName = accts.get(acctIndex).name + ' \'s', 
                                                 LastName = 'Contact ' + i,
                                                 AccountId = accts.get(acctIndex).id);
                testContactList.add(testContact);
                System.debug('Contact #' + i + ' FirstName: ' + testContact.FirstName);
                System.debug('Contact #' + i + ' LastName: ' + testContact.LastName);
            }
        
        return testContactList;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> testOrderList = new List<Order>();
        for (integer i = 0; i<cnt; i++){
            Order testOrder = new Order();
            testOrder.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            testOrder.Status = 'Draft';
            testOrder.EffectiveDate = Date.newInstance(2024, 02, 01);
            integer acctIndex = Math.mod(i, accts.size());
            testOrder.AccountId = accts.get(acctIndex).Id;
            testOrderList.add(testOrder);
        }
        return testOrderList;
 
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> testOrderItemList = new List<OrderItem>();
        for(integer i=0;i<cnt;i++){
            integer ordIndex = math.mod(i, ords.size());
            integer pbeIndex = math.mod(i,pbes.size());
            OrderItem testOrderItem = new OrderItem();
            testOrderItem.Quantity = Constants.DEFAULT_ROWS;
            testOrderItem.UnitPrice = 10;
            testOrderItem.OrderId = ords.get(ordIndex).Id;
            testOrderItem.PricebookEntryId = pbes.get(pbeIndex).Id;
            testOrderItemList.add(testOrderItem);
        }
        return testOrderItemList;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup groups = TestDataFactory.ConstructCollaborationGroup();
        insert groups;
        
        List<Product2>  products= TestDataFactory.ConstructProducts(cnt);
        insert products;
        
        List<PriceBookEntry> entries = TestDataFactory.ConstructPricebookEntries(products);
        insert entries;
        
        List<Account> accts = TestDataFactory.ConstructAccounts(cnt);
        insert accts;

        List<Contact> contacts = TestDataFactory.ConstructContacts(cnt,accts);
        insert contacts;

        List<Order> orders = TestDataFactory.ConstructOrders( cnt,  accts);
        insert orders;

        List<OrderItem> items = TestDataFactory.ConstructOrderItems(cnt, entries, orders);
        insert items;

    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        decimal totalOrdered = originalProduct.Quantity_Ordered__c + qtyOrdered;
        assert.areEqual(updatedProduct.Quantity_Ordered__c, totalOrdered );
    }


}