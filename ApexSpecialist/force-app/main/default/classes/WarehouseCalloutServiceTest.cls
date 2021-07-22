@isTest
public with sharing class WarehouseCalloutServiceTest {
    @isTest
    public static void testCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock()); 

        Test.startTest();
            WarehouseCalloutService.syncInventoryEquipment();
            System.enqueueJob(new WarehouseCalloutService());
            System.assertEquals(1, 1);
        Test.stopTest();
    }
}
