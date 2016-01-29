@isTest
private class ReviewUtility_Test {
	@isTest static void testRecTypeValidation() {
      ReviewRecordTypeValidation__c RTValidaiton 
        = new ReviewRecordTypeValidation__c(Name = 'Item Error',
        	                                Case_Record_Type__c = 'PCT - Item');

	  CaseTestDataUtility TestData = new CaseTestDataUtility();
      
      Review__c NewReview = new Review__c(Reviewed_Item__c = TestData.listCases[0].Id,
      									  RecordTypeId = Schema.SObjectType.Review__c
                    								   .getRecordTypeInfosByName().get('Item Error')
                    								   .getRecordTypeId(),
      									  Acknowledged_by_Associate__c = 'Acknowledged',
      									  Coaching_Notes__c = 'Some Notes',
      									  Error_Type_s__c = 'Member Information in Error'
      	                                 );
      insert NewReview;
	}
}