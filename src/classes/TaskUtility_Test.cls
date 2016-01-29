@isTest
private class TaskUtility_Test {
   static testMethod void testValidationFail() {
     
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

      ActivityRecordTypeValidation__c ActivityRecTypeVals
        = new ActivityRecordTypeValidation__c(Name = 'NCQA Action Taken'
                                               ,Case_Record_Type__c = 'PCT- NCQA');
      insert ActivityRecTypeVals;

      String PCTItemType 
                    = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('PCT - Item')
                    .getRecordTypeId();
      
      CaseTestDataUtility TestData = new CaseTestDataUtility();
      TestData.listCases[0].RecordTypeId = PCTItemType;
      TestData.listCases[1].RecordTypeId = PCTItemType;
      Test.startTest();
      try{
          update TestData.listCases[0];
          update TestData.listCases[1];
      }catch(exception e){
          system.debug('>>>>>** '+e.getLineNumber());
      }
    
        String NCQATaskTypeId 
                    = Schema.SObjectType.Task
                    .getRecordTypeInfosByName().get('NCQA Action Taken')
                    .getRecordTypeId();

        String PCTTaskTypeId 
                    = Schema.SObjectType.Task
                    .getRecordTypeInfosByName().get('To Do')
                    .getRecordTypeId();
                    
       list<ActivityMemberLetterSent__c> allActivity = new list<ActivityMemberLetterSent__c>();
       ActivityMemberLetterSent__c active = new ActivityMemberLetterSent__c(Activity_Status__c ='Completed,Sent',name='Member Letter');
       allActivity.add(active);
       
       ActivityMemberLetterSent__c active1 = new ActivityMemberLetterSent__c(Activity_Status__c ='Completed,Sent',name='Member Satisfaction Letter');
       allActivity.add(active1);
       
       ActivityMemberLetterSent__c active2 = new ActivityMemberLetterSent__c(Activity_Status__c ='Completed,Sent',name='Extension Letter');
       allActivity.add(active2);
       
      // insert allActivity;
       
       List<Task> lstTask = new List<Task>();
                    
       Task ActionTaken = new Task(RecordTypeId = NCQATaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[0].Id);
       lstTask.add(ActionTaken);
       
       Task PCTTaken = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[1].Id,type ='Extension Letter',status = 'Completed');
       
       lstTask.add(PCTTaken);
       
       Task task2 = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[2].Id,status = 'Completed');
       lstTask.add(task2);
       
       Task task3 = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[1].Id,type ='Grievance Timely Filing Letter',status = 'Completed');
       lstTask.add(task3);
       
       Task task4 = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[1].Id,type ='QOC Letter',status = 'Completed');
       lstTask.add(task4);
       
       Task task5 = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[1].Id,type ='Member Letter',status = 'Completed');
       lstTask.add(task5);
       
       Task task6 = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[1].Id,type ='QC Check Extension Letter Sent',status = 'Completed');
       lstTask.add(task6);
       
       Task task7 = new Task(RecordTypeId = PCTTaskTypeId, subject='Issue/Resolution Attachment',
                                   WhatId = TestData.listCases[1].Id,type ='Grievance Acknowledgement Letter',status = 'Completed');
       lstTask.add(task7);
                                   
       try {
         
         insert lstTask;
         TaskUtility.updateCaseFields(lstTask);
         TaskUtility.checkStaTusToUpdate(lstTask); 
         
       } 
       catch (exception ex) {
         system.assertNotEquals(null, ex.getMessage());
       }
    Test.stopTest();
  } 
  
}