/**
*   {Purpose}  – Custom Trigger manager for the Rx object.
*                 
*                 
*                 
*   {Function}  – Marshall for bulk operations on Rx 
*   
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    Name             Description
*   5/1/12  Nick Cook DCS     Created 
*   =============================================================================
*/

trigger RxEventListener on Rx__c(before insert, before update, 
                                   after insert, after update,
                                                  after delete) {
  if(trigger.isBefore && trigger.isInsert) {
    //Pre-Insert Methods
  }
  
  if(trigger.isAfter && trigger.isInsert){
    //Post-Insert Methods
    RxTriggerSwitch__c RunTrigger 
      = RxTriggerSwitch__c.getInstance('copyDataToCase');
    system.debug(RunTrigger);
    if(RunTrigger != null && RunTrigger.IsActive__c){
       RxDataReplicationFactory.copyDataToCase(trigger.new, trigger.oldMap);
    }
  }
  
  if(trigger.isBefore && trigger.isUpdate) {
    //Pre-Update Methods
  }
  
  if(trigger.isAfter && trigger.isUpdate){
    //Post-Update Methods
    RxTriggerSwitch__c RunTrigger 
      = RxTriggerSwitch__c.getInstance('copyDataToCase');
    if(RunTrigger != null && RunTrigger.IsActive__c){
       RxDataReplicationFactory.copyDataToCase(trigger.new, trigger.oldMap);
    }
  }
  
  if(trigger.isAfter && trigger.isDelete) {
    //Post-Delete Methods
  }
}