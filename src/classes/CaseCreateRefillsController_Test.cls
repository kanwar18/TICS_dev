@isTest
private class CaseCreateRefillsController_Test {
  @isTest static void testController(){
  test.startTest();
        Case thisCase = new Case(RecordTypeId = Schema.SObjectType.Case
                                                 .getRecordTypeInfosByName()
                                                 .get('PCT - Order Refill')
                                                 .getRecordTypeId());
      ApexPages.StandardController stdCase = new ApexPages.StandardController(thisCase);
      CaseCreateRefillsController controller 
        = new CaseCreateRefillsController(stdCase);
      controller.objRefillRows.AddRow(); 
      controller.objRefillRows.AddRow(); 
      Test.setCurrentPageReference(new PageReference('CaseCreateRefills'));
      System.currentPageReference().getParameters().put('RowToRemove', '1');
      controller.objRefillRows.RemoveRow();
      for(RX__c thisRX : controller.objRefillRows.mapRXs.values()){
             thisRX.Rx__c = 'Test RX Num';
             thisRX.Patient_Name__c = 'Some Dude';
             thisRX.Drug_Name__c = 'Mycoxaphalin';
             thisRX.Strength__c = '100';
      }     
          thisCase.Subject = 'Test Case';
          thisCase.Prescribers_Fax_Number__c='(111)-111-1111';                  
          thisCase.Member_First_Name__c = 'Nick';
          thisCase.Member_Id__c = '1WILLDMN8';
          thisCase.Member_Last_Name__c = 'Cook';
          thisCase.Patient_Last_Name__c = 'Cook';
          thisCase.Name_on_Credit_Card__c = 'Name';
          //thisCase.Prescriber_Called_In__c = TRUE;
          //thisCase.Prescriber_Agent__c = 'Agent';
          thisCase.Assignment_Queue__c = 'Queue 2c - Ready for 1st Fax';
          thisCase.Information_Description_To_Add__c = 'Test New Comment';
          thisCase.Request_Type__c = 'Test Request Type';
          controller.saveAll();
  test.stopTest();  
  }  
}