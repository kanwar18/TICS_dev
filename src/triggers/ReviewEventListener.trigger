trigger ReviewEventListener on Review__c (before insert, before update, 
	                                       after insert, after update) {
  if(trigger.isBefore){
    String ErrorMessage = ReviewUtility.validateRecordType(trigger.new);
    if(ErrorMessage != null){
      trigger.new[0].addError(ErrorMessage);
    }
  }
  if(trigger.isAfter){
  	list<Review__c> reviews = new list<Review__c>();
  	list<Review__c> oldreviews = new list<Review__c>();
  	set<Id> associateUsersToRemove = new set<Id>();
  	set<Id> associateUsers = new set<Id>();
  	set<Id> associateUsers2 = new set<Id>();
  	map<Id, Review__c> reviewMap = new map<Id, Review__c>();
  	for(Review__c rev : trigger.new){
  		if(rev.Associate_QR__c != null){
	  		reviews.add(rev);
	  		associateUsers.add(rev.Associate_QR__c);
  		}
  		if(trigger.isUpdate){// when the Associate is not assigned at the time of creation and added later on
  			if(rev.Associate_QR__c != null && rev.Associate_QR__c != trigger.oldmap.get(rev.Id).Associate_QR__c){
  				oldreviews.add(rev);
  				associateUsers2.add(rev.Associate_QR__c); 
  			}
  		if(rev.Quality_Review_Complete__c && rev.Quality_Review_Complete__c != trigger.oldmap.get(rev.Id).Quality_Review_Complete__c){
  			associateUsersToRemove.add(rev.Associate_QR__c);
  			reviewMap.put(rev.Id, rev);	
  		}
  		
  		}
  	}
  	
  	if(trigger.isInsert && reviewUtility.isExecuting){
  		if(reviews.size()>0){
  			reviewUtility.shareWithAssociate(reviews);  		
  		}
  		
  		if(associateUsers.size()>0){
  			reviewUtility.assignPermissionSet(associateUsers);
  		}
  		reviewUtility.isExecuting = false;
  	}
  	
  	if(trigger.isUpdate && reviewUtility.isExecuting){
  		if(oldreviews.size()>0){
  			reviewUtility.shareWithAssociate(oldreviews);  		
  		}  	 	
  		
	  	if(associateUsers2.size()>0){
	  		reviewUtility.assignPermissionSet(associateUsers2);
	  	}
  		
  		system.debug('<<associateUsersToRemove>>'+associateUsersToRemove+' <<reviewMap>>'+reviewMap);
	  	if(associateUsersToRemove.size()>0 && reviewMap.size()>0){
	  		reviewUtility.removePermissionSet(associateUsersToRemove);
	  		reviewUtility.updateShareWithAssociate(associateUsersToRemove, reviewMap);
	  	}
	  	reviewUtility.isExecuting = false;
  	}
  	
  }
}