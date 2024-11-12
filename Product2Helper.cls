public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id FROM CollaborationGroup 
        WHERE Name =: constants.INVENTORY_ANNOUNCEMENTS 
        OR Name = :('TEST'+ constants.INVENTORY_ANNOUNCEMENTS) 
        LIMIT 1];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        //ToDo: Declare a List of Product2 records named needsAnnouncement
        List<Product2> needsAnnouncement = new List<Product2>();

        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
        Map<String,Inventory_Setting__mdt> InventorySetting = new Map<String,Inventory_Setting__mdt>();
        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for (Inventory_Setting__mdt iSmdt: [SELECT MasterLabel,Low_Quantity_Alert__c FROM  Inventory_Setting__mdt]){
            InventorySetting.put(iSmdt.MasterLabel, iSmdt);
        }

        //ToDo: Loop through the Products in newList
        for(integer i=0;i<newList.size();i++){
            // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
            // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
            if(newList[i].Quantity_Remaining__c < InventorySetting.get(newList[i].Family).Low_Quantity_Alert__c &&
               oldList[i].Quantity_Remaining__c >= InventorySetting.get(newList[i].Family).Low_Quantity_Alert__c ){
                //add it to the needsAnnouncement list
                needsAnnouncement.add(newList[i]);  
            }
        }

        //ToDo: Pass records to the postAlerts method
        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            // ToDo: Construct a new AnnouncementInput for the Chatter Group.
            ConnectApi.AnnouncementInput newAlert = new ConnectApi.AnnouncementInput();
            // expires in a day
            newAlert.expirationDate = DateTime.now().addDays(1);
            // does not notify users via email.
            newAlert.sendEmails = false;
            // Create a MessageBodyInput object
            ConnectApi.MessageBodyInput messageBody = new ConnectApi.MessageBodyInput();
            //Announcement group ID.
            newAlert.parentId = COLLABORATION_GROUP[0].id;
            
            // Set the message body content
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = p.Name +'  '+ Constants.INVENTORY_LEVEL_LOW;
            messageBody.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            messageBody.messageSegments.add(textSegment);
                        
            // Set the body of the announcement
            newAlert.body = messageBody; // Assign the MessageBodyInput object
            
            toPost.add(newAlert);
        }
        // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
        AnnouncementQueueable annQue = new AnnouncementQueueable(toPost);
        system.enqueueJob(annQue);
    }
}