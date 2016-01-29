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
private class CaseRxCreateService_Test {

    static testMethod void CaseRxCreateService_Test() {
        
        Plan__c pAL = new Plan__c();
        	pAL.Name='AL - BCBS';
        	pAL.Line_of_Business__c='Commercial';
        	pAL.Plan_Status__c='Active';
        	
        	insert pAL;
        	
        Plan__c pUN = new Plan__c();
        	pUN.Name='*UNKNOWN*';
        	pUN.Line_of_Business__c='Commercial';
        	pUN.Plan_Status__c='Active';
        	
        	insert pUN;   
        
        CaseRxCreateService controller = new CaseRxCreateService();
        
        UnknownPlanRecordID__c cs = new UnknownPlanRecordID__c();
     		cs.Name='UnknownPlanRecordID';
     		cs.Unknown_Plan_ID__c=pUN.Id;
     		insert cs;
     	       
        CaseRxCreateService.Item i = new CaseRxCreateService.Item();
        	i.permaddress1='1234 Oak Dr';
        	i.permcity='Eagan';
        	i.permstate='MN';
        	i.permzip='11223';
        	i.cctype='Visa';
        	i.contactphone='111-111-1111';        	
        	i.memberfirstname='MFirstname';
        	i.memberlastname='MLastname';
        	i.memberid='2452';        	
        	i.memberplan='AL - BCBS';  //stage plan
        	i.nochargeforshipping=FALSE;
        	i.primerecordid='1';
        	i.recordtypeid='012i0000000rJC8AAM';  //pop record type id
        	i.readyfirstfax=FALSE;
        	i.readyrecordreview=FALSE;
        	i.readycphtcompletion=FALSE;
        	i.shippingissame=FALSE;
        	i.shippingmethod='Ground';  
       	
        CaseRxCreateService.Rx r = new CaseRxCreateService.Rx();
            r.patientname='Patientname';
        	r.primerecordid='1';
        	r.rxnum='Test Rx';	
        	r.strength='Weak';
        	r.drugname='Drug Name';
        	r.patientdaw=FALSE;
        	r.profilerx=FALSE;
        	r.prescriberdaw=FALSE;        	
        	
        List<CaseRxCreateService.Rx> lstRx = new List<CaseRxCreateService.Rx>();
        lstRx.add(r);
        	
        CaseRxCreateService.response res = new CaseRxCreateService.response();
   	 		res.success=TRUE;
   	 		res.casenumber='S000045';
  	 		res.id='005000000001112389';
  	 		res.statuscode='0';
  	 		res.message='No Error';
       
        CaseRxCreateService.insertCaseRx(i, lstRx);
	}
}