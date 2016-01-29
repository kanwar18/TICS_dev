/**
*   {Purpose}  –  This class is the set of functionality around the fax merging process
*                                 
*   {Support}   - For assistance with this code, please contact support@demandchainsystems.com              
*                 www.demandchainsystems.com
*                 (952) 345-4533
*/
/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date     Name             Description
*   2/24/13  RCD DCS          Created
*   =============================================================================
*/

public class FaxMergeUtility{
  /* This method takes in the current trigger values, as well as old values(if applicable)
  and a custom variable to denote the operation type */
  
  //Class Constants
  private static final string FAX_TEMPLATE_1 = 'Fax_POP_Test_Fax_Merge';
  private static final string FAX_TEMPLATE_2 = 'Fax_POP_1st_Fax';
  private static final string FAX_TEMPLATE_PREFIX = 'Fax_';
  final static map<string, EmailTemplate> mapFaxTemplates
    = new map<string, EmailTemplate>();


  /* This method takes in a list of the cases and operations, thendispatches them to the appropriate 
  methods based on the operation specified 
  */   
  public static void generateFaxHTML(list<case> listCases, 
                                         map<Id, case> mapOldCases,
                                                  string operation){
    fetchHTMLTemplates();
    List<String> caseFields = Metadatautility.fieldsInObject('Case');
     
    for(case thisCase : listCases) {
      system.debug(logginglevel.ERROR, 'Inside Case Loop');
      system.debug(logginglevel.ERROR, 'Queue: ' + thisCase.Assignment_Queue__c);
      if (thisCase.Assignment_Queue__c == 'Queue 2c – Ready for 1st Fax') {
        system.debug(logginglevel.ERROR, 'Proper Queue - go to field merge');
         system.debug('generateFaxHTML: Starting with case ' + thisCase.Id);
         performFieldMerge(thisCase, mapFaxTemplates.get(FAX_TEMPLATE_1), caseFields);   
      }     
    }    
  }
  
  /* This method takes in the current case trigger values, fax template and list of case fields to 
  perform a field merge and populate the Fax_HTML_Image__c field with the HTML representation of a fax 
  */
  private static void performFieldMerge(case thisCase, 
                                   EmailTemplate thisEmailTemplate, List<String> caseFields){
    string htmlBody;   
    htmlBody = thisEmailTemplate.HTMLValue;
    system.debug(logginglevel.ERROR, 'HTML Value after Template: ' + htmlBody);
    //We may need to have more 'built-in' functions
    htmlBody = htmlBody.replace('{!Today}',String.ValueOf(Date.today()));
     system.debug(logginglevel.ERROR, 'Replaced Date in HTML: ' + htmlBody);
    //We will likely need to do some formatting here (dates, times, etc)
    for (String fld : caseFields){
        String thisFieldValue = String.valueOf(thisCase.get(fld));
        if (thisFieldValue == null){
            system.debug('performFieldMerge: caseField (Value): ');
            htmlBody = htmlBody.replace('{!Case.' + fld + '}','');    
        } else {
            system.debug('performFieldMerge: caseField (Value): ' + thisFieldValue);
            htmlBody = htmlBody.replace('{!Case.' + fld + '}',thisFieldValue);
        }
    } 
    system.debug(logginglevel.ERROR, 'HTML Body after Loop: ' + htmlBody);
    //thisCase.Fax_HTML_Image__c = htmlBody;
  }
  
  /* This method initializes the fax templates available for use 
  */
  private static void fetchHTMLTemplates(){
    for(EmailTemplate thisEmailTemplate : [SELECT Id, Body, BrandTemplateId, 
                                           CreatedById, CreatedDate, Description, 
                                           DeveloperName, HtmlValue, IsActive, Markup, 
                                           Name, Subject, TemplateStyle, TemplateType                                           
                                           FROM EmailTemplate
                                           WHERE Name like :FAX_TEMPLATE_PREFIX + '%']){
      mapFaxTemplates.put(thisEmailTemplate.DeveloperName, thisEmailTemplate);
    }
  }
}