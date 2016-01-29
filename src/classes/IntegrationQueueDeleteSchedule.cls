/**
*   {Purpose}  –  This class handles an sObject from trigger after insert 
*                 and after update events and writes items to an integration 
*                 queue custom object.
*                 
*   {Function}  – Used in conjucntion with IntegrationQueueUtility and   
*                 IntegrationQueueBatchDelete
*                 
*                 
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                 
*/
 
/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    Name             Description
*   6/4/14  Nick Cook DCS     Created
*   =============================================================================
*/
global class IntegrationQueueDeleteSchedule implements Schedulable {  
  global void execute(SchedulableContext scMain) {
    IntegrationQueueBatchDelete clsIntegrationQueueBatchDelete
      = new IntegrationQueueBatchDelete(); 
      ID idBatch = Database.executeBatch(clsIntegrationQueueBatchDelete, 5000);
  }
}