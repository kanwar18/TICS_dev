@isTest
private class CaseUtility_Test {
  @isTest static void testInsertUpdateCase() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;
      
      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'closeOpenAssignmentHistories',
                                                            IsActive__c = true);
      insert RunTrigger10;
      
      CaseTriggerSwitch__c RunTrigger11
        = new CaseTriggerSwitch__c(Name = 'setOriginalCreatedByData',
                                                            IsActive__c = true);
      insert RunTrigger11;
      
       List<Profile> profiles = [select id, name from Profile where 
                        name = 'System Administrator'];
       User NewTestUser = new User(alias = 'admin',
                                    email='testinsert@prime.com',
                                    emailencodingkey='UTF-8',
                                    lastname='User', languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    profileid = profiles[0].Id,
                                    timezonesidkey='America/Los_Angeles',
                                    username='testinsert@prime.com');
       insert NewTestUser;
       
       User NewTestUser1 = new User(alias = 'admin',
                                    email='testupdate@prime.com',
                                    emailencodingkey='UTF-8',
                                    lastname='User', languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    profileid = profiles[0].Id,
                                    timezonesidkey='America/Los_Angeles',
                                    username='testupdate@prime.com');
       insert NewTestUser1;
      list<user> testUsers = new list<user>();
      testUsers.add(NewTestUser);
      testUsers.add(NewTestUser1);
      CaseUtility.CreateContact(testUsers);
      IntegrationUserID__c cs = new IntegrationUserID__c();
      cs.Name='IntegrationServiceID';
      cs.Integration_User_ID__c=NewTestUser.Id;
      insert cs;
      /*
      String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
      String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
                    
      CreateAndAssignReviewFromCase__c CAAARFC_CTM
        = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
      insert CAAARFC_CTM;
      
      CreateAndAssignReviewFromCase__c CAAARFC_GRI
        = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
      insert CAAARFC_GRI; */

      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      
      CaseTestDataUtility TestData = new CaseTestDataUtility();

      test.startTest();      
      CaseRecursionHandler.alreadyCreatedAssignments = false;
      TestData.listCases[0].Assignment_Queue__c 
       = 'Some Other Queue';
      TestData.listCases[0].Managing_Group__c 
        = 'Some Other Queue';
      TestData.listCases[0].ownerId = NewTestUser1.Id;
      update TestData.listCases[0];
      
      test.stopTest();
      
       System.RunAs(NewTestUser1){
            TestData.listCases[0].Member_ID__c ='7567565';
            update TestData.listCases[0];
       
       }

      list<Assignment_History__c> AssignmentTestResult
                          = [SELECT Id, 
                                    Assignee__c
                             FROM Assignment_History__c
                             WHERE Case__c = :TestData.listCases[0].Id
                             AND Assignment_Type__c = 'Queue Change'
                             ORDER BY CreatedDate];
    //  system.assertEquals(2, AssignmentTestResult.size());
      system.assertEquals('Queue 2c - Ready for 1st Fax', AssignmentTestResult[0].Assignee__c);
      system.assertEquals('Some Other Queue', AssignmentTestResult[1].Assignee__c);
  }
