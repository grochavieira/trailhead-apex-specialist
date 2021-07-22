public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    @future(callout=true)
    public static void syncInventoryEquipment() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            List<Object> inventory = (List<Object>) JSON.deserializeUntyped(response.getBody());
            
            System.debug('inventory => '+ inventory);

            List<Product2> productList = new List<Product2>();

            for (Object obj : inventory) {
                Map<String, Object> equipment = (Map<String,Object>) obj;
                Product2   prod               = new Product2();

                prod.Name                 = (String) equipment.get('name');
                prod.Replacement_Part__c  = (Boolean) equipment.get('replacement');
                prod.Current_Inventory__c = (Double) equipment.get('quantity');
                prod.Maintenance_Cycle__c = (Integer) equipment.get('maintenanceperiod');
                prod.Lifespan_Months__c   = (Integer) equipment.get('lifespan');
                prod.Cost__c              = (Decimal) equipment.get('cost');
                prod.Warehouse_SKU__c     = (String) equipment.get('sku');
                
                productList.add(prod);
            }

            if (!productList.isEmpty()) {
                upsert productList;
            }
        }
    }

    public static void execute(QueueableContext context){
        syncInventoryEquipment();
    }
}