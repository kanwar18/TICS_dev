@isTest
private class CreatePOPFromTransfer_Test {
	@isTest static void testController() {	
		list<RX__c> testRXs = new list<RX__c>();
		CaseTestDataUtility TestData = new CaseTestDataUtility();
		for(RX__c thisRX : TestData.listRXs) {
          if(thisRX.Related_Case__c == TestData.listCases[0].Id){
          	testRXs.add(thisRX);
          }
		}
		test.startTest();
		  ApexPages.StandardSetController stdRX = new ApexPages.StandardSetController(testRXs);
		  stdRX.setSelected(testRXs);
		  CaseCreatePOPFromTransferController controller 
		    = new CaseCreatePOPFromTransferController(stdRX);
	    	controller.createData();
	    test.stopTest();
         
	    Map<Id, Case> NewPOPResult = new map<Id, Case>([SELECT Id, (Select Id From Rx_s__r) FROM Case 
	                               WHERE Parent_Transfer__c = :TestData.listCases[0].Id]);

	    system.assertEquals(4, NewPOPResult.values().size());

	    list<AggregateResult> NewPOPRxResult = [SELECT Related_Case__c, Count(Id) NumRXs from RX__c 
	                                  WHERE Related_Case__c IN :NewPOPResult.keySet()
	                                  GROUP BY  Related_Case__c
	                                  Order By Count(Id)];
	    system.assertEquals(4, NewPOPRxResult.size());
        system.assertEquals(1, NewPOPRxResult[0].get('NumRXs'));
        system.assertEquals(3, NewPOPRxResult[1].get('NumRXs'));
        system.assertEquals(3, NewPOPRxResult[2].get('NumRXs'));
        system.assertEquals(3, NewPOPRxResult[3].get('NumRXs'));
	}
}