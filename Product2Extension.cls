public class Product2Extension {
	// Properties with automatic getters and setters
    public List<ProductWrapper> productsToInsert {get;set;}
	
    // default Constructor
    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            //productsToInsert.add( new Product2() );
            // Create a new Product2 object
            Product2 product = new Product2();
            // Create a new PricebookEntry object
            PricebookEntry pricebookEntry = new PricebookEntry();
            // Create a new ProductWrapper instance with the product and pricebook entry
            ProductWrapper wrapper = new ProductWrapper(product, pricebookEntry);
            productsToInsert.add(wrapper); // Add the wrapper to the list
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }
    
    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for (Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }
    public class ProductWrapper {
        public Product2 productRecord { get; set; }
        public PricebookEntry pricebookEntryRecord { get; set; }
        
        // Constructor
        public ProductWrapper(Product2 product, PricebookEntry pricebookEntry) {
            this.productRecord = product;
            this.pricebookEntryRecord = pricebookEntry;
        }
    }
    
    

    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();
        try {
            // Create lists to hold the records to be inserted
            List<Product2> productsToInsertList = new List<Product2>();
            List<PricebookEntry> pricebookEntriesToInsertList = new List<PricebookEntry>();
            for (ProductWrapper Wrapper : productsToInsert ){
                if(Wrapper.productRecord !=null && Wrapper.pricebookEntryRecord !=null) {
                    if(wrapper.productRecord.Name != null && wrapper.productRecord.Family != null && 
                       constants.SELECT_ONE != Wrapper.productRecord.Family && 
                       Wrapper.productRecord.Initial_Inventory__c != null && Wrapper.pricebookEntryRecord.UnitPrice != null ){
                           // Add Product2 record
                           productsToInsertList.add(wrapper.productRecord);
                           PricebookEntry pbe = Wrapper.pricebookEntryRecord;
                           pbe.IsActive = true;
                           pbe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                           pricebookEntriesToInsertList.add(pbe);
                       }
                }
                
            }
            insert productsToInsertList;
            for (integer i = 0; i < pricebookEntriesToInsertList.size(); i++) { 
                pricebookEntriesToInsertList[i].Product2Id = productsToInsertList[i].Id; 
            }
            
            insert pricebookEntriesToInsertList;
            

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
           Database.rollback(sp);
           apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        return null;
    }

}