@isTest (seeAllData=false)
private class OrderTests {
    
    @testSetup 
    private static void SetupTestData(){
        TestDataFactory.InsertTestData(5);
    }
    @isTest
    private static void OrderUpdate_UnitTest(){
        Test.startTest();
        List<Order> orderToActive = [SELECT Id, Name, Status FROM Order];
        for (Order o : orderToActive){
            OrderItem oirec = [SELECT Id, Pricebookentry.product2Id FROM orderitem where orderid=:o.id];
            Product2 p = [SELECT Family,Id,Name,Quantity_Ordered__c,Quantity_Remaining__c                                   
                                   FROM Product2 WHERE id =: oirec.Pricebookentry.product2Id  limit 1];
            o.status = Constants.ACTIVATED_ORDER_STATUS;
            update o;
            OrderItem oirec1 = [SELECT Id, Pricebookentry.product2Id FROM orderitem WHERE orderid=:o.id];
			Product2 updatedProduct = [SELECT Family,Id,Name,Quantity_Ordered__c,Quantity_Remaining__c 
                            	   FROM Product2 where id =: oirec1.Pricebookentry.product2Id  limit 1]; 
            // Call VerifyQuantityOrdered to validate the increase
            TestDataFactory.VerifyQuantityOrdered(p, updatedProduct, constants.DEFAULT_ROWS);
        }
        Test.stopTest();
        }

    }