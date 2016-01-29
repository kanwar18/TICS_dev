public without sharing class MetadataUtility {
/**
*   {Purpose}  –  This class performs various actions against the salesforce.com objects
*                 
*                  
*   {Support}   - For assistance with this code, please contact support@demandchainsystems.com              
*                 www.demandchainsystems.com
*                 (952) 345-4533
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date     Name             Description
*   2/24/14  Nick Cook        Created
*/

  public static list<String> fetchPicklistValues(SObject obj, String fieldName){
    list<String> listPicklistValues 
      = new list<String>();
    Schema.sObjectType objType 
      = obj.getSObjectType(); 
    Schema.DescribeSObjectResult objDescribe 
      = objType.getDescribe();       
    map<String, Schema.SObjectField> fieldMap 
      = objDescribe.fields.getMap(); 
    list<Schema.PicklistEntry> listValues 
      = fieldMap.get(fieldName).getDescribe().getPickListValues();
    
    for (Schema.PicklistEntry thisEntry : listValues){ 
      listPicklistValues.add(thisEntry.getLabel()); 
    }
    return listPicklistValues;
  }
    
   //Function to return the names of the fields in a given object
   public static List<String> fieldsInObject(String strObjectName) {
    List<String> fieldsInObject = new List<String>();
    SObjectType objToken = Schema.getGlobalDescribe().get(strObjectName);
    DescribeSObjectResult objDef = objToken.getDescribe();
    Map<String, SObjectField> fields = objDef.fields.getMap(); 

    for(String str : fields.keyset()) {
      SObjectField fieldToken = fields.get(str);
      DescribeFieldResult selectedField = fieldToken.getDescribe();
      fieldsInObject.add(selectedField.getName());
    }
    return fieldsInObject;
  } 

  //Function to return the names of the fields in a given object in a SET
  public static Set<String> fieldsInObjectSet(String strObjectName) {
    Set<String> fieldsInObject = new Set<String>();
    SObjectType objToken = Schema.getGlobalDescribe().get(strObjectName);
    DescribeSObjectResult objDef = objToken.getDescribe();
    Map<String, SObjectField> fields = objDef.fields.getMap(); 

    for(String str : fields.keyset()) {
      SObjectField fieldToken = fields.get(str);
      DescribeFieldResult selectedField = fieldToken.getDescribe();
      fieldsInObject.add(selectedField.getName());
    }
    return fieldsInObject;
  } 
}