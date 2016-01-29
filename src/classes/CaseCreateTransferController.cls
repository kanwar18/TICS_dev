public with sharing class CaseCreateTransferController {
  public Case objCase;
  public RXAddRows objRXRows{get;set;}

  public CaseCreateTransferController(ApexPages.StandardController stdController) {
    this.objCase = (Case)stdController.getRecord();
    this.objCase.RecordTypeId = Schema.SObjectType.Case
                                                 .getRecordTypeInfosByName()
                                                 .get('Transfer')
                                                 .getRecordTypeId();                                               
    this.objCase.Original_Created_By_User__c = UserInfo.getUserId();
    this.objCase.Original_Created_By_User_Email__c = UserInfo.getUserEmail(); 
    this.objRXRows = new RXAddRows();
  }

  public PageReference saveAll(){
    PageReference returnPage;
    Savepoint sp = Database.setSavepoint();
    try {
      upsert objCase;
      for(RX__c thisRX : this.objRXRows.mapRXs.values()){
        thisRX.Related_Case__c = objCase.Id;
      }
      upsert this.objRXRows.mapRXs.values();
      returnPage = new PageReference('/' + objCase.Id);
    } catch (exception ex) {
      Database.rollback(sp);
      Case newCase = objCase.clone(false, true, false, true);
      objCase = newCase;
      ApexPages.addmessage(new ApexPages.message
                 (ApexPages.severity.ERROR, ex.getMessage())); 
      returnPage = null;
    }
    return returnPage;
  }

  public class RXAddRows {   
    public map<integer, RX__c> mapRXs {get;set;}
    public Integer intNumberOfRXs {get;set;}
    public String LatestFirstName {get;set;}
    public String LatestAddr1 {get;set;}
    public String LatestLastName {get;set;}
    public String LatestAddr2 {get;set;}
    public String LatestNPI {get;set;}
    public String LatestCity {get;set;}
    public String LatestDEA {get;set;}
    public String LatestState {get;set;}
    public String LatestPhone {get;set;}
    public String LatestZip {get;set;}
    public String LatestFax {get;set;}

    public RXAddRows() {
      RX__c newRX = new RX__c(RecordTypeId = Schema.SObjectType.RX__c
                                                 .getRecordTypeInfosByName()
                                                 .get('Transfer Rx\'s')
                                                 .getRecordTypeId());
      mapRXs = new map<integer, RX__c>();
      mapRXs.put(0, newRX);
      intNumberOfRXs = mapRXs.keySet().size();
    }
    
    public void AddRow() {
      RX__c newRX = new RX__c(RecordTypeId = Schema.SObjectType.RX__c
                                                 .getRecordTypeInfosByName()
                                                 .get('Transfer Rx\'s')
                                                 .getRecordTypeId());
      mapRXs.put(mapRXs.size(), newRX);
      intNumberOfRXs = mapRXs.keySet().size();
    }  

    public void AddRowWithDoc() {
      RX__c newRX = new RX__c(RecordTypeId = Schema.SObjectType.RX__c
                                                 .getRecordTypeInfosByName()
                                                 .get('Transfer Rx\'s')
                                                 .getRecordTypeId(),
                             // Prescriber_First_Name__c = this.LatestFirstName,
                              Prescriber_Address1__c = this.LatestAddr1,
                             // Prescriber_Last_Name__c = this.LatestLastName,
                              Prescriber_Address2__c = LatestAddr2,
                              Prescriber_s_NPI__c = this.LatestNPI,
                              Prescriber_City__c = this.LatestCity,
                              Prescriber_s_DEA__c = this.LatestDEA,
                              Prescriber_State__c = this.LatestState,
                              Prescribers_Phone__c = this.LatestPhone,
                              Prescriber_Zip__c = this.LatestZip,
                              Prescribers_Fax__c = this.LatestFax
                              );
      mapRXs.put(mapRXs.size(), newRX);
      intNumberOfRXs = mapRXs.keySet().size();
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
      intNumberOfRXs = mapRXs.keySet().size();
    }

    public void updateLatestValues(){
      if(Apexpages.currentPage().getParameters().get('LatestFirstName') != null){
        this.LatestFirstName = Apexpages.currentPage().getParameters().get('LatestFirstName');
      }
      if(Apexpages.currentPage().getParameters().get('LatestAddr1') != null){
        this.LatestAddr1 = Apexpages.currentPage().getParameters().get('LatestAddr1');
      }
      if(Apexpages.currentPage().getParameters().get('LatestLastName') != null){
        this.LatestLastName = Apexpages.currentPage().getParameters().get('LatestLastName');
      }
      if(Apexpages.currentPage().getParameters().get('LatestAddr2') != null){
        this.LatestAddr2 = Apexpages.currentPage().getParameters().get('LatestAddr2');
      }
      if(Apexpages.currentPage().getParameters().get('LatestNPI') != null){
        this.LatestNPI = Apexpages.currentPage().getParameters().get('LatestNPI');
      }
      if(Apexpages.currentPage().getParameters().get('LatestCity') != null){
        this.LatestCity = Apexpages.currentPage().getParameters().get('LatestCity');
      }
      if(Apexpages.currentPage().getParameters().get('LatestDEA') != null){
        this.LatestDEA = Apexpages.currentPage().getParameters().get('LatestDEA');
      }
      if(Apexpages.currentPage().getParameters().get('LatestState') != null){
        this.LatestState = Apexpages.currentPage().getParameters().get('LatestState');
      }
      if(Apexpages.currentPage().getParameters().get('LatestPhone') != null){
        this.LatestPhone = Apexpages.currentPage().getParameters().get('LatestPhone');
      }
      if(Apexpages.currentPage().getParameters().get('LatestZip') != null){
        this.LatestZip = Apexpages.currentPage().getParameters().get('LatestZip');
      }
      if(Apexpages.currentPage().getParameters().get('LatestFax') != null){
        this.LatestFax = Apexpages.currentPage().getParameters().get('LatestFax');
      }      
    }
  }
}