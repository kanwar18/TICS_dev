public without sharing class ReviewUtility {
  public static boolean isExecuting = true;
  public static String validateRecordType(list<Review__c> listReviews){
  	String ErrorMessage = null;
  	map<String, ReviewRecordTypeValidation__c>  RTValidatoins
  	  = ReviewRecordTypeValidation__c.getAll();
    set<Id> ReviewIds = new set<Id>();
    map<Id, String> mapCaseRecordType 
      = new map<Id, string>();

    for(Review__c thisReview : listReviews){
      mapCaseRecordType.put(thisReview.Reviewed_Item__c, null);
    }

    for(Case thisCase : [SELECT RecordType.Name FROM Case WHERE Id IN :mapCaseRecordType.keySet()]){
      mapCaseRecordType.put(thisCase.Id, thisCase.RecordType.Name);
    }

  	for(Review__c thisReview : listReviews){
      String RecTypeName = Schema.SObjectType.Review__c
                  .getRecordTypeInfosById()
                  .get(thisReview.RecordTypeId).getName();
      if(RTValidatoins.containsKey(RecTypeName)){
      	if(!RTValidatoins.get(RecTypeName)
      		  .Case_Record_Type__c.contains(mapCaseRecordType.get(thisReview.Reviewed_Item__c))){
      	  ErrorMessage = 'The record type ' +
      	                  thisReview.RecordType.Name +
      	                  ' is not valid for cases with the record type ' +
      	                  thisReview.Reviewed_Item__r.recordType.Name + '.';
      	  break;
      	}
      }
  	}
  	return ErrorMessage;
  }
  
  
  // This method will create the sharing of QR record to the Associate User as R/W
  // once the user is selected as "Associate" on the QR record 
  public static void shareWithAssociate(list<Review__c> listReviews){
     // Review_Share is the "Share" table that was created when the
     // Organization Wide Default sharing setting was set to "Private".
     // Allocate storage for a list of Review_Share records.
    List<Review__Share> reviewShares  = new List<Review__Share>();
    
    // For each of the Job records being inserted, do the following:
    for(Review__c qReview : listReviews){

        // Create a new Review_Share record to be inserted in to the Review_Share table.
        Review__Share AssociateShare = new Review__Share();
            
        // Populate the Review_Share record with the ID of the record to be shared.
        AssociateShare.ParentId = qReview.Id;
            
        // Then, set the ID of user or group being granted access. In this case,
        // we’re setting the Id of the Associate that was specified by 
        // the User in the Associate_QR__c lookup field on the Quality Review record.        
        AssociateShare.UserOrGroupId = qReview.Associate_QR__c;
            
        // Specify that the Associate should have edit access for this particular record.
        AssociateShare.AccessLevel = 'edit';
            
        // Specify that the reason the Associate can edit the record  
        // (Associate_Access__c is the Apex Sharing Reason that we defined earlier.)
        AssociateShare.RowCause = Schema.Review__Share.RowCause.Associate_Access__c;
            
        // Add the new Share record to the list of new Share records.
        reviewShares.add(AssociateShare);
    }
        
    // Insert all of the newly created Share records and capture save result 
    Database.SaveResult[] reviewShareInsertResult = Database.insert(reviewShares,false);
    // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.SaveResult sr : reviewShareInsertResult){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                               &&  err.getMessage().contains('AccessLevel'))){
                    system.debug('Unable to grant sharing access due to following exception: '+ err.getMessage());
                }
            }
            i++;
        }   
  
  }
  
  
  // This method will update the sharing of the QR record from R/W to R only
  // for the Associate User once the "Quality Review Complete" checkbox is selected.
  public static void updateShareWithAssociate(set<Id> userSet, map<Id, Review__c> reviewMap){
  	system.debug('USER SET::'+userSet+'reviewMap>> '+reviewMap);
  	List<Review__Share> reviewShares  = new List<Review__Share>();
  	for(Review__Share revShare : [select AccessLevel,Id,ParentId,RowCause,UserOrGroupId from Review__Share where UserOrGroupId In: userSet ]){
  		system.debug('revshare>>'+revShare);
  		if(reviewMap.containsKey(revShare.ParentId)){
  			if(reviewMap.get(revShare.ParentId).Associate_QR__c == revshare.UserOrGroupId){
	  			revshare.AccessLevel = 'Read';
	  			reviewShares.add(revShare);
  			}
  		}
  		
  	}
  	
  	if(reviewShares.size()>0){
  		Database.SaveResult[] reviewShareInsertResult = Database.update(reviewShares,false);
    // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.SaveResult sr : reviewShareInsertResult){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                               &&  err.getMessage().contains('AccessLevel'))){
                    system.debug('Unable to change sharing access due to following exception: '+ err.getMessage());
                }
            }
            i++;
        }  	
  	}	
  }
  
  
  // This method will assign the permission set "Quality Review Associate Access" to the Associate user
  @future
  public static void assignPermissionSet(set<Id> listUsers){
  	list<user> usersToUpdate = new list<user>();
  	for(user u: [select id, Is_Associate__c from user where Id in: listUsers]){
  		if(!u.Is_Associate__c){
  			u.Is_Associate__c = true;
  			usersToUpdate.add(u);
  		}	
  	}
  	
  	if(usersToUpdate.size()>0){
  		update usersToUpdate;
  	}
  }
  
  // This method will remove the permission set "Quality Review Associate Access" from the Associate user
  @future
  public static void removePermissionSet(set<Id> listUsers){
  	list<user> usersToUpdate = new list<user>();
  	for(user u: [select id, Is_Associate__c from user where Id in: listUsers]){
  		if(u.Is_Associate__c){
  			u.Is_Associate__c = false;
  			usersToUpdate.add(u);
  		}	
  	}
  	
  	if(usersToUpdate.size()>0){
  		update usersToUpdate;
  	}
  }  
  
  
}