static void testCreateComment() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;
      
      CaseTriggerSwitch__c  RunTrigger12 
          = new CaseTriggerSwitch__c(Name = 'copyNotesToStdComment',
                                                            IsActive__c = true);  
    
      insert RunTrigger12;
     
      CaseTriggerSwitch__c RunTrigger13 
          = new CaseTriggerSwitch__c(Name = 'trackFieldChangesStd',
                                                            IsActive__c = true);  
    
      insert Runtrigger13;
      
      CaseTriggerSwitch__c  RunTrigger14 
          = new CaseTriggerSwitch__c(Name = 'copyNotesToCustomComment',
                                                            IsActive__c = true);  
    
      insert RunTrigger14;
     
      CaseTriggerSwitch__c RunTrigger15 
          = new CaseTriggerSwitch__c(Name = 'trackFieldChangesCustom',
                                                            IsActive__c = true);  
    
      insert Runtrigger15;
      
      CaseTriggerSwitch__c RunTrigger16 
          = new CaseTriggerSwitch__c(Name = 'trackFieldChangesStdSGC',
                                                            IsActive__c = true);  
    
      insert Runtrigger16;
      
      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'closeOpenAssignmentHistories',
                                                            IsActive__c = true);
      insert RunTrigger10;
       
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      
      /* not commented on by anoop 
      String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
      String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
         
      CreateAndAssignReviewFromCase__c CAAARFC_CTM
        = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
      insert CAAARFC_CTM;
      
      CreateAndAssignReviewFromCase__c CAAARFC_GRI
        = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
      insert CAAARFC_GRI; */

      CaseTestDataUtility TestData = new CaseTestDataUtility();

      list<CaseComment> CaseCommentResult
                          = [SELECT Id, 
                                    CommentBody
                             FROM CaseComment
                             WHERE ParentId = :TestData.listCases[0].Id
                             AND CommentBody = 'Test New Comment'
                            ];
      //system.assertEquals('Test New Comment', CaseCommentResult[0].CommentBody);
      //system.assertEquals(1, CaseCommentResult.size());
  }
  
 @isTest static void testCaseCommentFormatting(){
        system.debug('begin testCaseCommentFormatting');

      //1024
      CaseComment cc = new CaseComment();
      cc.CommentBody = 'Aritesh Mohanty -- test\r\nRx Number -- Error Message\r\n16261605 - Adjudication Error (01) Product/Service Not Covered [70]\r\n15932906 - Adjudication Error (01) Product/Service Not Covered [70]\r\n16634079 - Adjudication Error (01) Product/Service Not Covered [70]';
      String wrappedResult = CaseUtility.wrapComment(cc.CommentBody);
      system.debug('XXinput: ' + cc.CommentBody);
      system.debug('XXresult:' + wrappedResult);
      system.assert(wrappedResult.length() > cc.CommentBody.length(), '1024 Characters Test' + wrappedResult.length() + ' result.length : input.length ' + cc.CommentBody.length());

      //200
      cc = new CaseComment();
      cc.CommentBody = 'ORDER #23838120 NEEDS TO BE REVERSED FROM MBRS PLAN THAT ENDED ON 09/09/2014 AND REBILLED TO PLAN THAT STARTED ON 09/01/2014 WITH THOMAS HOLT AS THE PRIMARY. Previous plan had Mrs. Kristen Holt as the';
      wrappedResult = CaseUtility.wrapComment(cc.CommentBody);
      system.debug('XXinput: ' + cc.CommentBody);
      system.debug('XXresult:' + wrappedResult);
      system.assertEquals(wrappedResult.length(), cc.CommentBody.length(), '200 Characters Test' + wrappedResult.length() + ' result.length : input.length ' + cc.CommentBody.length());
/*
      //201
      cc = new CaseComment();
      cc.CommentBody = 'ORDER #23838120 NEEDS TO BE REVERSED FROM MBRS PLAN THAT ENDED ON 09/09/2014 AND REBILLED TO PLAN THAT STARTED ON 09/01/2014 WITH THOMAS HOLT AS THE PRIMARY. Previous plan had Mrs. Kristen Holt as the1';
      wrappedResult = CaseUtility.wrapComment(cc);
      system.debug('XXinput: ' + cc.CommentBody);
      system.debug('XXresult:' + wrappedResult);
      system.assert(wrappedResult.length() > cc.CommentBody.length(), '201 Characters Test' + wrappedResult.length() + ' result.length : input.length ' + cc.CommentBody.length());

      //399
      cc = new CaseComment();
      cc.CommentBody = 'ORDER #23838120 NEEDS TO BE REVERSED FROM MBRS PLAN THAT ENDED ON 09/09/2014 AND REBILLED TO PLAN THAT STARTED ON 09/01/2014 WITH THOMAS HOLT AS THE PRIMARY. Previous plan had Mrs. Kristen Holt as thsaORDER #23838120 NEEDS TO BE REVERSED FROM MBRS PLAN THAT ENDED ON 09/09/2014 AND REBILLED TO PLAN THAT STARTED ON 09/01/2014 WITH THOMAS HOLT AS THE PRIMARY. Previous plan had Mrs. Kristen Holt as t';      wrappedResult = CaseUtility.wrapComment(cc);
      system.debug('XXinput: ' + cc.CommentBody);
      system.debug('XXresult:' + wrappedResult);
      system.assert(wrappedResult.length() > cc.CommentBody.length(), '399 Characters Test' + wrappedResult.length() + ' result.length : input.length ' + cc.CommentBody.length());

      //402
      cc = new CaseComment();
      cc.CommentBody = 'ORDER #23838120 NEEDS TO BE REVERSED FROM MBRS PLAN THAT ENDED ON 09/09/2014 AND REBILLED TO PLAN THAT STARTED ON 09/01/2014 WITH THOMAS HOLT AS THE PRIMARY. Previous plan had Mrs. Kristen Holt as thsaORDER #23838120 NEEDS TO BE REVERSED FROM MBRS PLAN THAT ENDED ON 09/09/2014 AND REBILLED TO PLAN THAT STARTED ON 09/01/2014 WITH THOMAS HOLT AS THE PRIMARY. Previous plan had Mrs. Kristen Holt as t65s';
      wrappedResult = CaseUtility.wrapComment(cc);
      system.debug('XXinput: ' + cc.CommentBody);
      system.debug('XXresult:' + wrappedResult);
      system.assert(wrappedResult.length() > cc.CommentBody.length(), '402 Characters Test' + wrappedResult.length() + ' result.length : input.length ' + cc.CommentBody.length());
*/
        System.debug('end testCaseCommentFormatting');
  }

   @isTest static void testcheckOriginalRequestDate(){
    CaseTestDataUtility TestData = new CaseTestDataUtility();
    //CaseUtility.checkOriginalRequestDate(TestData.listCases);
    CaseUtility.hasLetterValidationError(TestData.listCases);
   }
 /* @isTest static void testCommentSummary() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'closeOpenAssignmentHistories',
                                                            IsActive__c = true);
      insert RunTrigger10;
             
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      
      String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
      String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
         
      CreateAndAssignReviewFromCase__c CAAARFC_CTM
        = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
      insert CAAARFC_CTM;
      
      CreateAndAssignReviewFromCase__c CAAARFC_GRI
        = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
      insert CAAARFC_GRI;

      CaseTestDataUtility TestData = new CaseTestDataUtility();

      list<Case> CaseResult
                          = [SELECT Id, 
                                    Comment_Summary__c
                             FROM Case
                             WHERE Id = :TestData.listCases[0].Id
                            ];
      //Assert that comment summary contains notes
      system.assert(CaseResult[0].Comment_Summary__c.indexOf('Test New Comment') >= 0);
      //Assert that comment summary only contains notes once
      system.assertEquals(-1, CaseResult[0].Comment_Summary__c.substring(
        CaseResult[0].Comment_Summary__c.indexOf('Test New Comment')+1).indexOf('Test New Comment'));
  }*/

   @isTest static void testAddRequestType() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'closeOpenAssignmentHistories',
                                                            IsActive__c = true);
      insert RunTrigger10;
                   
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      /*
      String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
      String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
         
      CreateAndAssignReviewFromCase__c CAAARFC_CTM
        = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
      insert CAAARFC_CTM;
      
      CreateAndAssignReviewFromCase__c CAAARFC_GRI
        = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
      insert CAAARFC_GRI; */

      CaseTestDataUtility TestData = new CaseTestDataUtility();

      list<Case> CaseTestResult
                          = [SELECT Id, Request_Type_Lookup__r.Name 
                             FROM Case
                             WHERE Id = :TestData.listCases[0].Id
                             limit 1];
      system.assertEquals('Test Request Type', CaseTestResult[0].Request_Type_Lookup__r.Name);
  }

  @isTest static void testRemoveRequestType() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'closeOpenAssignmentHistories',
                                                            IsActive__c = true);
      insert RunTrigger10;
             
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      /*
      String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
      String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
         
      CreateAndAssignReviewFromCase__c CAAARFC_CTM
        = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
      insert CAAARFC_CTM;
      
      CreateAndAssignReviewFromCase__c CAAARFC_GRI
        = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
      insert CAAARFC_GRI; */

      CaseTestDataUtility TestData = new CaseTestDataUtility();

      test.startTest();
        TestData.listCases[0].Request_Type__c = null;
        update TestData.listCases[0];
      test.stopTest();

      list<Case> CaseTestResult
                          = [SELECT Id, Request_Type_Lookup__r.Name 
                             FROM Case
                             WHERE Id = :TestData.listCases[0].Id
                             limit 1];
      system.assertEquals(null, CaseTestResult[0].Request_Type_Lookup__r.Name);
  }

  /*@isTest static void testOverwriteNCQAFields() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'closeOpenAssignmentHistories',
                                                            IsActive__c = true);
      insert RunTrigger10;
      
            CaseTriggerSwitch__c RunTrigger11
        = new CaseTriggerSwitch__c(Name = 'setOriginalCreatedByData',
                                                            IsActive__c = true);
      insert RunTrigger11;
      
      List<Profile> profiles = [select id, name from Profile where 
                        name = 'System Administrator'];
      User NewTestUser = new User(alias = 'admin',
                                    email='testinsert@prime.com',
                                    emailencodingkey='UTF-8',
                                    lastname='User', languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    profileid = profiles[0].Id,
                                    timezonesidkey='America/Los_Angeles',
                                    username='testinsert@prime.com');
      insert NewTestUser;
      
      IntegrationUserID__c cs = new IntegrationUserID__c();
      cs.Name='IntegrationServiceID';
      cs.Integration_User_ID__c=NewTestUser.Id;
      insert cs;
             
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      
      String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
      String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
         
      CreateAndAssignReviewFromCase__c CAAARFC_CTM
        = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
      insert CAAARFC_CTM;
      
      CreateAndAssignReviewFromCase__c CAAARFC_GRI
        = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = UserInfo.getUserId()
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
      insert CAAARFC_GRI;

      String NCQAActionTypeId 
       = Schema.SObjectType.Case
                  .getRecordTypeInfosByName().get('NCQA Action Taken')
                  .getRecordTypeId();

      String NCQATypeId 
       = Schema.SObjectType.Case
                  .getRecordTypeInfosByName().get('PCT - NCQA')
                  .getRecordTypeId();

        Case NCQACase = new Case(Subject = 'Test Case ',              
                             Member_First_Name__c = 'Nick',
                             Member_Id__c = '1WILLDMN8',
                             Member_Last_Name__c = 'Cook',
                             Patient_Last_Name__c = 'Cook',
                             Name_on_Credit_Card__c = 'Name',
                             Prescriber_Called_In__c = TRUE,
                             Prescriber_Agent__c = 'Agent',
                             Assignment_Queue__c = 'Queue 2c - Ready for 1st Fax',
                             Information_Description_To_Add__c
                               = 'Test New Comment',
                             RecordTypeId = NCQATypeId);
        insert NCQACase;

        Case NCQAAction = new Case(NCQA_Case__c = NCQACase.Id,
                                 Cause__c = 'Test Cause',
                                 Cause_Reason__c = 'Test Reason',
                                 Task_Type__c = 'Test NCQA',
                                 Priority__c = 'Primary',
                                 Subject = 'Test Case ',              
                                 Member_First_Name__c = 'Nick',
                                 Member_Id__c = '1WILLDMN8',
                                 Member_Last_Name__c = 'Cook',
                                 Patient_Last_Name__c = 'Cook',
                                 Name_on_Credit_Card__c = 'Name',
                                 Prescriber_Called_In__c = TRUE,
                                 Prescriber_Agent__c = 'Agent',
                                 Assignment_Queue__c = 'Queue 2c - Ready for 1st Fax',
                                 Information_Description_To_Add__c
                                   = 'Test New Comment',
                                 RecordTypeId = NCQAActionTypeId
                                );
        insert NCQAAction;



      list<Case> CaseTestResult
                          = [SELECT Id, Primary_Action_Taken__c,
                             Primary_Cause__c,
                             Primary_Cause_Reason__c
                             FROM Case
                             WHERE Id = :NCQACase.Id
                             limit 1];
      system.assertEquals('Test Cause', CaseTestResult[0].Primary_Cause__c);
      system.assertEquals('Test Reason', CaseTestResult[0].Primary_Cause_Reason__c);
      system.assertEquals('Test NCQA', CaseTestResult[0].Primary_Action_Taken__c);

      Case NCQAAction2 = new Case(NCQA_Case__c = NCQACase.Id,
                                 Cause__c = 'Test Cause 2',
                                 Cause_Reason__c = 'Test Reason 2',
                                 Task_Type__c = 'Test NCQA 2',
                                 Priority__c = 'Primary',
                                 Subject = 'Test Case ',              
                                 Member_First_Name__c = 'Nick',
                                 Member_Id__c = '1WILLDMN8',
                                 Member_Last_Name__c = 'Cook',
                                 Patient_Last_Name__c = 'Cook',
                                 Name_on_Credit_Card__c = 'Name',
                                 Prescriber_Called_In__c = TRUE,
                                 Prescriber_Agent__c = 'Agent',
                                 Assignment_Queue__c = 'Queue 2c - Ready for 1st Fax',
                                 Information_Description_To_Add__c
                                   = 'Test New Comment',
                                 RecordTypeId = NCQAActionTypeId
                                );
      test.startTest();
        CaseRecursionHandler.alreadyOverwrittenNCQAFields = false;
        insert NCQAAction2;
      test.stopTest();
      list<Case> CaseTestResult2
                          = [SELECT Id, 
                             Priority__c
                             FROM Case
                             WHERE NCQA_Case__c = :NCQACase.Id
                             AND Priority__c = 'Primary'
                             ];
      
      system.assertEquals(1, CaseTestResult2.size());

      list<Case> CaseTestResult3
                          = [SELECT Id, Primary_Action_Taken__c,
                             Primary_Cause__c,
                             Primary_Cause_Reason__c
                             FROM Case
                             WHERE Id = :NCQACase.Id
                             ];
                
      system.assertEquals('Test Cause 2', CaseTestResult3[0].Primary_Cause__c);
      system.assertEquals('Test Reason 2', CaseTestResult3[0].Primary_Cause_Reason__c);
      system.assertEquals('Test NCQA 2', CaseTestResult3[0].Primary_Action_Taken__c);
  } */

