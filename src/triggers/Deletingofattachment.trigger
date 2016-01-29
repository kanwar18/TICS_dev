trigger Deletingofattachment on Attachment (before delete) {
    set<Id> restrictedUserRoleIds = new set<Id>();
    set<Id> allowedUserRoleIds = new set<Id>();
    //userIds.add(UserInfo.getUserId());
    set<string> profileNames = new set<string>{'MMRT Compliance Specialist / Supervisor','MMRT Manager', 'MMRT MRS','MMRT Quality','System Administrator'};
    set<string> restrictedRoleNames = new set<string>{'MMRT_Contact_Center_Manager','Medicare_Resolution_Specialist','MMRT_Contact_Center_Supervisor', 'MMRT_Quality_Review'};
    set<string> allowedRoleNames = new set<string>{'Medicare_Member_Research_Team'};
    map<Id, Set<Id>> map_CreatedBy2Access = new map<Id, Set<Id>>();
    map<Id, User> map_AdminUsers = new map<Id, User>([Select Id, ManagerId, User_Supervisor__c from User Where Profile.Name IN :profileNames]);
    
    for(userRole ur: [SELECT DeveloperName,Id FROM UserRole]){
        if(restrictedRoleNames.Contains(ur.DeveloperName)){
            restrictedUserRoleIds.add(ur.Id);
        }
        if(allowedRoleNames.contains(ur.DeveloperName)){
            allowedUserRoleIds.add(ur.Id);  
        }
    }
    for(Attachment currAtt : trigger.old){
        map_CreatedBy2Access.put(currAtt.CreatedById, new set<Id>{currAtt.CreatedById});
    }
    
    for(User varUser :[ Select Id, ManagerId,UserRole.Id, User_Supervisor__c from User Where Id IN : map_CreatedBy2Access.keyset()]) {
    
        if(varUser.ManagerId != null) {
            map_CreatedBy2Access.get(varUser.Id).add(varUser.ManagerId);
            //userIds.add(varUser.ManagerId);
        }
        if(varUser.User_Supervisor__c != null) {
            map_CreatedBy2Access.get(varUser.Id).add(varUser.User_Supervisor__c);
            //userIds.add(varUser.User_Supervisor__c);
        }
        
        if(varUser.Id != null) {
            map_CreatedBy2Access.get(varUser.Id).add(varUser.Id);
        }
        
        if(varUser.UserRole.Id != null) {
            map_CreatedBy2Access.get(varUser.Id).add(varUser.UserRole.Id);
        }
    } 
    
    for(Attachment currAtt : trigger.old){
        map_CreatedBy2Access.get(currAtt.CreatedById).addAll(restrictedUserRoleIds);
    }
    
    
    for ( Attachment currAtt : trigger.old ) {
        /*if (!map_AdminUsers.containsKey(UserInfo.getUserId()) &&  !userIds.contains(UserInfo.getUserId())) {
               currAtt.CreatedById.addError('\nYou don\'t have the rights to delete this attachment. You may only delete your own Attachments.\n'
                       + 'For further information contact your Supervisor.\n');
               }*/
               system.debug(map_CreatedBy2Access.get(currAtt.CreatedById).contains(UserInfo.getUserRoleId())+'--CURRENT ROLE--'+UserInfo.getUserRoleId());
               //First check for current user, it's Manager and Supervisor
               if(map_AdminUsers.containsKey(UserInfo.getUserId()) &&  map_CreatedBy2Access.get(currAtt.CreatedById).contains(UserInfo.getUserId())) {
                    //do nothing
                    system.debug('FIRST IF');
               }
               else if(allowedUserRoleIds.contains(UserInfo.getUserRoleId())){
                // do nothing
                system.debug('SECOND IF');
               }
               else if(restrictedUserRoleIds.contains(UserInfo.getUserRoleId()) && currAtt.CreatedById != UserInfo.getUserId()){
                currAtt.CreatedById.addError('\nYou don\'t have the rights to delete this attachment. You may only delete your own Attachments.\n'
                       + 'For further information contact your Supervisor.\n');
               system.debug('THIRD IF');
               }
               
               if (!map_AdminUsers.containsKey(UserInfo.getUserId()) &&  !map_CreatedBy2Access.get(currAtt.CreatedById).contains(UserInfo.getUserId())) {
               currAtt.CreatedById.addError('\nYou don\'t have the rights to delete this attachment. You may only delete your own Attachments.\n'
                       + 'For further information contact your Supervisor.\n');
               continue;
               }
               /*
               if(map_CreatedBy2Access.get(currAtt.CreatedById).contains(UserInfo.getUserRoleId()) && currAtt.CreatedById != UserInfo.getUserId()){
                currAtt.CreatedById.addError('\nYou don\'t have the rights to delete this attachment. You may only delete your own Attachments.\n'
                       + 'For further information contact your Supervisor.\n');
               } 
               */
       }
      
  }