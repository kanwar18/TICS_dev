trigger CaseCommentEventListener on CaseComment (before Insert, before Update) {
  if(trigger.isBefore){
    CaseUtility.formatCaseComments(trigger.new);
  }
}