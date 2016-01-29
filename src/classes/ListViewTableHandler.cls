public with sharing class ListViewTableHandler {
  public String filterId {get;set;}
  public ApexPages.StandardSetController ssc {get;set;}
  public String containerId {get;set;}
  public String columnFields {get; set;}
  public String columnTitles {get; set;}
  public String selectedFilter {get;set;}
  public String selectedView;
  public static final string INITIAL_FILTER_ID = 'My Open Cases';

  public ListViewTableHandler(ApexPages.StandardSetController stdSetController) {
    this.ssc = new ApexPages.StandardSetController(this.records);
    this.selectedFilter = INITIAL_FILTER_ID;
    this.selectedView = INITIAL_FILTER_ID;
  }

  public list<SelectOption> getCaseListViews(){
    list<SelectOption> Options = new list<SelectOption>();
    for (String thisViewName : CustomCaseListViews__c.getAll().keySet()){ 
      Options.add(new SelectOption(thisViewName,thisViewName)); 
    }
    return Options;
  }

  public List<String> columnFieldsList {
    get {
      list<string> columnFields = new list<string>();
      CustomCaseListViews__c CaseListView = 
        CustomCaseListViews__c.getInstance(this.selectedView);
      if(CaseListView.Column_List_1__c != null){
        columnFields.addAll(CaseListView.Column_List_1__c.split('\\,'));
      }
      if(CaseListView.Column_List_2__c != null){
        columnFields.addAll(CaseListView.Column_List_2__c.split('\\,'));
      }
      if(CaseListView.Column_List_3__c != null){
        columnFields.addAll(CaseListView.Column_List_3__c.split('\\,'));
      }
        system.debug('columnFields>> '+columnFields);
      return columnFields;
    }
    set;
    }
     
  public List<String> columnTitlesList {
    get {
      list<string> columnTitles = new list<string>();
      string fieldLabel;
      string objectName;
      for(String fieldName : this.columnFieldsList){
        system.debug(logginglevel.ERROR, 'FieldName: ' + fieldName);
        if(fieldName.contains('.')) {
          system.debug(logginglevel.ERROR, 'Field Name Contains Period');
          if(fieldName.split('\\.')[0].contains('__r')){
            objectName = fieldName.split('\\.')[0].replace('__r', '__c');
            objectName 
              = string.valueOf(this.ssc.getRecord().getSObjectType().getDescribe().fields.getMap().get(objectName).getDescribe().getReferenceTo()[0]);
          } else {
            objectName = fieldName.split('\\.')[0];
          }
          system.debug('objectName: ' + objectName);
          if(objectName != 'Owner') {
            Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
            Schema.sObjectType sObjType = globalDescription.get(objectName);
            fieldLabel = sObjType.getDescribe().fields.getMap().get(fieldName.split('\\.')[1]).getDescribe().getLabel();
          } else { 
            fieldLabel = 'Owner';
          }
        } else {
          fieldLabel 
            = this.ssc.getRecord().getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
        }
        columnTitles.add(fieldLabel);
      }
      return columnTitles;
    }
    set;
  }
 
  public List<Case> records {
    get {
      if(records == null) {
        String query = 'SELECT ';
        for(string fieldName : this.columnFieldsList) {
          query += fieldName + ', ';
        }
        //query += 'Id, CaseNumber, Edit__c, (SELECT CommentBody, CreatedBy.Name, CreatedDate FROM CaseComments ORDER BY CreatedDate DESC) FROM Case';
        query += 'Id, CaseNumber, Edit__c,Case_Comments__c FROM Case'; 
        //Convert to Pull From Selected Value
        CustomCaseListViews__c CaseListView = 
          CustomCaseListViews__c.getInstance(this.selectedView);
        if(CaseListView.View_Filter_1__c != null){
          query += ' WHERE ' + CaseListView.View_Filter_1__c;
        }
        if(CaseListView.View_Filter_2__c != null){
          query += CaseListView.Column_List_2__c;
        }
        if(CaseListView.View_Filter_3__c != null){
          query += CaseListView.Column_List_3__c;
        }
        query += ' ORDER BY CreatedDate ASC LIMIT 500';
        system.debug(logginglevel.ERROR, 'QUERY: ' + query);
        return Database.query(query);
      }
      return records;
    }
    set;
  }

  public map<Id, list<CaseComment>> mapCommentWrapper {
    get {
      map<Id, list<CaseComment>> thisCommentWrapper 
        = new map<Id, list<CaseComment>>();
      if(this.records != null && mapCommentWrapper == null){
        for(Case thisCase : this.records){
          list<CaseComment> listCaseComments 
            = new list<CaseComment>();
          for(CaseComment thisCC : thisCase.CaseComments){
            listCaseComments.add(thisCC);
          }
          thisCommentWrapper.put(thisCase.Id, listCaseComments);     
        }        
      }
      return thisCommentWrapper;
    }
    set;
  }
  public PageReference filter(){
    this.selectedView = selectedFilter;
    return null;
  }    

  public String getSelectedView() {
    return this.selectedView;
  }

  public void setSelectedView(String viewName) {
    if (this.selectedView != viewName) {
      this.selectedView = viewName;
    }
  }        
}