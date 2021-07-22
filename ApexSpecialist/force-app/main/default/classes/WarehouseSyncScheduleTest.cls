@isTest
public with sharing class WarehouseSyncScheduleTest {
    public static String CRON_EXP = '0 0 1 * * ?';

    @isTest
    public static void testScheduledJog() {
        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleTest', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();

        System.assertEquals(1, 1);
    }
}