/*  @isTest static void testCreateAndAssignReview() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;
      
      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'setOriginalCreatedByData',
                                                            IsActive__c = true);
      insert RunTrigger10;
      
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      
       //CaseTestDataUtility TestData = new CaseTestDataUtility();
       List<Profile> profiles = [select id, name from Profile where 
                        name = 'System Administrator'];
       User NewTestUser = new User(alias = 'admin',
                                    email='testagent@prime.com',
                                    emailencodingkey='UTF-8',
                                    lastname='User', languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    profileid = profiles[0].Id,
                                    timezonesidkey='America/Los_Angeles',
                                    username='testagent@prime.com');
       insert NewTestUser;
      
      IntegrationUserID__c cs = new IntegrationUserID__c();
      cs.Name='IntegrationServiceID';
      cs.Integration_User_ID__c=NewTestUser.Id;
      insert cs; 

         String ReviewRecordTypeCTM
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('CTM Quality Review')
                    .getRecordTypeId();
          String ReviewRecordTypeGri
         = Schema.SObjectType.Review__c
                    .getRecordTypeInfosByName().get('Grievance Quality Review')
                    .getRecordTypeId();
          String CaseRecordType
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Item: CTM Grievance')
                    .getRecordTypeId();

         CreateAndAssignReviewFromCase__c CAAARFC_CTM
         = new CreateAndAssignReviewFromCase__c (Name = 'CTM'
                                                  ,ReviewQueue__c = NewTestUser.Id
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeCTM);
         insert CAAARFC_CTM;
         CreateAndAssignReviewFromCase__c CAAARFC_GRI
         = new CreateAndAssignReviewFromCase__c (Name = 'Grievance'
                                                  ,ReviewQueue__c = NewTestUser.Id
                                                  ,ReviewRecorcdType__c = ReviewRecordTypeGri);
         insert CAAARFC_GRI;

        Request_Type__c newRequestTypeCTM 
          = new Request_Type__c(Name = 'Test Request Type CTM', Is_a_CTM__c = true, Is_a_Grievance__c = false);
        insert newRequestTypeCTM;

        Request_Type__c newRequestTypeGRI 
          = new Request_Type__c(Name = 'Test Request Type GRI', Is_a_CTM__c = false, Is_a_Grievance__c = true);
        insert newRequestTypeGRI;

        Case TestCase = new Case( RecordTypeId = CaseRecordType
                                  ,Member_Id__c = '12345'
                                  ,Member_Last_Name__c = 'Test'
                                  ,Member_First_Name__c = 'Test'
                                  ,Contact_Phone__c = '555-555-5555'
                                  ,Request_Type__c = newRequestTypeCTM.Name
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  );
        Case TestCase2 = new Case( RecordTypeId = CaseRecordType
                                  ,Member_Id__c = '12345'
                                  ,Member_Last_Name__c = 'Test'
                                  ,Member_First_Name__c = 'Test'
                                  ,Contact_Phone__c = '555-555-5555'
                                  ,Request_Type__c = newRequestTypeGRI.Name
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  );
        CaseRecursionHandler.alreadySetCreatedBy = false;
        insert TestCase;
        insert TestCase2;         
         test.startTest();
            TestCase.Request_Type__c = newRequestTypeGRI.Name;
            TestCase.Ready_for_QA_Review__c = true;
            testCase2.Request_Type__c = newRequestTypeCTM.Name;
            TestCase2.Ready_for_QA_Review__c = true;
            update TestCase;
            CaseRecursionHandler.alreadyAssignedReviews = false;
            update TestCase2;
         test.stopTest();

Case VerifyCase = [SELECT status,Request_Type__c, Request_Type_Lookup__c, Submitted_to_Quality_Review_by__c, 
                    Request_Type_Lookup__r.Is_a_CTM__c FROM Case WHERE Id = :testcase.id];

        list<Review__c> ReviewTestResult
                            = [SELECT Id                                
                               FROM Review__c
                               WHERE Reviewed_Item__c = :TestCase.Id OR Reviewed_Item__c = :TestCase2.Id 
                ];
      //system.assertEquals(2, ReviewTestResult.size());
  } */

  @isTest static void testInsertPQT() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;


      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;
      
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;

      CaseTestDataUtility TestData = new CaseTestDataUtility();
      test.startTest();
      PQT__c newPQT = new PQT__c(Case__c = TestData.listCases[0].Id
                                 ,Type__c = 'AEE'
                                 ,QB_Date_Time_Created__c = DateTime.Now()
                                );
        insert newPQT;
        update TestData.listCases[0];
      test.stopTest();
    } 

    @isTest static void testInsertPQTQueueError() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;
      

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;
      
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;

      CaseTestDataUtility TestData = new CaseTestDataUtility();
      test.startTest();
      PQT__c newPQT = new PQT__c(Case__c = TestData.listCases[0].Id
                                 ,Type__c = 'AEE'
                                 ,QB_Date_Time_Created__c = DateTime.Now()
                                );
        insert newPQT;
        TestData.listCases[0].Transfer_Doc_Name__c = 'Test Error';
        update TestData.listCases[0];
      test.stopTest();
    }  

    @isTest static void testFaxFieldMerge() {
      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;
      

      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;
      
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item'
                                         ,Task_Status__c = 'Sent'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;

      CaseTestDataUtility TestData = new CaseTestDataUtility();
      test.startTest();
        TestData.listCases[0].Assignment_Queue__c = 'Queue 2c – Ready for 1st Fax';
        update TestData.listCases[0];
      test.stopTest();
    }
    
    @isTest static void testInsertRefill() {
        List<Profile> profiles = [select id, name from Profile where 
                            name = 'Integration Service'];
        User NewTestUser = new User(alias = 'admin',
        email='testagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = profiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testintegration@prime.com');
        insert NewTestUser;    

        RxToCaseMap__c RxCaseMap 
          = new RxToCaseMap__c(Name='RX__c'
                               ,RX_Field_Name__c = 'RX__c'
                               ,Case_Field_Name__c = 'RX__c');

        insert RxCaseMap;

        IntegrationUserID__c IntegrationUserID 
          = new IntegrationUserID__c(Name='IntegrationServiceID'
                                   ,Integration_User_Id__c = NewTestUser.Id);
        insert IntegrationUserID;  

            CaseTriggerSwitch__c RunTrigger1
          = new CaseTriggerSwitch__c(Name = 'populatePharmacy',
                                                            IsActive__c = true);
        insert RunTrigger1;
        
        RxTriggerSwitch__c RunTrigger2
          = new RxTriggerSwitch__c(Name = 'copyDataToCase',
                                                           IsActive__c = true);
        insert RunTrigger2;  
        
        Case TestRefillCase1 = new Case(Member_First_Name__c = 'Nick',
                                 Member_Id__c = '1WILLDMN8',
                                 Member_Last_Name__c = 'Cook',
                                 Status = 'Open',
                                 Contact_Phone__c = '111-111-1111',
                                 RecordTypeId = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Order Refill')
                    .getRecordTypeId(),
                                 Shipping_Address_1__c = 'Test Drive',
                                 Shipping_City__c = 'Testville',
                                 Shipping_State__c = 'MN',
                                 Other_ZIP__c = '11111',
                                 Shipping_Method__c = 'USPS'
                                 );
        insert TestRefillCase1;
       
        Rx__c TestRefillRx1 = new Rx__c(Controlled_Drug_TF__c = TRUE,
                                        Cost__c = 1000, 
                    RecordTypeId = Schema.SObjectType.RX__c
                    .getRecordTypeInfosByName().get('Refill Rx')
                    .getRecordTypeId(),
                                        Days_Supply__c = 10,
                                        Directions__c = '2xDaily',
                                        Drug_Name__c = 'mycoxaphalin',
                                        Patient_DAW__c = true,
                                        Profile_Rx__c = true,
                                        Quantity__c = '100',
                                        Rx__c = '20000000',
                                        Prescribers_Name__c = 'Whats UpDoc',
                                        Related_Case__c = TestRefillCase1.Id
                                        );
      insert TestRefillRx1;
      
      list<Case> testCopiedRX = [SELECT Rx_1_Rx__c FROM Case WHERE ID = :TestRefillCase1.Id];
      system.assertEquals('20000000', testCopiedRX[0].Rx_1_Rx__c);

      test.startTest();
        update TestRefillCase1;
      test.stopTest();
      List<Case> lst_Case = new List<Case>();
      lst_case.add(TestRefillCase1);
      CaseUtility.syncAssignmentDateTimes(lst_Case);
      list<Case> TestCaseResult1 = [SELECT Pharmacy__c FROM Case WHERE ID = :TestRefillCase1.Id];
      system.assertEquals('Irving', TestCaseResult1[0].Pharmacy__c);
    } 

 @isTest static void testShareWithPlanUser() {
      List<Profile> intprofiles = [select id, name from Profile where 
                            name = 'Integration Service'];
        User NewIntUser = new User(alias = 'admin',
        email='testagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = intprofiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testintegration@prime.com');
      insert NewIntUser;   
     list<user> testUsers = new list<user>();
      system.runAs(NewIntUser) {
        List<Profile> profiles = [select id, name from Profile where 
                              name = 'Plan User'];
        List<UserRole> roles = [select id, name from UserRole where 
                              name = 'Commercial - AL'];
        User NewTestUser = new User(alias = 'puser',
          email='testplanuser@prime.com',
          emailencodingkey='UTF-8',
          lastname='User', languagelocalekey='en_US',
          localesidkey='en_US',
          profileid = profiles[0].Id,
          userroleid = roles[0].Id,
          timezonesidkey='America/Los_Angeles',
          username='testplanusern@prime.com',
          Plan_Account__c = 'BCBS Alabama');
          
          User NewUser = new User(alias = 'admin',
                                    email='testinsert@prime.com',
                                    emailencodingkey='UTF-8',
                                    lastname='User', languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    profileid = profiles[0].Id,
                                    timezonesidkey='America/Los_Angeles',
                                    username='testinsert@prime.com');
       
       
       User NewTestUser1 = new User(alias = 'admin',
                                    email='testupdate@prime.com',
                                    emailencodingkey='UTF-8',
                                    lastname='User', languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    profileid = profiles[0].Id,
                                    timezonesidkey='America/Los_Angeles',
                                    username='testupdate@prime.com');
       
      
      testUsers.add(NewTestUser);
      testUsers.add(NewUser);
      testUsers.add(NewTestUser1);
      insert testUsers;
      }

     


      CaseTriggerSwitch__c RunTrigger 
        = new CaseTriggerSwitch__c(Name = 'createAssignmentHistory',
                                                            IsActive__c = true);
      insert RunTrigger;


      CaseTriggerSwitch__c RunTrigger2
        = new CaseTriggerSwitch__c(Name = 'generateFaxHTML',
                                                            IsActive__c = true);
      insert RunTrigger2;

      CaseTriggerSwitch__c RunTrigger3
        = new CaseTriggerSwitch__c(Name = 'copyNotesToComment',
                                                            IsActive__c = true);
      insert RunTrigger3;

      CaseTriggerSwitch__c RunTrigger4
        = new CaseTriggerSwitch__c(Name = 'summarizeCaseComments',
                                                            IsActive__c = true);
      insert RunTrigger4;

      CaseTriggerSwitch__c RunTrigger5
        = new CaseTriggerSwitch__c(Name = 'manageFaxNumbers',
                                                            IsActive__c = true);
      insert RunTrigger5;

      CaseTriggerSwitch__c RunTrigger6
        = new CaseTriggerSwitch__c(Name = 'updateRequestTypeLookup',
                                                            IsActive__c = true);
      insert RunTrigger6;

      CaseTriggerSwitch__c RunTrigger7
        = new CaseTriggerSwitch__c(Name = 'overwritePrimaryNCQAFields',
                                                            IsActive__c = true);
      insert RunTrigger7;
      
      CaseTriggerSwitch__c RunTrigger8
        = new CaseTriggerSwitch__c(Name = 'CreateAndAssignReview',
                                                            IsActive__c = true);
      insert RunTrigger8;

      CaseTriggerSwitch__c RunTrigger9
        = new CaseTriggerSwitch__c(Name = 'UpdateAccountLookupFromPlan',
                                                            IsActive__c = true);
      insert RunTrigger9;

      CaseTriggerSwitch__c RunTrigger10
        = new CaseTriggerSwitch__c(Name = 'createPlanSharingRecords',
                                                            IsActive__c = true);
      insert RunTrigger10;
      
      CaseTriggerSwitch__c RunTrigger11 
        = new CaseTriggerSwitch__c(Name = 'hasLetterValidationError',
                                                            IsActive__c = true);
      insert RunTrigger11;
      
      CaseTriggerSwitch__c  RunTrigger12 
          = new CaseTriggerSwitch__c(Name = 'copyNotesToStdComment',
                                                            IsActive__c = true);  
    
      insert RunTrigger12;
     
      CaseTriggerSwitch__c RunTrigger13 
          = new CaseTriggerSwitch__c(Name = 'trackFieldChangesStd',
                                                            IsActive__c = true);  
    
      insert Runtrigger13;
      
      CaseTriggerSwitch__c  RunTrigger14 
          = new CaseTriggerSwitch__c(Name = 'copyNotesToCustomComment',
                                                            IsActive__c = true);  
    
      insert RunTrigger14;
     
      CaseTriggerSwitch__c RunTrigger15 
          = new CaseTriggerSwitch__c(Name = 'trackFieldChangesCustom',
                                                            IsActive__c = true);  
    
      insert Runtrigger15;
      
      CaseTriggerSwitch__c RunTrigger16 
          = new CaseTriggerSwitch__c(Name = 'trackFieldChangesStdSGC',
                                                            IsActive__c = true);  
    
      insert Runtrigger16;
      
      Case_Utility_Settings__c utilSettings = new Case_Utility_Settings__c(Name = 'Settings');
      insert utilSettings;
      
      PlanUserSharingRules__c PlanUserSharingRules 
        = new PlanUserSharingRules__c(Name = 'AL - BCBS Item Business Group'
                                         ,FieldName__c = 'Business_Group_Channel__c'
                                         ,FieldValue__c = 'PrimeMail,Retail'
                                         ,Case_Record_Type__c = 'PCT - Item'
                                         ,Plan_Contains__c = 'AL - BCBS'
                                         ,Shared_Roles__c = 'Commercial_AL'
                                        );
      insert PlanUserSharingRules;     

      PlanUserSharingRules__c PlanUserSharingRules2
        = new PlanUserSharingRules__c(Name = 'AL - BCBS Req Type Med Appeal'
                                         ,FieldName__c = 'Request_Type__c'
                                         ,FieldValue__c = 'Medicare - Appeal'
                                         ,Case_Record_Type__c = 'PCT - Item'
                                         ,Plan_Contains__c = 'AL - BCBS'
                                         ,Shared_Roles__c = 'Commercial_AL'
                                         ,IsExclude__c = true
                                        );
      insert PlanUserSharingRules2;  
      
      PlanUserSharingRules__c PlanUserSharingRules3
        = new PlanUserSharingRules__c(Name = 'Assigned To - Plan'
                                         ,FieldName__c = 'Request_Type__c'
                                         ,FieldValue__c = 'Medicare - Appeal'
                                         ,Case_Record_Type__c = 'PCT - Service Gesture'
                                         ,Plan_Contains__c = 'Assigned To - Plan'
                                         ,Shared_Roles__c = 'Commercial_AL'
                                         ,IsExclude__c = true
                                        );
      insert PlanUserSharingRules3;
      
      
      Account testPlanAccount 
        = new Account(Name = 'BCBS Alabama');
      insert testPlanAccount;
  
      PLan__c testALPlan 
        = new Plan__c(Name = 'AL - BCBS+B43'
                   ,Client__c = testPlanAccount.Id
                   ,Line_of_Business__c = 'Commercial'
                   ,Plan_Status__c = 'Active'
                   ,Plan_Group__c = 'BCBSAL');
      insert testALPlan; 
       list<case> testCaseList = new list<case>(); 
      String CaseRecordType
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Item')
                    .getRecordTypeId();
     String CaseRecordType1
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Order Refill')
                    .getRecordTypeId();
     String CaseRecordType2
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Service Gesture')
                    .getRecordTypeId();
     String CaseRecordType3
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - NCQA')
                    .getRecordTypeId();
     String CaseRecordType4
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Replacement Order Standalone')
                    .getRecordTypeId(); 
     
     String CaseRecordType5
         = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Replacement Order with Item')
                    .getRecordTypeId();
     Case TestCase = new Case(RecordTypeId = CaseRecordType
                                  ,Member_Id__c = '12345'
                                  ,Member_Last_Name__c = 'Test'
                                  ,Member_First_Name__c = 'Test'
                                  ,Contact_Phone__c = '555-555-5555'
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  ,Member_Plan_Lookup__c = testALPlan.Id
                                  ,Business_Group_Channel__c = 'PrimeMail'
                                  ,Request_Type__c = 'Early Refill'
                                  ,Case_Comments__c = 'Test'
                                  ,Information_Description_to_Add_Standard__c = 'Test'
                                  ,Other_Member_Notes__c = 'Test Notes'
                                  ,Original_Request_Date_Time__c = system.today()
                                  ,Resolution_Date_Time__c = system.today()+2
                                  ,Status = 'Open'
                                  ,Contact_Method__c = 'Phone'
                                  ,Group_Number__c='EP93600'
                               
                                  );
      testCaseList.add(testcase);
      Case TestCase1 = new Case(RecordTypeId = CaseRecordType1
                                  ,Member_Id__c = '1234521'
                                  ,Member_Last_Name__c = 'Testqw'
                                  ,Member_First_Name__c = 'Testas'
                                  ,Contact_Phone__c = '555-555-5255'
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  ,Member_Plan_Lookup__c = testALPlan.Id
                                  ,Business_Group_Channel__c = 'PrimeMail'
                                  ,Request_Type__c = 'Early Refill'
                                  ,Information_Description_to_Add_Standard__c = 'Test'
                                  ,Other_Member_Notes__c = 'Test Notes'
                                  ,Original_Request_Date_Time__c = system.today()
                                  ,Resolution_Date_Time__c = system.today()+2
                                  ,Status = 'Open'
                                  ,Contact_Method__c = 'Phone'
                                	,Group_Number__c='EP93600'
                                
                                  );
      
      testCaseList.add(testcase1);
      
      Case TestCase2 = new Case(RecordTypeId = CaseRecordType2
                                  ,Member_Id__c = '1234521'
                                  ,Member_Last_Name__c = 'Testqwtest'
                                  ,Member_First_Name__c = 'Testas'
                                  ,Contact_Phone__c = '555-555-5255'
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  ,Member_Plan_Lookup__c = testALPlan.Id
                                  ,Business_Group_Channel__c = 'PrimeMail'
                                  ,Request_Type__c = 'Early Refill'
                                  ,Information_Description_to_Add_Standard__c = 'Test'
                                  ,Other_Member_Notes__c = 'Test Notes'
                                  ,Original_Request_Date_Time__c = system.today()
                                  ,Resolution_Date_Time__c = system.today()+2
                                  ,Status = 'Open'
                                  ,Contact_Method__c = 'Phone'
                                  ,Group_Number__c='EP93600'
                                	
                                  );
      
      testCaseList.add(testcase2);
      
      Case TestCase3 = new Case(RecordTypeId = CaseRecordType3
                                  ,Member_Id__c = '1234521'
                                  ,Member_Last_Name__c = 'Testqwqa'
                                  ,Member_First_Name__c = 'Testas'
                                  ,Contact_Phone__c = '555-555-5235'
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  ,Member_Plan_Lookup__c = testALPlan.Id
                                  ,Business_Group_Channel__c = 'PrimeMail'
                                  ,Request_Type__c = 'Early Refill'
                                  ,Information_Description_to_Add_Standard__c = 'Test'
                                  ,Other_Member_Notes__c = 'Test Notes'
                                  ,Original_Request_Date_Time__c = system.today()
                                  ,Resolution_Date_Time__c = system.today()+2
                                  ,Status = 'Open'
                                  ,Contact_Method__c = 'Phone'
                                   ,Group_Number__c='EP93600'
                                
                                  );
      
      testCaseList.add(testcase3);
      
      Case TestCase4 = new Case(RecordTypeId = CaseRecordType4
                                  ,Member_Id__c = '1234521'
                                  ,Member_Last_Name__c = 'Testqw'
                                  ,Member_First_Name__c = 'Testas'
                                  ,Contact_Phone__c = '555-555-5255'
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  ,Member_Plan_Lookup__c = testALPlan.Id
                                  ,Business_Group_Channel__c = 'PrimeMail'
                                  ,Request_Type__c = 'Early Refill'
                                  ,Information_Description_to_Add_Standard__c = 'Test'
                                  ,Other_Member_Notes__c = 'Test Notes'
                                  ,Original_Request_Date_Time__c = system.today()
                                  ,Resolution_Date_Time__c = system.today()+2
                                  ,Status = 'Open'
                                  ,Contact_Method__c = 'Phone'
                                  ,Group_Number__c='EP93600'
                                
                                  );
      
      testCaseList.add(testcase4);
      
      Case TestCase5 = new Case(RecordTypeId = CaseRecordType5
                                  ,Member_Id__c = '1234521'
                                  ,Member_Last_Name__c = 'Testqw'
                                  ,Member_First_Name__c = 'Testas'
                                  ,Contact_Phone__c = '555-555-5255'
                                  ,Plan_Line_of_Business__c = 'Commercial'
                                  ,Ready_for_QA_Review__c = true
                                  ,Member_Plan_Lookup__c = testALPlan.Id
                                  ,Business_Group_Channel__c = 'PrimeMail'
                                  ,Request_Type__c = 'Early Refill'
                                  ,Information_Description_to_Add_Standard__c = 'Test'
                                  ,Other_Member_Notes__c = 'Test Notes'
                                  ,Original_Request_Date_Time__c = system.today()
                                  ,Resolution_Date_Time__c = system.today()+2
                                  ,Status = 'Open'
                                  ,Contact_Method__c = 'Phone'
                                  ,Group_Number__c='EP93600'
                                  
                                  );
      
      testCaseList.add(testcase5);
      
      CaseTaskValidationTypes__c ValidationTypes 
        = new CaseTaskValidationTypes__c(Name = 'Letter'
                                         ,Record_Types__c = 'PCT - Item, PCT - Order Refill,PCT - Service Gesture'
                                         ,Task_Status__c = 'Sent,Closed'
                                         ,Task_Types__c = 'Member Letter Sent, Extension Letter Sent, QOC Letter Sent'
                                         ,Case_Status__c = 'Resolved, Closed'
                                        );
      insert ValidationTypes;
      
                               
      insert TestCaseList;
      test.startTest();
      Task testTask = new task(Subject='Test Task', WhatId= TestCaseList[0].Id, Type = 'Member Letter Sent');
      try{
          insert testTask;
      }
      catch(exception e){
      }
      List<Case> lst_Case = new List<Case>{TestCase};
      CaseUtility.syncAssignmentDateTimes(lst_Case);
      List<CaseComment> lst_CaseComment = new List<CaseComment>();
      lst_CaseComment.add(new CaseComment(parentId = TestCaseList[0].Id, CommentBody='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
       'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
       'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'+
      'TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'));
       
       
       
       lst_CaseComment.add(new CaseComment(parentId = TestCaseList[0].Id,CommentBody='TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest'));
        insert lst_CaseComment;
      CaseUtility.formatCaseComments(lst_CaseComment);
      CaseUtility.validateCaseComments(TestCaseList);
      CaseUtility.updateRequestTypeLookup(TestCaseList, 'Insert');
      CaseUtility.emailListCases.addAll(TestCaseList);
      CaseUtility.sendEmail();
      CaseUtility.hasLetterValidationError(TestCaseList);
      Boolean isOut = CaseUtility.isOutsideHours();
      list<case> updateCase = [select Id,Owner.Id, RecordTypeId, Original_Request_Date_Time__c,Information_Description_to_Add_Standard__c, Resolution_Date_Time__c from case where Id In: testCaseList ];
      if(updateCase.size()>0){
          updateCase[0].Original_Request_Date_Time__c = system.today()-4;
          updateCase[0].Resolution_Date_Time__c = system.today()+6;
          updateCase[0].Information_Description_to_Add_Standard__c = 'Test';
          updateCase[0].Other_Member_Notes__c = 'New Test Note';
          updateCase[0].Status = 'Renewal Hold';
          updateCase[0].OwnerId = testUsers[0].Id;
          updateCase[1].Original_Request_Date_Time__c = system.today()-4;
          updateCase[1].Information_Description_to_Add_Standard__c = 'New Test';
          updateCase[1].Other_Member_Notes__c = 'New note';
          updateCase[1].Resolution_Date_Time__c = system.today()+6;
          updateCase[1].Status = 'Renewal Hold';
          updateCase[1].OwnerId = testUsers[1].Id;
          //updateCase[0].RecordTypeId = CaseRecordType2;
          //updateCase[1].RecordTypeId = CaseRecordType2;
          CaseUtility.isResolutionTracked = true;
          CaseUtility.isStatusTracked = true;
          CaseUtility.isCustomTrack = true;
          //PCT - Item: CTM Grievance
          update updateCase;
      }
      
  test.stopTest();  
  } 
   @isTest static void updateEmpGroup() {
       Case caseobj=new Case();
      caseobj.Group_Number__c='EP93600';
       caseobj.RecordTypeId='012i0000000rPfbAAE';
       caseobj.ParentId='500e0000008JkN7AAK';
        list<case> listCases=new List<Case>() ;
       listCases.add(caseobj);
 
   }
      
   @isTest static void fhcpValidation() {
       Case caseobj=new Case();
      caseobj.ownerId='005i0000003SQ8u';
       caseobj.Member_Plan_Name__c='Medicare - FL - PARTB - H1035';
       
        list<case> listCases=new List<Case>() ;
       listCases.add(caseobj);
 
   }
  
}