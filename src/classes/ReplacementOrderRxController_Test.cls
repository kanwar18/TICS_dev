@isTest
private class ReplacementOrderRxController_Test {
    
   @isTest static void testCreateRx() {    
    String drugName = 'drugName';
    String patientName = 'patientName';
    Decimal cost = 123.10;
    Decimal price = 321.00;
    String quantity = 'quantity';
    Decimal tax = 123.12;
    String operator = 'oper';
    
    Case c = new Case();
    String caseId = c.Id;
    
    Replacement_Order_Rx_Import__c rx = new Replacement_Order_Rx_Import__c();
    rx.Drug_Name__c = drugName;
    rx.Member_Name__c = patientName;
    rx.Cost__c = cost;
    rx.Price__c = price;
    rx.Quantity__c = quantity;
    rx.Tax__c = tax;
    rx.Operator__c = operator;

    Replacement_Rx__c resultRx = ReplacementOrderImportUtility.createRx(c, rx);
    
    Test.setCurrentPage(Page.ReplacementOrderRxReconcile);
    ApexPages.StandardController testController = new ApexPages.StandardController(resultRx);
    ReplacementOrderRxController testObj = new ReplacementOrderRxController(testController);
    testObj.getFilterOptions();
    testObj.first();
    testObj.last();
    testObj.previous();
    testObj.next();
    testobj.getTotalPages();
    testObj.ErrorsPresent();
    testobj.reconcileRxImports();
  }
}