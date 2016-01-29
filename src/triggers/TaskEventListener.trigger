trigger TaskEventListener on Task (before insert, before update,
                                   after insert, after update) {
  if(trigger.isBefore){
      map<Id,string> errorMap = new map<Id,String>(); 
       errorMap = TaskUtility.validateRecordTypeMatch(trigger.new);
      if(errorMap != null && errorMap.size()>0){
      	for(task tsk: trigger.new){
      		if(errorMap.containsKey(tsk.Id)){
      			tsk.addError(errorMap.get(tsk.Id));
      		}
      	}
        //trigger.new[0].addError(validationError);
      }

      TaskUtility.defaultTypeForIssueResolution(trigger.new);

  }

  if(trigger.isAfter){
    try{
      TaskUtility.LetterActivitiesValidation(trigger.new);
        if(TaskUtility.isExecuting){
            TaskUtility.updateCaseFields(trigger.new);
            //TaskUtility.checkStaTusToUpdate(trigger.new);
            TaskUtility.isExecuting = false;
        } 
        if(trigger.isUpdate){
          if(TaskUtility.firstRun){
            TaskUtility.checkStaTusToUpdate(trigger.new);
            TaskUtility.firstRun = false;
          }
            
        }
          
        }
        catch(exception e){
            for(task thisTask: trigger.new){
              thisTask.addError('Error: '+e.getMessage());
        }
    }
    
  }
}