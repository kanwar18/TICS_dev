@isTest
private class UserUtility_Test {
 @isTest static void testAssignPermissionSet() {
    List<Profile> intprofiles = [select id, name from Profile where 
                            name = 'Integration Service'];
        User NewIntUser = new User(alias = 'admin',
        email='testagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = intprofiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testintegration@prime.com');
    insert NewIntUser;   

    UserFieldPermissionSetMapping__c thisMapping
      = new UserFieldPermissionSetMapping__c(Name = 'Crisis Management',
                                             User_Field__c = 'Crisis_Management__c');
    insert thisMapping;

    system.runAs(NewIntUser){
      List<Profile> profiles = [select id, name from Profile where 
                            name = 'Member Services Agent - MSA'];
      User NewTestUser = new User(alias = 'msaag',
        email='testmsaagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = profiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testmsaagent@prime.com',
        Crisis_Management__c = true);
      insert NewTestUser;
      update NewTestUser;

      list<PermissionSetAssignment> listPSResult = [SELECT Id FROM PermissionSetAssignment
                                     WHERE AssigneeId = :NewTestUser.Id
                                     AND PermissionSet.Label = 'Crisis Management'];
   //   system.assertEquals(1, listPSResult.size());       
    }                          
  }

  @isTest static void testDeletePermissionSet() {
    List<Profile> intprofiles = [select id, name from Profile where 
                            name = 'Integration Service'];
        User NewIntUser = new User(alias = 'admin',
        email='testagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = intprofiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testintegration@prime.com');
   insert NewIntUser;  

    UserFieldPermissionSetMapping__c thisMapping
      = new UserFieldPermissionSetMapping__c(Name = 'Crisis Management',
                                             User_Field__c = 'Crisis_Management__c');
    insert thisMapping;  

    system.runAs(NewIntUser){   
      List<Profile> profiles = [select id, name from Profile where 
                             name = 'Member Services Agent - MSA'];
    
      User NewTestUser = new User(alias = 'msaag',
        email='testmsaagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = profiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testmsaagent@prime.com',
        Crisis_Management__c = true);
      insert NewTestUser;

      NewTestUser.Crisis_Management__c = false;
      UserRecursionHandler.alreadySynchedPermissionSet = false;
      update NewTestUser;
    

      list<PermissionSetAssignment> listPSResult = [SELECT Id FROM PermissionSetAssignment
                                     WHERE AssigneeId = :NewTestUser.Id
                                     AND PermissionSet.Label = 'Crisis Management'
                                     AND PermissionSet.IsOwnedByProfile = false];
      system.assertEquals(0, listPSResult.size());          
    }                       
  }

  @isTest static void testNonExistingPermissionSet() {
    UserFieldPermissionSetMapping__c thisMapping
      = new UserFieldPermissionSetMapping__c(Name = 'Crisis Management Oops',
                                             User_Field__c = 'Crisis_Management__c');
    insert thisMapping;
    List<Profile> profiles = [select id, name from Profile where 
                            name = 'Member Services Agent - MSA'];
    
    User NewTestUser = new User(alias = 'msaag',
        email='testmsaagent@prime.com',
        emailencodingkey='UTF-8',
        lastname='User', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = profiles[0].Id,
        timezonesidkey='America/Los_Angeles',
        username='testmsaagent@prime.com',
        Crisis_Management__c = true,
        Receive_Custom_Apex_Emails__c = true);

    test.startTest();
      Insert NewTestUser;
    test.stopTest();

    list<PermissionSetAssignment> listPSResult = [SELECT Id FROM PermissionSetAssignment
                                     WHERE AssigneeId = :NewTestUser.Id
                                     AND PermissionSet.Label = 'Does Not Exist'];
    system.assertEquals(0, listPSResult.size());       
  }                         
}