trigger RequireApprovalComments on Case (before update) 
{
  // Create a map that stores all the objects that require editing 
  Map<Id, Case> approvalStatements = 
  new Map<Id, Case>{};

  for(Case inv: trigger.new)
  {
    // Put all objects for update that require a comment check in a map,
    // so we only have to use 1 SOQL query to do all checks
    
    if (inv.Approval_Comment_Check__c == 'Requested')
    { 
      approvalStatements.put(inv.Id, inv);
      // Reset the field value to null, 
      // so that the check is not repeated,
      // next time the object is updated
      inv.Approval_Comment_Check__c = null; 
    }
  }  
   
  if (!approvalStatements.isEmpty())  
  {
    // UPDATE 2/1/2014: Get the most recent process instance for the approval.
    // If there are some approvals to be reviewed for approval, then
    // get the most recent process instance for each object.
    List<Id> processInstanceIds = new List<Id>{};
    
    for (Case invs : [SELECT (SELECT ID
                                              FROM ProcessInstances
                                              ORDER BY CreatedDate DESC
                                              LIMIT 1)
                                      FROM Case
                                      WHERE ID IN :approvalStatements.keySet()])
    {
        processInstanceIds.add(invs.ProcessInstances[0].Id);
    }
      
    // Now that we have the most recent process instances, we can check
    // the most recent process steps for comments.  
    for (ProcessInstance pi : [SELECT TargetObjectId,
                                   (SELECT Id, StepStatus, Comments 
                                    FROM Steps
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1 )
                               FROM ProcessInstance
                               WHERE Id IN :processInstanceIds
                               ORDER BY CreatedDate DESC])
    {
      // If no comment exists, then prevent the object from saving.                 
      if ((pi.Steps[0].Comments == null || 
           pi.Steps[0].Comments.trim().length() == 0))
      {
        approvalStatements.get(pi.TargetObjectId).addError(
         'Please provide a reason for your approval/rejection');
      }
    }                                       
  }
}