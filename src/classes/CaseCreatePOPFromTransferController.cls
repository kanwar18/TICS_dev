public without sharing class CaseCreatePOPFromTransferController {  
  private Case TransferCase;
  private final String caseId;
  private final set<Id> selectedRXIds = new set<Id>();
  private map<String, list<RX__c>> mapDocRXs
    = new map<String, list<RX__c>>();
  public list<RX__c> selectedRXs = new list<RX__c>();

  public CaseCreatePOPFromTransferController(ApexPages.StandardSetController stdSetController){
    if(stdSetController.getSelected().size() > 0){
      this.caseId = string.valueOf(stdSetController.getSelected()[0].get('Related_Case__c'));
      system.debug(logginglevel.ERROR, 'setting case id: ' + this.caseId);
    }
    list<RX__c> listSelectedRXs = stdSetController.getSelected();
    system.debug(logginglevel.ERROR, 'listSelectedRXs: ' + stdSetController.getSelected());
    if(listSelectedRXs.size() > 0) {
      this.selectedRXs = listSelectedRXs;
    }    
    for(RX__c thisRX : listSelectedRXs){
    system.debug(logginglevel.ERROR, 'Created POP? ' + thisRX.Created_POP__c);
      if(!thisRX.Created_POP__c){
        selectedRXIds.add(thisRX.Id);
      }
    }
    system.debug(logginglevel.ERROR, 'selectedRXIds: ' + selectedRXIds);
    if(this.selectedRXIds.size() > 0){
      system.debug(logginglevel.ERROR, 'calling fetch data');
      fetchData();
    }
  }

  public PageReference createData(){
    PageReference detialPage = new PageReference('/'+this.caseId);
    system.debug(logginglevel.ERROR, 'NICK starting createData');
    map<String, map<Case, List<RX__c>>> mapDocCaseRXs
      = new map<String, map<Case, List<RX__c>>>();
    list<Case> newPOPs = new list<Case>();

    map<Case, list<RX__c>> mapCaseRX 
      = new map<Case, list<RX__c>>();
    
    system.debug(logginglevel.ERROR, 'NICK selectedRXIds: ' + this.selectedRXIds);
    if(this.selectedRXIds.size() > 0){
  //  fetchData();
  // need to augment error handling here to show actual error when this fails.
  // also need to be smart enough to create multiple pops if the doc has more than 3 on the transfer.
    system.debug(logginglevel.ERROR, 'NICK mapDocRXs: ' + mapDocRXs);
        for(String thisDocName : mapDocRXs.keySet()){
         Case newPOP = new Case(Member_ID__c = this.TransferCase.Member_ID__c
                                   ,Member_First_Name__c = this.TransferCase.Member_First_Name__c
                                   ,Member_Last_Name__c = this.TransferCase.Member_Last_Name__c
                                   ,Group_Number__c = this.TransferCase.Group_Number__c
                                   ,Contact_Phone__c = this.TransferCase.Contact_Phone__c
                                   ,Alternate_Phone__c = this.TransferCase.Alternate_Phone__c
                                   ,Member_Plan_Lookup__c = this.TransferCase.Member_Plan_Lookup__c
                                   ,Contact_Email__c = this.TransferCase.Contact_Email__c
                                   ,Shipping_Address_1__c = this.TransferCase.Shipping_Address_1__c
                                   ,Shipping_Address_2__c = this.TransferCase.Shipping_Address_2__c
                                   ,Shipping_City__c = this.TransferCase.Shipping_State__c
                                   ,Shipping_State__c = this.TransferCase.Shipping_State__c
                                   ,Shipping_ZIP__c = this.TransferCase.Shipping_ZIP__c
                                   ,Shipping_Method__c = this.TransferCase.Shipping_Method__c
                                   ,Patient_First_Name__c = this.TransferCase.Patient_First_Name__c
                                   ,Patient_Last_Name__c = this.TransferCase.Patient_Last_Name__c
                                   ,DOB__c = this.TransferCase.DOB__c
                                   ,Does_patient_have_any_allergies_or_he__c
                                     = this.TransferCase.Does_patient_have_any_allergies_or_he__c
                                   ,OwnerId = UserInfo.getUserId()
                                   ,Source_System__c = 'User'
                                  // ,RecordTypeId 
                                   //  = Schema.SObjectType.Case.getRecordTypeInfosByName()
                                   //                           .get('POP')
                                  //                            .getRecordTypeId()
                                   //,POP_Type__c = 'New to Mail Service'
                                   ,Source__c = 'User'
                                   ,Parent_Transfer__c = this.caseId
                                   //,Prescribers_First_Name__c = mapDocRXs.get(thisDocName)[0].Prescriber_First_Name__c 
                                   //,Prescribers_Last_Name__c = mapDocRXs.get(thisDocName)[0].Prescriber_Last_Name__c 
                                   //,Prescribers_Phone_Number__c = mapDocRXs.get(thisDocName)[0].Prescribers_Phone__c       
                                   //,DEA__c = mapDocRXs.get(thisDocName)[0].Prescriber_s_DEA__c
                                   ,Prescribers_Fax_Number__c = mapDocRXs.get(thisDocName)[0].Prescribers_Fax__c               
                                   ,Transfer_Doc_Name__c = thisDocName
                                );
          list<RX__c> newRXs = new list<RX__c>();
          system.debug(logginglevel.ERROR, 'NICK RXs Retreived for this Doc: ' + mapDocRXs.get(thisDocName));
          for(RX__c thisRX : mapDocRXs.get(thisDocName)){
            RX__c newRX = new RX__c(
                                           Prescriber_Last_Name__c = thisRX.Prescriber_Last_Name__c
                                           ,Prescriber_First_Name__c = thisRX.Prescriber_First_Name__c
                                           //,Prescriber_s_DEA__c = thisRX.Prescriber_s_DEA__c
                                           ,Prescriber_s_NPI__c = thisRX.Prescriber_s_NPI__c
                                           ,Prescribers_Phone__c = thisRX.Prescribers_Phone__c
                                           ,Prescribers_Fax__c = thisRX.Prescribers_Fax__c
                                           ,Prescriber_Address1__c = thisRX.Prescriber_Address1__c
                                           ,Prescriber_Address2__c = thisRX.Prescriber_Address2__c
                                           ,Prescriber_City__c = thisRX.Prescriber_City__c
                                           ,Prescriber_State__c = thisRX.Prescriber_State__c
                                           ,Prescriber_Zip__c = thisRX.Prescriber_ZIP__c
                                           ,Drug_Name__c = thisRX.Drug_Name__c
                                           ,Controlled_Drug_TF__c = thisRX.Controlled_Drug_TF__c
                                           ,Strength__c = thisRX.Strength__c
                                           ,Directions__c = thisRX.Directions__c
                                           ,Patient_DAW__c = thisRX.Patient_DAW__c
                                           ,Profile_Rx__c = thisRX.Profile_Rx__c
                                           ,Expected_Date_of_Fill__c = thisRX.Expected_Date_of_Fill__c
                                           ,Quantity__c = thisRX.Quantity__c
                                           ,Refills__c = thisRX.Remaining_of_Refills__c
                                           ,Prescriber_DAW__c = thisRX.Prescriber_DAW__c
                                           ,RecordTypeId = Schema.SObjectType.RX__c
                                                              .getRecordTypeInfosByName()
                                                              .get('POP Rx')
                                                              .getRecordTypeId()
                                   );
            newRXs.add(newRX);
          }
          mapCaseRX.put(newPOP, newRXs);
          system.debug(logginglevel.ERROR, 'mapCaseRX in loop' + mapCaseRX);
        }
        system.debug(logginglevel.ERROR, 'before SavePOPs');
        
        try{
          savePOPs(mapCaseRX);
          checkCreatedPOP();
          return detialPage;
        } catch (exception ex) {
          return null;
        }
    } else {
      ApexPages.addmessage(new ApexPages.message
                 (ApexPages.severity.ERROR,'No RX records were selected to create POPs.')); 
      return null;
    }
  }

  private void checkCreatedPOP(){
    for(RX__c originalRX : this.selectedRXs){
      originalRX.Created_POP__c = true;
    }
    update this.selectedRXs;
  }

  private void savePOPs(map<Case, list<RX__c>> mapCaseRXInserts){
  system.debug(logginglevel.ERROR, 'NICK mapCaseRXInserts: '+mapCaseRXInserts);
    try {
        map<String, Case> mapDocCase = new map<String, Case>();
        map<String, list<RX__c>> mapRXInserts = new map<String, list<RX__c>>();
        list<Case> CaseInserts = new list<Case>();
        CaseInserts.addAll(mapCaseRXInserts.keySet());
        for(Case thisCase : mapCaseRXInserts.keySet()){
          list<RX__c> listCopyRX = new list<RX__c>();
          for(RX__c thisRX : mapCaseRXInserts.get(thisCase)){
            listCopyRX.add(thisRX);
          }
          mapRXInserts.put(thisCase.Transfer_Doc_Name__c, listCopyRX);
        }
        insert CaseInserts;
        for(Case insertedCase : CaseInserts){
          mapDocCase.put(insertedCase.Transfer_Doc_Name__c, insertedCase);
        }
        list<Rx__c> RXInsertFinal = new list<RX__c>();
        for(String thisDocName : mapRXInserts.keySet()){
          for(RX__c thisRX : mapRXInserts.get(thisDocName)){
            thisRX.Related_Case__c = mapDocCase.get(thiSDocName).Id;
            RXInsertFinal.add(thisRX);
          }
        }
        system.debug(logginglevel.ERROR, 'NICK before RX Insert');
        insert RXInsertFinal;  
        system.debug(logginglevel.ERROR, 'NICK after RX Insert');
    } catch (exception ex) {
      system.debug(logginglevel.ERROR, 'NICK caught exception: ' + ex.getMessage());
      ApexPages.addmessage(new ApexPages.message
                 (ApexPages.severity.ERROR,'There was an Error creating POP records.' + ex.getMessage())); 
    }
  }

  private void FetchData(){
  system.debug(logginglevel.ERROR, 'NICK case id in fetch data ' + this.caseId);
    this.TransferCase = [SELECT Related_Case__c
                               ,Member_ID__c
                               ,Member_First_Name__c
                               ,Member_Last_Name__c
                               ,Group_Number__c
                               ,Contact_Phone__c
                               ,Alternate_Phone__c
                               ,Member_Plan_Lookup__c
                               ,Contact_Email__c
                               ,Shipping_Address_1__c
                               ,Shipping_Address_2__c
                               ,Shipping_City__c
                               ,Shipping_State__c
                               ,Shipping_ZIP__c
                               ,Shipping_Method__c
                               ,Patient_First_Name__c
                               ,Patient_Last_Name__c
                               ,DOB__c
                               ,Does_patient_have_any_allergies_or_he__c
                               //,Prescribers_First_Name__c
                               //,Prescribers_Last_Name__c
                               ,(SELECT 
                                        
                                       Prescriber_s_NPI__c
                                       ,Prescribers_Phone__c
                                       ,Prescribers_Fax__c
                                       ,Prescriber_Address1__c
                                       ,Prescriber_Address2__c
                                       ,Prescriber_City__c
                                       ,Prescriber_State__c
                                       ,Prescriber_Zip__c
                                       ,Drug_Name__c
                                       ,Controlled_Drug_TF__c
                                       ,Strength__c
                                       ,Directions__c
                                       ,Patient_DAW__c
                                       ,Profile_Rx__c
                                       ,Expected_Date_of_Fill__c
                                       ,Quantity__c
                                       ,Refills__c
                                       ,Prescriber_DAW__c
                                       ,Related_Case__c
                                       ,Remaining_of_Refills__c
                                       ,Prescriber_First_Name__c
                                       ,Prescriber_Last_Name__c
                                       //Prescriber_s_DEA__c
                                FROM Rx_s__r)
                        FROM Case
                        WHERE Id = :this.caseId];
    system.debug(logginglevel.ERROR, 'selected trans case: ' + this.TransferCase);
    system.debug(logginglevel.ERROR, 'RXs from DB: ' + this.TransferCase.RX_s__r);
    for(RX__c thisRX : TransferCase.RX_s__r){
      if(this.selectedRXIds.contains(thisRX.Id)){ 
        Integer intCurrentIteration = 1;
        Boolean blnFoundIteration = true;
        for(Integer i = 1; blnFoundIteration && i <= 100; i++){ 
          blnFoundIteration = mapDocRXs.containsKey(thisRX.Prescriber_First_Name__c + thisRX.Prescriber_Last_Name__c + string.valueOf(i));
          intCurrentIteration = i - 1;
        }
        String strCurrentIteration = string.valueOf(intCurrentIteration);
        if(!mapDocRXs.ContainsKey(thisRX.Prescriber_First_Name__c + thisRX.Prescriber_Last_Name__c + strCurrentIteration)){ 
          list<RX__c> listDocRX = new list<RX__c>();
          listDocRX.add(thisRX);
          mapDocRXs.put(thisRX.Prescriber_First_Name__c + thisRX.Prescriber_Last_Name__c + strCurrentIteration, listDocRX);
        } else { 
          if(mapDocRXs.get(thisRX.Prescriber_First_Name__c + thisRX.Prescriber_Last_Name__c + strCurrentIteration).size() < 3){
            mapDocRXs.get(thisRX.Prescriber_First_Name__c + thisRX.Prescriber_Last_Name__c + strCurrentIteration).add(thisRX);
          } else {
            list<RX__c> listDocRX = new list<RX__c>();
            listDocRX.add(thisRX);
            mapDocRXs.put(thisRX.Prescriber_First_Name__c + thisRX.Prescriber_Last_Name__c + string.valueOf(intCurrentIteration + 1), listDocRX);
          }
        }
      }
    }
  }
}