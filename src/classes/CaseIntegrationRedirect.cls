/**
*   {Purpose}  –  Direct user to Case that was requested via external GET                 
*        
*   {Function}  – Referenced by CaseRedirect page.  This page is called by external GET integrations.
*				  Retrieves CaseNumber paramater from passed url and looks up related 18 char unique CaseID using CaseNumber as key
*				  The returned Case unique id is applied to a page redirect which opens the respective Case
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032   
*
*	ASSUMPTION:	- 
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   3/26/14 	Kevin Johnson DCS    	Created 
*   =============================================================================
*/

public class CaseIntegrationRedirect {	
	public PageReference getRedir() {
        String strCaseNumber 
          = string.EscapeSingleQuotes(ApexPages.currentPage().getParameters().get('casenum'));
    	List<Case> cId = [SELECT Id 
						  FROM Case
        			      WHERE CaseNumber = :strCaseNumber];        			      

    	if(cId.size() > 0){
    		PageReference newPage;
    		newPage = new PageReference('/'+cId[0].Id);
    		return newPage.setRedirect(true);
    	} else {
    	    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Could not resolve Case Number'));  
    		return null;
    	}
    }	
}