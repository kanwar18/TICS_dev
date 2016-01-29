public class CaseNewButtonOverrideController{
  private ApexPages.StandardController controller;
  public String retURL {get; set;}
  public String saveNewURL {get; set;}
  public String recType {get; set;}
  public String cancelURL {get; set;}
  public String ent {get; set;}
  public String confirmationToken {get; set;}
    
  public CaseNewButtonOverrideController(ApexPages.StandardController controller) {
    this.controller = controller;
    retURL = ApexPages.currentPage().getParameters().get('retURL');
    recType = ApexPages.currentPage().getParameters().get('RecordType');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
  }

  public List<SelectOption> getrectypes(){
    List<SelectOption> options = new List<SelectOption>();

    set<string> setExcludeRecTypes = new set<string>();
    for(String thisRecType : ExcludedNewRecTypes__c.getAll().keySet()){
      setExcludeRecTypes.add(thisRecType);
    }

    options.add(new SelectOption('','--Select Record Type --'));

    Schema.DescribeSObjectResult CaseDescribe = Case.SObjectType.getDescribe();
    for(Schema.RecordTypeInfo rt:CaseDescribe.getRecordTypeInfos()){
      if(rt.isAvailable() && rt.getName() != 'Master'){  
        if(!setExcludeRecTypes.contains(rt.getName())){      
          options.add(new SelectOption(rt.getName(),rt.getName()));   
        } 
      }
    }
    return options;
  }
    
  public String getRecordType(){
    return recType;
  }
    
  public void setRecordType(String recType) {
    this.recType = recType;
  }
    
  public PageReference redirectToPage(){
    PageReference returnURL;
    if(recType == 'PCT - Order Refill') {
      returnURL = new PageReference('/apex/CaseCreateRefills');
    }
    else if(recType == 'Transfer'){
      returnURL = new PageReference('/apex/CaseCreateTransfer');
    }
    else {
      returnURL = new PageReference('/500/e');
    }
  
    returnURL.getParameters().put('retURL', retURL);
    returnURL.getParameters().put('RecordType', Schema.SObjectType.Case
                                                              .getRecordTypeInfosByName()
                                                              .get(recType)
                                                              .getRecordTypeId());
    returnURL.getParameters().put('cancelURL', cancelURL);
    returnURL.getParameters().put('ent', ent);
    returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
    returnURL.getParameters().put('save_new_url', saveNewURL);
    returnURL.getParameters().put('nooverride', '1');
    returnURL.setRedirect(true);
    return returnURL;
  }
 
  public PageReference cancel(){
    pageReference cancelPage = new PageReference('/500/o');
    return cancelPage;
  }
}