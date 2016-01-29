@isTest
private class ListViewTableHandler_Test {
  @isTest static void testPageLoad() {
    CustomCaseListViews__c ListView 
        = new CustomCaseListViews__c(Name = 'My Open Cases',
                                     View_Filter_1__c = 'RecordType.Name = \'PCT - Item\'',
                                     Column_List_1__c = 'Aging_Days__c,Assignment_Queue__c,' +
                                     'Owner.Name,Business_Group_Channel__c,' +
                                     'Member_Plan_Lookup__r.Name,Request_Type__c,Account.Name');
      insert ListView;
    CaseTestDataUtility testData = new CaseTestDataUtility();
    PageReference pageRef = Page.CaseListView;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testData.listCases);
    ListViewTableHandler controller = new ListViewTableHandler(ssc);
    controller.getCaseListViews();
      list<string> lstFieldList = controller.columnFieldsList;
    list<string> lstFieldTitlesList = controller.columnTitlesList;
    controller.filter();
  }
}