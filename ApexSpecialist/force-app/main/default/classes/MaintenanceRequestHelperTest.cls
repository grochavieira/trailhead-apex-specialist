@isTest
public with sharing class MaintenanceRequestHelperTest {
    @TestSetup
    static void setup(){
        List<Vehicle__c> vehicleList = new List<Vehicle__c>();
        Vehicle__c vehicle = new Vehicle__c(
            Name = 'Vehicle test'
        );

        vehicleList.add(vehicle);
        insert vehicleList;

        List<Case> maintenanceRequestList = new List<Case>();
        Case maintenanceRequest = new Case(
            Type             = 'Routine Maintenance',
            Vehicle__C       = vehicle.Id,
            Date_Reported__c = System.today(),
            Date_Due__c      = System.today().addDays(10),
            Subject          = 'test subject',
            Status           = 'New',
            Origin           = 'Phone'
        );

        maintenanceRequestList.add(maintenanceRequest);
        insert maintenanceRequestList;

        List<Product2> productList = new List<Product2>();
        Product2 product = new Product2(
            Name                 = 'test product',
            Maintenance_Cycle__c = 100,
            Replacement_Part__c  = true
        );

        productList.add(product);
        insert productList;

        System.debug('product => ' + product);
        System.debug('maintenanceRequest => ' + maintenanceRequest);

        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemList = new List<Equipment_Maintenance_Item__c>();
        Equipment_Maintenance_Item__c equipmentMaintenanceItem = new Equipment_Maintenance_Item__c (
            Equipment__c           = product.Id,
            Maintenance_Request__c = maintenanceRequest.Id,
            Quantity__c            = 100
        );

        equipmentMaintenanceItemList.add(equipmentMaintenanceItem);
        
        Equipment_Maintenance_Item__c equipmentMaintenanceItem2 = new Equipment_Maintenance_Item__c (
            Equipment__c           = product.Id,
            Maintenance_Request__c = maintenanceRequest.Id,
            Quantity__c            = 10
        );

        equipmentMaintenanceItemList.add(equipmentMaintenanceItem2);
        
        insert equipmentMaintenanceItemList;
    }

    @isTest
    public static void testMaintenanceHelperSuccess() {
        List<Case> maintenanceRequestList = [
            SELECT Id, Status
            FROM Case
            LIMIT 1
        ];

        maintenanceRequestList.get(0).Status = 'Closed';

        Test.startTest();
            update maintenanceRequestList;
            System.assertEquals(1, maintenanceRequestList.size());
        Test.stopTest();
    }
    
    @isTest
    public static void testMaintenanceHelperConstructors() {
        MaintenanceRequestHelper maintenanceReqHelper = new MaintenanceRequestHelper();
    }
}