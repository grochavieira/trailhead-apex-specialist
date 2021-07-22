public with sharing class MaintenanceRequestTriggerHandler {
    List<Case> oldList {get; set;}
    List<Case> newList {get; set;}
    Map<Id, Case> oldMap {get; set;}
    Map<Id, Case> newMap {get; set;}
    
    public static Boolean runTrigger;

    static {
        runTrigger = true;
    }

    public static Boolean isTriggerEnabled() {
        return runTrigger;
    }

    public static Boolean enableTrigger() {
        return runTrigger = true;
    }
    
    public static Boolean disableTrigger() {
        return runTrigger = false;
    }

    public MaintenanceRequestTriggerHandler() {}

    public MaintenanceRequestTriggerHandler(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        this.oldList = oldList;
        this.newList = newList;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void afterUpdate() {
        MaintenanceRequestHelper.handleClosedMaintenance(this.oldMap, this.newMap);
    }
}
