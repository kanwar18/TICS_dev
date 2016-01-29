Trigger UserTrigger on User (before Update) {
  
  set<Id> userSupervisorId = new  set<Id>();
  List<User> updateUserLst = new List<User>(); // this list to remove User Supervisor

    for(User thisUser : Trigger.New){
      if( thisUser.IsActive == False && trigger.OldMap.get(thisUser.Id).IsActive != thisUser.IsActive)
          userSupervisorId.add(thisUser.Id);
    }
    for(User userRec : [Select id, User_Supervisor__c from user where User_Supervisor__c IN : userSupervisorId]){
        userRec.User_Supervisor__c = null;
        updateUserLst.add(userRec);
    }
    if(!updateUserLst.Isempty()){
        update updateUserLst;
    }
    
}