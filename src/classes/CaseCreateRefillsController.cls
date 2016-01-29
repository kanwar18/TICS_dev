public with sharing class CaseCreateRefillsController {
  public Case objCase {get;set;}
  public RefillAddRows objRefillRows{get;set;}
  private ApexPages.StandardController controller {get;set;}
  public CaseCreateRefillsController(ApexPages.StandardController stdController) {
    this.controller = stdController;
    initialize();
  }
    @testVisible private void initialize(){
        if(objCase == null)
            objCase = new case();
        this.objCase = (Case)controller.getRecord();
        this.objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PCT - Order Refill').getRecordTypeId();
        this.objCase.Original_Created_By_User__c = UserInfo.getUserId();
        system.debug(logginglevel.ERROR, 'gotUserId');
        this.objCase.Original_Created_By_User_Email__c = UserInfo.getUserEmail(); 
        system.debug(logginglevel.ERROR, 'gotUserEmail');
        if(this.objRefillRows == null)
            this.objRefillRows = new RefillAddRows();
        system.debug(logginglevel.ERROR, 'createdRefillRows');

        // This code is here to support pre-populating the view during MsaTools B2B PCT Refill creation
        String memberId = System.currentPageReference().getParameters().get('MEMBERID');
        if(String.isNotEmpty(memberId)) {
          objCase.Member_ID__c = memberId;
        }
    
        // This code is here to support pre-populating the view during MsaTools B2B PCT Refill creation
        String lastName = System.currentPageReference().getParameters().get('LASTNAME');
        if(String.isNotEmpty(lastName)) {
          objCase.Member_Last_Name__c = lastName;
        }
    
    }   
    
  public PageReference saveAll(){
    PageReference returnPage;
    Savepoint sp = Database.setSavepoint();
    initialize();
    system.debug(objCase.No_Charge_for_Shipping__c+'<<--objCase>>'+objcase.No_Charge_for_Shipping_Reason__c);
    try {
          case newObjCase = objCase.clone(false);
          insert newObjCase;
          for(RX__c thisRX : this.objRefillRows.mapRXs.values()){
            thisRX.Related_Case__c = newObjCase.Id;
          }
          
      insert this.objRefillRows.mapRXs.values();
      returnPage = new PageReference('/' + newObjCase.Id);
    } catch (exception ex) {
      Database.rollback(sp);
      map<integer, RX__c> mapRXsCopy = this.objRefillRows.mapRXs.clone();
      this.objRefillRows.mapRXs.clear();
      this.objRefillRows.mapRXs.putAll(mapRXsCopy);
      
      if(ex.getDMLType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
        ApexPages.addmessages(ex);//(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
      else
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage())); 
      returnPage = null;
    }
    return returnPage;
  }

  public class RefillAddRows {   
    public map<integer, RX__c> mapRXs {get;set;}
    public Integer intNumberOfRefills {get;set;}

    public RefillAddRows() {
        system.debug(logginglevel.ERROR, 'instantiate RefillAdRows');
        RX__c newRX = new RX__c(RecordTypeId = Schema.SObjectType.RX__c.getRecordTypeInfosByName().get('Refill Rx').getRecordTypeId());
      mapRXs = new map<integer, RX__c>();
      mapRXs.put(0, newRX);
      intNumberOfRefills = mapRXs.keySet().size();
    }
    
    public void AddRow() {
      RX__c newRX = new RX__c(RecordTypeId = Schema.SObjectType.RX__c
                                                 .getRecordTypeInfosByName()
                                                 .get('Refill Rx')
                                                 .getRecordTypeId());
      mapRXs.put(mapRXs.size(), newRX);
      intNumberOfRefills = mapRXs.keySet().size();
    }  

    public void RemoveRow(){
      String rowToRemove = ApexPages.currentPage().getParameters().get('RowToRemove');
      mapRXs.remove(integer.valueOf(rowToRemove));

      map<integer, RX__c> newOrderedMap = new map<integer, RX__c>();
      integer i = 0;
      for(RX__c thisRX : mapRXs.values()){
        newOrderedMap.put(i, thisRX);
        i = i + 1;
      }
      mapRXs = newOrderedMap;
      intNumberOfRefills = mapRXs.keySet().size();
    }
  }
}