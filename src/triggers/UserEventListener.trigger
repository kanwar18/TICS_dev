trigger UserEventListener on User (Before Insert, Before Update,
	                                After Insert, After Update) {
  if(trigger.isBefore && trigger.isInsert) {
    UserUtility.updatePlanAccountId(trigger.new);
  }

  if(trigger.isAfter && trigger.isInsert) {
    UserUtility.updatePermissionSetAssignment(trigger.new, null);
  }
  
  if(trigger.isBefore && trigger.isUpdate) {
    UserUtility.updatePlanAccountId(trigger.new);
  }

  if(trigger.isAfter && trigger.isUpdate) {
    UserUtility.updatePermissionSetAssignment(trigger.new, trigger.oldMap);
  }
}