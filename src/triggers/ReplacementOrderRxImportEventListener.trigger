trigger ReplacementOrderRxImportEventListener on Replacement_Order_Rx_Import__c (before insert) {
    
    system.debug(logginglevel.DEBUG,'ReplacementOrderRxImport TRIGGER ENTERED');
    
//  system.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
//    system.debug('Total Number of records that can be queried  in this apex code context: ' +  Limits.getLimitDmlRows());
//    system.debug('Total Number of DML statements allowed in this apex code context: ' +  Limits.getLimitDmlStatements() );
//    system.debug('Total Number of script statements allowed in this apex code context: ' +  Limits.getLimitScriptStatements());
    
    
    ReplacementOrderImportUtility.updateCaseAndRx(Trigger.new);
    
//  system.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
//    system.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
//    system.debug('3. Number of script statements used so far : ' +  Limits.getDmlStatements());
//    system.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
//    system.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
    
//    system.debug('Final number of script statements used so far : ' +  Limits.getDmlStatements());
//    system.debug('Final heap size: ' +  Limits.getHeapSize());
    
    system.debug(logginglevel.DEBUG,'ReplacementOrderRxImport TRIGGER EXITING');
    
}