@isTest
private class IntegrationQueueBatchDelete_Test {
    static testmethod void testBatch() {
      QueueItem__c newQI 
        = new QueueItem__c(  
          ObjectName__c = 'Case',
	      Insert_Time__c = DateTime.Now(), 
	      OperationType__c = 'Insert',
	      Status__c = 'Archived'
      	);
      insert newQI;
      
      Test.startTest();
         IntegrationQueueBatchDelete bd = new IntegrationQueueBatchDelete();
         Database.executeBatch(bd, 100);
      Test.stopTest();

      Integer i = [SELECT COUNT() FROM QueueItem__c WHERE Status__c = 'Archived'];
      System.assertEquals(i, 0);
    }	
}