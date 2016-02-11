public without sharing class CaseUtility {
  public static Boolean isInsertOnly = false;
  public static boolean isBeforeUpdate = true;
  public static boolean isBeforeInsert = true;
  public static boolean isSGC = true;
  public static boolean isCustomTrack = true;
  public static list<case> emailListCases = new list<case>();
  static set<Id> errorSet = new set<Id>();
  static set<Id> errorIdsSet = new set<Id>();
  static list<CaseComment> listInsertComments = new list<CaseComment>();
  static list<CaseComment> listInsertCommentsSGC = new list<CaseComment>();
  //static boolean isExecuting = false;
  private static set<Id> setCaseIds
    = new set<Id>();
  private static map<Id, String> mapOwnerNames 
    = new map<Id, String>();   
  private static map<Id, String> mapAssignedToPlanNames 
    = new map<Id, String>();  
  private static map<Id, String> mapAssignedToPrimeNames 
    = new map<Id, String>();   
  private static map<Id, Assignment_History__c> mapAssignmentUpserts 
    =  new map<Id, Assignment_History__c>();  
  private static list<Assignment_History__c> listAssignmentInserts 
    =  new list<Assignment_History__c>();    
  private static map<Id, Assignment_History__c> mapPriorOwnerAssignments
    = new map<Id, Assignment_History__c>();
  private static map<Id, Assignment_History__c> mapPriorQueueAssignments
    = new map<Id, Assignment_History__c>();  
  private static map<Id, Assignment_History__c> mapPriorPlanAssignments
    = new map<Id, Assignment_History__c>();
  private static map<Id, Assignment_History__c> mapPriorPrimeAssignments
    = new map<Id, Assignment_History__c>();  
  private static final string OWNER_ASSIGNMENT_TYPE = 'Owner Change';
  private static final string QUEUE_ASSIGNMENT_TYPE = 'Queue Change';
  private static final string PRIME_ASSIGNMENT_TYPE = 'Assigned To - Prime Change';
  private static final string PLAN_ASSIGNMENT_TYPE = 'Assigned To - Plan  Change';
  private static final set<String> setReadOnlyQueues = new set<String>{'Historical Items & Transfers Queue',
                                                                        'Protected Items & Transfers Queue'};
                      
  
  static string timeStamp = '<b>'+'Created By: '+ '<u>'+userinfo.getName()+'</u>'+' ('+system.now().format('MM/dd/yyyy h:mm a')+ ')'+'</b> <br/>';
  
  private static boolean run = true;
  public static boolean runOnce(){
    if(run){
        run=false;
        return true;
    }
    else{
        return run;
        }
  }
  
  
  public static void closeOpenAssignmentHistories(list<Case> listCases){
    map<Id, Case> mapClosedCases = new map<Id, Case>();
    for(Case thisCase : listCases){
      if(thisCase.IsClosed){
        mapClosedCases.put(thisCase.Id, thisCase);
      }
    }
    
    list<Assignment_History__c> listOpenAssignments 
      = new list<Assignment_History__c>();
    for(Assignment_History__c thisOpenAssignment : [SELECT Id, 
                                                      Case__c 
                                                    FROM Assignment_History__c
                                                    WHERE Assignment_End_Date__c = null
                                                    AND Case__c IN :mapClosedCases.keySet()]){
      thisOpenAssignment.Assignment_End_Date__c 
        = mapClosedCases.get(thisOpenAssignment.Case__c).ClosedDate;
      listOpenAssignments.add(thisOpenAssignment);
    }
    update listOpenAssignments;
  }

  public static void syncAssignmentDateTimes(List<Case> listCases) {

    Map<String, Case> caseIdMap = new Map<String, Case>();
    Map<String, List<Assignment_History__c>> caseIdAssignmentHistoryMap = new Map<String, List<Assignment_History__c>>();

    // Populate the Case Id map
    for(Case c : listCases) {
       caseIdMap.put(c.Id, c); 
    }

    List<Assignment_History__c> allAssignmentHistory = [SELECT Id, 
                                                            Name, 
                                                            Case__c, 
                                                            Created_Date_Time_of_Assignment_History__c, 
                                                            Assignment_End_Date__c
                                                        FROM Assignment_History__c
                                                        WHERE Case__c in :caseIdMap.keySet()
                                                        ORDER BY Case__c ASC, Created_Date_Time_of_Assignment_History__c DESC];

    // Populate the Case Id to Assignment History map
    for(Assignment_History__c a : allAssignmentHistory) {

        List<Assignment_History__c> assignmentList = caseIdAssignmentHistoryMap.get(a.Case__c);        
        if(assignmentList == null) {
            assignmentList = new List<Assignment_History__c>();
            caseIdAssignmentHistoryMap.put(a.Case__c, assignmentList);
        }
        assignmentList.add(a);
    }

    // Go through Assignment History for each Case
    for(Case c : listCases) {
        
        List<Assignment_History__c> history = caseIdAssignmentHistoryMap.get(c.Id);
        
        if(history == null) {
            continue;
        }
        /* Check each assignment history entry to see if it matches 
        criteria for the following 3 fields, and assign appropriately:

        1. Plan_Response_Received_Date_Time__c
        2. Plan_Assigned_Date_Time__c
        3. Prime_Assigned_Date_Time__c
        */
        for(Assignment_History__c h : history) {
            // Workaround for Assignment history name 'null' bug
            if(h.name.contains('- null')) {
                continue;
            }

            if(h.name.contains('Assigned To - Plan')) {          
                // If the case doesn't have a value yet or the date is newer than already set
                if(c.Plan_Assigned_Date_Time__c == null || h.Created_Date_Time_of_Assignment_History__c > c.Plan_Assigned_Date_Time__c) {
                    c.Plan_Assigned_Date_Time__c = h.Created_Date_Time_of_Assignment_History__c;
                }

                // If we have a response from the plan
                if(h.Assignment_End_Date__c != null) {
                    // If the case doesn't have a value yet or the date is newer than already set
                    if(c.Plan_Response_Received_Date_Time__c == null || h.Assignment_End_Date__c > c.Plan_Response_Received_Date_Time__c) {
                        // Set plan response date/time
                        c.Plan_Response_Received_Date_Time__c = h.Assignment_End_Date__c;
                    }
                }
            }
            else if(h.name.contains('Assigned To - Prime')) {
                // If the case doesn't have a value yet or the date is newer than already set
                if(c.Prime_Assigned_Date_Time__c == null || h.Created_Date_Time_of_Assignment_History__c > c.Prime_Assigned_Date_Time__c) {
                    c.Prime_Assigned_Date_Time__c = h.Created_Date_Time_of_Assignment_History__c;
                }
            }
        }
    }
  }

  public static void createAssignmentHistory(list<Case> listCases, 
                                             map<Id, Case> mapOldCases){
    if(!CaseRecursionHandler.hasCreatedAssignments()){
        for(Case thisCase : listCases) {
          setCaseIds.add(thisCase.Id);  
        }
        fetchCaseOwnerNames();
        if(mapOldCases == null) { 
          for(Case thisCase : listCases){
            Assignment_History__c OwnerAssignmentHistory
              = new Assignment_History__c(Assignment_Type__c = OWNER_ASSIGNMENT_TYPE,
                                          Name = OWNER_ASSIGNMENT_TYPE 
                                            + ' - ' + mapOwnerNames.get(thisCase.Id),
                                            Assignee__c = mapOwnerNames.get(thisCase.Id),
                                            Case__c = thisCase.Id);
            listAssignmentInserts.add(OwnerAssignmentHistory);
            if(thisCase.Assignment_Queue__c != null) {
              Assignment_History__c QueueAssignmentHistory
                = new Assignment_History__c(Assignment_Type__c = QUEUE_ASSIGNMENT_TYPE,
                                            Name = QUEUE_ASSIGNMENT_TYPE
                                              + ' - ' + thisCase.Assignment_Queue__c,
                                              Assignee__c = thisCase.Assignment_Queue__c,
                                              Case__c = thisCase.Id);
              listAssignmentInserts.add(QueueAssignmentHistory);      
            }  
            if(thisCase.Assigned_To_Prime__c != null) {
              Assignment_History__c PrimeAssignmentHistory
                = new Assignment_History__c(Assignment_Type__c = PRIME_ASSIGNMENT_TYPE,
                                          Name = PRIME_ASSIGNMENT_TYPE 
                                            + ' - ' + mapAssignedToPrimeNames.get(thisCase.Id),
                                            Assignee__c = mapAssignedToPrimeNames.get(thisCase.Id),
                                            Case__c = thisCase.Id);
              listAssignmentInserts.add(PrimeAssignmentHistory);
            }
            if(thisCase.Assigned_To_Plan__c != null) {
              Assignment_History__c PlanAssignmentHistory
                = new Assignment_History__c(Assignment_Type__c = PLAN_ASSIGNMENT_TYPE,
                                            Name = PLAN_ASSIGNMENT_TYPE
                                              + ' - ' + mapAssignedToPlanNames.get(thisCase.Id),
                                              Assignee__c = mapAssignedToPlanNames.get(thisCase.Id),
                                              Case__c = thisCase.Id);
              listAssignmentInserts.add(PlanAssignmentHistory);      
            }  
          }
          upsert listAssignmentInserts;
        } else { 
          fetchPriorAssignments();  
          for(Case thisCase : listCases){
            if(thisCase.OwnerId != mapOldCases.get(thisCase.Id).OwnerId
               || (!thisCase.IsClosed && mapOldCases.get(thisCase.Id).IsClosed)){
              if(mapPriorOwnerAssignments.get(thisCase.Id) != null) {
                mapPriorOwnerAssignments.get(thisCase.Id).Assignment_End_Date__c 
                  = system.datetime.now();
                mapAssignmentUpserts.put(mapPriorOwnerAssignments.get(thisCase.Id).Id,
                 mapPriorOwnerAssignments.get(thisCase.Id));    
              }
              Assignment_History__c OwnerAssignmentHistory
              = new Assignment_History__c(Assignment_Type__c = OWNER_ASSIGNMENT_TYPE,
                                          Name = OWNER_ASSIGNMENT_TYPE
                                            + ' - ' + mapOwnerNames.get(thisCase.Id),
                                            Assignee__c = mapOwnerNames.get(thisCase.Id),
                                            Case__c = thisCase.Id);
            listAssignmentInserts.add(OwnerAssignmentHistory);
            }
            if(thisCase.Assignment_Queue__c 
                  != mapOldCases.get(thisCase.Id).Assignment_Queue__c
              || (!thisCase.IsClosed && mapOldCases.get(thisCase.Id).IsClosed)){
            if(mapPriorQueueAssignments.get(thisCase.Id) != null) {
                mapPriorQueueAssignments.get(thisCase.Id).Assignment_End_Date__c 
                  = system.datetime.now();
                mapAssignmentUpserts.put(mapPriorQueueAssignments.get(thisCase.Id).Id,
                  mapPriorQueueAssignments.get(thisCase.Id));    
              }
              Assignment_History__c QueueAssignmentHistory
              = new Assignment_History__c(Assignment_Type__c = QUEUE_ASSIGNMENT_TYPE,
                                          Name = QUEUE_ASSIGNMENT_TYPE
                                            + ' - ' + thisCase.Assignment_Queue__c,
                                            Assignee__c = thisCase.Assignment_Queue__c,
                                            Case__c = thisCase.Id);  
            listAssignmentInserts.add(QueueAssignmentHistory);                                              
            }
            if(thisCase.Assigned_to_Prime__c != mapOldCases.get(thisCase.Id).Assigned_to_Prime__c
               || (!thisCase.IsClosed && mapOldCases.get(thisCase.Id).IsClosed && thisCase.Assigned_to_Prime__c != null)){
              if(mapPriorPrimeAssignments.get(thisCase.Id) != null) {
                mapPriorPrimeAssignments.get(thisCase.Id).Assignment_End_Date__c 
                  = system.datetime.now();
                mapAssignmentUpserts.put(mapPriorPrimeAssignments.get(thisCase.Id).Id,
                 mapPriorPrimeAssignments.get(thisCase.Id));    
              }
              Assignment_History__c OwnerAssignmentHistory
                = new Assignment_History__c(Assignment_Type__c = PRIME_ASSIGNMENT_TYPE,
                                          Name = PRIME_ASSIGNMENT_TYPE
                                            + ' - ' + mapAssignedToPrimeNames.get(thisCase.Id),
                                            Assignee__c = mapAssignedToPrimeNames.get(thisCase.Id),
                                            Case__c = thisCase.Id);
            listAssignmentInserts.add(OwnerAssignmentHistory);
            }
            if(thisCase.Assigned_to_Plan__c != mapOldCases.get(thisCase.Id).Assigned_to_Plan__c
               || (!thisCase.IsClosed && mapOldCases.get(thisCase.Id).IsClosed && thisCase.Assigned_to_Plan__c != null)){
              if(mapPriorPlanAssignments.get(thisCase.Id) != null) {
                mapPriorPlanAssignments.get(thisCase.Id).Assignment_End_Date__c 
                  = system.datetime.now();
                mapAssignmentUpserts.put(mapPriorPlanAssignments.get(thisCase.Id).Id,
                 mapPriorPlanAssignments.get(thisCase.Id));    
              }
              Assignment_History__c OwnerAssignmentHistory
                = new Assignment_History__c(Assignment_Type__c = PLAN_ASSIGNMENT_TYPE,
                                          Name = PLAN_ASSIGNMENT_TYPE
                                            + ' - ' + mapAssignedToPlanNames.get(thisCase.Id),
                                            Assignee__c = mapAssignedToPlanNames.get(thisCase.Id),
                                            Case__c = thisCase.Id);
            listAssignmentInserts.add(OwnerAssignmentHistory);
            }
          }
          if(listAssignmentInserts.size() > 0
             || mapAssignmentUpserts.values().size() > 0){
            upsert listAssignmentInserts;
            upsert mapAssignmentUpserts.values();    
            CaseRecursionHandler.setAlreadyCreatedAssignments();    
          }  
        }
    }
  }

  private static void fetchCaseOwnerNames(){
    list<Case> listCaseOwners 
      = [SELECT Id, Owner.Name, 
                Assigned_To_Plan__r.Name, Assigned_To_Prime__r.Name 
         FROM Case
         WHERE Id IN :setCaseIds];
    for(Case thisCase: listCaseOwners){
      mapOwnerNames.put(thisCase.Id, thisCase.Owner.Name); 
      mapAssignedToPlanNames.put(thisCase.Id, thisCase.Assigned_To_Plan__r.Name);
      mapAssignedToPrimeNames.put(thisCase.Id, thisCase.Assigned_To_Prime__r.Name);
    }
  }

  private static void fetchPriorAssignments(){
    
    
    for(Assignment_History__c thisAssign : [SELECT Id, Case__c, Assignment_Type__c FROM Assignment_History__c
                                        WHERE Assignment_End_Date__c = null AND Case__c IN :setCaseIds]){
    
    if(thisAssign.Assignment_Type__c == OWNER_ASSIGNMENT_TYPE)
        mapPriorOwnerAssignments.put(thisAssign.Case__c, thisAssign);   
    if(thisAssign.Assignment_Type__c == QUEUE_ASSIGNMENT_TYPE)
        mapPriorQueueAssignments.put(thisAssign.Case__c, thisAssign);
    if(thisAssign.Assignment_Type__c == PRIME_ASSIGNMENT_TYPE)
        mapPriorPrimeAssignments.put(thisAssign.Case__c, thisAssign);
    if(thisAssign.Assignment_Type__c == PLAN_ASSIGNMENT_TYPE)
        mapPriorPlanAssignments.put(thisAssign.Case__c, thisAssign);
    
    }
    
  }
  //Sudheer code to change owner
  public static void caseOwnerChangeRestriction(list<Case> listCases,list<case> listoldcases){ 
  Map<String,Schema.RecordTypeInfo> rtMapByNameCase = Schema.SObjectType.Case.getRecordTypeInfosByName();
  rtItem =  rtMapByNameCase.get('PCT - Item').getRecordTypeId();
  rtGrievance =  rtMapByNameCase.get('PCT - Item: CTM Grievance').getRecordTypeId();
  system.debug('sudheer1'+listcases);
  list<id> ownersid = new list<string>();
  for(case newcase: listCases){
  ownersid.add(newcase.ownerid);
  }
  
  system.debug('listoldcaseownerid: '+listoldcases[0].ownerid);
  map<id, user> userlist = new map<id, user>([select id, user_type__c,plan_Account_Id__c from user where id =: ownersid]);
  system.debug('userlist: '+userlist);
  system.debug('userlist: '+userlist.size());
  if(userlist.size() != 0){
  for(case newcase: listCases){
  for(case oldcase: listoldcases){
  
  system.debug('accountid: '+oldcase.Member_Plan_Account_Text__c);
  if(userlist.get(newcase.ownerid).User_Type__c == 'Plan User'){
  if((newcase.recordTypeID == rtGrievance || newcase.recordTypeId == rtItem) && newcase.ownerid != oldcase.ownerid && newcase.id == oldcase.id && oldcase.Member_Plan_Account_Text__c != userlist.get(newcase.ownerid).Plan_Account_Id__c && oldcase.Member_Plan_Parent_Account_Text__c != userlist.get(newcase.ownerid).Plan_Account_Id__c){
  //if(newcase.id == oldcase.id && userlist.keyset().contains(newcase.id) && userlist.get(newcase.ownerid).User_Type__c == 'Plan User' && newcase.Member_Plan_Lookup__r.client__c != userlist.get(newcase.ownerid).Plan_Account_Id__c && newcase.Member_Plan_Lookup__r.client__r.parentid != userlist.get(newcase.ownerid).Plan_Account_Id__c  ){
  system.debug('sudheer2');
  newcase.adderror('The Owner User you have selected is not valid for Cases at this Client/Plan. Please select a different Owner User');
            }
          }
        }
     }
    }
  }
  
  
  static Map<Id, User> map_OwnerNames = new Map<Id, User>();
  static Map<Id, Group> map_QueueNames = new Map<Id, Group>();
  static Id rtItem,rtGrievance,rtTask, rtOrderRefill, rtServGesture,rtRepOrderAlone,rtRepOrderWithItem,rtNcqa;
  
  // to be called once in before insert, before update and before other case comments methods
  public static void dataSetup(list<Case> listCases){
      Map<String,Schema.RecordTypeInfo> rtMapByNameCase = Schema.SObjectType.Case.getRecordTypeInfosByName();
      rtItem =  rtMapByNameCase.get('PCT - Item').getRecordTypeId();
      rtGrievance =  rtMapByNameCase.get('PCT - Item: CTM Grievance').getRecordTypeId();
      rtTask = rtMapByNameCase.get('Task').getRecordTypeId();
      rtOrderRefill = rtMapByNameCase.get('PCT - Order Refill').getRecordTypeId();
      rtServGesture = rtMapByNameCase.get('PCT - Service Gesture').getRecordTypeId();
      rtRepOrderAlone = rtMapByNameCase.get('PCT - Replacement Order Standalone').getRecordTypeId();
      rtRepOrderWithItem = rtMapByNameCase.get('PCT - Replacement Order with Item').getRecordTypeId();
      rtNcqa = rtMapByNameCase.get('PCT - NCQA').getRecordTypeId();
      //rtOrderRefill = rtMapByNameCase.get('Task').getRecordTypeId();
      Set<String> set_CaseOwnerIds = new Set<String>();  
      Set<String> set_CaseQueueIds = new Set<String>(); 
      
      for(Case thisCase : listCases) {
        setCaseIds.add(thisCase.Id); 
        String caseOwnerId = thisCase.OwnerId;
        if(caseOwnerId.startsWith('005')){
            set_CaseOwnerIds.add(thisCase.OwnerId);
        }else{
            set_CaseQueueIds.add(thisCase.OwnerId);
        }
      }
      set_CaseOwnerIds.add(userInfo.getUserId());
      
      if(!set_CaseOwnerIds.isEmpty()){
          map_OwnerNames = new Map<Id, User>([Select Id, Name,Plan_Account__c,Plan_Account_Id__c,profile.name,profileId,User_Type__c From User Where Id IN : set_CaseOwnerIds]);
      }
      if(!set_CaseQueueIds.isEmpty()){
          map_QueueNames = new Map<Id, Group>([Select Id, Name From Group Where Id IN : set_CaseQueueIds]);
      }
  }
  
  //Copy notes to custom comments field
  public static void copyNotesToCustomComment(list<Case> listCases, map<id,case> oldCases){
    //if(!CaseRecursionHandler.hasCopiedNotes()){
      //run on update
      if(oldCases != null){
          for(Case thisCase : listCases){
            //if(isBeforeUpdate){
                if((thisCase.recordTypeID == rtGrievance || thisCase.recordTypeID == rtItem)){
                  system.debug('@@@#####000>>>> '+thisCase.Information_Description_To_Add__c);
                    if(thisCase.Information_Description_To_Add__c != null ){
                      system.debug('@@@#####111>>>> '+thisCase.Information_Description_To_Add__c);
                        string thisInformation = thisCase.Information_Description_To_Add__c.replaceAll('\n', '<br/>');
                        thisInformation = thisInformation.replaceAll('\"', '\'');
                        system.debug('@@@#####222>>>> '+thisInformation);
                        thisInformation = thisInformation.replaceAll('<', '< ');
                        system.debug('@@@#####222AFTER>>>> '+thisInformation);
                        if(thisCase.Case_Comments__c == null)
                            thisCase.Case_Comments__c = timeStamp+ thisInformation ;
                        else
                            thisCase.Case_Comments__c += '<br/><br/>'+timeStamp+ thisInformation+'<br/>';  
                    system.debug('@@@#####>3333>>> '+thisCase.Case_Comments__c);
                    }
                }
               
            //}       
          }// for loop on case list ends here
      }//Update IF ends here
      
      //run on insert
        if(oldCases == null){            
            for(Case thisCase : listCases){
                system.debug('####'+thisCase.Id);
                //if(isBeforeInsert){
                    if((thisCase.recordTypeID == rtGrievance || thisCase.recordTypeID == rtItem)){
                        if(thisCase.Information_Description_to_Add__c != null){
                            // replace all carriage returns with <br/> elements since we will be writing this to a rich text area
                            string thisInfo = thisCase.Information_Description_To_Add__c.replaceAll('\n', '<br/>');
                            thisCase.Case_Comments__c =  timeStamp+thisInfo+ '<br/><br/>'; 
                            thisCase.Case_Comments__c = thisCase.Case_Comments__c.replaceAll('\"', '\'');
                        }
                    }
                //}
                
            } // loop for case list ends here 
        }//Insert IF ends here
    //}
  }//method ends
  
  public static void copyNotesToStdComment(list<Case> listCases, map<id,case> oldCases){
    //if(!CaseRecursionHandler.hasCopiedNotes()){
        //run on update
      if(oldCases != null){
          for(Case thisCase : listCases){
            //if(isBeforeUpdate){
                if(thisCase.Information_Description_to_Add_Standard__c != null && (thisCase.recordTypeID != rtGrievance || thisCase.recordTypeID != rtItem)){
                      system.debug('Inside StandardCase Comment When Update');     
                      CaseComment thisCaseComment = new CaseComment( CommentBody = thisCase.Information_Description_to_Add_Standard__c, 
                                                                    ParentId = thisCase.Id);
                      thisCaseComment.CommentBody = thisCaseComment.CommentBody.replaceAll('\"', '\'');
                      listInsertComments.add(thisCaseComment);
                }
            
            
          if(!(thisCase.Other_Member_Notes__c == null)){
                if(thisCase.Other_Member_Notes__c != oldCases.get(thisCase.Id).Other_Member_Notes__c ){
                        //thisCase.Case_Comments__c += thisCase.Other_Member_Notes__c+ '\r\n';
                        CaseComment thisCaseComment 
                        = new CaseComment(
                          CommentBody = thisCase.Other_Member_Notes__c,
                          ParentId = thisCase.Id);
                thisCaseComment.CommentBody = thisCaseComment.CommentBody.replaceAll('\"', '\'');
                listInsertComments.add(thisCaseComment); 
                  }
              }
            
            
            //}   
          }// for loop on case list ends here
      }//Update IF ends here
      
      //run on insert
        if(oldCases == null){            
            for(Case thisCase : listCases){
                system.debug('####'+thisCase.Id);
                //if(isBeforeInsert){
                   
                //}
                //else {
                    if(!(thisCase.recordTypeID == rtGrievance || thisCase.recordTypeID == rtItem)){
                        if(thisCase.Information_Description_to_Add_Standard__c != null){
                            system.debug('####$$$$'+thisCase.Id);
                            CaseComment thisCaseComment = new CaseComment( CommentBody = thisCase.Information_Description_to_Add_Standard__c,
                                                                        ParentId = thisCase.Id);
                            listInsertComments.add(thisCaseComment);    
                        }
                    }
                    
                    if(thisCase.Other_Member_Notes__c != null){
                        CaseComment thisCaseComment = new CaseComment( CommentBody = thisCase.Other_Member_Notes__c,ParentId = thisCase.Id);
                        listInsertComments.add(thisCaseComment);
                        system.debug(logginglevel.ERROR, 'ADAM CaseComment Inserted! ' + thisCaseComment);
                    }
                    
            //} 
        }// loop for case list ends here 
      }//Insert IF ends here 
    //}//First IF ends here
  }
  
  public static boolean isResolutionTracked = true;
  public static boolean isStatusTracked =true;
  //isCustomTrack
  // For Custom Case Comments
  public static void trackFieldChangesCustom(list<case> listcases, map<id,case> oldCases){
    list<String> trackedFields;
    string statusvalue, resolutionvalue;
    set<string> fieldSet;
    //if(!CaseRecursionHandler.hasCopiedNotes()){
        for(case thisCase : listCases){
        trackedFields = new list<String>();
        //trackedFields.add('Status');
        if(thisCase.recordTypeID == rtItem || thisCase.recordTypeID == rtGrievance){
            fieldSet = new set<string>{'Status','Reason','Original_Request_Date_Time__c','Resolution_Date_Time__c','OwnerId','Source__c'};
            trackedFields.addAll(fieldSet); 
        }
        
        // Iterate through tracked fields list
            for(String thisField : trackedFields){
                system.debug('thisField:::> '+thisField);
                String NewCommentBody = '';
                //if(MetadataUtility.fieldsInObjectSet('Case').contains(thisField)) {
                    //if(thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField) && thisCase.get(thisField) != null){
                        String FieldLabel = thisCase.getSObjectType().getDescribe().fields.getMap().get(thisField).getDescribe().getLabel();
                        //
                        system.debug('<<isStatusTracked>>'+isStatusTracked);
                        system.debug('<<isResolutionTracked>>'+isResolutionTracked);
                        system.debug('<<isCustomTrack>>'+isCustomTrack);
                        if(thisField.equalsIgnoreCase('Status') && isStatusTracked && thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField) && thisCase.get(thisField) != null){
                            NewCommentBody += '<br/><br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField)
                                    ;
                            //thisCase.Case_Comments__c += NewCommentBody+ '<br/>';
                            statusvalue = NewCommentBody+ '<br/>';
                            isStatusTracked = false;    
                        }
                        
                        else if(thisField.equalsIgnoreCase('Resolution_Date_Time__c') && isResolutionTracked && thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField) && thisCase.get(thisField) != null){
                            NewCommentBody = '';
                            string oldVal = '' ;
                            string newVal = dateTime.valueOf(thisCase.get(thisField)).format('MM/dd/yyyy h:mm a');
                            if(oldCases.get(thisCase.Id).get(thisField) != null)
                                oldVal = dateTime.ValueOf(oldCases.get(thisCase.Id).get(thisField)).format('MM/dd/yyyy h:mm a');
                            else
                                oldVal = string.valueOf(oldCases.get(thisCase.Id).get(thisField));
                            
                            NewCommentBody += '<br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldVal + ' to '+ newVal;
                            //thisCase.Case_Comments__c += NewCommentBody+ '<br/>';
                            resolutionvalue = NewCommentBody+ '<br/>';
                            isResolutionTracked = false;
                        }
                        
                        
                        else if(isCustomTrack && thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField) && thisCase.get(thisField) != null){
                            NewCommentBody = '';
                            if(thisField.equalsIgnoreCase('Original_Request_Date_Time__c')){
                                string oldVal = '' ;
                                string newVal = dateTime.valueOf(thisCase.get(thisField)).format('MM/dd/yyyy h:mm a');
                                if(oldCases.get(thisCase.Id).get(thisField) != null)
                                    oldVal = dateTime.ValueOf(oldCases.get(thisCase.Id).get(thisField)).format('MM/dd/yyyy h:mm a');
                                else
                                    oldVal = string.valueOf(oldCases.get(thisCase.Id).get(thisField));
                                
                                NewCommentBody += '<br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldVal + ' to '+ newVal;
                        
                            }
                            
                            else if(thisField == 'OwnerId'){
                                if(map_OwnerNames.containsKey(thisCase.OwnerId)){
                                  NewCommentBody += '<br/>'+ timeStamp + 'Changed Owner to '+ 
                                                + map_OwnerNames.get(thisCase.OwnerId).Name
                                                + '<br/>';
                                 
                                }else{
                                  NewCommentBody += '<br/>'+ timeStamp  +'Changed Owner to '+
                                                + map_QueueNames.get(thisCase.OwnerId).Name
                                                + '<br/>';
                                  
                                }
                    
                  
                            }
                            else if(thisField == 'RecordTypeId'){
                              if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                                NewCommentBody += '<br/>'+ timeStamp + 'Changed Record Type to ' 
                                              + Schema.SObjectType.Case
                                                .getRecordTypeInfosById()
                                                .get(thisCase.RecordTypeId).getName();
                                
                              }                
                            }
                            else{
                                NewCommentBody += '<br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField);
                            }
                            
                            
                            
                        }
                        
                        if(string.isNotBlank(NewCommentBody)){
                            thisCase.Case_Comments__c += NewCommentBody+ '<br/><br/>';
                        } 
                        
                   // }
                //}
                
                /*
                
              system.debug('thisField>>## '+thisField);
              // variable to store in case_comments__c field
              String NewCommentBody = '';
              if(thisField != 'OwnerId' && thisField != 'RecordTypeId' && thisField !='created' && thisField != 'closed'
                 && thisField != 'ownerAssignment' && thisField != 'owerAccepted'){
                if(MetadataUtility.fieldsInObjectSet('Case').contains(thisField)) {
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    String FieldLabel = thisCase.getSObjectType().getDescribe().fields.getMap().get(thisField).getDescribe().getLabel();
                    if(thisField.equalsIgnoreCase('Resolution_Date_Time__c') || thisField.equalsIgnoreCase('Original_Request_Date_Time__c')){
                        string oldVal = '' ;
                        string newVal = dateTime.valueOf(thisCase.get(thisField)).format('MM/dd/yyyy h:mm a');
                        if(oldCases.get(thisCase.Id).get(thisField) != null)
                            oldVal = dateTime.ValueOf(oldCases.get(thisCase.Id).get(thisField)).format('MM/dd/yyyy h:mm a');
                        else
                            oldVal = string.valueOf(oldCases.get(thisCase.Id).get(thisField));
                        
                        NewCommentBody += '<br/><br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldVal + ' to '+ newVal;
                        
                    }
                    else{
                            if(thisField.equalsIgnoreCase('Status') && isStatusTracked){
                                NewCommentBody += '<br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField)
                                    ;
                            }
                            NewCommentBody += '<br/>'+ timeStamp + 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField)
                                    ;
                           
                    }  
                  }
                }     
              } 
              else {
                if(thisField == 'OwnerId'){
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    if(map_OwnerNames.containsKey(thisCase.OwnerId)){
                      NewCommentBody += '<br/><br/>'+ timeStamp + 'Changed Owner to '+ 
                                    + map_OwnerNames.get(thisCase.OwnerId).Name
                                    + '<br/>';
                     
                    }else{
                      NewCommentBody += '<br/><br/>'+ timeStamp  +'Changed Owner to '+
                                    + map_QueueNames.get(thisCase.OwnerId).Name
                                    + '<br/>';
                      
                    }
                    
                  }
                }
                if(thisField == 'RecordTypeId'){
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    NewCommentBody += '<br/><br/>'+ timeStamp + 'Changed Record Type to ' 
                                  + Schema.SObjectType.Case
                                    .getRecordTypeInfosById()
                                    .get(thisCase.RecordTypeId).getName()
                                  + '<br/>';
                    
                  }                
                }
              }
              
                if(string.isNotBlank(NewCommentBody)){
                    thisCase.Case_Comments__c += NewCommentBody+ '<br/><br/>'; 
                    isCustomTrack =false;
                }               
                */
                
            } // loop for tracked fields ends here
    
        }//for loop for case ends here
        isCustomTrack = false;
    //}
    
    
  }
  
  
  //For Standard Case Comments on Service Gesture record Type
  public static void trackFieldChangesStdSGC(list<case> listcases, map<id,case> oldCases){
    list<String> trackedFields;
    set<string> fieldSet;
    //if(!CaseRecursionHandler.hasCopiedNotes()){
        for(case thisCase : listCases){
        trackedFields = new list<String>();
        if(thisCase.recordTypeID == rtServGesture){
            trackedFields.add('Status');
            trackedFields.add('OwnerId');
            trackedFields.add('Reason');
            trackedFields.add('Original_Request_Date_Time__c');
        }
        
        // Iterate through tracked fields list
            for(String thisField : trackedFields){
              system.debug('thisField>>## '+thisField);
              // variable to store in standard case comments
              string thisCommentBody = '';
              /*
                if(MetadataUtility.fieldsInObjectSet('Case').contains(thisField)) {
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    String FieldLabel = thisCase.getSObjectType().getDescribe().fields.getMap().get(thisField).getDescribe().getLabel();
                            thisCommentBody += 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField)
                                    + '\r\n';
                      
                  }
                }
                /*   
                if(thisCase.recordTypeID == rtServGesture && string.isNotBlank(thisCommentBody)){
                    CaseComment thisCaseComment = new CaseComment(CommentBody = thisCommentBody,ParentId = thisCase.Id);
                    listInsertCommentsSGC.add(thisCaseComment); 
                }*/
                
              if(thisField != 'OwnerId' && thisField != 'RecordTypeId' && thisField !='created' && thisField != 'closed'
                 && thisField != 'ownerAssignment' && thisField != 'owerAccepted'){
                if(MetadataUtility.fieldsInObjectSet('Case').contains(thisField)) {
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    String FieldLabel = thisCase.getSObjectType().getDescribe().fields.getMap().get(thisField).getDescribe().getLabel();
                    if(thisField.equalsIgnoreCase('Resolution_Date_Time__c') || thisField.equalsIgnoreCase('Original_Request_Date_Time__c')){
                        string oldVal = '' ;
                        string newVal = dateTime.valueOf(thisCase.get(thisField)).format('MM/dd/yyyy h:mm a');
                        if(oldCases.get(thisCase.Id).get(thisField) != null)
                            oldVal = dateTime.ValueOf(oldCases.get(thisCase.Id).get(thisField)).format('MM/dd/yyyy h:mm a');
                        else
                            oldVal = string.valueOf(oldCases.get(thisCase.Id).get(thisField));
                        
                        thisCommentBody += 'Changed field ' + FieldLabel + ' from ' 
                                    + oldVal + ' to '+ newVal +
                                    + '\r\n';
                    }
                    else{
                            thisCommentBody += 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField)
                                    + '\r\n';
                    }  
                  }
                }     
              } 
              else {
                if(thisField == 'OwnerId'){
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    if(map_OwnerNames.containsKey(thisCase.OwnerId)){
                     thisCommentBody += 'Changed Owner to '+ 
                                    + map_OwnerNames.get(thisCase.OwnerId).Name
                                    + '\r\n';
                    }else{
                      thisCommentBody += 'Changed Owner to '+
                                    + map_QueueNames.get(thisCase.OwnerId).Name
                                    + '\r\n';
                    }
                  }
                }
                if(thisField == 'RecordTypeId'){
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    thisCommentBody += 'Changed Record Type to ' 
                                  + Schema.SObjectType.Case
                                    .getRecordTypeInfosById()
                                    .get(thisCase.RecordTypeId).getName()
                                  + '\r\n';
                  }                
                }
              }
               
                if(thisCase.recordTypeID == rtServGesture && string.isNotBlank(thisCommentBody)){
                    CaseComment thisCaseComment = new CaseComment(CommentBody = thisCommentBody,ParentId = thisCase.Id);
                    listInsertCommentsSGC.add(thisCaseComment); 
                }
                        
                    
                   
                
                    
                    system.debug('listInsertComments####@@@ '+listInsertCommentsSGC);
                
                
            } // loop for tracked fields ends here
        }//for loop for cases ends here
    //}
    
        system.debug('listInsertCommentsSGC+++'+listInsertCommentsSGC);
            
            if(listInsertCommentsSGC.size() > 0 ){
                insert listInsertCommentsSGC;
                isSGC = false;
                system.debug('isSGC>>'+isSGC);
            }
            
  }
  
  //For Standard Case Comments; record type: Order Refill and NCQA 
  public static void trackFieldChangesStd(list<case> listcases, map<id,case> oldCases){
    list<String> trackedFields;
    set<string> fieldSet;
    //if(!CaseRecursionHandler.hasCopiedNotes()){
        for(case thisCase : listCases){
        trackedFields = new list<String>();
        trackedFields.add('Status');
        trackedFields.add('OwnerId');
        trackedFields.add('RecordTypeId');
        if(thisCase.recordTypeID == rtOrderRefill){
            fieldSet = new set<string>{'Resolution_Date_Time__c','Member_ID__c'};
            trackedFields.addAll(fieldSet);
           
        }
        
       if(thisCase.recordTypeID == rtNcqa){
            fieldSet = new set<string>{'Source__c','Resolution__c','Reason','Resolution_Date_Time__c'};
            trackedFields.addAll(fieldSet);
        }
        if(thisCase.recordTypeID == rtRepOrderAlone){
        fieldSet = new set<string>{'Source__c','Reason'};
            trackedFields.addAll(fieldSet);
            // add more fields here if need tracking
        }
        if(thisCase.recordTypeID == rtRepOrderWithItem){
        fieldSet = new set<string>{'Source__c','Reason'};
            trackedFields.addAll(fieldSet);
            // add more fields here if need tracking
        }
        
        // Iterate through tracked fields list
            for(String thisField : trackedFields){
              system.debug('thisField>>## '+thisField);
              // variable to store in standard case comments
              string thisCommentBody = '';
              if(thisField != 'OwnerId' && thisField != 'RecordTypeId' && thisField !='created' && thisField != 'closed'
                 && thisField != 'ownerAssignment' && thisField != 'owerAccepted'){
                if(MetadataUtility.fieldsInObjectSet('Case').contains(thisField)) {
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    String FieldLabel = thisCase.getSObjectType().getDescribe().fields.getMap().get(thisField).getDescribe().getLabel();
                    if(thisField.equalsIgnoreCase('Resolution_Date_Time__c') || thisField.equalsIgnoreCase('Original_Request_Date_Time__c')){
                        string oldVal = '' ;
                        string newVal = dateTime.valueOf(thisCase.get(thisField)).format('MM/dd/yyyy h:mm a');
                        if(oldCases.get(thisCase.Id).get(thisField) != null)
                            oldVal = dateTime.ValueOf(oldCases.get(thisCase.Id).get(thisField)).format('MM/dd/yyyy h:mm a');
                        else
                            oldVal = string.valueOf(oldCases.get(thisCase.Id).get(thisField));
                        
                        thisCommentBody += 'Changed field ' + FieldLabel + ' from ' 
                                    + oldVal + ' to '+ newVal +
                                    + '\r\n';
                    }
                    else{
                            thisCommentBody += 'Changed field ' + FieldLabel + ' from ' 
                                    + oldCases.get(thisCase.Id).get(thisField) + ' to '
                                    + thisCase.get(thisField)
                                    + '\r\n';
                    }  
                  }
                }     
              } 
              else {
                if(thisField == 'OwnerId'){
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    if(map_OwnerNames.containsKey(thisCase.OwnerId)){
                     thisCommentBody += 'Changed Owner to '+ 
                                    + map_OwnerNames.get(thisCase.OwnerId).Name
                                    + '\r\n';
                    }else{
                      thisCommentBody += 'Changed Owner to '+
                                    + map_QueueNames.get(thisCase.OwnerId).Name
                                    + '\r\n';
                    }
                  }
                }
                if(thisField == 'RecordTypeId'){
                  if((thisCase.get(thisField) != oldCases.get(thisCase.Id).get(thisField)) && thisCase.get(thisField) != null){
                    thisCommentBody += 'Changed Record Type to ' 
                                  + Schema.SObjectType.Case
                                    .getRecordTypeInfosById()
                                    .get(thisCase.RecordTypeId).getName()
                                  + '\r\n';
                  }                
                }
              }
               
                if((thisCase.recordTypeID != rtGrievance || thisCase.recordTypeID != rtItem) && string.isNotBlank(thisCommentBody)){
                        if(thisCase.recordTypeID != rtServGesture){
                            CaseComment thisCaseComment = new CaseComment(CommentBody = thisCommentBody,ParentId = thisCase.Id);
                            listInsertComments.add(thisCaseComment);
                        }
                        
                    
                    system.debug('listInsertComments####@@@ '+listInsertComments);
                }
                
            } // loop for tracked fields ends here
        }//for loop for cases ends here
    //}
    
        system.debug('listInsertComments+++'+listInsertComments);
            if(listInsertComments.size() > 0 ){
                insert listInsertComments; 
            }
            
  }
   
    
  public static String hasLetterValidationError(list<Case> listCases){
    string ErrorMessage = null;
    set<String> setTaskStatuses = new set<String>();
    set<String> setTaskTypes = new set<String>();
    map<Id, boolean> mapCaseIdWithDelegPlan = new map<Id, boolean>();
    set<string> planIds = new set<string>();
    map<Id, Plan__c> mapCasePlans = new map<Id, Plan__c>();
    
    map<String, CaseTaskValidationTypes__c> ValidationTypes 
    = CaseTaskValidationTypes__c.getAll();
    map<Id, Case> CaseIdsToValidate = new map<Id, Case>();

    for(String validationName : ValidationTypes.keySet()){
      if(ValidationTypes.get(validationName).Task_Status__c != null 
                         && ValidationTypes.get(validationName).Task_Status__c != ''){
        for(String thisTaskStatus : validationTypes.get(validationName)
                                          .Task_Status__c.split('\\,')){
          setTaskStatuses.add(thisTaskStatus.trim());
        }
      }
      if(ValidationTypes.get(validationName).Task_Types__c != null 
                         && ValidationTypes.get(validationName).Task_Types__c != ''){
        for(String thisTaskType : ValidationTypes.get(validationName)
                                          .Task_Types__c.split('\\,')){
         setTaskTypes.add(thisTaskType.trim());
        }
      }

    }
system.debug(logginglevel.ERROR, 'NICK Task Types: ' + setTaskTypes);
    for(Case thisCase : listCases){
      String thisRecordType 
        = Schema.SObjectType.Case
          .getRecordTypeInfosById()
          .get(thisCase.RecordTypeId).getName();
      for(String validationName : ValidationTypes.keySet()){
        if(ValidationTypes.get(validationName).Record_Types__c.contains(thisRecordType)){   // && ValidationTypes.get(validationName).Case_Status__c.contains(thisCase.Status)
          CaseIdsToValidate.put(thisCase.Id, thisCase);
          if(thisCase.Member_Plan_Lookup__c != null)
            planIds.add(thisCase.Member_Plan_Lookup__c);
        }
      }
    }
    
    if(planIds.size()>0)
        mapCasePlans = new map<Id, Plan__c>([select id, name, Delegated__c from plan__c where Id in:planIds]);
    for(case cs : listCases){
        if(mapCasePlans.ContainsKey(cs.Member_Plan_Lookup__c)){
            mapCaseIdWithDelegPlan.put(cs.id,mapCasePlans.get(cs.Member_Plan_Lookup__c).Delegated__c);
        }
    }
    system.debug(logginglevel.ERROR, 'NICK CaseIdsToValidate: ' + CaseIdsToValidate.keySet()+' :mapCaseIdWithDelegPlan: '+mapCaseIdWithDelegPlan.keyset());
    if(CaseIdsToValidate.size()>0){
        for(Task thisTask : [SELECT Id, Type, WhatId, Status, (Select Id FROM Attachments)
                             FROM Task WHERE WhatId IN :CaseIdsToValidate.keySet() AND Type IN :setTaskTypes]){
      String thisCaseRecordType 
        = Schema.SObjectType.Case.getRecordTypeInfosById().get(CaseIdsToValidate.get(thisTask.WhatId).RecordTypeId).getName();
      String thisCaseStatus = CaseIdsToValidate.get(thisTask.WhatId).Status;
      for(String validationName : ValidationTypes.keySet()){
        boolean blnStautsOrCheckbox = false;
        if(ValidationTypes.get(validationName).Case_Status__c.contains(thisCaseStatus)){
          blnStautsOrCheckbox = true;
          system.debug('blnStautsOrCheckbox:: '+blnStautsOrCheckbox);
        }
        if(ValidationTypes.get(validationName) != null){
          if(ValidationTypes.get(validationName).CheckBox__c != null){
            for(String thisChkbox : ValidationTypes.get(validationName).Checkbox__c.split('\\,')){
              String fieldName = thisChkbox.trim();
              system.debug(logginglevel.ERROR, 'NICK Chk Field Name: ' + fieldName);
              if(CaseIdsToValidate.get(thisTask.WhatId).get(fieldName) != null){
                if(CaseIdsToValidate.get(thisTask.WhatId).get(fieldName) == true) {
                  system.debug(logginglevel.ERROR, 'NICK Field Val IS True');
                  blnStautsOrCheckbox = true;
                }
              }
            }
          }
        }
        if(Test.isRunningTest())
            blnStautsOrCheckbox = true; 
        if(Case_Utility_Settings__c.getInstance('Settings').Task_Attachment_Validation__c) {
            system.debug('TASK-TYPES--'+ValidationTypes.get(validationName).Task_Types__c);
            system.debug(mapCaseIdWithDelegPlan.get(thisTask.WhatId)+'-this task type: '+thisTask.Type+'-SIZE::'+thisTask.Attachments.size());
            system.debug(blnStautsOrCheckbox+'-FIRSTCOND:'+ValidationTypes.get(validationName).Record_Types__c.contains(thisCaseRecordType)+'---'+ValidationTypes.get(validationName).Task_Types__c.contains(thisTask.Type));
          if(ValidationTypes.get(validationName).Record_Types__c.contains(thisCaseRecordType) && (blnStautsOrCheckbox == true)
             && ValidationTypes.get(validationName).Task_Types__c.contains(thisTask.Type)){
            if(ValidationTypes.get(validationName).Requires_Attachment__c){ //requires attachment
              if(thisTask.Attachments.size() == 0 && mapCaseIdWithDelegPlan.get(thisTask.WhatId)){ //doesnt have one ---- and if it is Delegated plan
                if(ErrorMessage != null){
                    ErrorMessage = ErrorMessage + 'Activity ' + thisTask.Type+' must have an attachment. \r\n \r\n  ';
                } else {
                  ErrorMessage = 'Activity ' + thisTask.Type + ' must have an attachment. \r\n \r\n  ';
                }
              } else {
                if(!ValidationTypes.get(validationName).Task_Status__c.contains(thisTask.Status)){ //has attach, but bad status ??Add Checkbox Field to CS?
                  if(ErrorMessage != null){
                    ErrorMessage = ErrorMessage + 'Activity ' + thisTask.Type + ' must be completed prior to closing this case. \r\n \r\n  ';
                  } else {
                    ErrorMessage = 'Activity ' + thisTask.Type+ ' must be completed prior to closing this case. \r\n \r\n  ';
                  }
                }
              }
            } else { //doesn't require attachment
              if(!ValidationTypes.get(validationName).Task_Status__c.contains(thisTask.Status)){ //no attach required, bad status ??Add Checkbox Field to CS?
                if(ErrorMessage != null){
                  ErrorMessage = ErrorMessage + 'Activty ' + thisTask.Type 
                     + ' must be completed prior to closing this case. \r\n \r\n  ';
                } else {
                  ErrorMessage = 'Activity ' + thisTask.Type 
                     + ' must be completed prior to closing this case. \r\n \r\n  ';
                }
              }
            }
          }
        }
      }
    }
    }
    system.debug('ErrorMessage::: '+ErrorMessage);
    return ErrorMessage;
  }
  
  public static void checkGrvAckLetter(map<Id,Case> newMap, map<Id,Case> oldMap){
    set<string> statusValues = new set<string>{'Completed','Sent','Printed'};
    boolean isGrvTmlyAck = false;
    if(newMap != NULL){
      map<Id, Task> taskMap = new map<Id,Task>([Select Id,Status,WhatId,Type,Date_Time_Completed__c from task where WhatId IN: newMap.keyset()]);
      //for(task tsk: [Select Id,Status,WhatId,Type,Date_Time_Completed__c from task where WhatId IN: newMap.keyset()]){
       //   taskMap.put(tsk.WhatId,tsk);
      //}
      system.debug('taskMap>>'+taskMap.size());

      for(case cs: newMap.values()){
        system.debug(oldMap.get(cs.Id).Prime_Receipt_Date_Time__c+'------@@----'+cs.Prime_Receipt_Date_Time__c);
        if((cs.RecordTypeId == '012i0000000rJC7' || cs.RecordTypeId == '012i0000001M7Co') && taskMap != NULL && cs.Prime_Receipt_Date_Time__c != oldMap.get(cs.Id).Prime_Receipt_Date_Time__c){
          for(task tsk : taskMap.values()){
            if(statusValues.contains(tsk.status) && tsk.Type == 'Grievance Acknowledgement Letter' ){
              system.debug(tsk.Date_Time_Completed__c+'<<<TASK>>>'+cs.Prime_Receipt_Date_Time__c);
              if(tsk.Date_Time_Completed__c != null){
                  system.debug('H<<<IFFF>>>');
                  if(TaskUtility.dateDiff(cs.Prime_Receipt_Date_Time__c,tsk.Date_Time_Completed__c)){
                    isGrvTmlyAck = true;
                    system.debug('<<<%%%%>>>');
                  }
                  else
                    isGrvTmlyAck = false;

              }
            //continue;
            }
          }//task for loop ends here
          if(isGrvTmlyAck){
            system.debug('THEREE IF>>>');
              cs.Grievance_Timely_Acknowledged__c = true;
          }
          else{
            system.debug('THEREE ELSE>>>');
            cs.Grievance_Timely_Acknowledged__c = false;
          }
        }
      }//Case for loop ends here
    }

  }

  public static String hasFaxNumberFormatValidationError(list<Case> listCases){    
    string ErrorMessage = null;
    for(Case c : listCases){
        if(c.Prescribers_Fax_Number__c != null 
            && !Pattern.matches('(\\D?[0-9]{3}\\D?)[\\s][0-9]{3}-[0-9]{4}', 
                                               c.Prescribers_Fax_Number__c)){
            ErrorMessage = 'Fax format must match (###) ###-####';
        }
    }
    return ErrorMessage;    
  }
  
    
  public static void setOriginalCreatedByData(list<Case> lstCases, list<case> oldCases) {
    //set original created by fields if case is created via the gui as opposed via integration
    List<Case> lstCasesToUpdate = new List<Case>();
    Set<String> setCreatedById = new Set<String>();
    if(!CaseRecursionHandler.hasAlreadySetCreatedBy()) {
      CaseRecursionHandler.setAlreadySetCreatedBy();
      
      for(Case cs : lstCases) {
          setCreatedById.add(cs.CreatedById);
      }
      
      //get integration user id
      IntegrationUserID__c integrationUserID = IntegrationUserID__c.getInstance('IntegrationServiceID');
      string intUId = integrationUserID.Integration_User_ID__c;
      
      //get list of email addresses
      List<User> lstUserData = [select Id, 
                                       Email 
                                       from User 
                                       where Id in :setCreatedById];    
      Map<String, String> mapEmailAddress = new Map<String, String>();
      //add to map for processing loop reference
      for(User u : lstUserData){
         mapEmailAddress.put(u.Id, u.Email);
      }
      
      for(Case c : lstCases) { 
          //case created through integration: original created by user will already be populated by integration at this point
          //case created through gui createdby will not = integration user: need to populate original created by data
          // if oldcases list is null, it means this method was called from Insert event of trigger
          // and we will override the value of Original_Request_Date_Time__c field with createdDate field value
          dateTime Original_Request_Date_Time;
          system.debug('@@@#####: '+oldcases);
          if(c.Original_Request_Date_Time__c > c.CreatedDate){
            Original_Request_Date_Time = c.CreatedDate;
          }
          else {
            Original_Request_Date_Time = c.Original_Request_Date_Time__c;
          }
          system.debug('@@@#Original_Request_Date_Time####: '+Original_Request_Date_Time);
          if(c.CreatedById != intUId){      
            /*Case caseToUpdate = new Case(Id = c.Id,
                                        Original_Created_By_User__c = c.CreatedById,                                    
                                        Original_Created_By_User_Email__c = mapEmailAddress.get(c.CreatedById),
                                        Original_Request_Date_Time__c = Original_Request_Date_Time
                                        );
            lstCasesToUpdate.add(caseToUpdate);*/
            
            c.Original_Created_By_User__c = c.CreatedById;                                  
            c.Original_Created_By_User_Email__c = mapEmailAddress.get(c.CreatedById);
       //     c.Original_Request_Date_Time__c = Original_Request_Date_Time;
         // c.Employer_Group_Name__c = 'TEST12345';
            
          }               
      }
      if(lstCasesToUpdate.size() > 0){
        //  update lstCasesToUpdate;
      }
    }  
  }
