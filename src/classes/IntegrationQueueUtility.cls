/**
*   {Purpose}  –  This class handles an sObject from trigger after insert 
*                 and after update events and writes items to an integration 
*                 queue custom object.
*                 
*   {Function}  – This class has interdependent batchable and schedulable 
*                 classes to execute in bulk daily.
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

public without sharing class IntegrationQueueUtility {
  public static void insertQueueItem (List<sObject> listObjects, String ObjectName, String OperationType) {
    list<QueueItem__c> listQueueItemInserts 
      = new list<QueueItem__c>();
    String opType = OperationType;
    for (sObject thisObject : listObjects) {
      if(thisObject.get('Transfer_Doc_Name__c') == 'Test Error') { //Purely for Negative Test
      	opType = 'Test Error';
      }
      QueueItem__c QI = new QueueItem__c();
      QI.ObjectName__c = ObjectName;
      QI.Insert_Time__c = DateTime.Now();
      QI.Record_Id__c = thisObject.Id;
      QI.OperationType__c = opType;
      QI.Status__c = 'Processing';
      listQueueItemInserts.Add(QI);
    }
    try {
      insert listQueueItemInserts;
    } catch (Exception ex) {
      Messaging.SingleEmailMessage mail 
        = new Messaging.SingleEmailMessage();
      String[] toAddresses 
        = new String[] {'nickc@demandchainsystems.com','citty@primetherapeutics.com'};   
      mail.setToAddresses(toAddresses);
      mail.setReplyTo('citty@primetherapeutics.com');
      mail.setSenderDisplayName('Salesforce Integration Queue Error');
      mail.setSubject('Salesforce Integration Queue Error');
      mail.setPlainTextBody('An error occurred writing an insert or update to the Salesforce integration queue.');
      if(!test.isRunningTest()){
      	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }	
      return;
    }           
  }
}