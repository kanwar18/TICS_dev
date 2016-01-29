@isTest 
private class ReplacementOrderImportUtility_Test {

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
		
		System.assertEquals(rx.Drug_Name__c, resultRx.Drug_Name__c);
		System.assertEquals(rx.Member_Name__c, resultRx.Patient_Name__c);
		System.assertEquals(rx.Cost__c, resultRx.Cost__c);
		System.assertEquals(rx.Price__c, resultRx.Price__c);
		System.assertEquals(rx.Quantity__c, resultRx.Quantity__c);
		System.assertEquals(rx.Tax__c, resultRx.Tax__c);
		System.assertEquals(rx.Operator__c, resultRx.Operator__c);
		System.assertEquals(c.Id, resultRx.Related_Case__c);
	}
	
	@isTest static void testGetCasesByReplacementOrders() {
		set<String> replacementOrderNumbers = new Set<String>();
		replacementOrderNumbers.add('123');
		
		ReplacementOrderImportUtility.getCasesByReplacementOrders(replacementOrderNumbers);
	}
	
	@isTest static void testUpdateCaseAndRx() {
		String drugName = 'drugName';
		String patientName = 'patientName';
		Decimal cost = 123.10;
		Decimal price = 321.00;
		String quantity = 'quantity';
		Decimal tax = 123.12;
		String operator = 'oper';
		String replacementOrderNumber = '123';
		
		Case c = new Case();
		String caseId = c.Id;
		c.Replacement_Order__c = replacementOrderNumber;
		insert c;
		
		Replacement_Order_Rx_Import__c rx = new Replacement_Order_Rx_Import__c();
		rx.Drug_Name__c = drugName;
		rx.Member_Name__c = patientName;
		rx.Cost__c = cost;
		rx.Price__c = price;
		rx.Quantity__c = quantity;
		rx.Tax__c = tax;
		rx.Operator__c = operator;
		rx.Replacement_Order_Number__c = replacementOrderNumber;
		
		list<Replacement_Order_Rx_Import__c> roRxs = new list<Replacement_Order_Rx_Import__c>();
		roRxs.add(rx);

		ReplacementOrderImportUtility.updateCaseAndRx(roRxs);
	}
	
	@isTest static void testInsertRxsToReplacementOrderCase() {
		String drugName = 'drugName';
		String patientName = 'patientName';
		Decimal cost = 123.10;
		Decimal price = 321.00;
		String quantity = 'quantity';
		Decimal tax = 123.12;
		String operator = 'ope';
		
		list<ReplacementOrderImportUtility.RxImportXRxXCase> wrapList = new list<ReplacementOrderImportUtility.RxImportXRxXCase>();
		
		Case myCase = new Case();
		myCase.Replacement_Order__c = '123456789';
		
		Replacement_Rx__c rx = new Replacement_Rx__c();
		rx.Drug_Name__c = drugName;
		rx.Patient_Name__c = patientName;
		rx.Cost__c = cost;
		rx.Price__c = price;
		rx.Quantity__c = quantity;
		rx.Tax__c = tax;
		rx.Operator__c = operator;
		
		
		Replacement_Order_Rx_Import__c rxImport = new Replacement_Order_Rx_Import__c();
		rx.Drug_Name__c = drugName;
		rx.Member_Name__c = patientName;
		rx.Cost__c = cost;
		rx.Price__c = price;
		rx.Quantity__c = quantity;
		rx.Tax__c = tax;
		rx.Operator__c = operator;
		
		ReplacementOrderImportUtility.RxImportXRxXCase wrapperObj = new ReplacementOrderImportUtility.RxImportXRxXCase();
		wrapperObj.c = myCase; 
		wrapperObj.rx = rx;
		wrapperObj.rxImport = rxImport;
		
		wrapList.add(wrapperObj);
		
		
		ReplacementOrderImportUtility.insertRxsToReplacementOrderCase(wrapList);
	}
	
	@isTest static void testInsertRxImport() {

		String drugName = 'drugName';
		String patientName = 'patientName';
		Decimal cost = 123.10;
		Decimal price = 321.00;
		String quantity = 'quantity';
		Decimal tax = 123.12;
		String operator = 'oper';
		String replacementOrderNumber = '123';
		
		Replacement_Order_Rx_Import__c rxImport = new Replacement_Order_Rx_Import__c();
		rxImport.Drug_Name__c = drugName;
		rxImport.Member_Name__c = patientName;
		rxImport.Cost__c = cost;
		rxImport.Price__c = price;
		rxImport.Quantity__c = quantity;
		rxImport.Tax__c = tax;
		rxImport.Operator__c = operator;
	
		test.startTest();      
		
	      insert rxImport;
	      
    	test.stopTest();
	}
}