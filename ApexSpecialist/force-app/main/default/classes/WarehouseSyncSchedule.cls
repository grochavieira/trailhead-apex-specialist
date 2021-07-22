global class WarehouseSyncSchedule implements Schedulable{
    global void execute(System.SchedulableContext context) {
       System.enqueueJob(New WarehouseCalloutService());
    }
}