/*
public void MediCareAlert(){
        
        system.debug('objCase.Request_Type__c in MedicareMethod'+ objCase.Request_Type__c);
        if(objCase.Request_Type__c != null && (objCase.Request_Type__c == 'Medicaid - Grievance' || objCase.Request_Type__c == 'Medicaid - Inquiry')){
        system.debug('map_Plan.size() in MedicareMethod'+map_Plan.size());
        system.debug('objCase.Contact_Method__c in MedicareMethod'+objCase.Contact_Method__c);
        system.debug('objCase.Member_Plan_Lookup__c inside seconf if'+objCase.Member_Plan_Lookup__c);
            if(objCase.Contact_Method__c != null && objCase.Contact_Method__c == 'Phone' && map_Plan.containsKey(objCase.Member_Plan_Lookup__c) && isOutsideHours() ){
                system.debug('objCase.Contact_Method__c inside seconf if'+objCase.Contact_Method__c);
                if(map_Plan.get(objCase.Member_Plan_Lookup__c).startsWith('Medicare - NC') && string.isNotBlank(profileId)){
                    if(!profileId.equalsIgnoreCase(userinfo.getProfileID())){
                        system.debug('objCase.Member_Plan_Lookup__c in MedicareMethod'+objCase.Member_Plan_Lookup__c);
                        objCase.Display_Alert_Message__c = '*ALL* NC Grievances and Inquiries must be warm transferred to BCBSNC during normal business hours (8am - 8pm ET / 7am - 7pm CT) 7 days per week for handling. If you do have to enter a PCT record during these hours you must explain why you created the PCT record instead of warm transferring the call.';  
                        objCase.Information_Description_to_Add__c ='*ALL* NC Grievances and Inquiries must be warm transferred to BCBSNC during normal business hours (8am - 8pm ET / 7am - 7pm CT) 7 days per week for handling. If you do have to enter a PCT record during these hours you must explain why you created the PCT record instead of warm transferring the call.';
                        displayAlert = true;
                        //sendEmail();
                        isEmailSent = true;
                    }
                
                }
                
            }
        
        }
        }*/


    public static boolean isOutsideHours(){
        boolean isAllowed;
        Time myTime1 = Time.newInstance(7, 00, 2, 20);
        time mytime2 = Time.newInstance(19, 00, 2, 20);
        system.debug(mytime1+'--------'+mytime2);
        time ct = system.now().time();
        system.debug('>>>'+ct);
        if(mytime1 <ct && ct < mytime2){
            system.debug('inside working hours');
            isAllowed = true;
        }
        else{
            system.debug('outside working hours');
            isAllowed = false;
        }
        if(Test.isRunningTest())
            return true;
     return isAllowed;    
    }
    
    public static void isInsideHours(List<Case> newList, Map<Id,Case> oldMap){
        string SysAdminProfileId = [ Select Id from Profile Where NAme='System Administrator'].Id;
        boolean isRestricted;
        Time myTime1 = Time.newInstance(22, 59, 59, 000);
        Time mytime2 = Time.newInstance(23, 59, 59, 000);
        Time mytime3 = Time.newInstance(00, 00, 01, 000);
        Time mytime4 = Time.newInstance(01, 00, 00, 000);
        Time mytime5 = Time.newInstance(02, 01, 00, 000);
        Time mytime6 = Time.newInstance(00, 00, 00, 000);
        system.debug(mytime1+'--------'+mytime2);
        for(case cs: newList){
          if(cs.Original_Request_Date_Time__c != null){
              time ct  = cs.Original_Request_Date_Time__c.time();
              String strRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getName();
              system.debug('>>>'+ct);
              if(UserInfo.getProfileId()  != SysAdminProfileId){
                if(strRecordTypeName =='PCT - Item' || strRecordTypeName == 'PCT - Item: CTM Grievance'){
                  if((mytime1 <ct && ct < mytime2) || (mytime3 <ct && ct < mytime4)|| (mytime4<ct&& ct < mytime5) || ct ==  mytime6){
                    if(oldMap == null)
                      cs.addError(System.Label.originalDateTimeMsg);
                    else if(oldMap != null && cs.ownerId == oldmap.get(cs.Id).ownerId)
                      cs.addError(System.Label.originalDateTimeMsg);
                  }
                }
              }
            }
          }//for loop ends
    }

  public static void updateRequestTypeLookup(list<Case> lstCases, string strOperation) {
    /*TODO: 
     If Request Type does not exist on object, create it, assign it, and notify admins 
    */
    list<Request_Type__c> listReferencedRequestTypes 
      = new list<Request_Type__c>();
    set<String> setRequestTypes = new set<String>();
    map<String, Request_Type__c> mapRequestTypesByName
      = new map<String, Request_Type__c>();
    set<String> setMissingRequestTypes  
      = new set<String>();
    list<Request_Type__c> listNewRequestTypes 
      = new list<Request_Type__c>();
    set<Id> planIds = new set<Id>();
    map<Id, String> map_Plan = new map< Id, string>();    
    for(Case thisCase : lstCases){
      if(thisCase.Request_Type__c != null){
        setRequestTypes.add(thisCase.Request_Type__c);
      }
      if(thisCase.Member_Plan_Lookup__c != null){
        planIds.add(thisCase.Member_Plan_Lookup__c);
      }
    }

    if(setRequestTypes.size()>0){
        for(Request_Type__c thisRequestType : [SELECT Id, Name, 
                                                      Description_Guidelines__c,
                                                      Display_Alert_Message__c
                                               FROM Request_Type__c
                                               WHERE Name IN :setRequestTypes]){
          mapRequestTypesByName.put(thisRequestType.Name, thisRequestType);
        }
    }

    for(String thisRequestTypeText : setRequestTypes){
      if(!mapRequestTypesByName.containsKey(thisRequestTypeText)){
        setMissingRequestTypes.add(thisRequestTypeText);
      }
    }

    for(String thisRequestTypeText : setMissingRequestTypes){
       Request_Type__c newRequestType 
         = new Request_Type__c(Name = thisRequestTypeText);
       listNewRequestTypes.add(newRequestType);
    }

    if(listNewRequestTypes.size() > 0){
      insert listNewRequestTypes;
      sendMissingRequestTypeEmail(setMissingRequestTypes);
    }

   /* for(Request_Type__c thisRequestType : [SELECT Id, Name, 
                                                  Description_Guidelines__c,
                                                  Display_Alert_Message__c
                                           FROM Request_Type__c
                                           WHERE Name IN :setRequestTypes]){
      mapRequestTypesByName.put(thisRequestType.Name, thisRequestType);
    }*/

    //string profileId = system.label.CasePCT_Profile_ID;
    string profileId;
    list<profile> myProfile = [select id, name from profile where name ='Plan User'];
    if(myProfile.size()>0){
        profileId = myProfile[0].Id;
    }
    if(planIds.size()>0){
        for(Plan__c oPlan :[select id,name from Plan__c where Id in: planIds]){
            map_Plan.put(oPlan.Id, oPlan.name);
        }
    }
    
    for(Case thisCase : lstCases) {
      if(thisCase.Request_Type__c != null){
        if(mapRequestTypesByName.containsKey(thisCase.Request_Type__c)){
          thisCase.Request_Type_Lookup__c 
            = mapRequestTypesByName.get(thisCase.Request_Type__c).Id;
          thisCase.Description_Guidelines__c 
            = mapRequestTypesByName.get(thisCase.Request_Type__c).Description_Guidelines__c;
          thisCase.Display_Alert_Message__c 
            = mapRequestTypesByName.get(thisCase.Request_Type__c).Display_Alert_Message__c;
        } else {
          thisCase.Request_Type_Lookup__c = null;
          thisCase.Description_Guidelines__c = null;
          thisCase.Display_Alert_Message__c = null;
        }
      } else {
        thisCase.Request_Type_Lookup__c = null;
        thisCase.Description_Guidelines__c = null;
        thisCase.Display_Alert_Message__c = null;
      }
      
      if(thisCase.Contact_Method__c != null && thisCase.Contact_Method__c == 'Phone' && isOutsideHours() && map_Plan.containsKey(thisCase.Member_Plan_Lookup__c) && strOperation.equalsIgnoreCase('insert')){
                system.debug('thisCase.Contact_Method__c inside seconf if'+thisCase.Contact_Method__c);
                if(map_Plan.get(thisCase.Member_Plan_Lookup__c).startsWith('Medicare - NC') && string.isNotBlank(profileId) && (thisCase.Request_Type__c.contains('Grievance') || thisCase.Request_Type__c.contains('Inquiry'))){
                    if(!profileId.equalsIgnoreCase(userinfo.getProfileID())){
                        system.debug('thisCase.Member_Plan_Lookup__c in MedicareMethod'+thisCase.Member_Plan_Lookup__c);
                        thisCase.Medicare_NC_Plan_Alert__c = '*ALL* NC Grievances and Inquiries must be warm transferred to BCBSNC during normal business hours (8am - 8pm ET / 7am - 7pm CT) 7 days per week for handling. If you do have to enter a PCT record during these hours you must explain why you created the PCT record instead of warm transferring the call.';  
                        //thisCase.Information_Description_to_Add__c ='*ALL* NC Grievances and Inquiries must be warm transferred to BCBSNC during normal business hours (8am - 8pm ET / 7am - 7pm CT) 7 days per week for handling. If you do have to enter a PCT record during these hours you must explain why you created the PCT record instead of warm transferring the call.';
                        emailListCases.add(thiscase);
                    }
                    else{thisCase.Medicare_NC_Plan_Alert__c = null;}
                
                }
                else{
                    thisCase.Medicare_NC_Plan_Alert__c = null;
                   // emailListCases.add(thiscase);
                }
                
            }
            else{
                //thisCase.Medicare_NC_Plan_Alert__c = null;
                // emailListCases.add(thiscase);
            }
    }
    
    
  }

 
        
        public static void sendEmail(){
        //string recipients = system.label.PCT_Notification_recipients;
        string recipients;
        map<String, Case_Email_Recipients__c> recipientsList = Case_Email_Recipients__c.getAll();
        if(recipientsList.containsKey('PCT_Notification_recipients')){
            recipients = Case_Email_Recipients__c.getInstance('PCT_Notification_recipients').email__c;
        }
        list<Messaging.SingleEmailMessage> allEmails = new list<Messaging.SingleEmailMessage>();
        list<contact> listContacts = new list<contact>();
        String[] toAddresses = new String[]{};
        if(string.isNotBlank(recipients)){
            toAddresses = recipients.split(';');    
        }
        if(test.isRunningTest())
            toAddresses.add('testupdate@prime.com');
        list<EmailTemplate> emailTemplates = [SELECT DeveloperName,Id,Name FROM EmailTemplate where DeveloperName = 'North_Carolina_Inquiry_or_Grievance'];
        list<user> listUsers = [select id, email, firstname, lastname from user where email in:toAddresses];
                
        if(listUsers.size()>0){
            listContacts = CreateContact(listUsers);    
        }
        system.debug('emailListCases>> '+emailListCases);
        if(emailListCases.size()>0){
            for(case objCase : emailListCases){
                system.debug('>>><<<<'+objCase.Id);
                if(listContacts.size()>0){
                    for(contact con: listContacts){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(emailTemplates.size()>0)
                            mail.setTemplateId(emailTemplates[0].id);
                        mail.setBccSender(false);
                        mail.setTargetObjectId(con.id);
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(objCase.Id);
                        allEmails.add(mail);
                    }
                }
            }
        }
        
        system.debug('INSIDE SENDEMAIL');
        try{
            system.debug('####****: '+allEmails);
            if(allEmails.size()>0)
                Messaging.sendEmail(allEmails);
            DeleteContacts(listContacts);
        }
        catch(exception e){
            system.debug('Exception caught while sending email');
        }
    
    } 
    
    public static list<Contact> CreateContact(list<user> EmailRecipient){
        list<Contact> Con = new List<contact>();        
        for(User u: EmailRecipient){
            Contact tempContact = new Contact(email = u.email, firstName = u.firstName, lastName = u.lastName);
            Con.add(tempContact);
            system.debug('tempContact>> '+tempContact);
        }
        insert Con;
        return con;
    }
    
    public static void DeleteContacts(List<Contact> DelCon){
        if(delCon.size()>0)
            delete DelCon;
    }
    
  private static void sendMissingRequestTypeEmail(set<String> setMissingRequestTypes){
    list<User> listUsers = [SELECT Email FROM User 
                  WHERE Receive_Custom_Apex_Emails__c = true];

    Messaging.SingleEmailMessage ErrorEmail 
                = new Messaging.SingleEmailMessage();
    
    String strErrorMessage = 'One or more Reqeust Types were automatically added to Salesforce \\r\\n' +
                              'The following missing ' +
                              'Request Types were added and need to be configured: ' + '\\r\\n';
    for(String thisReqeustType : setMissingRequestTypes) {
      strErrorMessage += thisReqeustType + '\\r\\n';
    }
    list<String> listToAddrs = new list<String>();
    for(User thisUser : listUsers){
      listToAddrs.add(thisUser.Email);
    }
    ErrorEmail.setToAddresses(listToAddrs);
    ErrorEmail.setSubject('Missing Request Type in Salesforce');
    ErrorEmail.setPlainTextBody(strErrorMessage);
    if(!test.isRunningTest()){ 
      Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ErrorEmail});
    }
  }

 /* public static void overwritePrimaryNCQAFields(list<Case> listCases){ 
    if(!CaseRecursionHandler.hasOverwrittenNCQAFields()){
      String NCQATypeId 
       = Schema.SObjectType.Case
                    .getRecordTypeInfosByName().get('NCQA Action Taken')
                    .getRecordTypeId();
      map<Id, Case> updateCases = new map<Id, Case>();
      map<Id, Case> mapImpactedCases = new map<Id, Case>();
      set<Id> setCurrentPrimaryIds = new set<Id>();

      for(Case thisCase : listCases){
        if(thisCase.RecordTypeId == NCQATypeId 
          && thisCase.Priority__c == 'Primary'){
          if(thisCase.NCQA_Case__c != null){
            setCurrentPrimaryIds.add(thisCase.Id);
            mapImpactedCases.put(thisCase.NCQA_Case__c, thisCase);
          }
        }
      }

      for(Case parentCase : [SELECT Id FROM Case
                             WHERE Id IN :mapImpactedCases.keySet()]){
        parentCase.Primary_Cause__c 
          = mapImpactedCases.get(parentCase.Id).Cause__c;
        parentCase.Primary_Cause_Reason__c 
          = mapImpactedCases.get(parentCase.Id).Cause_Reason__c;
        parentCase.Primary_Action_Taken__c 
          = mapImpactedCases.get(parentCase.Id).Task_Type__c;
        updateCases.put(parentCase.Id, parentCase);
      }

      for(Case oldPrimary : [SELECT Id FROM Case  
                             WHERE RecordTypeId = :NCQATypeId
                             AND Priority__c = 'Primary'
                             And NCQA_Case__c IN :mapImpactedCases.keySet()]){
        if(!setCurrentPrimaryIds.Contains(oldPrimary.Id)){
          oldPrimary.Priority__c = null;
          updateCases.put(oldPrimary.Id, oldPrimary);
        }
      }

      if(updateCases.size() > 0){
        CaseRecursionHandler.setalreadyOverwrittenNCQAFields();
        update updateCases.values();
      }
    } 
  }*/

 /* public static void CreateAndAssignReview(list<Case> listCases){
    if(!CaseRecursionHandler.hasAssignedReview()){
        CaseRecursionHandler.setalreadyAssignedReviews();
      id idUser = system.Userinfo.getUserId();
        String strFirstLastName = system.Userinfo.getFirstName() + ' ' + system.Userinfo.getLastName();
        List<Case> lstCasesToUpdate = new List<Case>();
        List<Review__c> lstReviewToInsert = new List<Review__c>();
        string strCTM = 'CTM';
        string strGriv ='Grievance';
        string strupdateString = 'Assigned User to Submitted to Quaility Review by';
      set<ID> setRequestIDs = new set<Id>();
        
      for(Case C:listCases){
        if(C.Request_Type_Lookup__c != null 
          && C.Ready_for_QA_Review__c == true
          ){
          setRequestIDs.add(C.Request_Type_Lookup__c);
        }
      }

        map<id,Request_Type__c> mapRequestType 
          = new map<id,Request_Type__c>([SELECT ID, Is_a_CTM__c, 
                                               Is_a_Grievance__c 
                                         FROM Request_Type__c 
                                         WHERE (Is_a_CTM__c = true OR
                                            Is_a_Grievance__c = true) AND
                                        Id in :setRequestIDs]);
    
          if(mapRequestType.size()>0){
        map<string, CreateAndAssignReviewFromCase__c> mapCAARFC 
          = CreateAndAssignReviewFromCase__c.getall();
              for(Case CA: listCases){
            CreateAndAssignReviewFromCase__c CAARFC_CTM = mapCAARFC.get(strCTM);
            CreateAndAssignReviewFromCase__c CAARFC_Gri = mapCAARFC.get(strGriv);
            Request_Type__c RT = mapRequestType.get(CA.Request_Type_Lookup__c);
              if(CA.Ready_for_QA_Review__c == true && RT.Is_a_CTM__c == true 
                  && (CA.Submitted_to_Quality_Review_by__c == null || CA.Submitted_to_Quality_Review_by__c == '')){
                lstCasesToUpdate.add(new Case(ID = CA.Id, Submitted_to_Quality_Review_by__c = strFirstLastName
                                                , Information_Description_To_Add__c = strupdateString));
                        lstReviewToInsert.add(new Review__c(
                            Reviewed_Item__c = CA.Id,
                            RecordTypeId = CAARFC_CTM.ReviewRecorcdType__c,
                            OwnerId = CAARFC_CTM.ReviewQueue__c,
                            Associate__c = idUser
                        ));
                    }
                    if(CA.Ready_for_QA_Review__c == true && RT.Is_a_Grievance__c == true  
                  && (CA.Submitted_to_Quality_Review_by__c == null || CA.Submitted_to_Quality_Review_by__c == '')){
                        lstCasesToUpdate.add(new Case(ID = CA.Id, Submitted_to_Quality_Review_by__c = strFirstLastName
                                                , Information_Description_To_Add__c = strupdateString));
                        lstReviewToInsert.add(new Review__c(
                            Reviewed_Item__c = CA.Id,
                            RecordTypeId = CAARFC_Gri.ReviewRecorcdType__c,
                            OwnerId = CAARFC_Gri.ReviewQueue__c,
                            Associate__c = idUser
                        ));
              }
                  }
            if(lstCasesToUpdate.size() > 0){
                update lstCasesToUpdate;    
            }
            if(lstReviewToInsert.size() >0){
                insert lstReviewToInsert;           
            }
      }
     }
   } */

  public static void UpdateAccountLookupFromPlan(list<Case> listCases){
    set<Id> CaseIds = new set<Id>();
    map<String, String> mapCasePlan = new map<String, String>();
    map<String, String> mapCasePlanParent = new map<String, String>();
    for(Case thisCase : listCases){
      CaseIds.add(thisCase.Id);
    }

    for(Case thisCase : [SELECT Id, Member_Plan_Lookup__r.Client__c, Member_Plan_Lookup__r.Client__r.ParentId
                         FROM Case WHERE Id IN :CaseIds]){
      if(thisCase.Member_Plan_Lookup__r.Client__c != null){
        mapCasePlan.put(thisCase.Id, thisCase.Member_Plan_Lookup__r.Client__c);
      } else {
        thisCase.AccountId = null;
        thisCase.Member_Plan_Account_Text__c = null;
        thisCase.Member_Plan_Parent_Account_Text__c = null;
      }
      if(thisCase.Member_Plan_Lookup__r.Client__r.ParentId != null){
        mapCasePlanParent.put(thisCase.Id, thisCase.Member_Plan_Lookup__r.Client__r.ParentId);
      }
    }

    system.debug(logginglevel.ERROR, 'mapCasePlan: ' + mapCasePlan);
    for(Case thisCase : listCases){
      if(mapCasePlan.containsKey(thisCase.Id)){
          thisCase.AccountId 
            = mapCasePlan.get(thisCase.Id);
          thisCase.Member_Plan_Account_Text__c 
            = mapCasePlan.get(thisCase.Id);
          if(mapCasePlanParent.containsKey(thisCase.id)){
            thisCase.Member_Plan_Parent_Account_Text__c 
              = mapCasePlanParent.get(thisCase.Id);
          }
      }
    }
  }

  public static void populateIntegrationQueue(list<Case> listCases, String strOperation){
    if(!CaseRecursionHandler.hasAlreadyPopulatedIntegrationQueue()) {
      list<Case> integratedCases = new list<Case>();
      for(case thisCase : listCases){ //make criteria configurable
        if(thisCase.PQT_Last_Modified__c != null) {
           integratedCases.add(thisCase);
        }
      }
      IntegrationQueueUtility.insertQueueItem(integratedCases, 'Case', strOperation);
      CaseRecursionHandler.setAlreadyPopulatedIntegrationQueue();
    }  
  }
  
  public static void populatePharmacy(list<Case> casesToProcess){
    //reference rx number copied from related rx to case in order to determine pharmacy to assign
    List<Case> lstCasesToUpdate = new List<Case>();

    //get integration user id
    IntegrationUserID__c integrationUserID = IntegrationUserID__c.getInstance('IntegrationServiceID');
    string intUId = integrationUserID.Integration_User_ID__c;

    if(!CaseRecursionHandler.hasAlreadySetPharmacy()) {
        for(case thisCase : casesToProcess){
            system.debug('RX #: ' + thisCase.Rx_1_Rx__c);
            //run if case was not created via integration being the integration will have already set the pharmacy
            if(thisCase.CreatedById != intUId){
          if(thisCase.RX_1_Rx__c != null){
                if(integer.valueof(thisCase.Rx_1_Rx__c) >= 1 && integer.valueof(thisCase.Rx_1_Rx__c) <= 49999999){
                    Case caseToUpdate = new Case(Id = thisCase.Id,
                                                 Pharmacy__c = 'Irving' 
                                                 );                         
                lstCasesToUpdate.add(caseToUpdate);
                } else {
                    Case caseToUpdate = new Case(Id = thisCase.Id,
                                                 Pharmacy__c = 'Albuquerque' 
                                                 );  
                lstCasesToUpdate.add(caseToUpdate);
                }           
          }  
            } 
        }
        if(lstCasesToUpdate.size() > 0){
            update lstCasesToUpdate;
        CaseRecursionHandler.setAlreadySetPharmacy();
        }   
    }   
  }

  public static void createPlanSharingRecords(list<Case> listCases, map<Id, Case> oldCases){
  //  if(!CaseRecursionHandler.hasAlreadyCreatedPlanSharingRecords()){
      /* Clear Existing */ 
      CaseUtility.clearExistingPlanSharing(listCases);

      /* Start New */
      list<CaseShare> insertCaseShare = new list<CaseShare>();
      map<String, list<PlanUserSharingRules__c>> mapPlanSharingRuleIncludes
        = new map<String, list<PlanUserSharingRules__c>>();
      map<String, list<PlanUserSharingRules__c>> mapPlanSharingRuleExcludes
        = new map<String, list<PlanUserSharingRules__c>>();
      set<Id> setIds = new set<Id>();
      
      map<String, PlanUserSharingRules__c> mapPlanSharingRules 
        = PlanUserSharingRules__c.getAll();
      for(String thisRule : mapPlanSharingRules.keySet()){
        if(mapPlanSharingRules.get(thisRule).IsExclude__c){
          if(mapPlanSharingRuleExcludes.containsKey(mapPlanSharingRules.get(thisRule).Plan_Contains__c)){
              mapPlanSharingRuleExcludes.get(mapPlanSharingRules.get(thisRule).Plan_Contains__c).add(mapPlanSharingRules.get(thisRule));
          } else {
            list<PlanUserSharingRules__c> newRules = new list<PlanUserSharingRules__c>();
            newRules.add(mapPlanSharingRules.get(thisRule));
            mapPlanSharingRuleExcludes.put(mapPlanSharingRules.get(thisRule).Plan_Contains__c, newRules);
          }
        } else {
          if(mapPlanSharingRuleIncludes.containsKey(mapPlanSharingRules.get(thisRule).Plan_Contains__c)){
              mapPlanSharingRuleIncludes.get(mapPlanSharingRules.get(thisRule).Plan_Contains__c).add(mapPlanSharingRules.get(thisRule));
          } else {
            list<PlanUserSharingRules__c> newRules = new list<PlanUserSharingRules__c>();
            newRules.add(mapPlanSharingRules.get(thisRule));
            mapPlanSharingRuleIncludes.put(mapPlanSharingRules.get(thisRule).Plan_Contains__c, newRules);
          }
        }
      }
      
      map<Id, list<String>> mapCaseIdToRoleNames = new map<Id, list<String>>();
      map<Id, boolean> mapCaseIsHistorical = new map<Id, boolean>();
      set<String> setRoleNames = new set<String>();
      for(Case thisCase : listCases){
        mapCaseIsHistorical.put(thisCase.Id, false);
        String strRecordTypeName = Schema.SObjectType.Case
                  .getRecordTypeInfosById()
                  .get(thisCase.RecordTypeId).getName();
        if((strRecordTypeName.contains('Item') || strRecordTypeName == 'Task')
             && thisCase.Request_Type__c != 'Crisis Management'&& thisCase.Request_Type__c != 'Prof Practices - Complaint'&& thisCase.Request_Type__c != 'Research'){
            
          for(String thisPlanContains : mapPlanSharingRuleIncludes.keySet()){
            if(thisCase.Member_Plan_Name__c != null){
              if(thisCase.Member_Plan_Name__c.contains(thisPlanContains)){
                for(PlanUserSharingRules__c thisSharingRule : mapPlanSharingRuleIncludes.get(thisPlanContains)){
                    if((strRecordTypeName.contains('Item') && thisSharingRule.Case_Record_Type__c.contains('Item'))
                        || (strRecordTypeName == thisSharingRule.Case_Record_Type__c)){
                      if(thisSharingRule.FieldName__c != null && thisSharingRule.FieldValue__c != null){
                         if(thisSharingRule.FieldValue__c.contains(string.valueOf(thisCase.get(thisSharingRule.FieldName__c)))){
                            if(mapCaseIdToRoleNames.containsKey(thisCase.Id)){
                              mapCaseIdToRoleNames.get(thisCase.Id).addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                              setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                            } else {
                              list<String> newRoleNames = new list<String>();
                              newRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                              mapCaseIdToRoleNames.put(thisCase.Id, newRoleNames);
                              setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                            }
                          }
                      } else {
                        if(mapCaseIdToRoleNames.containsKey(thisCase.Id)){
                          system.debug(LoggingLevel.ERROR, 'Roles Before 2nd Add: ' + mapCaseIdToRoleNames.get(thisCase.Id));
                          mapCaseIdToRoleNames.get(thisCase.Id).addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                          system.debug(LoggingLevel.ERROR, 'Roles After 2nd Add: ' + mapCaseIdToRoleNames.get(thisCase.Id));
                          setRoleNames.add(thisSharingRule.Shared_Roles__c);
                        } else {
                          list<String> newRoleNames = new list<String>();
                          newRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                          mapCaseIdToRoleNames.put(thisCase.Id, newRoleNames);
                          setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                        }
                      }
                   }
                }
              }
            }
          }
          for(String thisPlanContains : mapPlanSharingRuleExcludes.keySet()){
            if(thisCase.Member_Plan_Name__c != null){
              if(thisCase.Member_Plan_Name__c.contains(thisPlanContains)){
                for(PlanUserSharingRules__c thisSharingRule : mapPlanSharingRuleExcludes.get(thisPlanContains)){
                  if((strRecordTypeName == thisSharingRule.Case_Record_Type__c)
                      || strRecordTypeName.contains('Item') && thisSharingRule.Case_Record_Type__c.contains('Item')){  
                      if(thisSharingRule.FieldName__c != null && thisSharingRule.FieldValue__c != null){
                          if(!(string.valueOf(thisCase.get(thisSharingRule.FieldName__c)).contains(thisSharingRule.FieldValue__c))){
                            if(mapCaseIdToRoleNames.containsKey(thisCase.Id)){
                              mapCaseIdToRoleNames.get(thisCase.Id).addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                              setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                            } else {
                              list<String> newRoleNames = new list<String>();
                              newRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                              mapCaseIdToRoleNames.put(thisCase.Id, newRoleNames);
                              setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                            }
                          }
                      } else {
                        if(mapCaseIdToRoleNames.containsKey(thisCase.Id)){
                          mapCaseIdToRoleNames.get(thisCase.Id).addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                          setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                        } else {
                          list<String> newRoleNames = new list<String>();
                          newRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                          mapCaseIdToRoleNames.put(thisCase.Id, newRoleNames);
                          setRoleNames.addAll(thisSharingRule.Shared_Roles__c.split('\\,'));
                        }
                      }
                  }   
                }
              }
            }
          }
        }
      }
      
      mapCaseIsHistorical = isCaseHistorical(mapCaseIsHistorical.keySet());
      system.debug(logginglevel.ERROR, 'mapCaseIsHistorical: ' + mapCaseIsHistorical);
      map<String, Id> mapRoleIdByName = new map<String, Id>();
      set<Id> setRoleIds = new set<Id>();
      map<Id, Id> mapGroupIdByRoleId = new map<Id, Id>();
      if(setRoleNames.size()>0){
          for(UserRole thisRole : [SELECT Id, DeveloperName FROM UserRole Where DeveloperName IN :setRoleNames]){
            mapRoleIdByName.put(thisRole.DeveloperName, thisRole.Id);
            setRoleIds.add(thisRole.Id);
          }
      }
      
      
      if(setRoleIds.size()>0){
          for(Group thisGroup : [SELECT Id, RelatedId, Name FROM Group Where RelatedId IN :setRoleIds]){
            mapGroupIdByRoleId.put(thisGroup.RelatedId, thisGroup.Id);
          }
     }
     
      for(Id thisCaseId : mapCaseIdToRoleNames.keySet()){
        for(String thisRoleName : mapCaseIdToRoleNames.get(thisCaseId)){
          system.debug(LoggingLevel.ERROR, 'Final Roles: ' + mapCaseIdToRoleNames.get(thisCaseId));
          system.debug(LoggingLevel.ERROR, 'thisRoleName: ' + thisRoleName);
          system.debug(LoggingLevel.ERROR, 'RoleIdByName: ' + mapRoleIdByName.containsKey(thisRoleName));
          if(mapRoleIdByName.containsKey(thisRoleName)){
            String strAccessLevel = 'Read';
           // if(!mapCaseIsHistorical.containsKey(thisCaseId)){
            if(!mapCaseIsHistorical.get(thisCaseId)){
              strAccessLevel = 'Edit';
            }
            system.debug(logginglevel.ERROR, 'strAccessLevel: ' + strAccessLevel);
            CaseShare newCaseShare 
              = new CaseShare(CaseAccessLevel = strAccessLevel,
                                  CaseId = thisCaseId, 
                                  UserOrGroupId = mapGroupIdByRoleId.get(mapRoleIdByName.get(thisRoleName)));
            insertCaseShare.add(newCaseShare);
          }
        }
      }
      
      if(insertCaseShare.size() > 0){
        insert insertCaseShare;
        CaseRecursionHandler.setAlreadyCreatedPlanSharingRecords();
      }
//    }
  }

  private static map<Id, Boolean> isCaseHistorical(set<Id> CaseIds){
    map<Id, Boolean> mapCaseHistory = new map<Id, Boolean>();
    for(Case thisCase : [SELECT Id, Owner.Name 
                           FROM Case WHERE Id IN :CaseIds]){
      mapCaseHistory.put(thisCase.Id, 
                          setReadOnlyQueues.contains(thisCase.Owner.Name));
    }
    return mapCaseHistory;
  }

  private static void clearExistingPlanSharing(list<Case> listCases){
    set<Id> caseIds = new set<Id>();
    for(Case thisCase : listCases){
      caseIds.add(thisCase.Id);
    }
    list<CaseShare> deleteCaseShare
      = [SELECT Id FROM CaseShare 
            WHERE CaseId IN :caseIds AND RowCause = 'Manual'];
    if(deleteCaseShare.size() > 0) {
      delete deleteCaseShare;
    }
  }

  public static void syncManagingGroupAndQueue(list<Case> listCases){
    for(Case thisCase : listCases){
      String strRecordTypeName = Schema.SObjectType.Case
                  .getRecordTypeInfosById()
                  .get(thisCase.RecordTypeId).getName();
      if((strRecordTypeName == 'PCT - Item' || strRecordTypeName == 'PCT - Item: CTM Grievance')
                                  && thisCase.Assignment_Queue__c != thisCase.Managing_Group__c) {
        if(thisCase.Managing_Group__c != null) {
          thisCase.Assignment_Queue__c = thisCase.Managing_Group__c;
        } else {
          thisCase.Assignment_Queue__c = null;
        }
      }
    }
  }
  
  
  public static void fetchSupervisorEmail(list<Case> listCases){
    user usr = [select id, User_Supervisor__r.email,User_Supervisor__c from user where id =: userinfo.getUserId()];
    for(Case thisCase : listCases){
        if(usr.User_Supervisor__c != null){
            thisCase.Supervisor_Email_Address__c = usr.User_Supervisor__r.email;
        }
    }
  }
