public with sharing class MaintenanceRequestHelper {    
    public MaintenanceRequestHelper() {}

    public static void handleClosedMaintenance(Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id, Case> closedCases = new Map<Id, Case>();
        // pega os ids das manutenções fechadas
        for (Case newCase : newMap.values()) {
            Case oldCase = oldMap.get(newCase.Id);

            if (newCase.Status == 'Closed' && newCase.Status != oldCase.Status && (newCase.Type == 'Routine Maintenance' || newCase.Type == 'Repair')) {
                caseIds.add(newCase.Id);
                closedCases.put(newCase.Id, newCase);
            }
        }

        Map<Id, List<MaintenanceItemEquipment>> closedCasesMaintenanceMap = new Map<Id, List<MaintenanceItemEquipment>>();

        // cria um map com o id da manutenção para os equipamentos relacionados a ela
        for (Equipment_Maintenance_Item__c equipmentItem : 
        [
            SELECT Id, Equipment__c, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN: caseIds
        ]
        ) {
            Product2 product = new Product2(
                Id                   = equipmentItem.Equipment__c,
                Maintenance_Cycle__c = equipmentItem.Equipment__r.Maintenance_Cycle__c
            );
            MaintenanceItemEquipment maintenanceEquipmentItem = new MaintenanceItemEquipment(
                product,
                equipmentItem
            );
            if(closedCasesMaintenanceMap.containsKey(equipmentItem.Maintenance_Request__c)) {
                closedCasesMaintenanceMap.get(equipmentItem.Maintenance_Request__c).add(maintenanceEquipmentItem);
            } else {
                List<MaintenanceItemEquipment> maintenanceEquipmentItemList = new List<MaintenanceItemEquipment>{
                    maintenanceEquipmentItem
                };
                closedCasesMaintenanceMap.put(
                    equipmentItem.Maintenance_Request__c,
                    maintenanceEquipmentItemList
                );
            }
        }

        List<Case> caseList = new List<Case>();
        Map<Id, Case> closedCaseToNewCase = new Map<Id, Case>();

        for (Id maintenanceId : closedCasesMaintenanceMap.keySet()) {
            Decimal lowestCycle = 9999;
            for(MaintenanceItemEquipment maintenanceEquipmentItem : closedCasesMaintenanceMap.get(maintenanceId)) {
                if (maintenanceEquipmentItem.product.Maintenance_Cycle__c != null && maintenanceEquipmentItem.product.Maintenance_Cycle__c < lowestCycle) {
                    lowestCycle = maintenanceEquipmentItem.product.Maintenance_Cycle__c;
                }
            }
            Case closedCase = newMap.get(maintenanceId);
            Case newCase = new Case(
                Subject          = 'New vehicle maintenance',
                Date_Reported__c = System.today(),
                Date_Due__c      = System.today().addDays(Integer.valueOf(lowestCycle)),
                Vehicle__c       = closedCase.Vehicle__c,
                Type             = 'Routine Maintenance'
            );
            caseList.add(newCase);
            closedCaseToNewCase.put(maintenanceId, newCase);
        }

        insert caseList;

        List<Equipment_Maintenance_Item__c> equipmentMaintenanceList = new List<Equipment_Maintenance_Item__c>();
        List<Equipment_Maintenance_Item__c> oldEquipmentMaintenanceList = new List<Equipment_Maintenance_Item__c>();

        for (Id maintenanceId : closedCaseToNewCase.keySet()) {
            for(MaintenanceItemEquipment maintenanceEquipmentItem : closedCasesMaintenanceMap.get(maintenanceId)) {
                Equipment_Maintenance_Item__c newEquipmentItem = maintenanceEquipmentItem.equipmentItem.clone(false);
                newEquipmentItem.Maintenance_Request__c = closedCaseToNewCase.get(maintenanceId).Id;
                oldEquipmentMaintenanceList.add(maintenanceEquipmentItem.equipmentItem);
                equipmentMaintenanceList.add(newEquipmentItem);
            }
        }

        insert equipmentMaintenanceList;
        delete oldEquipmentMaintenanceList;
    }

    public class MaintenanceItemEquipment {
        Product2 product {get; set;}
        Equipment_Maintenance_Item__c equipmentItem {get; set;}

        MaintenanceItemEquipment(Product2 product, Equipment_Maintenance_Item__c equipmentItem){
            this.product = product;
            this.equipmentItem = equipmentItem;
        }
    }
}