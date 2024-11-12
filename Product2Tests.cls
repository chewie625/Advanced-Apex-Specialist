@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest
    private static void Product2Extension_UnitTest(){
        
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        // Create a mock StandardController
        ApexPages.StandardController controller = new ApexPages.StandardController(new Product2());
        
        Test.startTest();
        Product2Extension ext = new Product2Extension(controller);
        integer initialSize = ext.productsToInsert.size();
        
        // Assert initial size of productsToInsert list
        // 'Initial size should be equal to DEFAULT_ROWS'
        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS);
        ext.addRows();
        integer newSize = ext.productsToInsert.size();
        //new size should be equal to 2 * DEFAULT_ROWS
        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS * 2);
        List<Product2Extension.ProductWrapper> wrapperList = new List<Product2Extension.ProductWrapper>(ext.productsToInsert); 
        
        // Populate values for the first 5 records in the new list
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
                Product2Extension.ProductWrapper wrapper = wrapperList[i]; // Reference the inner class
                wrapper.productRecord.Name = 'Product ' + i;
                integer familyIndex = Math.mod(i, 4);
                wrapper.productRecord.Family = Constants.PRODUCT_FAMILY[familyIndex].getValue();
                wrapper.productRecord.Initial_Inventory__c = 10; // Set some inventory value
                wrapper.pricebookEntryRecord.UnitPrice = 100; // Set a price value
            }
        
            ext.save();
        Test.stopTest();
        // Verify that only populated products were saved
        List<Product2> savedProducts = [SELECT Id FROM Product2 LIMIT 10]; // Limit to check only recent products
        System.assertEquals(5, savedProducts.size(), 'Only 5 products should be saved');
    }

}