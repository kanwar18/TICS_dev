public without sharing class UserUtility {
  public static void updatePlanAccountId(list<User> listUsers){
    list<User> listUpdateUsers = new list<User>();
    map<String, Id> mapPlanAccounts = new map<String, Id>();
    
    for(User thisUser : listUsers){
      mapPlanAccounts.put(thisUser.Plan_Account__c, null);
    }
    
    for(Account thisAccount: [SELECT Id, Name, System_Name__c, ParentId FROM Account 
                              WHERE System_Name__c IN :mapPlanAccounts.keySet()]){
      if(thisAccount.ParentId == null){
        mapPlanAccounts.put(thisAccount.System_Name__c, thisAccount.Id);
      } else {
        mapPlanAccounts.put(thisAccount.System_Name__c, thisAccount.ParentId);
      }
    }

    for(User thisUser : listUsers){
      if(mapPlanAccounts.containsKey(thisUser.Plan_Account__c)){
        thisUser.Plan_Account_Id__c
           = mapPlanAccounts.get(thisUser.Plan_Account__c);
      } else {
        thisUser.Plan_Account_Id__c = null;
      }
    }
  }

  public static void updatePermissionSetAssignment(list<User> listUsers, map<Id, User> mapOldUsers){
    map<String, PermissionSetAssignment> mapPermissionSetAssign
      = new map<String, PermissionSetAssignment>();  
    map<String, Id> mapPermissionSets 
      = new map<String, Id>();
    set<Id> setUserIds = new set<Id>();  
    set<String> setMissingPermissions = new set<String>();
    map<Id, set<Id>> mapUserPSDeletes 
      = new map<Id, set<Id>>();

    if(!UserRecursionHandler.hasSynchedPermissionSet()){
      map<String, UserFieldPermissionSetMapping__c> UserPermissionSetMapping 
          = UserFieldPermissionSetMapping__c.getAll();
      
      for(PermissionSet thisPermissionSet : [SELECT Id, Label FROM PermissionSet
                                                 WHERE IsOwnedByProfile = false]){
        mapPermissionSets.put(thisPermissionSet.Label, thisPermissionSet.Id);
      }

      if(mapOldUsers == null){ //Insert
        for(User thisUser : listUsers){
          for(String thisMapping : UserPermissionSetMapping.keySet()){
            if(mapPermissionSets.containsKey(thisMapping)){
              if(thisUser.get(UserPermissionSetMapping.get(thisMapping).User_Field__c) == true){
                PermissionSetAssignment thisAssignment 
                  = new PermissionSetAssignment(PermissionSetId = mapPermissionSets.get(thisMapping)
                                                ,AssigneeId = thisUser.Id);
                  mapPermissionSetAssign.put(string.ValueOf(mapPermissionSets.get(thisMapping)) + string.ValueOf(thisUser.Id), thisAssignment);
              }
            } else {
              setMissingPermissions.add(thisMapping);
            }
          }
        }
      } else { //Update
        for(User thisUser : listUsers){
          setUserIds.add(thisUser.Id);
          for(String thisMapping : UserPermissionSetMapping.keySet()){
            if(mapPermissionSets.containsKey(thisMapping)){
              if(thisUser.get(UserPermissionSetMapping.get(thisMapping).User_Field__c) !=
                  mapOldUsers.get(thisUser.Id).get(UserPermissionSetMapping.get(thisMapping).User_Field__c)) {
                if(thisUser.get(UserPermissionSetMapping.get(thisMapping).User_Field__c) == true){ //was false is now true
                  PermissionSetAssignment thisAssignment 
                    = new PermissionSetAssignment(PermissionSetId = mapPermissionSets.get(thisMapping)
                                                  ,AssigneeId = thisUser.Id);
                  mapPermissionSetAssign.put(string.ValueOf(mapPermissionSets.get(thisMapping)) + string.ValueOf(thisUser.Id), thisAssignment);           
                }
                else { //was true is now false
                  if(!mapUserPSDeletes.containsKey(thisUser.Id)){
                    set<Id> setPS = new set<Id>();
                    setPS.add(mapPermissionSets.get(thisMapping));
                    mapUserPSDeletes.put(thisUser.Id, setPS);
                  } else {
                    mapUserPSDeletes.get(thisUser.Id).add(mapPermissionSets.get(thisMapping));
                  }
                }  
              }
            } else {
              setMissingPermissions.add(thisMapping);
            }
          }
        }
      }  
      
      if(mapUserPSDeletes.keySet().size() > 0){
        clearPermissionSets(mapUserPSDeletes);
      }
     
      if(setMissingPermissions.size() > 0){
        system.debug(LoggingLevel.ERROR, 'Missing Permissions: ' + setMissingPermissions);
        sendMissingPermissionEmail(setMissingPermissions);
      }
      if(mapPermissionSetAssign.keySet().size() > 0){
        system.debug(LoggingLevel.ERROR, 'Assign Permissions: ' + mapPermissionSetAssign);
        Database.UpsertResult[] UR = Database.upsert(mapPermissionSetAssign.values(),Schema.PermissionSetAssignment.Id, false);
        //upsert mapPermissionSetAssign.values();
        UserRecursionHandler.setAlreadySynchedPermissionSet();
      }
    }
  }

  public static void clearPermissionSets(map<Id, set<Id>> mapUserPermissions){
    list<PermissionSetAssignment> listPermissionSetDelete 
      = new list<PermissionSetAssignment>();
    for(PermissionSetAssignment thisPSA : [SELECT Id, PermissionSetID, AssigneeId 
                                              FROM PermissionSetAssignment
                                              WHERE PermissionSet.IsOwnedByProfile = false 
                                              AND AssigneeId IN :mapUserPermissions.keySet()]){
      for(Id thisPSetId : mapUserPermissions.get(thisPSA.AssigneeId)) {
        if(thisPSA.PermissionSetId == thisPSetId){
          listPermissionSetDelete.add(thisPSA);
        }
      }
    }

    if(listPermissionSetDelete.size() > 0){
      system.debug(LoggingLevel.ERROR, 'Delete Permissions: ' + listPermissionSetDelete);
      delete listPermissionSetDelete;
    }
  }

  private static void sendMissingPermissionEmail(set<String> setMissingPermissions){
    list<User> listUsers = [SELECT Email FROM User 
                  WHERE Receive_Custom_Apex_Emails__c = true];

    Messaging.SingleEmailMessage ErrorEmail 
                = new Messaging.SingleEmailMessage();
    
    String strErrorMessage = 'One or more users were updated with a permission ' +
                              'set that does not exist.  The following missing ' +
                              'permissions were found: ' + '\\r\\n';
    for(String thisPermission : setMissingPermissions) {
      strErrorMessage += thisPermission + '\\r\\n';
    }
    list<String> listToAddrs = new list<String>();
    for(User thisUser : listUsers){
      listToAddrs.add(thisUser.Email);
    }
    ErrorEmail.setToAddresses(listToAddrs);
    ErrorEmail.setSubject('Missing Permission Set in Salesforce');
    ErrorEmail.setPlainTextBody(strErrorMessage);
    if(!test.isRunningTest()){ 
      Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ErrorEmail});
    }
  }
}