public without sharing class TaskUtility {
    public static boolean isExecuting = true;
    public static boolean firstRun = true;
  public static map<Id,string> validateRecordTypeMatch(list<Task> listTasks){
    map<Id,string> retMap = new map<Id,String>();
    String ValidationError = null;
    map<String, ActivityRecordTypeValidation__c> mapActivityRecordTypeValidations
      = ActivityRecordTypeValidation__c.getAll();
    map<Id, String> mapTasktoCaseRecordType
      = new map<Id, String>();
    map<Id, Id> mapCaseIdTaskId
      = new map<Id, Id>();
    
    for(Task thisTask : listTasks){
      if(thisTask.WhatId != null) {
          if(String.valueOf(thisTask.WhatId).startsWith('500')){
            mapTasktoCaseRecordType.put(thisTask.Id, '');
            mapCaseIdTaskId.put(thisTask.WhatId, thisTask.Id);
          }
      }
    }

    for(Case thisCase : [SELECT Id, RecordType.Name FROM Case 
                           WHERE Id IN :mapCaseIdTaskId.keySet()]){
      mapTasktoCaseRecordType.put(mapCaseIdTaskId.get(thisCase.Id), thisCase.RecordType.Name);
    }

    for(Task thisTask : listTasks){
      String TaskRecordType  = Schema.SObjectType.Task
                                    .getRecordTypeInfosById()
                                    .get(thisTask.RecordTypeId).getName();
      if(mapActivityRecordTypeValidations.containsKey(TaskRecordType)){
        if(!(mapActivityRecordTypeValidations.get(TaskRecordType).Case_Record_Type__c.contains(
                                    mapTasktoCaseRecordType.get(thisTask.Id)))){
          ValidationError = 'Activity record type ' + TaskRecordType 
                   + ' does not match the record type on the parent Case: ' 
                   + mapTasktoCaseRecordType.get(thisTask.Id) + '. \r\n \r\n  ';
          if(!retMap.containsKey(mapTasktoCaseRecordType.get(thisTask.Id)))
          	retMap.put(thisTask.Id,ValidationError);
          break;
        }
      }
    }
    return retMap;
  }

  public static void updateCaseFields(list<Task> listTasks){
    map<String, ActivityMemberLetterSent__c> LetterSentCheck
      = ActivityMemberLetterSent__c.getAll();
    List<Case> listUpdateCases = new list<Case>();

    for(Task thisTask : listTasks){
      if(thisTask.WhatId != null && String.valueOf(thisTask.WhatId).startsWith('500')){
        for(String thisLetterSentCheck : LetterSentCheck.keySet()){
          if(LetterSentCheck.get(thisLetterSentCheck).Name != null 
                                           && thisTask.Type != null){
            if(LetterSentCheck.get(thisLetterSentCheck).Name.Contains(thisTask.Type)
                && LetterSentCheck.get(thisLetterSentCheck).Activity_Status__c.Contains(thisTask.Status)){
               Case updCase = new Case(Id = thisTask.WhatId);
               updCase.put(LetterSentCheck.get(thisLetterSentCheck).Case_Field_to_Set__c, true);
               //updCase.put(LetterSentCheck.get(thisLetterSentCheck).Case_Date_Field__c, datetime.NOW());
               listUpdateCases.add(updCase);
            }
          }
        }
      }
    }
    if(listUpdateCases.size() > 0){
      update listUpdateCases;
    }
  }

  public static void defaultTypeForIssueResolution(list<Task> listTasks){
    for(Task thisTask : listTasks){
      if(thisTask.Subject.contains('Issue/Resolution Attachment')
                                        &&  thisTask.Type == null){
        thisTask.Type = 'Issue/Resolution Attachment';
      }
    }
  }
  public static void checkStaTusToUpdate(list<Task> listTasks){
        
    set<string> statusValues = new set<string>{'Completed','Sent','Printed'};
    set<Id> caseIds = new set<Id>();
    set<Id> taskIds = new set<Id>();
    list<case> casesToUpdate = new list<case>();
    boolean isQCCheck = false;
    boolean isExtension = false;
    boolean isGrievAck = false;
    boolean isGrievTimely = false;
    boolean isMRSRerch = false;
    boolean isMemltr = false;
    boolean isGrvTmlyAck = false;
    for(Task thisTask : listTasks){
        if(String.valueOf(thisTask.WhatId).startsWith('500')){
            caseIds.add(thisTask.WhatId);
            taskIds.add(thisTask.Id);
        }
        
    }
    
    System.debug('caseIds++++'+caseIds);
    if(caseIds.size()>0){       
        for(Case cs : [SELECT Id,Medicare_Extension_Ltr_Sent_CMS_Rpt__c,RecordTypeId, Extension_Letter_Sent__c,Grievance_Acknowledgement_Letter_sent__c,Prime_Receipt_Date_Time__c,
                        Grievance_Timely_Filing_Letter_sent__c,QC_Check_Extension_Letter_SentR__c,QOC_Letter_SentR__c,Member_Letter_SentR__c, (select Id,status,Type,Date_Time_Completed__c from tasks where whatId in: caseIds) FROM Case where id=: caseIds]){
            System.debug('Inside 1st For ++++'+cs);
            system.debug('cs.RecordTypeId::- '+cs.RecordTypeId);
                if(cs.RecordTypeId == '012i0000000rJC7' || cs.RecordTypeId == '012i0000001M7Co'){
                    system.debug('isQCCheck@@@:: '+isQCCheck);
                    system.debug('cs.RecordTypeId::- '+cs.RecordTypeId);
                   for(task tsk: cs.tasks){
                    System.debug('Inside 2nd For ++++'+tsk);
                    if(statusValues.contains(tsk.status) && (tsk.Type == 'QC Check Extension Letter Sent') ){
                         isQCCheck = true; 
                         system.debug('isQCCheck INSIDE@@@:: '+isQCCheck); 
                         continue;
                    }                   
                   
                    if(statusValues.contains(tsk.status) && tsk.Type == 'Extension Letter' ){
                        isExtension = true;
                        continue;
                    }
                    if(statusValues.contains(tsk.status) && tsk.Type == 'Grievance Acknowledgement Letter' ){
                        isGrievAck = true;
                        //system.debug(tsk.Date_Time_Completed__c+'<<<TASK>>>'+cs.Prime_Receipt_Date_Time__c+'------>>'+Math.abs(integer.valueOf(tsk.Date_Time_Completed__c.date().daysBetween(cs.Prime_Receipt_Date_Time__c.date()))));
                        if(tsk.Date_Time_Completed__c != null){
                            system.debug('HTHIS>>>');
                            if(dateDiff(cs.Prime_Receipt_Date_Time__c,tsk.Date_Time_Completed__c)){
                              isGrvTmlyAck = true;
                              system.debug('HEREEEEE>>>');
                            }
                            
                        }
                        
                        continue;
                    }
                    if(statusValues.contains(tsk.status) && tsk.Type == 'Grievance Timely Filing Letter'){
                        isGrievTimely = true;
                        continue;
                    }  
                    
                    if(statusValues.contains(tsk.status) && tsk.Type == 'QOC Letter' ){
                        isMRSRerch = true;
                        continue;
                    }
                    if(statusValues.contains(tsk.status) && tsk.Type == 'Member Letter' ){
                        isMemltr = true;
                        continue;
                    }
                } 
                
                System.debug('isQCCheck ++++'+isQCCheck);
                if(isQCCheck){
                    system.debug('cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c@@@:: '+cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c);
                    system.debug('cs.QC_Check_Extension_Letter_SentR__c@@@:: '+cs.QC_Check_Extension_Letter_SentR__c);
                    cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c = true;
                    cs.QC_Check_Extension_Letter_SentR__c = true;
                    system.debug('cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c@@@##:: '+cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c);
                    system.debug('cs.QC_Check_Extension_Letter_SentR__c@@@###:: '+cs.QC_Check_Extension_Letter_SentR__c);
                }
                else{
                    cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c = false;
                    cs.QC_Check_Extension_Letter_SentR__c=false;  
                    system.debug('cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c##:: '+cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c);
                    system.debug('cs.QC_Check_Extension_Letter_SentR__c###:: '+cs.QC_Check_Extension_Letter_SentR__c);
                }
                    
                if(isExtension){
                    cs.Extension_Letter_Sent__c = true;
                    cs.Medicare_Extension_Ltr_Sent_CMS_Rpt__c = true;
                }
                else
                    cs.Extension_Letter_Sent__c = false;    
                
                
                if(isGrievAck){
                    cs.Grievance_Acknowledgement_Letter_sent__c = true;
                }
                else
                    cs.Grievance_Acknowledgement_Letter_sent__c = false;
                
                if(isGrievTimely){
                    cs.Grievance_Timely_Filing_Letter_sent__c = true;
                }
                else
                    cs.Grievance_Timely_Filing_Letter_sent__c = false;
                    
                if(isMRSRerch){
                    cs.QOC_Letter_SentR__c = true;
                }
               else
                    cs.QOC_Letter_SentR__c = false;
                    
                if(isMemltr){
                    cs.Member_Letter_SentR__c = true;
                }
                else
                    cs.Member_Letter_SentR__c = false;     
                
                if(isGrvTmlyAck){
                  system.debug('THEREE IF>>>');
                    cs.Grievance_Timely_Acknowledged__c = true;
                }
                else{
                  system.debug('THEREE ELSE>>>');
                  cs.Grievance_Timely_Acknowledged__c = false;
                }

                casesToUpdate.add(cs);
                
                }
                
        }
    }
    
    System.debug('casesToUpdate ++++'+casesToUpdate);
    if(casesToUpdate.size()>0){      
      Database.SaveResult[] srList = Database.update(casesToUpdate, false);
       map<StatusCode, string> errorMap = new map<StatusCode, string>();
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) { 
            if (!sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Case. Case ID: ' + sr.getId());
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errorMap.put(err.getStatusCode(), err.getMessage());
                }  
            }
            else{
                System.debug('Successfully updated Case. Case ID: ' + sr.getId());  
            }
        }   
                 
        if(errorMap.size()>0){
            for(task tsk : listTasks){
                if(errorMap.containsKey(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION))
                    tsk.addError(errorMap.get(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)); 
            }
        }    
    
                   
       
    }
       /**/
        
  }

  public static void LetterActivitiesValidation(list<Task> listTasks){
    set<Id> allowedProfiles = new set<Id>();
    map<Id,case> caseMap = new map<Id,case>();
    set<Id> caseIds = new set<Id>();
    for(profile pro : [Select Id,Name from Profile Where Name like '%MMRT%']){
        allowedProfiles.add(pro.Id);
    }   
    set<string> taskTypes = new set<string>{'Member Letter','Extension Letter','QOC Letter','QC Check Extension Letter Sent','Grievance Acknowledgement Letter','Grievance Timely Filing Letter'};
    //set<string> statusValues = new set<string>{'Completed','Sent','Printed'};
    map<string,string> errorsMap = new map<string,string>();
    string msg = 'Select Status as \'Completed\' when no attachment is needed and as \'Sent\' or \'Printed\' when there is an attachment';
    string msg1 = 'You can not set the Status to Complete. Add an attachment and set the Status to Sent or Printed';
    set<Id> taskIds = new set<Id>();
    for(Task thisTask : listTasks){
        if(String.valueOf(thisTask.WhatId).startsWith('500')){
            taskIds.add(thisTask.Id);
            caseIds.add(thisTask.WhatId);
        }
    }

    caseMap = new map<Id,case>([Select Id,IsAdminUser__c from case where Id IN: caseIds ]);
    //
    for(Task tsk : [Select Id, Type , Status, WhatId, (Select Id from Attachments) from Task where Id IN: taskIds]){
        system.debug('IN TASK>>'+tsk); 
        integer attCount = tsk.Attachments != null ? tsk.Attachments.size() : 0;
        boolean byPass = caseMap != Null && caseMap.containsKey(tsk.WhatId) ? caseMap.get(tsk.WhatId).IsAdminUser__c : false;
        //If not an admin or integration user
        if(!byPass){
          if(taskTypes.Contains(tsk.type) && tsk.Status == 'Completed' && attCount > 0)
            errorsMap.put(tsk.Id,msg);
          else if(taskTypes.Contains(tsk.type) && tsk.Status == 'Completed' && !allowedProfiles.Contains(userInfo.getProfileId()))
            errorsMap.put(tsk.Id,msg1);
        }
        
    }

    if(errorsMap != null && errorsMap.size() > 0){
      for(Task t : listTasks){
        if(errorsMap.containsKey(t.Id))
          t.addError(errorsMap.get(t.Id));
      }
    } 
  }


  public static boolean dateDiff(dateTime taskDateTime, dateTime primeDateTime){
    boolean isValid =false;
    system.debug(taskDateTime+'<<>>'+primeDateTime);
    integer intDays = 10;
    if(taskDateTime != null && primeDateTime != null)
      intDays =  Math.abs(integer.valueOf(taskDateTime.Date().daysBetween(primeDateTime.Date())));
    if(intDays <= 5){
      //datetime sameDayEndDate = taskDateTime.addDays(intDays);
      //if(sameDayEndDate.getTime() > primeDateTime.getTime())
        isValid = true;
    } 
    return isValid;
  }
  
  }