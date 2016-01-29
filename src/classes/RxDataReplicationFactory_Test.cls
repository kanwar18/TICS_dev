/**
*   {Purpose}  –  Test Class for RxDataReplicationFactory
*                 
*   {Function}  – Test bulk inserts and updates on Rx Data
*                 de-normalizing data to Case
*   
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    Name             Description
*   2/7/14  Nick Cook DCS    Created 
*   =============================================================================
*/

@isTest
private class RxDataReplicationFactory_Test {
	
	@isTest static void testInsertRx() {
	  RxTriggerSwitch__c RunTrigger = new RxTriggerSwitch__c(Name = 'copyDataToCase',
	 	                                                    IsActive__c = true);
	  insert RunTrigger;

	  CaseTriggerSwitch__c RunTrigger2 = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
	 	                                                    IsActive__c = true);
	  insert RunTrigger2;

	  list<RxToCaseMap__c> FieldMaps = new list<RxToCaseMap__c>();  
	  RxToCaseMap__c FieldMap1 = new RxToCaseMap__c(Name = 'Drug_Name__c');
	  FieldMaps.add(FieldMap1);
	  RxToCaseMap__c FieldMap2 = new RxToCaseMap__c(Name = 'Controlled_Drug_TF__c');
	  FieldMaps.add(FieldMap2);
	  RxToCaseMap__c FieldMap3 = new RxToCaseMap__c(Name = 'Cost__c');
	  FieldMaps.add(FieldMap3);
	  RxToCaseMap__c FieldMap4 = new RxToCaseMap__c(Name = 'Days_Supply__c');
	  FieldMaps.add(FieldMap4);
	  RxToCaseMap__c FieldMap5 = new RxToCaseMap__c(Name = 'Directions__c');
	  FieldMaps.add(FieldMap5);
	  RxToCaseMap__c FieldMap7 = new RxToCaseMap__c(Name = 'Patient_DAW__c'); 
	  FieldMaps.add(FieldMap7);
	  RxToCaseMap__c FieldMap8 = new RxToCaseMap__c(Name = 'Profile_Rx__c'); 
	  FieldMaps.add(FieldMap8);
	  RxToCaseMap__c FieldMap9 = new RxToCaseMap__c(Name = 'Quantity__c');
	  FieldMaps.add(FieldMap9);
	  RxToCaseMap__c FieldMap10 = new RxToCaseMap__c(Name = 'Rx__c');
	  FieldMaps.add(FieldMap10);
	  insert FieldMaps;

	  list<Case> TestCases = CaseTestDataUtility.createCases(1);

	  test.startTest();
	  list<Rx__c> TestRXs = CaseTestDataUtility.createRXs(3, TestCases);
	  TestCases[0].Assignment_Queue__c = 'Some Other Queue';
	  update TestCases;
	  update TestRXs;
	  test.stopTest();

	  Case CaseTestResult = [SELECT Id, 
	                                Rx_1_Drug_Name__c, 
	                                Rx_2_Drug_Name__c, 
	                                Rx_3_Drug_Name__c
	                         FROM Case
	                         WHERE Id = :TestCases[0].Id];
	  system.assertEquals(TestRXs[0].Drug_Name__c, CaseTestResult.Rx_1_Drug_Name__c);
	  system.assertEquals(TestRXs[1].Drug_Name__c, CaseTestResult.Rx_2_Drug_Name__c);
	  system.assertEquals(TestRXs[2].Drug_Name__c, CaseTestResult.Rx_3_Drug_Name__c);
	}
	
/*	@isTest static void testUpdateRx() {
	  CaseTestDataUtility TestData 
	    = new CaseTestDataUtility();
	}

    @isTest static void testDeleteRx() {
	  CaseTestDataUtility TestData 
	    = new CaseTestDataUtility();
	}
*/
}