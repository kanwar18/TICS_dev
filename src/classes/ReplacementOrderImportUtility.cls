public without sharing class ReplacementOrderImportUtility {

    public static List<Replacement_Order_Rx_Import__c> updateCaseAndRx(list<Replacement_Order_Rx_Import__c> roRxs){
    
        System.debug('Trigger Size:' + roRxs.size());
        
        // Order Number -> List of replacement order rx's
        map<String, list<Replacement_Order_Rx_Import__c>> roNumberXrxImportMap = new map<String, list<Replacement_Order_Rx_Import__c>>();


        // Iterate over list of all records from trigger, to populate the map with all replacement order numbers X list of Rx's for Case
        for(Replacement_Order_Rx_Import__c importedRx : roRxs ){
    
            list<Replacement_Order_Rx_Import__c> listRxs = roNumberXrxImportMap.get(importedRx.Replacement_Order_Number__c);
    
            if(listRxs == null){
                listRxs = new list<Replacement_Order_Rx_Import__c>();
            }
            
            listRxs.add(importedRx);
            
            roNumberXrxImportMap.put(importedRx.Replacement_Order_Number__c, listRxs);
        }
        
        // Query for all Cases that match order numbers from records on trigger --does this need to include record type in query.
        list<Case> cases = getCasesByReplacementOrders(roNumberXrxImportMap.keySet());
        
        // Create list of Replacement_Rx__c object to insert
        
        list<RxImportXRxXCase> xrefList = new list<RxImportXRxXCase>();
        // Iterate over all Cases, and add Replacement_Rx__c objects that correspond to the order number
        for(Case c : cases) {
            System.debug('CASELOOP: Case Number Found:'+c.CaseNumber + ' for ReplacementOrderNumber:' + c.Replacement_Order__c);
            for(Replacement_Order_Rx_Import__c importRx : roNumberXrxImportMap.get(c.Replacement_Order__c)) {
                
                Replacement_Rx__c rx = createRx(c, importRx);
                
                RxImportXRxXCase obj = new RxImportXRxXCase(); 
                obj.importId = importRx.Id;
                System.debug(obj.importId);
                
                obj.c = c;
                obj.rx = rx;
                obj.rxImport = importRx;
                
                System.debug('IMPORTLISTLOOP: Case Number Found:'+ obj.c.CaseNumber + 
                    ' for ReplacementOrderNumber:' + obj.c.Replacement_Order__c + 
                    ' rxDrugName:' + obj.rx.Drug_Name__c + 
                    ' importDrugName:' + obj.rxImport.Drug_Name__c );
                
                xrefList.add(obj);
                
            }
        }
        
        list<Replacement_Order_Rx_Import__c> successList = insertRxsToReplacementOrderCase(xrefList);
        return successList;

    }
    
    public static list<Case> getCasesByReplacementOrders(set<String> replacementOrderNumbers) {
        
    //  return [select r.Related_Case__r.Replacement_Order__c, r.Drug_Name__c From Replacement_Rx__c r where r.Related_Case__r.Replacement_Order__c in :replacementOrderNumbers];
        return [select Id, Replacement_Order__c, CaseNumber from Case where Replacement_Order__c in :replacementOrderNumbers];
    }
    
    public static Replacement_Rx__c createRx(Case c, Replacement_Order_Rx_Import__c importRx) {
        Replacement_Rx__c rx = new Replacement_Rx__c();
        rx.Drug_Name__c = importRx.Drug_Name__c;
        rx.Patient_Name__c = importRx.Member_Name__c;
        rx.Closed_Date__c = importRx.Closed_Date__c;
        rx.Cost__c = importRx.Cost__c;
        rx.Price__c = importRx.Price__c;
        rx.Quantity__c = importRx.Quantity__c;
        rx.Tax__c = importRx.Tax__c;
        rx.Operator__c = importRx.Operator__c;
        rx.Related_Case__c = c.Id;
        
        return rx;
    }
    
    public static list<Replacement_Order_Rx_Import__c> insertRxsToReplacementOrderCase(List<RxImportXRxXCase> xrefList ){
        list<Replacement_Order_Rx_Import__c> successList = new list<Replacement_Order_Rx_Import__c>();
        // Insert all Replacement_Rx__c objects
        try{
            list<Replacement_Rx__c> rxsToAdd = new list<Replacement_Rx__c>();
            
            for(RxImportXRxXCase obj : xrefList){
                rxsToAdd.add(obj.rx);
            }
            
            list<Database.Saveresult> srList = insertRxs(rxsToAdd);
    
            Integer i = 0;
    
            System.debug('SaveResult Size: ' + srList.size() + ' Rxs to Insert Size:' + rxsToAdd.size() );

            
            for(Database.Saveresult sr : srList){
                
                Replacement_Rx__c rx = rxsToAdd.get(i);
                RxImportXRxXCase obj = xrefList.get(i);             
            
                System.debug('SaveResult: ' + sr.isSuccess() + ' Case Number:'+ obj.c.CaseNumber + 
                    ' for ReplacementOrderNumber:' + obj.c.Replacement_Order__c + 
                    ' rxDrugName:' + obj.rx.Drug_Name__c + 
                    ' importDrugName:' + obj.rxImport.Drug_Name__c );
        
                i++;//increase index
            
                if (sr.isSuccess()) {
                    System.debug('Updating Import object to mark as case found for: '+ obj.c.Replacement_Order__c + ' Replacement_Rx__c.id:' + sr.getId()); 

                    obj.rxImport.Replacement_Order_Case_Found__c = true;
                    //drop this return void from this method
                    successList.add(obj.rxImport);
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. RxId: ' + sr.getId());
                }  else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred statusCode:' + err.getStatusCode() + ' errorMessage:' + err.getMessage());                    
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
                 
        } catch (Exception e){
            system.debug('Error trying to insert rxs:' + e.getMessage() + ' stacktrace:' + e.getStackTraceString());
    
        }
        
        return successList;
    }
    
    private static list<Database.Saveresult> insertRxs(list<Replacement_Rx__c> rxsToAdd) {
        return Database.insert(rxsToAdd, false);
    }
    
    public class RxImportXRxXCase{
        
        public String importId;
        
        public Replacement_Order_Rx_Import__c rxImport;
        
        public Replacement_Rx__c rx;
    
        public Case c;
        
    }

}