public with sharing class HTTPPostPQTUtility {
    
    private final Case c;
    private QuickbaseFieldMappings__c qbMap;
    private string recType;
    
    //constructor
    public HTTPPostPQTUtility() {
        c = [SELECT Id
                    , Business_Group_Channel__c
                    , CaseNumber
                    , Contact_First_Name__c
                    , Contact_Last_Name__c
                    , Contact_Phone__c
                    , Group_Number__c
                    , Member_Last_Name__c
                    , Member_First_Name__c
                    , Member_ID__c
                    , Member_Plan_Lookup__r.Name
                    , Original_Request_Date_Time__c                 
                    , Order__c
                    , Request_Type_Lookup__r.Long_Text_Name__c
                    , Rx_Claim__c
                    , Subcategory__c
                    , isClosed                
                FROM Case 
                WHERE Id = :ApexPages.currentPage().getParameters().get('caseid')];                      
                
                //determine type of pqt being processed
                recType = ApexPages.currentPage().getParameters().get('type');                           
    }

    //return case data
    public Case getCase() {
        return c;
    }   
    
    public String getCaseLink(){
        //{!ApexPages.currentPage().getHeaders().get('Host')}/apex/CaseRedirect?caseNum={!Case.CaseNumber}
        return 'https://' + Apexpages.currentPage().getHeaders().get('Host')+'/apex/CaseRedirect?caseNum='+ c.CaseNumber;
    }
    
    //get and return qb id custom setting data    
    public QuickbaseFieldMappings__c getQBMappings(){            
        system.debug('TYPE: ' + recType); 
        if(recType == 'AEE'){
            QuickbaseFieldMappings__c qbIDs = QuickbaseFieldMappings__c.getValues('AEEMappings');
            qbMap = qbIDs;
        } else if(recType == 'PHI'){
            QuickbaseFieldMappings__c qbIDs = QuickbaseFieldMappings__c.getValues('PHIMappings');
            qbMap = qbIDs;
        }
        else if(recType == 'MEIR'){
            QuickbaseFieldMappings__c qbIDs = QuickbaseFieldMappings__c.getValues('MEIRMappings');
            qbMap = qbIDs;
        }      
        return qbMap; 
    }
    
    //need to return original request date time formatted: MM/dd/yyyy hh:mm am/pm
    public string getOrigDT(){
        string origDateTime = c.Original_Request_Date_Time__c.format('MM/dd/yyyy hh:mm a');
        return origDateTime;
    } 
    

}