/*
// new method to setup format of case comments
 public static void formatNewCaseComments(list<Case_Comments__c> listCaseComments){
    if(!CaseRecursionHandler.hasAlreadyFormattedCaseComments()){
      for(Case_Comments__c thisComment : listCaseComments){
        if(thisComment.Comment_Body__c.length() > 200){
        //  thisComment.Comment_Body__c.replaceAll('\n', '');
          list<String> listRows = new list<String>();
          String currentRow = '';
          for(string thisWord : thisComment.Comment_Body__c.split(' ')){
            if(currentRow.length() < 200){
              currentRow = currentRow + thisWord + ' ';
              if(currentRow.length() > 200) {
                listRows.add(currentRow);
                currentRow = '';
              }
            } else {
              listRows.add(currentRow);
              currentRow = '';
            }
          }
          String formattedBody = '';
          for(String thisRow : listRows){
            formattedBody = formattedBody + thisRow + '\n';
          }
          thisComment.Comment_Body__c = formattedBody;
      //    thisComment.Comment_Body__c = formattedBody.replaceAll('\\*\\*', '\r\n');
        }
      }
      CaseRecursionHandler.setAlreadyFormattedCaseComments();  
    }
  }
*/

  public static void formatCaseComments(list<CaseComment> listCaseComments){
    system.debug('CALLED from CASECOMMENT TRIGGER::: '+CaseRecursionHandler.hasAlreadyFormattedCaseComments());
    if(!CaseRecursionHandler.hasAlreadyFormattedCaseComments()){
      for(CaseComment thisComment : listCaseComments){
        system.debug('ADAM Comment before = ' + thisComment.CommentBody);
        thisComment.CommentBody = thisComment.CommentBody.replaceAll('\"', '\'');
        if(thisComment.CommentBody.length() > 200){
        //  thisComment.CommentBody.replaceAll('\n', '');
          thisComment.CommentBody += ' O';
          list<String> listRows = new list<String>();
          String currentRow = '';
          for(string thisWord : thisComment.CommentBody.split(' ')){
            system.debug(currentRow.length()+'thisWord:: '+thisWord);
            if(currentRow.length() < 200){
              currentRow = currentRow + thisWord + ' ';
              system.debug('currentRow.length1:: '+currentRow.length());
              if(currentRow.length() > 200) {               
                listRows.add(currentRow);                
                currentRow = '';
              }
              if(thisWord.equalsIgnoreCase('O')){
                system.debug('WENT HERE::'+thisWord);
                currentRow = currentRow.replace('O','');
                listRows.add(currentRow);
                break;
              }
              
            } else {
              listRows.add(currentRow);
              currentRow = '';
            }
          }
          
          String formattedBody = '';
          for(String thisRow : listRows){
            formattedBody = formattedBody + thisRow + '\n';
          }
          system.debug('ADAM formatted Comment + ' + formattedBody);
          thisComment.CommentBody = formattedBody;
          system.debug('ADAM Comment after = ' + thisComment.CommentBody);
          
      //    thisComment.CommentBody = formattedBody.replaceAll('\\*\\*', '\r\n');
        }
      }
      CaseRecursionHandler.setAlreadyFormattedCaseComments();  
    }
  }
  
 public static void validateCaseComments(list<Case> listCaseComments){
    Integer COMMENT_MAX_LENGTH = 130000;
    if(!CaseRecursionHandler.hasAlreadyFormattedCaseComments()){
      for(Case thisComment : listCaseComments){
        if(thisComment.Case_Comments__c != null){
             thisComment.Case_Comments__c = wrapComment(thisComment.Case_Comments__c);
            if(thisComment.Case_Comments__c.length() > COMMENT_MAX_LENGTH) {
              integer charsOver = thisComment.Case_Comments__c.length() - COMMENT_MAX_LENGTH;
              thisComment.Case_Comments__c.addError('Comment too long. Must be less than 130,000 characters.' 
                + ' Your comment is over by ' + charsOver + ' characters.');
              //errorIdsSet.add(thisComment.Id);   
            }
            
        }
        //else
        
         system.debug('errorIdsSet>>'+errorIdsSet);
               // thisComment.Case_Comments__c = wrapComment(thisComment);
      }
      CaseRecursionHandler.setAlreadyFormattedCaseComments();  
    }
  }
  
 /* public static boolean validateCaseComments(list<Case> listCaseComments){
    Integer COMMENT_MAX_LENGTH = 130000;
    boolean lengthExceeded = false;
    if(!CaseRecursionHandler.hasAlreadyFormattedCaseComments()){
      for(Case thisComment : listCaseComments){
        if(thisComment.Case_Comments__c != null){
            if(thisComment.Case_Comments__c.length() > COMMENT_MAX_LENGTH) {
              integer charsOver = thisComment.Case_Comments__c.length() - COMMENT_MAX_LENGTH;
              thisComment.Case_Comments__c.addError('Comment too long. Must be less than 130,000 characters.' 
                + ' Your comment is over by ' + charsOver + ' characters.');
               
               lengthExceeded = true;
               errorIdsSet.add(thisComment.Id); 
            }
        }
               // thisComment.Case_Comments__c = wrapComment(thisComment);
      }
      CaseRecursionHandler.setAlreadyFormattedCaseComments();  
    }
    return lengthExceeded;
  }*/
  
  
  public static final integer BREAK_AT = 200;
    public static String wrapComment(string thisComment){
      system.debug('ADAM comment before = ' + thisComment);
    String formattedBody = '';  
    system.debug('length input comment:'+thisComment.length());     
    if(thisComment.length() > BREAK_AT){
      list<String> listRows = new list<String>();
      String currentRow = '';

      //for each word in the comment
      for(string thisWord : thisComment.split(' ')){
        //if current row length < BREAK_AT append next word
        if(currentRow.length() < BREAK_AT){
          currentRow = currentRow + thisWord + ' ';
          //if current row is now > BREAK_AT add to list and clear row
          if(currentRow.length() > BREAK_AT) {
            listRows.add(currentRow);
            currentRow = '';
          }
        } else {
          system.debug('in else condition !!');
          listRows.add(currentRow);
          currentRow = '';
        }
      }
      //if current row length is < BREAK_AT but no more words left to add then 
      //current row needs to be added to the list of rows
      if(currentRow.length() > 0){
        listRows.add(currentRow);
      }
      
      for(String thisRow : listRows){
        //formattedBody = formattedBody + thisRow + '\n';
        formattedBody = formattedBody + thisRow + '<br/>';
      }

      system.debug('inputCommentLength:' + thisComment.length() + 'num rows: '+listRows.size() + ' formattedBodyLength:' + formattedBody.length());
    } else {
      formattedBody =  thisComment;
    }
    system.debug('formattedBody:' + formattedBody);

    return formattedBody;
  }
  
   /* public static final integer BREAK_AT = 200;
    public static String wrapComment(CaseComment thisComment){
    String formattedBody = '';  
    system.debug('length input comment:'+thisComment.CommentBody.length());     
    if(thisComment.CommentBody.length() > BREAK_AT){
      list<String> listRows = new list<String>();
      String currentRow = '';

      //for each word in the comment
      for(string thisWord : thisComment.CommentBody.split(' ')){
        //if current row length < BREAK_AT append next word
        if(currentRow.length() < BREAK_AT){
          currentRow = currentRow + thisWord + ' ';
          //if current row is now > BREAK_AT add to list and clear row
          if(currentRow.length() > BREAK_AT) {
            listRows.add(currentRow);
            currentRow = '';
          }
        } else {
          system.debug('in else condition !!');
          listRows.add(currentRow);
          currentRow = '';
        }
      }
      //if current row length is < BREAK_AT but no more words left to add then 
      //current row needs to be added to the list of rows
      if(currentRow.length() > 0){
        listRows.add(currentRow);
      }
      
      for(String thisRow : listRows){
        formattedBody = formattedBody + thisRow + '\n';
      }

      system.debug('inputCommentLength:' + thisComment.CommentBody.length() + 'num rows: '+listRows.size() + ' formattedBodyLength:' + formattedBody.length());
    } else {
      formattedBody =  thisComment.CommentBody;
    }
    system.debug('formattedBody:' + formattedBody);

    return formattedBody;
  }

  public static void formatCaseComments(list<CaseComment> listCaseComments){
    Integer COMMENT_MAX_LENGTH = 1800;
    if(!CaseRecursionHandler.hasAlreadyFormattedCaseComments()){
      for(CaseComment thisComment : listCaseComments){

        if(thisComment.CommentBody.length() > COMMENT_MAX_LENGTH) {
          integer charsOver = thisComment.CommentBody.length() - COMMENT_MAX_LENGTH;
          thisComment.CommentBody.addError('Comment too long. Must be less than 1,800 characters.' 
            + ' Your comment is over by ' + charsOver + ' characters.');
        }

        thisComment.CommentBody = wrapComment(thisComment);
      }
      CaseRecursionHandler.setAlreadyFormattedCaseComments();  
    }
  }*/

