@isTest
private class CaseListViewControllerTest {

    static testMethod void myUnitTest() {
        test.startTest();
        CaseTestDataUtility TestData = new CaseTestDataUtility();
        PageReference pageRef = Page.CaseListViewnew;
     Test.setCurrentPage(pageRef);
     ApexPages.StandardController ssc = new ApexPages.StandardController(testData.listRXs[0]);        
        CaseListViewController control = new CaseListViewController(ssc);
        control.getFilterOptions();
        //control.setCon = new ApexPages.StandardSetController(testData.listRXs);
        control.getRecords();
        control.refreshList();
        control.ErrorsPresent();
        control.getTotalPages();
        control.last();
        control.first();
        control.next();
        control.previous();
        control.save(); 
        CaseListViewController.getRecordTypes('Case');
        test.stopTest();
    }
}