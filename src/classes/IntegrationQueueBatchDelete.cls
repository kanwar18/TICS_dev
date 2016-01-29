/**
*   {Purpose}  –  This class handles an sObject from trigger after insert 
*                 and after update events and writes items to an integration 
*                 queue custom object.
*                 
*   {Function}  – Used in conjucntion with IntegrationQueueUtility and   
*                 IntegrationQueueDeleteSchedule
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
global class IntegrationQueueBatchDelete implements Database.Batchable<SObject>{
    global String strQuery;
    global List<SObject> lstScopeRecords;

    global IntegrationQueueBatchDelete() {
        strQuery = 'SELECT Id FROM QueueItem__c WHERE Status__c = \'Archived\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bcMain) {
     return Database.getQueryLocator(strQuery);
    }
 
    global void execute(Database.BatchableContext bcMain, 
                                                  List<SObject> lstBatchRecords) {
        lstScopeRecords = lstBatchRecords;
          if(lstScopeRecords.size() > 0){
              delete lstScopeRecords;
          }
    }
    
    global void finish(Database.BatchableContext bcMain) {}
}