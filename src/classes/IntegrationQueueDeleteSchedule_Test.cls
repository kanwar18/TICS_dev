@isTest
private class IntegrationQueueDeleteSchedule_Test { 
  static testmethod void testSchedule() {
    IntegrationQueueDeleteSchedule DS 
      = new IntegrationQueueDeleteSchedule();
    String sch = '0 0 8 13 2 ?';
    system.schedule('Test Delete', sch, DS);
  }
}