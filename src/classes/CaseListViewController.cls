public without sharing class CaseListViewController {

    public String selectedFilterOption{get;set;}
    Public Integer noOfRecords{get; set;}
    private string filterField;
    public String fromDate{get;set;}
    public String toDate{get;set;}
    public boolean hasError {get;set;}
    public ApexPages.StandardSetController setCon {get;set;}
    //list<Rx__c> repList = new List<Rx__c>();
    public string recordTypeId = getRecordTypes('Rx__c').get('Replacement_Rx');
    public list<Replacement_Rx__c> repList;
    
    
    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
    
    // constructor, std contrlr will be for Replacement_Rx__c object
    public CaseListViewController(ApexPages.StandardController controller) {
        //setCon = new 
        selectedFilterOption = 'none';
        DateTime d = datetime.now().addMonths(-3);
        DateTime dt= datetime.now();
        fromDate   = d.format('MM/dd/yyyy');
        toDate  = dt.format('MM/dd/yyyy');
        refreshList();
        getRecords();
        hasError = false;
    } 
    
    private boolean checkValidations (){
        boolean isValid = true;
        if(string.isBlank(fromDate) && string.isBlank(toDate)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'From date and To date can not be left blank'));
            hasError = ApexPages.hasMessages(ApexPages.Severity.ERROR);          
           isValid = false;
           system.debug('>>>>3');
        }
        else if(string.isBlank(toDate)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To date can not be left blank'));
            hasError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
            isValid = false;   
            system.debug('>>>>1');    
        }
        else if(string.isBlank(fromDate)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'From date can not be left blank'));
            hasError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
            isValid = false;
            system.debug('>>>>2');
        }
        else if(Date.parse(toDate) > system.today()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records found for future date'));
                hasError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
                isValid = false;
                system.debug('>>>>4');
        }
        else{
            system.debug('else>>>>4');  
        }
        system.debug('isValid:: '+isValid);
        return isValid; 
        
    
    }
        
        
    // to be called on onchange event
    public pageReference refreshList(){
        filterRecords();
        try{               
                if(!checkValidations()){
                    system.debug('Inside CHECK');
                    return null;
                }
                else{
                        system.debug('ALL Good');
                        list<Replacement_Rx__c> repOrderList = Database.query(getQuery());
                         system.debug('repOrderList:: '+repOrderList.size());
                         setCon = new ApexPages.StandardSetController(repOrderList);
                         setCon.setPageSize(200);
                         hasError = false;
                }
                
        }
        catch(exception e){
            
        }
    return null;
    }
    
    // used for pageblockTable
    Public List<Replacement_Rx__c> getRecords(){
        
        repList = new List<Replacement_Rx__c>();
        if(setCon != null){
                for(Replacement_Rx__c a : (List<Replacement_Rx__c>)setCon.getRecords())
                    repList.add(a);
                system.debug('repList>>> '+repList);
        }
        
        return repList;
    }
    
    public pageReference save(){
    
        
    system.debug('repList:::>> '+repList);
    update repList;
    PageReference pr = ApexPages.CurrentPage();
    pr.setRedirect(true);
    return pr;
    
    }
    
    @TestVisible 
    private void filterRecords() {
        system.debug('INSIDE Filter Records');
        if(selectedFilterOption.equals('none')) {
           filterField = '';
       }
      else if(selectedFilterOption.equals('Yes')) {
           filterField = 'Yes';
        }
        else if(selectedFilterOption.equals('No')) {
            filterField = 'No';
        }
        system.debug('INSIDE Filter Records filterField:: '+filterField+'--Filter option-- '+selectedFilterOption);
   }
    
    public List<SelectOption> getFilterOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('none','None'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));

        return options;
    }
    
    
    
    private dateTime convertToDate(string toDate){
        Date convertToDate;
        DateTime convertToDateTime;
        if(toDate != null) { 
            convertToDate = Date.parse(toDate);
            convertToDateTime = Datetime.newInstanceGMT(convertToDate , Time.newInstance(23, 59, 59, 59));
        }
        system.debug('convertToDateTime>> '+convertToDateTime);
     return convertToDateTime;
    }
    
    
    private dateTime convertFromDate(string fromDate){
        Date convertFromDate;
        DateTime convertFromDateTime;
        if(fromDate != null) { 
            convertFromDate = Date.parse(fromDate);
            convertFromDateTime = Datetime.newInstanceGMT(convertFromDate , Time.newInstance(00, 01, 01, 01));
        }
        system.debug('convertFromDateTime>> '+convertFromDateTime);
    return convertFromDateTime;
    }
    
    
    private string getQuery(){
        String strForconvertedToDatetime;
        String strForconvertedFromDatetime;
        String query = 'Select Id, Controlled_Medication__c,Cost__c,Drug_Name__c,Quantity__c,'+
                        'Member_Name__c, Related_Case__c,Related_Case__r.Replacement_Order__c, Related_Case__r.Replacement_Order_Date__c, '+ 
                        'CreatedDate From Replacement_Rx__c';
                        
        String whereClause = '';
        // if the picklist value is not null then build Where clause
        system.debug(toDate+ '<<<fromDate>> '+fromDate+' *****'+system.today());
        
        if(fromDate != null) {
            strForconvertedFromDatetime =  convertFromDate(fromDate).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'','UTC');
            system.debug('strForconvertedFromDatetime>> '+strForconvertedFromDatetime);
        }
        
        if(toDate != null) { 
            strForconvertedToDatetime = convertToDate(toDate).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'','UTC');
            system.debug('strForconvertedToDatetime>> '+strForconvertedToDatetime);
        }
    
        if(string.isNotBlank(selectedFilterOption) && string.isNotBlank(strForconvertedFromDatetime) && string.isNotBlank(strForconvertedToDatetime)){
            whereClause = ' WHERE Controlled_Medication__c = \''+ filterField +'\' and CreatedDate <= ' + strForconvertedToDatetime +' and CreatedDate >= '+strForconvertedFromDatetime;
        }
        else if(string.isNotBlank(strForconvertedFromDatetime) && string.isNotBlank(strForconvertedToDatetime)){
            whereClause = ' WHERE Controlled_Medication__c =\''+ filterField +'\'  and CreatedDate <= ' + strForconvertedToDatetime +' and CreatedDate >= '+strForconvertedFromDatetime ;
        }
        
        System.debug('whereClause '+whereClause );
        // if WHERE clause is not blank and Drop down is not "None", then include it in the Query
        if(string.isNotBlank(whereClause)){
            query = query+ whereClause;
        }
        query = query+ ' Order by CreatedDate Desc limit 2000';
        System.debug('query '+query );
        return query ;
    } 
         
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
     // returns the total number of pages in a setcontroller
    public Integer getTotalPages() {
       Decimal totalSize = this.setCon.getResultSize();
       Decimal pageSize = this.setCon.getPageSize();
       Decimal pages = totalSize/pageSize;
       return (Integer)pages.round(System.RoundingMode.CEILING);
   }
  
    public Integer pageNumber {
        get {
                if(setCon != null){
                    if(this.setCon.getResultSize()>0)
                        return setCon.getPageNumber();
                        else
                        return 0;
                }
                else
                        return 0;
                
                        
            
        }
        set;
    }
  
    public void first() {
        setCon.first();
    }
  
    public void last() {
        setCon.last();
    }
  
    public void previous() {
        setCon.previous();
    }
  
    public void next() {
        setCon.next();
    } 
    
    
    /*
     * @params: API name of the sObject
     * @returns a map, K: RecordType DeveloperName, V:RecordType Id 
     */
    public static map<string,string> getRecordTypes(string sObjectName){
        list<RecordType> rTypes = [Select Id, Name, DeveloperName from RecordType where sObjectType =:sObjectName and isActive = true];
        map<string,string> sObjectRecordTypes = new map<string,string>();
        for(RecordType rt : rTypes){
            sObjectRecordTypes.put(rt.DeveloperName, rt.Id); 
        }
        return sObjectRecordTypes;
    }
          
}