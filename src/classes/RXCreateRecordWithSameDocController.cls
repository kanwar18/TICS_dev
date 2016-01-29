public with sharing class RXCreateRecordWithSameDocController {
  private final RX__c objRX;
  
  public RXCreateRecordWithSameDocController(ApexPages.StandardController stdController) {
    this.objRX = (RX__c)stdController.getRecord();
  }

  public pageReference cloneRecord(){
    RX__c newRX = new RX__c(Related_Case__c = objRX.Related_Case__c
                           ,Prescribers_Name__c = objRX.Prescribers_Name__c
                           ,Prescriber_s_DEA__c = objRX.Prescriber_s_DEA__c
                           ,Prescriber_s_NPI__c = objRX.Prescriber_s_NPI__c
                           ,Prescribers_Phone__c = objRX.Prescribers_Phone__c
                           ,Prescribers_Fax__c = objRX.Prescribers_Fax__c
                           ,Prescriber_Address1__c = objRX.Prescriber_Address1__c
                           ,Prescriber_Address2__c = objRX.Prescriber_Address2__c
                           ,Prescriber_City__c = objRX.Prescriber_City__c
                           ,Prescriber_State__c = objRX.Prescriber_State__c
                           ,Prescriber_Zip__c = objRX.Prescriber_ZIP__c
                           ,RecordTypeId = Schema.SObjectType.RX__c
                                                 .getRecordTypeInfosByName()
                                                 .get('Transfer Rx\'s')
                                                 .getRecordTypeId()
                          );
    try{
       insert newRX; 
       PageReference newPage = new PageReference('/' + newRX.Id + '/e?retURL=%2F' + newRX.Id);
       return newPage;
    } catch (exception ex) {
      ApexPages.addmessage(new ApexPages.message
                 (ApexPages.severity.ERROR,'There was an Error creating the new RX record.')); 
      return null;
    }
  }
}