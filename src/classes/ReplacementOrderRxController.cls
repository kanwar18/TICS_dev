public without sharing class ReplacementOrderRxController {

    public String selectedFilterOption{get;set;}
    Public Integer noOfRecords{get; set;}
    private string filterField;
    public Replacement_Order_Rx_Import__c replacementOrder{get;set;}
    public String fromDate{get;set;}
    public String toDate{get;set;}
    public boolean hasError {get;set;}
    public ApexPages.StandardSetController setCon {get;set;}
    
    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
        }
    
    // constructor
    public ReplacementOrderRxController(ApexPages.StandardController controller) {
        selectedFilterOption = 'unmatched';
        DateTime d = datetime.now().addMonths(-2);
        DateTime dt= datetime.now();
        fromDate   = d.format('MM/dd/yyyy');
        toDate  = dt.format('MM/dd/yyyy');
        refreshList();
        getRecords();
        hasError = false;
    } 
    
    private boolean checkValidations(){
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
        
    public PageReference reconcileRxImports() {
        selectedFilterOption = 'unmatched';
        refreshList();
        //List<Replacement_Order_Rx_Import__c> successfulRecords = ReplacementOrderImportUtility.updateCaseAndRx(getRecords());
        List<Replacement_Order_Rx_Import__c> successfulRecords = ReplacementOrderImportUtility.updateCaseAndRx(Database.query(getQuery()));
        update successfulRecords; // update records that were successfully reconciled
        
        // Reload Page
        PageReference pf = new PageReference('/apex/ReplacementOrderRxReconcile');
        pf.setRedirect(true);
        return pf;
    }
    
    // to be called on onchange event
    public pageReference refreshList(){
        filterRecords();
        try{
                //system.debug('convertToDate(toDate)>>> '+convertToDate(toDate).format('MM/dd/yyyy')+'<<<system.today()>>>>'+ system.today());
                if(!checkValidations()){
                    system.debug('Inside CHECK');
                    return null;
                }
                else{
                        system.debug('ALL Good');
                        list<Replacement_Order_Rx_Import__c> repOrderList = Database.query(getQuery());
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
    Public List<Replacement_Order_Rx_Import__c> getRecords(){
        
        list<Replacement_Order_Rx_Import__c> repList = new List<Replacement_Order_Rx_Import__c>();
        for(Replacement_Order_Rx_Import__c a : (List<Replacement_Order_Rx_Import__c>)setCon.getRecords())
            repList.add(a);
        system.debug('repList>>> '+repList);
        return repList;
    }
    
    private void filterRecords() {
        system.debug('INSIDE Filter Records');
        if(selectedFilterOption.equals('unmatched')) {
            filterField = 'false';
        }
        else if(selectedFilterOption.equals('matched')) {
            filterField = 'true';
        }
        else if(selectedFilterOption.equals('all')) {
            filterField = '';
        }
        system.debug('INSIDE Filter Records filterField:: '+filterField+'--Filter option-- '+selectedFilterOption);
    }
    
    public List<SelectOption> getFilterOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('unmatched','Unmatched Records'));
        options.add(new SelectOption('matched','Matched Records'));
        options.add(new SelectOption('all','All Records'));

        return options;
    }
    
    private dateTime convertToDate(string toDate){
        Date convertToDate;
        DateTime convertToDateTime;
        if(toDate != null) { 
            convertToDate = Date.parse(toDate);
            convertToDateTime = Datetime.newInstance(convertToDate , Time.newInstance(23, 59, 59, 999));
        }
        system.debug('convertToDateTime>> '+convertToDateTime);
     return convertToDateTime;
    }
    
    
    private dateTime convertFromDate(string fromDate){
        Date convertFromDate;
        DateTime convertFromDateTime;
        if(fromDate != null) { 
            convertFromDate = Date.parse(fromDate);
            convertFromDateTime = Datetime.newInstance(convertFromDate , Time.newInstance(0, 0, 0, 0));
        }
        system.debug('convertFromDateTime>> '+convertFromDateTime);
    return convertFromDateTime;
    }
    
    
    private string getQuery(){
        String strForconvertedToDatetime;
        String strForconvertedFromDatetime;
        String query = 'Select Id, Replacement_Order_Number__c, Price__c, Tax__c,'+
                        'Drug_Name__c,Member_Name__c, Closed_Date__c, Cost__c, Operator__c,'+ 
                        ' Quantity__c,Replacement_Order_Case_Found__c, CreatedDate From Replacement_Order_Rx_Import__c';
                        
        String whereClause = '';
        // if the picklist value is not null then build Where clause
        system.debug(toDate+ '<<<fromDate>> '+fromDate+' *****'+system.today());
        
        if(fromDate != null) {
            strForconvertedFromDatetime =  convertFromDate(fromDate).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        }
        
        if(toDate != null) { 
            strForconvertedToDatetime = convertToDate(toDate).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        }
    
        if(string.isNotBlank(selectedFilterOption) && !selectedFilterOption.equalsIgnoreCase('all') && string.isNotBlank(strForconvertedFromDatetime) && string.isNotBlank(strForconvertedToDatetime)){
            whereClause = ' WHERE Replacement_Order_Case_Found__c ='+ filterField +' and CreatedDate <=' + strForconvertedToDatetime +' and CreatedDate >='+strForconvertedFromDatetime;
        }
        else if(string.isNotBlank(strForconvertedFromDatetime) && string.isNotBlank(strForconvertedToDatetime)){
            whereClause = ' WHERE CreatedDate <=' + strForconvertedToDatetime +' and CreatedDate >='+strForconvertedFromDatetime ;
        }
        
        System.debug('whereClause '+whereClause );
        // if WHERE clause is not blank and Drop down is not "ALL", then include it in the Query
        if(string.isNotBlank(whereClause)){
            query = query+ whereClause;
        }
        query = query+ ' Order by CreatedDate Desc limit 1000';
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
             if(this.setCon.getResultSize()>0)
                return setCon.getPageNumber();
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
          
}