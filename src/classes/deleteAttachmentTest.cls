/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class deleteAttachmentTest {

    static testMethod void myUnitTest() {
      list<user> testUsers = new list<user>();
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      user admin = new User(Alias = 'standt', Email='standarduser@testorg.com', 
					      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
					      LocaleSidKey='en_US', ProfileId = p.Id, 
					      TimeZoneSidKey='America/Los_Angeles', UserName='standarduserAdmin@testorg.com');
      insert admin;
      
      for(integer i=0; i<5;i++){
      	User u = new User(Alias = 'standt'+i, Email='standarduser@testorg.com', 
					      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
					      LocaleSidKey='en_US', ProfileId = p.Id, 
					      TimeZoneSidKey='America/Los_Angeles', UserName='testabcuser'+i+'@testorg.com');
      
      	testUsers.add(u);
      }
      insert testUsers;
	      user testUser1 = testUsers[0];
	      user manager = testUsers[1];
	      user supervisor = testUsers[2];
	      user otherUser = testUsers[3];
	      testUser1.ManagerId = manager.Id;
	      testUser1.User_Supervisor__c = supervisor.Id;
      update testUser1;
      attachment attach;
      //system.runAs(admin){
      	Blob b = Blob.valueOf('Test Data'); 
      	account acc = new account(Name='Testacc');
      	insert acc;
      	attach = new attachment();
      	attach.Body = b;
      	attach.Name = 'Test Attachment';
      	attach.ownerId = testUser1.Id;
      	attach.ParentID=acc.id;
      	insert attach;
     // }
      
      system.runAs(otherUser){
      	try{
      		delete attach;
      	}
      	catch(exception e){}
      }
    }
}