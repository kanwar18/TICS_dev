@isTest
private class RXCreateRecordWithSameDoc_Test {
	@isTest static void testController() {
		list<RX__c> testRXs = new list<RX__c>();
		CaseTestDataUtility TestData = new CaseTestDataUtility();
		for(RX__c thisRX : TestData.listRXs) {
          if(thisRX.Related_Case__c == TestData.listCases[0].Id){
          	testRXs.add(thisRX);
          }
		}
		test.startTest();
		  ApexPages.StandardController stdRX = new ApexPages.StandardController(testRXs[0]);
		  RXCreateRecordWithSameDocController controller 
		    = new RXCreateRecordWithSameDocController(stdRX);
	    	controller.cloneRecord();
	    test.stopTest();
	}
}