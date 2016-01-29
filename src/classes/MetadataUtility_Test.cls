@isTest
private class MetadataUtility_Test {
  @isTest static void testGetObjectFields() {
	 MetadataUtility.fieldsInObject('Case');
  }
	
  @isTest static void testFetchPickListValues() {
	case testCase = new Case();
	MetaDataUtility.fetchPicklistValues
	  (testCase, 'Assignment_Queue__c');
  }	
}