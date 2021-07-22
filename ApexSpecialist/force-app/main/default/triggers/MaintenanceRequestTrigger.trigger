trigger MaintenanceRequestTrigger on Case (after update) {

    if (MaintenanceRequestTriggerHandler.isTriggerEnabled()) {
        MaintenanceRequestTriggerHandler handler = new MaintenanceRequestTriggerHandler(
            Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
        );

        switch on Trigger.operationType {
            when AFTER_UPDATE {
                handler.afterUpdate();
            }
        }
    }
}