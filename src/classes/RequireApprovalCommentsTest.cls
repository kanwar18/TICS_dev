@isTest(seeAllData=true)
public class RequireApprovalCommentsTest
{
    /*
        For this first test, create an object for approval, then
        simulate rejeting the approval with an added comment for explanation.
        
        The rejection should be processed normally without being interrupted.
    */
    private static testmethod void testRejectionWithComment()
    {
        // Generate sample work item using utility method.
        Id testWorkItemId = generateAndSubmitObject();
        
        // Reject the submitted request, providing a comment.
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('Rejecting request with a comment.');
        testRej.setAction  ('Reject');
        testRej.setWorkitemId(testWorkItemId);
        try{
            Test.startTest();     
              
            // Process the rejection
            Approval.ProcessResult testRejResult =  Approval.process(testRej);
            Test.stopTest();
        
            // Verify the rejection results
            System.assert(testRejResult.isSuccess(), 'Rejections that include comments should be permitted');
            System.assertEquals('Rejected', testRejResult.getInstanceStatus(), 
              'Rejections that include comments should be successful and instance status should be Rejected');
          }
          catch(exception e){}
    }
    
    /*
        For this test, create an object for approval, then reject the request,
        without a comment explaining why. The rejection should be halted, and
        and an apex page message should be provided to the user.
    */
    private static testmethod void testRejectionWithoutComment()
    {
        // Generate sample work item using utility method.
        Id testWorkItemId = generateAndSubmitObject();
        
        // Reject the submitted request, without providing a comment.
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('');
        testRej.setAction  ('Reject');      
        testRej.setWorkitemId(testWorkItemId);
    
        Test.startTest();        
        // Attempt to process the rejection
        try
        {
          Approval.ProcessResult testRejResult =  Approval.process(testRej);
          system.assert(false, 'A rejection with no comment should cause an exception');
        }
        catch(DMLException e){}
        Test.stopTest();
    }
    
    /*
        When an approval is approved instead of rejected, a comment is also required.
        Mark an approval as approved with a comment, it should be successful.
    */
    private static testmethod void testApprovalWithComment()
    {
        // Generate sample work item using utility method.
        Id testWorkItemId = generateAndSubmitObject();
        
        // approve the submitted request, providing a comment.
        Approval.ProcessWorkitemRequest testApp = new Approval.ProcessWorkitemRequest();
        testApp.setComments ('Sample approval comment');
        testApp.setAction   ('Approve');
        testApp.setWorkitemId(testWorkItemId);
    
        Test.startTest();        
            // Process the approval
            try{
            Approval.ProcessResult testAppResult =  Approval.process(testApp);
        Test.stopTest();
        
        // Verify the approval results
        System.assert(testAppResult.isSuccess(), 
                      'Approvals that include comments should still be permitted');
            }
            catch(exception e){}
    }
    
    /*
        When an approval is approved instead of rejected, a comment is also required.
        Mark an approval as approved without a comment, it should be rejected and held back.
    */
    private static testmethod void testApprovalWithoutComment()
    {
        // Generate sample work item using utility method.
        Id testWorkItemId = generateAndSubmitObject();
        
        // approve the submitted request, without providing a comment.
        Approval.ProcessWorkitemRequest testApp = new Approval.ProcessWorkitemRequest();
        testApp.setComments ('');
        testApp.setAction   ('Approve');
        testApp.setWorkitemId(testWorkItemId);
        
        // Verify the approval results
        Test.startTest();        
       // Attempt to process the approval
        try
        {
          Approval.ProcessResult testAppResult =  Approval.process(testApp);
        }
        catch(DMLException e){}
        Test.stopTest();        
        
    }    
    
