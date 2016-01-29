/**
*   {Purpose}  –  Test data generator for Cases and RXs and other 
*                 POP/PCT data.
*                 
*                 
*                 
*   {Function}  – Creates test data either statically or as a gruop 
*                 by direct instantiation.
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

public without sharing class CaseTestDataUtility {
  public list<Case> listCases;
  public list<CaseComment> listCaseComments;
  public list<Rx__c> listRXs;
  public list<Fax_Numbers__c> listFaxNums;
  public static User TestUser;
  public static Account testClient;
  
  public CaseTestDataUtility(){
    createInitialDataset();
  }

  public void createInitialDataset(){
    TestUser = createTestUser();
    listCases = createCases(10);
    listCaseComments = createCaseComments(10, listCases);
    listRXs = createRXs(10, listCases); 
    listFaxNums = createFaxNums(2); 
  }
  public static User createTestUser(){
    List<Profile> profiles = [select id, name from Profile where 
                        name = 'System Administrator'];
    User NewTestUser = new User(alias = 'admin',
    email='testagent@prime.com',
    emailencodingkey='UTF-8',
    lastname='User', languagelocalekey='en_US',
    localesidkey='en_US',
    profileid = profiles[0].Id,
    timezonesidkey='America/Los_Angeles',
	username='testagent@prime.com',                          
    Receive_Custom_Apex_Emails__c = true);
    insert NewTestUser;
    return NewTestUser;    
  } 
  
  public static list<Case> createCases(integer listSize){
    if(TestUser == null) TestUser = createTestUser();
    list<Case> listCaseCreates = new list<Case>();
    Request_Type__c newRequestType 
      = new Request_Type__c(Name = 'Test Request Type', Is_a_CTM__c = true);
    insert newRequestType;     
    string faxnum=null;
    for(integer i=0;i<listSize; i++){
       if(i <= 9){
           faxnum = '(111) 111-111' + String.valueOf(i);
         }
        Case thisCase 
          = new Case(Subject = 'Test Case ' + String.valueOf(i),
                     Prescribers_Fax_Number__c=faxnum,                   
                     Member_First_Name__c = 'Nick',
                     Member_Id__c = '1WILLDMN8',
                     Member_Last_Name__c = 'Cook',
                     Patient_Last_Name__c = 'Cook',
                     Name_on_Credit_Card__c = 'Name',
                    // Prescriber_Called_In__c = TRUE,
                    // Prescriber_Agent__c = 'Agent',
                     Assignment_Queue__c = 'Queue 2c - Ready for 1st Fax',
                     Managing_Group__c = 'Queue 2c - Ready for 1st Fax',
                     Assigned_To_Prime__c = TestUser.Id,
                     Assigned_To_Plan__c = TestUser.Id,
                     Group_Number__c='EP93600', 
                    // Owner_Type__c='Queue',
                     ownerId='005i0000003SQ8u',
                     Member_Plan_Name__c='Medicare - FL - PARTB - H1035',
                    //Member_Plan_Lookup__r=[select name from plan__c where name='Medicare - FL - PARTB - H1035'],
                     Information_Description_To_Add__c 
                       = 'On the other hand, we denounce with righteous indignation' +
                          ' and dislike men who are so beguiled and demoralized by the' +
                          ' charms of pleasure of the moment, so blinded by desire, that' +
                          ' they cannot foresee the pain and trouble that are bound to ensue',
                     Request_Type__c = 'Test Request Type',
                     RecordTypeId = Schema.SObjectType.Case
                                          .getRecordTypeInfosByName().get('PCT - Item')
                                          .getRecordTypeId()
                     );
      listCaseCreates.add(thisCase);
    }
    insert listCaseCreates;
    return listCaseCreates;
  }
  
  public static list<Rx__c> createRXs(integer listSize, list<Case> listNewCases){
    if(TestUser == null) TestUser = createTestUser();
    list<Rx__c> listRXCreates
      = new list<Rx__c>();
    for(Case thisCase : listNewCases){
      for(integer i=1;i<=listSize; i++){
        Rx__c thisRX 
          = new Rx__c(Controlled_Drug_TF__c = TRUE,
            Cost__c = 1000, 
            Days_Supply__c = 10,
            Directions__c = '2xDaily',
            Drug_Name__c = 'mycoxaphalin',
            Patient_DAW__c = true,
            Profile_Rx__c = true,
            Quantity__c = '100',
            Rx__c = '12345678',
            Prescribers_Name__c = 'Whats UpDoc',
            Related_Case__c = thisCase.Id);
              listRXCreates.add(thisRX);    
       }
    }
    insert listRXCreates;
    return listRXCreates;
  }

  public static list<CaseComment> createCaseComments(integer listSize, list<Case> listNewCases){
    if(TestUser == null) TestUser = createTestUser();
    list<CaseComment> listCaseComments
      = new list<CaseComment>();
    for(Case thisCase : listNewCases){
      for(integer i=1;i<=listSize; i++){
        CaseComment thisCaseComment 
          = new CaseComment(CommentBody = 'COMMENT BODY COMMENT BODY',
                      ParentId = thisCase.Id);
              listCaseComments.add(thisCaseComment);    
       }
    }
    insert listCaseComments;
    return listCaseComments;
  }
  
  public static list<Fax_Numbers__c> createFaxNums(integer listSize){
    if(TestUser == null) TestUser = createTestUser();
    list<Fax_Numbers__c> listFaxNumCreates = new list<Fax_Numbers__c>();
    for(integer i=0;i<listSize; i++){
        Fax_Numbers__c thisFaxNum 
          = new Fax_Numbers__c(Name = '(111) 111-111' + String.valueOf(i),
                               Fax__c = '(111) 111-111' + String.valueOf(i)
                     );
      listFaxNumCreates.add(thisFaxNum);
    }
    insert listFaxNumCreates;
    return listFaxNumCreates;
  }
}