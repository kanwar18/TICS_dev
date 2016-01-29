public class RxDataReplicationFactory { 
  private static set<Id> setCaseIds = new set<Id>();
  private static map<Id, list<Rx__c>> mapCaseRXs
    = new map<Id, list<Rx__c>>();  
  private static map<Id, Case> mapCaseUpdates
    = new map<Id, Case>();  
  private static final integer RX_LIMIT = 3;
  private static final map<string, RxToCaseMap__c> RxToCaseFieldMap 
    = RxToCaseMap__c.getAll();  

  public static void copyDataToCase(list<Rx__c> listRXs, 
                                   map<Id, Rx__c> mapOldRXs) {    
    system.debug(RxToCaseFieldMap);
    fetchRelatedData(listRXs);
    system.debug(mapCaseRXs);
    clearCaseRXData();
    if (mapCaseRXs.keySet().size() >= 1) {
      for(Id caseId : mapCaseRXs.keyset()){
        Case updateCase = new Case(Id=caseId);
        integer intRXCount = 0;
        for(Rx__c thisRX : mapCaseRXs.get(caseId)){
          /*if(thisRX.Patient_ID_Entered_in_Rx_Express__c == 'Yes') {
            updateCase.Patient_ID_Entered_in_Rx_Express__c = 'Yes';
          }*/
          intRXCount = intRXCount + 1;
          for(string thisFieldName : RxToCaseFieldMap.keySet()){
            if(intRXCount <= RX_LIMIT){
              string RxFieldName = thisFieldName;
              string CaseFieldName 
                = 'RX_' + string.valueOf(intRXCount) + '_' + thisFieldName;
              updateCase.put(CaseFieldName, thisRX.get(RxFieldName));
            }
          }
        }
        mapCaseUpdates.put(caseId, updateCase);
      }
      if(mapCaseUpdates.keySet().size() > 0){
        update mapCaseUpdates.values();
      }
    }
  }

  private static void fetchRelatedData(List<Rx__c> listRXs){
    for(RX__c thisRX : listRXs){
      setCaseIds.add(thisRx.Related_Case__c);
    }
    for(RX__c thisRX : [SELECT Controlled_Drug_TF__c, 
                                      Cost__c, CreatedById, 
                                      CreatedDate, Days_Supply__c, Directions__c, 
                                      Drug_Name__c, Expected_Date_of_Fill__c, Id, 
                                      Include_in_RTMB__c, IsDeleted, 
                                      Last_Date_Filled__c, LastModifiedById, 
                                      LastModifiedDate, Name, Patient_DAW__c, 
                                      Patient_Name__c, Prescribers_Fax__c, 
                                      Prescribers_Name__c, Prescribers_Phone__c, 
                                      Profile_Rx__c, Quantity__c, Related_Case__c,
                                      Prescriber_DAW__c, 
                                      Rx__c, 
                                      Strength__c, Refills__c, 
                                      RTMB_Include_Drug__c, Patient_ID_Entered_in_Rx_Express__c 
                                 FROM Rx__c
                                 WHERE Related_Case__c in :setCaseIds]) {
      if(!mapCaseRXs.containsKey(thisRX.Related_Case__c)){
        list<RX__c> listFullRXs = new list<RX__c>();
        listFullRXs.add(thisRX);
        mapCaseRXs.put(thisRX.Related_Case__c, listFullRXs);
      } else {
        mapCaseRXs.get(thisRX.Related_Case__c).add(thisRX);
      }
    }

    for(Case thisCase : [SELECT Id FROM Case WHERE Id IN :setCaseIds]){
      mapCaseUpdates.put(thisCase.Id, thisCase);  
    }
  }

  private static void clearCaseRXData(){
    for(Id caseId : mapCaseRXs.keyset()){
      Case updateCase = new Case(Id=caseId);
      for(string thisFieldName : RxToCaseFieldMap.keySet()){
        for(integer i = 1; i <= RX_LIMIT; i++){
          string CaseFieldName 
            = 'RX_' + string.valueOf(i) + '_' + thisFieldName;
          updateCase.put(CaseFieldName, null);
        }
      }
      mapCaseUpdates.put(caseId, updateCase);
    }
  }
}