public static boolean validateCaseComments(list<CaseComment> listCaseComments){
    Integer COMMENT_MAX_LENGTH = 4000;
    boolean lengthExceeded = false;
   // if(!CaseRecursionHandler.hasAlreadyFormattedCaseComments()){
      for(CaseComment thisComment : listCaseComments){
        if(thisComment.Commentbody != null){
            thisComment.Commentbody = wrapComment(thisComment.Commentbody);
            if(thisComment.Commentbody.length() > COMMENT_MAX_LENGTH) {
              integer charsOver = thisComment.Commentbody.length() - COMMENT_MAX_LENGTH;
              thisComment.Commentbody.addError('Comment too long. Must be less than 4,000 characters.' 
                + ' Your comment is over by ' + charsOver + ' characters.');
            lengthExceeded = true;
            errorSet.add(thisComment.ParentId);
            }
        }
                
      }
     // CaseRecursionHandler.setAlreadyFormattedCaseComments();  
   // }
    system.debug('lengthExceeded>> '+lengthExceeded+' <<<errorSet>> '+errorSet);
    return lengthExceeded;
  }

  public static void changeCaseOwner(list<Case> listCases, map<Id, Case> mapOldCases){
    set<Id> ownerIds = new set<Id>();
    map<Id, set<Id>> userMap = new map<Id, set<Id>>();
    String SysAdminProfileId  = [ Select Id from Profile Where NAme='System Administrator'].Id;
    for(Case thisCase : mapOldCases.values()){
      String strRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(thisCase.RecordTypeId).getName();
      if(strRecordTypeName == 'PCT - Service Gesture' && ((String)thisCase.OwnerId).substring(0,3) == '005'){
        ownerIds.add(thisCase.OwnerId);
        system.debug('>>>>>'+ownerIds);
      }
    }
    
    for(user usr: [select id, managerId, User_Supervisor__c from user where Id in: ownerIds]){
        if(!userMap.containskey(usr.Id)){
            userMap.put(usr.Id, new set<Id>());
            userMap.get(usr.Id).add(usr.managerId);
            userMap.get(usr.Id).add(usr.User_Supervisor__c);
        }
        else{
            userMap.put(usr.Id, new set<Id>());
        }   
    }
    
    if(UserInfo.getProfileId()  != SysAdminProfileId){
    for(case thisCase : listCases){
        if(thisCase.ownerId != mapOldCases.get(thisCase.Id).OwnerId && userMap.size()>0){
            system.debug('userMap:: '+userMap);
            // if it returns true, Manager or User Supervisor are trying to change the owner
            if(userMap.get(mapOldCases.get(thisCase.Id).OwnerId).contains(userinfo.getUserId())){
                if(((String)thisCase.OwnerId).substring(0,3) != '005')
                    thisCase.addError('Case Owner cannot be assigned to a Queue');
            }   
            else
                thisCase.addError('Service Gesture Case Owner cannot be changed');
        }
    }
  }
  }
  
  
 /* public static void caseOwnerRestriction(list<Case> listCases, map<Id, Case> mapOldCases){
    set<Id> profileIds = new set<Id>();
    set<Id> ownerIds = new set<Id>();
    set<Id> usersWithType = new set<Id>();
    for(profile p : [select id, name from profile where name like '%integration%' OR name like '%admin%']){
        profileIds.add(p.Id);   
    }
    
    for(case cs : listCases){
        if(((String)cs.OwnerId).substring(0,3) == '005'){
            ownerIds.add(cs.OwnerId);   
        }
    }
    
    if(ownerIds.size()>0){
        for(user usr : [select Id, name, User_Type__c from user where Id in:ownerIds]){
            if(usr.User_Type__c == 'Prime Internal' || usr.User_Type__c == 'External Vendor'){
                usersWithType.add(usr.Id);
            }   
        }
    }
    
    for(case thisCase: listCases){
        if(thisCase.ownerId != mapOldCases.get(thisCase.Id).OwnerId && (profileIds.Contains(userInfo.getProfileId()) || usersWithType.size()>0)){
            system.debug('Allow changes');
        }
        else{
            thisCase.addError('Plan users cannot  be selected for this field.');
        }
    }
  }*/
  
  
  public static String validateManagingGroup(list<Case> listCases, map<Id, Case> mapOldCases){
    String ErrorMessage = null;
    set<Id> CaseIds = new set<Id>();
    set<Id> AccountIds = new set<Id>();
    set<Id> PlanIds = new set<Id>();
    map<Id, String> mapPlanAllowedGroups
      = new map<Id, String>();
    map<Id, String> mapQueueNames
      = new map<Id, String>();
     // string profileId;
    //list<profile> myProfile = [select id, name from profile where name ='Plan User'];
    //if(myProfile.size()>0){
     //   profileId = myProfile[0].Id;
   // }
    for(Case thisCase : listCases){
      String strRecordTypeName = Schema.SObjectType.Case
                  .getRecordTypeInfosById()
                  .get(thisCase.RecordTypeId).getName();
      if((strRecordTypeName == 'PCT - Item' || strRecordTypeName == 'PCT - Item: CTM Grievance')){
        CaseIds.add(thisCase.Id);
        PlanIds.add(thisCase.Member_Plan_lookup__c);
      }
    }
    
    for(QueuesObject thisQueue : [select queue.id, queue.name from queuesobject]){
      mapQueueNames.put(thisQueue.Queue.Id, thisQueue.Queue.Name);
    }

    if(PlanIds.size()>0){
        for(Plan__c thisPlan : [SELECT Id, Client__r.Allowed_Managing_Groups__c 
                                 FROM Plan__c WHERE Id IN :PlanIds]){
          if(thisPlan.Client__r.Allowed_Managing_Groups__c != null){
            mapPlanAllowedGroups.put(thisPlan.Id, thisPlan.Client__r.Allowed_Managing_Groups__c);
          }
        }
    }

    for(Case thisCase : listCases){
      
      if(mapPlanAllowedGroups.containsKey(thisCase.Member_Plan_Lookup__c)
         && mapQueueNames.containsKey(thisCase.OwnerId)){
        system.debug(LoggingLevel.ERROR, 'Owner Name: ' + mapQueueNames.get(thisCase.OwnerId));
        system.debug(LoggingLevel.ERROR, 'Owner Name Trimed: ' + string.valueOf(mapQueueNames.get(thisCase.OwnerId)).remove('Queue').trim());
        system.debug(LoggingLevel.ERROR, 'Allowed Groups: ' + mapPlanAllowedGroups.get(thisCase.Member_Plan_lookup__c));
        system.debug(LoggingLevel.ERROR, 'Owner Id: ' + thisCase.OwnerId);
        system.debug(LoggingLevel.ERROR, 'Old Owner Id: ' + mapOldCases.get(thisCase.Id).OwnerId);
        if(thisCase.OwnerId != mapOldCases.get(thisCase.Id).OwnerId){

          if(!(mapPlanAllowedGroups.get(thisCase.Member_Plan_lookup__c).Contains(
          string.valueOf(mapQueueNames.get(thisCase.OwnerId)).remove('Queue').trim()))){
              //string.valueOf(mapQueueNames.get(thisCase.OwnerId)).remove('Queue').trim())) && userInfo.getProfileId() == profileId){
            ErrorMessage = ' The Owner Queue you have selected is not valid for ' +
                           'Cases at this Client / Plan.  Please select a different Owner Queue.';      
            break;
          }

        }
      }
      if(thisCase.Managing_Group__c != null && mapPlanAllowedGroups.containsKey(thisCase.Member_Plan_lookup__c)){
        if(!mapPlanAllowedGroups.get(thisCase.Member_Plan_lookup__c).Contains(thisCase.Managing_Group__c)){
          ErrorMessage = ' The Managing Group you have selected is not valid for ' +
                         'Cases at this Client / Plan.  Please select a different Managing Group.';
          break;
        }
      }
    }
    return ErrorMessage;
  }
  
  public static void createCreatedBySharingRecord(list<Case> listCases){
    list<CaseShare> insertCaseShare = new list<CaseShare>();
    map<Id, boolean> mapUserHasRefillEntry
      = new map<Id, boolean>();
    
    set<Id> CreatedByIds = new set<Id>();
    for(Case thisCase : listCases){
      CreatedByIds.add(thisCase.CreatedById);
    }

    for(PermissionSetAssignment thisAssignment : [SELECT Id, PermissionSet.Label, AssigneeId
                                              FROM PermissionSetAssignment
                                              WHERE PermissionSet.IsOwnedByProfile = false 
                                              AND AssigneeId IN :CreatedByIds]){
      if(thisAssignment.PermissionSet.Label == 'Order Refill Entry'){
        mapUserHasRefillEntry.put(thisAssignment.AssigneeId, true);
      }
    }

    for(Case thisCase : listCases){
      if(mapUserHasRefillEntry.containsKey(thisCase.CreatedById)
         && thisCase.CreatedById != thisCase.OwnerId){
        String RecordTypeName = Schema.SObjectType.Case
                                .getRecordTypeInfosById()
                                .get(thisCase.RecordTypeId).getName();
        if(RecordTypeName == 'PCT - Order Refill'
                            && !thisCase.isClosed){
          CaseShare newCaseShare = new CaseShare(CaseId = thisCase.Id,
                                                 UserOrGroupId = thisCase.CreatedById,
                                                 CaseAccessLevel = 'Edit'
                                                 );
          insertCaseShare.add(newCaseShare);
        }
      }
    }

    if(insertCaseShare.size() > 0){
      insert insertCaseShare;
    }
  }
  
  public static void clearCreatedBySharing(list<Case> listCases, map<Id, Case> oldCases) {
    list<CaseShare> deleteCaseShares = new list<CaseShare>();
    set<Id> CreatedByIds = new set<Id>();
    set<Id> CaseIds = new set<Id>();

    for(Case thisCase : listCases){
      if(thisCase.isClosed && !(oldCases.get(thisCase.Id).isClosed)){
        CaseIds.add(thisCase.Id);
        CreatedByIds.add(thisCase.CreatedById);
      }
    }
    for(CaseShare thisCaseShare : [SELECT CaseId, UserOrGroupId
                                   FROM CaseShare WHERE CaseId IN :CaseIds
                                   AND UserOrGroupId IN :CreatedByIds
                                   AND RowCause = 'Manual']){
      for(Case thisCase : listCases){
        if(thisCase.Id == thisCaseShare.CaseId
            && thisCase.CreatedById == thisCaseShare.UserOrGroupId){
          deleteCaseShares.add(thisCaseShare);
          break;
        }
      }
    }
    if(deleteCaseShares.size() > 0){
      delete deleteCaseShares;
    }
  }

  public static String validateRecordTypeChange(list<Case> listCases, map<Id, Case> oldCases){
    String ErrorMessage = null;
    for(Case thisCase : listCases){
      if(thisCase.RecordTypeId != oldCases.get(thisCase.Id).RecordTypeId
         && (thisCase.RecordTypeId != null)){
        String OldRecordType = Schema.SObjectType.Case
                                  .getRecordTypeInfosById()
                                  .get(oldCases.get(thisCase.Id).RecordTypeId).getName();
        String NewRecordType = Schema.SObjectType.Case
                                  .getRecordTypeInfosById()
                                  .get(thisCase.RecordTypeId).getName();
        if((OldRecordType.Contains('POP') && NewRecordType.Contains('POP'))
            || (OldRecordType.Contains('Item') && NewRecordType.Contains('Item'))
            || (OldRecordType == null && NewRecordType == null)) {
          //Do Nothing
        } else {
          ErrorMessage = 'Cases with the Record Type ' + 
                         OldRecordType +
                         ' cannot be changed to the record type ' + 
                         NewRecordType;
          break;
        }                                                
      }
    }
    return ErrorMessage;
  }
  public static void currentUserManagerEmailAddress(list<case> listCases,
                                                   map<Id, case> mapCases,
                                                   string operation){ 
                                                   
    Map<ID, User> map_USER = new Map<id, User>();
    Id userId = userinfo.getuserid();

    for(User oUser :[select FirstName,Id,IsActive,Manager.email,Location__c,Group_Team__c from user    
                     where id=:userinfo.getuserid()]){
        map_USER.put(oUser.id, oUser);
    }
    
    for(case objCase : listCases) {
        if(map_USER.containsKey(UserId)){
             if(operation.equalsIgnoreCase('Insert')){
                objCase.Createdby_Manager_Email_Address__c = map_USER.get(UserId).Manager.email;
                objCase.Createdby_User_Group_Team__c = map_USER.get(UserId).Group_Team__c;
                objCase.Createdby_User_Location__c = map_USER.get(UserId).Location__c;
            }
        }
    }
  }
  public static void currentUserRole(list<case> listCases,string operation){ 
        
        Id roleId= userinfo.getUserRoleId();
         system.debug('my debug'+roleId);
         String roleName='None';
          if(roleId!=null){
         roleName=[Select Id,Name from UserRole where Id=:roleId].Name;
         }
        
        for(case objCase : listCases) {
            Boolean isAlready=false;
            if(operation.equalsIgnoreCase('insert')){
                 DateTime currentTime = datetime.now();
                String lastVal=objCase.Edited_Role_History__c;
                if(lastVal==null){
                lastVal='';
                }
                else{
                if(lastVal.contains(roleName)){
            
               isAlready=true;
                }
                }
              if(!isAlready){
              String updateVal=lastVal+'-<b>EditedBy:</b>'+roleName+' -'+currentTime;
               objCase.Edited_Role_History__c=updateVal;
               }
                
            }
        }      
  } 
    
    public static void replaceDoubleQuotes(list<case> cases) {
        for(Case c : cases) {
            c.Member_ID__c = replaceDoubleQuotes(c.Member_ID__c);
            c.Member_Last_Name__c = replaceDoubleQuotes(c.Member_Last_Name__c);
            c.Member_First_Name__c = replaceDoubleQuotes(c.Member_First_Name__c);
            c.Prime_Record_Number__c = replaceDoubleQuotes(c.Prime_Record_Number__c);
            c.Other_Member_Notes__c = replaceDoubleQuotes(c.Other_Member_Notes__c);
            c.Patient_First_Name__c = replaceDoubleQuotes(c.Patient_First_Name__c);
            c.Patient_Last_Name__c = replaceDoubleQuotes(c.Patient_Last_Name__c);
        }
    }
    
    private static String replaceDoubleQuotes(String s) {
        if(s == null) {
            return s;
        }
        return s.replaceAll('\"', '\'');
    }
    
    public static void isEmployeeUpdate(list<case> listCases,string operation){ 
        
        system.debug('my debug');
        for(case objCase : listCases) {
            if( (objCase.RecordTypeId==rtTask)||(objCase.RecordTypeId==rtItem)||(objCase.RecordTypeId==rtGrievance)){
                String groupName= objCase.Group_Number__c;
                String plan_account=objCase.Plan_Account_Name__c;
                 String client_id= objCase.Member_Plan_Account_Text__c;
                
                //If groupName is null that means it could be a task
                system.debug('groupName '+groupName);
                if(groupName==null){
                    String parentId=objCase.ParentId;
                    List<Case> parentDetails=[select Group_Number__c,Plan_Account_Name__c,Member_Plan_Account_Text__c from case where id=:parentId];
                    Case parentCase=parentDetails.get(0);
                    groupName=parentCase.Group_Number__c;
                    plan_account=parentCase.Plan_Account_Name__c;  
                    client_id=parentCase.Member_Plan_Account_Text__c; 
                    system.debug('client_id for task '+client_id);
                }
                             
                system.debug('client_id for item cases '+client_id);     
                Boolean empFlag=false;
                integer grpCount=0;      
                if(groupName!=null){
                    grpCount=[SELECT count() from Group__c  where name=:groupName and client__c=:client_id];
                    if(grpCount>0){
                        empFlag=[select id, name,Employee_Group__c from Group__c  where name=:groupName and client__c=:client_id].Employee_Group__c;
                    }
                    system.debug('my debug'+grpCount);
                }
                Id roleId= userinfo.getUserRoleId();
                system.debug('my debug'+roleId);
                String roleName='None';
                if(roleId!=null){
                    roleName=[Select Id,Name from UserRole where Id=:roleId].Name;
                }
                if(roleName=='BCBS - MN (Without Employee)' && empFlag==true){
                    //objCase.Group_Number__c='test';
                    objCase.addError('This case could not be created as your rights do not allow to create this case');
                    errorIdsSet.add(objCase.Id); 
                    
                } 
                
                if(operation.equalsIgnoreCase('insert')){           
                    
                    objCase.isEmployeeGroup__c=empFlag;
                                    
                    
                }
            }
        }
        
        
    }
          public static void memberPlanTextUpdate(list<case> listCases,string operation){   
        system.debug('my debug');
       for(case objCase : listCases) {      
       if(operation.equalsIgnoreCase('insert')){           
           objCase.Member_Plan_Text__c=objCase.Member_Plan_Name_Formula__c;
                            
           }
       }
  } 

      public static void fhcpValidation(list<case> listCases,string operation){ 
        case objCase = listCases.get(0);
            if( (objCase.RecordTypeId==rtTask)||(objCase.RecordTypeId==rtItem)||(objCase.RecordTypeId==rtGrievance)){
                String ownerType=objCase.Owner_Type__c;
                String ownerId= objCase.OwnerId;    
                String currentPlan=objCase.Member_Plan_Name__c;
                boolean isShowError=false; 
                   if(ownerType=='Queue'){
                    try{               
                 String qName=[select  queue.name from queuesobject where queue.id=:ownerId].queue.name;
                      
                     if(objCase.Member_Plan_Name__c != null){
                    if(!currentPlan.contains('H1035')&&qName.contains('FHCP')){
                        isShowError=true;
                    }
                     }
                    }
                    catch(Exception ex){
                       
                    }
                }
                else{
                    try{
                   String roleName=[Select userrole.name from User where Id=:ownerId].userrole.name;
                     if(objCase.Member_Plan_Name__c != null){
                     if(roleName.contains('FHCP')&& !currentPlan.contains('H1035')){
                        isShowError=true;
                    }  
                     }
                }
                    catch(Exception ex ){
                        
                    }
                    
                }
                if(isShowError){
                        objCase.addError('The Owner or Queue you have selected is not valid for Cases at this Client / Plan.  Please select a different Owner Queue or User');
                        errorIdsSet.add(objCase.Id);    
                }                                
        
            } 
        
    
      }
    
}