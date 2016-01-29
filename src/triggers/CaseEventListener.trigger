/**
*   {Purpose}  – Custom Trigger manager for the Case object.
*                 
*                 
*                 
*   {Function}  – Marshall for bulk operations on Case 
*   
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    Name             Description
*   5/1/12  Nick Cook DCS     Created 
*   =============================================================================
*/
trigger CaseEventListener on Case (before insert, before update, 
                                   after insert, after update,
                                                  after delete) {
  map<Id, case> errorMap = new map<Id, case>();
                                            
 
    if(trigger.isBefore && trigger.isInsert) {
        
    
    //Pre-Insert Methods
    String validationErrorFax 
      = CaseUtility.hasFaxNumberFormatValidationError(trigger.new);
    if(validationErrorFax != null){
      trigger.new[0].addError(validationErrorFax);
    }  
    
    for(case cs: trigger.new){
      String strRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getName();
        system.debug(cs.No_Charge_for_Shipping__c+'INSIDE CASE UTILITY'+cs.No_Charge_for_Shipping_Reason__c);
        if(cs.No_Charge_for_Shipping__c && string.ISBLANK(cs.No_Charge_for_Shipping_Reason__c))
            cs.addError('No Charge for Shipping Reason is a required field if "No Charge for Shipping" is selected');
        
    }
    String validationErrorManagingGroup
      = CaseUtility.validateManagingGroup(trigger.new, null);
    if(validationErrorManagingGroup != null) {
      trigger.new[0].addError(validationErrorManagingGroup);
    }
    

    CaseTriggerSwitch__c RunTrigger 
      = CaseTriggerSwitch__c.getInstance('generateFaxHTML');
    if(RunTrigger != null && RunTrigger.IsActive__c && UserInfo.getName() != 'Integration Service'){
      FaxMergeUtility.generateFaxHTML(trigger.new, trigger.oldMap, 'Insert');
    }

   RunTrigger 
      = CaseTriggerSwitch__c.getInstance('isInsideHours');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.isInsideHours(trigger.new, trigger.oldMap);
    }
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('manageFaxNumbers');
    if(validationErrorFax == null && RunTrigger != null && RunTrigger.IsActive__c){             
        CaseUtility.manageFaxNumbers(trigger.new);                
    }
        
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('replaceDoubleQuotes');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.replaceDoubleQuotes(trigger.new);
    }

    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('updateRequestTypeLookup');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.updateRequestTypeLookup(trigger.new, 'insert');
    }

    RunTrigger
      = CaseTriggerSwitch__c.getInstance('UpdateAccountLookupFromPlan');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.UpdateAccountLookupFromPlan(trigger.new);
    }  
    
    /*
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.copyNotesToComment(trigger.new, trigger.oldMap);
    }
    */
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToCustomComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
        CaseUtility.dataSetup(trigger.new);
        CaseUtility.copyNotesToCustomComment(trigger.new, trigger.oldMap);
    }
    
    
    RunTrigger
     = CaseTriggerSwitch__c.getInstance('syncAssignmentDateTimes');
    if(RunTrigger != null && RunTrigger.IsActive__c) {
      CaseUtility.syncAssignmentDateTimes(trigger.new);
    }
     
    RunTrigger
     = CaseTriggerSwitch__c.getInstance('validateCaseComments');
    if(RunTrigger != null && RunTrigger.IsActive__c) {
      CaseUtility.validateCaseComments(trigger.new);
    }
   // CaseUtility.copyTaskDescToComment(trigger.new);
    CaseUtility.syncManagingGroupAndQueue(trigger.new);
    CaseUtility.currentUserManagerEmailAddress(trigger.new, trigger.newMap, 'Insert');
    CaseUtility.fetchSupervisorEmail(trigger.new);
  }

  if(trigger.isAfter && trigger.isInsert){
    CaseUtility.isBeforeInsert = false;
    //Post-Insert Methods
    CaseTriggerSwitch__c RunTrigger 
      = CaseTriggerSwitch__c.getInstance('createAssignmentHistory');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.createAssignmentHistory(trigger.new, trigger.oldMap);
    }
    /*RunTrigger 
      = CaseTriggerSwitch__c.getInstance('setOriginalCreatedByData');
    if(RunTrigger != null && RunTrigger.IsActive__c){           
        CaseUtility.setOriginalCreatedByData(trigger.new, trigger.old);                
    }  */
    RunTrigger
      = CaseTriggerSwitch__c.getInstance('closeOpenAssignmentHistories');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.closeOpenAssignmentHistories(trigger.new);
    }
  /*  RunTrigger
      = CaseTriggerSwitch__c.getInstance('overwritePrimaryNCQAFields');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.overwritePrimaryNCQAFields(trigger.new);
    }*/
    
   RunTrigger
      = CaseTriggerSwitch__c.getInstance('populatePharmacy');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      system.debug(logginglevel.ERROR,'POPULATEPHARMACY TRIGGER ENTERED');
      CaseUtility.populatePharmacy(trigger.new);
    }
    
  //  CaseUtility.createCreatedBySharingRecord(trigger.new);

    if(UserInfo.getName() != 'Integration Service'){
      CaseUtility.populateIntegrationQueue(trigger.new, 'Insert');    
    }

    /*
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.copyNotesToComment(trigger.new, trigger.oldMap);
    } */
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToStdComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
        CaseUtility.copyNotesToStdComment(trigger.new, trigger.oldMap);
    }
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('trackFieldChangesStd');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
        //CaseUtility.trackFieldChangesStd(trigger.new, trigger.oldMap);
    }
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToCaseComments');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
      //CaseUtility.copyNotesToCaseComments(trigger.new, trigger.oldMap);
    }
    
    CaseUtility.isInsertOnly = true;
  }
  
  
    
  
  if(trigger.isBefore && trigger.isUpdate) { 
       
    //Pre-Update Methods
    CaseTriggerSwitch__c RunTrigger 
      = CaseTriggerSwitch__c.getInstance('hasLetterValidationError');
   



    
    if(RunTrigger != null && RunTrigger.IsActive__c){
      String validationError 
        = CaseUtility.hasLetterValidationError(trigger.new);
      if(validationError != null){
        trigger.new[0].addError(validationError);
      }
    }
   
    system.debug('CaseUtility.isInsertOnly:: '+CaseUtility.isInsertOnly);
    if(CaseUtility.isInsertOnly){
        RunTrigger = CaseTriggerSwitch__c.getInstance('setOriginalCreatedByData');
        if(RunTrigger != null && RunTrigger.IsActive__c){           
            CaseUtility.setOriginalCreatedByData(trigger.new, trigger.old);                
        }
        
    }
    




    system.debug('CaseUtility.isInsertOnly2:: '+CaseUtility.isInsertOnly);
    /*if(!CaseUtility.isInsertOnly){
        errorMap = CaseUtility.checkOriginalRequestDate(trigger.new);
        if(errorMap.size()>0){
            for(case cs: trigger.new){
                if(errorMap.containsKey(cs.id)){
                    cs.addError('Original Request Date cannot be after the Created Date.');
                }
            }
        }
    }*/
    
       
RunTrigger 
      = CaseTriggerSwitch__c.getInstance('isInsideHours');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.isInsideHours(trigger.new, trigger.oldMap);
    }
    
    if(CaseUtility.isInsertOnly){
        system.debug('Send EMail called');
        caseUtility.sendEmail(); 
    }
    
    
    String validationErrorRecordType
      = CaseUtility.validateRecordTypeChange(trigger.new, trigger.oldMap);
    if(validationErrorRecordType !=null){
      trigger.new[0].addError(validationErrorRecordType);
    }

    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('hasFaxNumberFormatValidationError');
    String validationErrorFax = null;
    if(RunTrigger != null && RunTrigger.IsActive__c){
      validationErrorFax 
       = CaseUtility.hasFaxNumberFormatValidationError(trigger.new);
      if(validationErrorFax != null){
        trigger.new[0].addError(validationErrorFax);
      }
    }     

    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('generateFaxHTML');
    if(RunTrigger != null && RunTrigger.IsActive__c && UserInfo.getName() != 'Integration Service'){
      FaxMergeUtility.generateFaxHTML(trigger.new, trigger.oldMap, 'Update');      
    }

    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('manageFaxNumbers');
    if(validationErrorFax == null && RunTrigger != null && RunTrigger.IsActive__c){             
        CaseUtility.manageFaxNumbers(trigger.new);                
    }    
      
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('replaceDoubleQuotes');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.replaceDoubleQuotes(trigger.new);
    }

    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('updateRequestTypeLookup');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.updateRequestTypeLookup(trigger.new, 'update');
    }

    RunTrigger
      = CaseTriggerSwitch__c.getInstance('UpdateAccountLookupFromPlan');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.UpdateAccountLookupFromPlan(trigger.new);
    }

    String validationErrorManagingGroup
      = CaseUtility.validateManagingGroup(trigger.new, trigger.oldMap);
    if(validationErrorManagingGroup != null) {
      trigger.new[0].addError(validationErrorManagingGroup);
    } 





    /*  
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.copyNotesToComment(trigger.new, trigger.oldMap);
    } */
    
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToCustomComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
        CaseUtility.dataSetup(trigger.new);
        CaseUtility.copyNotesToCustomComment(trigger.new, trigger.oldMap);
    }
    
    // This method has to run after DATASETUP method
    RunTrigger = CaseTriggerSwitch__c.getInstance('caseOwnerChangeRestriction');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
        CaseUtility.caseOwnerChangeRestriction(trigger.new, trigger.old);
    }
    
     
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('trackFieldChangesCustom');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
        CaseUtility.trackFieldChangesCustom(trigger.new, trigger.oldMap);
    }
    
    RunTrigger
     = CaseTriggerSwitch__c.getInstance('syncAssignmentDateTimes');
    if(RunTrigger != null && RunTrigger.IsActive__c) {
      CaseUtility.syncAssignmentDateTimes(trigger.new);
    }




    RunTrigger
     = CaseTriggerSwitch__c.getInstance('validateCaseComments');
    if(RunTrigger != null && RunTrigger.IsActive__c) {
      if(!CaseUtility.isInsertOnly)
        CaseUtility.validateCaseComments(trigger.new);
    }
    CaseUtility.syncManagingGroupAndQueue(trigger.new);
  }
  //&& CaseUtility.runOnce()
  if(trigger.isAfter && trigger.isUpdate){     
    CaseUtility.isBeforeUpdate = false;
         
    //Post-Update Methods
    CaseTriggerSwitch__c RunTrigger 
      = CaseTriggerSwitch__c.getInstance('hasLetterValidationError');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      String validationError 
        = CaseUtility.hasLetterValidationError(trigger.new);
      if(validationError != null){
        trigger.new[0].addError(validationError);
      }
    }
    // check the case owner change
    caseUtility.changeCaseOwner(trigger.new, trigger.oldMap);
    //caseUtility.caseOwnerRestriction(trigger.new, trigger.oldMap);
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('createAssignmentHistory');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.createAssignmentHistory(trigger.new, trigger.oldMap);
    } 
    /*    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToComment');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.copyNotesToComment(trigger.new, trigger.oldMap);
    }*/  
    
    if(CaseUtility.runOnce()){
        RunTrigger 
          = CaseTriggerSwitch__c.getInstance('copyNotesToStdComment');  
        if(RunTrigger != null && RunTrigger.IsActive__c){
          CaseUtility.copyNotesToStdComment(trigger.new, trigger.oldMap);
        }
        
        RunTrigger 
          = CaseTriggerSwitch__c.getInstance('trackFieldChangesStd');   
        if(RunTrigger != null && RunTrigger.IsActive__c){
          CaseUtility.trackFieldChangesStd(trigger.new, trigger.oldMap);
        }
    }
    
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('trackFieldChangesStdSGC');   
    if(RunTrigger != null && RunTrigger.IsActive__c && CaseUtility.isSGC){
      CaseUtility.trackFieldChangesStdSGC(trigger.new, trigger.oldMap);
    }
    
    RunTrigger 
      = CaseTriggerSwitch__c.getInstance('copyNotesToCaseComments');  
    if(RunTrigger != null && RunTrigger.IsActive__c){
      //CaseUtility.copyNotesToCaseComments(trigger.new, trigger.oldMap);
    }
 /*   RunTrigger
      = CaseTriggerSwitch__c.getInstance('overwritePrimaryNCQAFields');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.overwritePrimaryNCQAFields(trigger.new);
    }*/
    RunTrigger
      = CaseTriggerSwitch__c.getInstance('closeOpenAssignmentHistories');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.closeOpenAssignmentHistories(trigger.new);
    }
   /* RunTrigger
      = CaseTriggerSwitch__c.getInstance('CreateAndAssignReview');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.CreateAndAssignReview(trigger.new);
    }*/
    RunTrigger = 
      CaseTriggerSwitch__c.getInstance('createPlanSharingRecords');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      CaseUtility.createPlanSharingRecords(trigger.new, trigger.oldMap);
    }
    CaseUtility.createCreatedBySharingRecord(trigger.new);
    CaseUtility.clearCreatedBySharing(trigger.new, trigger.oldMap);
    
    RunTrigger
      = CaseTriggerSwitch__c.getInstance('populatePharmacy');
    if(RunTrigger != null && RunTrigger.IsActive__c){
      //check for changes on the rx 1 # field.  pass record to method setting pharmacy if field is not null and has changed
      //rx 1 # determines which pharmacy is reflected on case in pharmacy_c
      List<Case> casesToUpdate = new List<Case>();
      for(integer i = 0; i < trigger.new.size(); i++){ 
        //run for order refill       
        if(trigger.new[i].RecordTypeId == Schema.SObjectType.Case
                         .getRecordTypeInfosByName().get('PCT - Order Refill')
                         .getRecordTypeId()){
            if(trigger.new[i].Rx_1_Rx__c != trigger.old[i].Rx_1_Rx__c && trigger.new[i].Rx_1_Rx__c != null){
            casesToUpdate.add(trigger.new[i]);
          }
        } 
      }
      if(casesToUpdate.size() > 0){        
        CaseUtility.populatePharmacy(casesToUpdate);
      }
    }
    if(UserInfo.getName() != 'Integration Service'){
      CaseUtility.populateIntegrationQueue(trigger.new, 'Update');
    }
    
  }
    if(trigger.isBefore&& trigger.isUpdate){
    CaseTriggerSwitch__c RunTrigger
      = CaseTriggerSwitch__c.getInstance('currentUserRole');
     CaseUtility.currentUserRole(trigger.new,'insert');
     }
    if(trigger.isBefore&& trigger.isUpdate){
    CaseTriggerSwitch__c RunTrigger
      = CaseTriggerSwitch__c.getInstance('isEmployeeUpdate');
     CaseUtility.isEmployeeUpdate(trigger.new,'insert');
     }
                                                      
 if(trigger.isBefore&& trigger.isUpdate){
    CaseTriggerSwitch__c RunTrigger
      = CaseTriggerSwitch__c.getInstance('fhcpValidation');
     CaseUtility.fhcpValidation(trigger.new,'insert');
     }                                                      
       if(trigger.isBefore&& trigger.isUpdate){
    CaseTriggerSwitch__c RunTrigger
      = CaseTriggerSwitch__c.getInstance('memberPlanTextUpdate');
     CaseUtility.memberPlanTextUpdate(trigger.new,'insert');
     }                                                     
  if(trigger.isAfter && trigger.isDelete) {
    //Post-Delete Methods
  } 
 
  
}