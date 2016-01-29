@isTest
private class CaseCreateTransferController_Test {
  @isTest static void testController(){
  test.startTest();
        Case thisCase = new Case(RecordTypeId = Schema.SObjectType.Case
                                                 .getRecordTypeInfosByName()
                                                 .get('Transfer')
                                                 .getRecordTypeId());
      ApexPages.StandardController stdCase = new ApexPages.StandardController(thisCase);
      CaseCreateTransferController controller 
        = new CaseCreateTransferController(stdCase);
      controller.objRXRows.AddRow(); 
      controller.objRXRows.AddRow(); 
      Test.setCurrentPageReference(new PageReference('CaseCreateTransfer'));
      System.currentPageReference().getParameters().put('RowToRemove', '1');
      controller.objRXRows.RemoveRow();

      System.currentPageReference().getParameters().put('LatestFirstName','string');
      System.currentPageReference().getParameters().put('LatestAddr1','string');
      System.currentPageReference().getParameters().put('LatestLastName','string');
      System.currentPageReference().getParameters().put('LatestAddr2','string');
      System.currentPageReference().getParameters().put('LatestNPI','string');
      System.currentPageReference().getParameters().put('LatestCity','string');
      System.currentPageReference().getParameters().put('LatestDEA','string');
      System.currentPageReference().getParameters().put('LatestState','string');
      System.currentPageReference().getParameters().put('LatestPhone','string');
      System.currentPageReference().getParameters().put('LatestZip','string');
      System.currentPageReference().getParameters().put('LatestFax','string');

      controller.objRXRows.updateLatestValues();

      for(RX__c thisRX : controller.objRXRows.mapRXs.values()){
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