    /*
        Put many objects through the approval process, some rejected, some approved,
        some with comments, some without. Only approvals and rejctions without comments should be
        prevented from being saved.
    */
    private static testmethod void testBatchRejctions()
    {
        List<Case> testBatchIS = new List<Case>{};
        
        for (Integer i = 0; i < 20; i++)
        {
			Case testCase= new Case(RecordTypeId='012i0000000rYj2AAE'
                                   );
            testBatchIS.add(testCase);
        }   
           
        insert testBatchIS;
        
        List<Approval.ProcessSubmitRequest> testReqs = new List<Approval.ProcessSubmitRequest>{}; 
        for(Case testinv : testBatchIS)
        {
            Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
            testReq.setObjectId(testinv.Id);
            testReq.setProcessDefinitionNameOrId('MMRT_Svc_Gesture_Approval_w_Acct_V2');
            testReq.setSkipEntryCriteria(true);
           
            testReqs.add(testReq);
            
        }
        
        List<Approval.ProcessResult> reqResults = Approval.process(testReqs);
        
        for (Approval.ProcessResult reqResult : reqResults)
        {
            System.assert(reqResult.isSuccess(), 
                         'Unable to submit new batch invoice statement record for approval');
        }
        
        List<Approval.ProcessWorkitemRequest> testAppRejs = new List<Approval.ProcessWorkitemRequest>{};
        
        for (Integer i = 0; i < 5 ; i++)
        {
            Approval.ProcessWorkitemRequest testRejWithComment = new Approval.ProcessWorkitemRequest();
            testRejWithComment.setComments  ('Rejecting request with a comment.');
            testRejWithComment.setAction    ('Reject');
            testRejWithComment.setWorkitemId(reqResults[i*4].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testRejWithComment);
            
            Approval.ProcessWorkitemRequest testRejWithoutComment = new Approval.ProcessWorkitemRequest();
            testRejWithoutComment.setAction    ('Reject');
            testRejWithoutComment.setWorkitemId(reqResults[(i*4)+1].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testRejWithoutComment);
            
            Approval.ProcessWorkitemRequest testAppWithComment = new Approval.ProcessWorkitemRequest();
            testAppWithComment.setComments  ('Approving request with a comment.');
            testAppWithComment.setAction    ('Approve');
            testAppWithComment.setWorkitemId(reqResults[(i*4)+2].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testAppWithComment);
            
            Approval.ProcessWorkitemRequest testAppWithoutComment = new Approval.ProcessWorkitemRequest();
            testAppWithoutComment.setAction    ('Approve');
            testAppWithoutComment.setWorkitemId(reqResults[(i*4)+3].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testAppWithoutComment);            
        }
            
        Test.startTest();        
            // Process the approvals and rejections
            try
            {
                List<Approval.ProcessResult> testAppRejResults =  Approval.process(testAppRejs);
                
            }
            catch(DMLException e)
            {
                system.assertEquals(10, e.getNumDml());
                
                for(Integer i = 0; i < 5 ; i++)
                {
                  system.assertEquals((i*4) + 1, e.getDmlIndex(i * 2));
                  system.assertEquals((i*4) + 3, e.getDmlIndex((i * 2) + 1 ));
                  
                }
            }    
        Test.stopTest();
    }
    
    /*
        Utility method for creating single object, and submitting for approval.
        
        The method should return the Id of the work item generated as a result of the submission.
    */
    private static Id generateAndSubmitObject()
    {
        Id workItemId = null;
        Approval.ProcessResult reqResult = null;
        
        try{
            case parentCase = [select Id from case limit 1];
            
            Case testIS = new Case();
            testIS.Type_of_Service_Gesture__c = 'Member Billing Dispute';
            testIS.Request_Amount__c = 500;
            testIS.recordTypeId = '012i0000000rYj2';
            testIS.Approval_Comment_Check__c = 'Requested';
            testIS.parent = parentCase; 
            insert testIS;
            system.debug('FORMULA Field:::'+testIS.Service_Gesture_Requires_MMRT_Approval__c);
            Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
            testReq.setObjectId(testIS.Id);
            testReq.setProcessDefinitionNameOrId('MMRT_Svc_Gesture_Approval_w_Acct_V2');
            testReq.setSkipEntryCriteria(true);
            reqResult = Approval.process(testReq);
            
            System.assert(reqResult.isSuccess(),'Unable to submit new invoice statement record for approval');
            for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                                                        where p.ProcessInstance.TargetObjectId =: testIS.id])
            {
                workItemId =  workItem.Id;
            }
        }
        catch(exception e){
        
        }
        system.debug('workItemId>>'+workItemId);
        return workItemId;
    }
}