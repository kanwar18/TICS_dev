/**
*   {Purpose}  –  Create Case and related Rx records.
*                         
*   {Function}  – Service leveraged to create Cases and related Rx records 
*                 triggered from MSATB / MyPrimeMail / ...
*         - Record processing is atomic in nature.  If one record fails in
*          the transaction the whole transaction fails and is rolled back
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032   
*
*  ASSUMPTION:  - Each item along with related rx records will be passed to class one at a time 
*        - Creates either PCT Order Refill or POP Cases
*        - Lookup key for related plan is the passed POP Plan name
*          - If a plan cannot be resolved default to Unknown Plan - Unknown Plan record ID is stored in a custom setting
*        - Lookup key for related legacy user is the passed user's email address 
*          - Assumes MSATB / MyPrimeMail user is a user in SFDC and user email addresses are unique 
*        - MAPPING RECORDTYPES AT THE GATEWAY
*          - POP recordtype=012i0000000rJC8AAM  
*          - POP Rx recordtype=012i0000000rnlbAAA
*          - PCT Order Refill recordtype=012i0000000rVe0AAE
*          - PCT Refill Rx recordtype=012i0000000sJWEAA2
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date    Name                 Description
*   2/22/14 Kevin Johnson DCS      Created 
*   =============================================================================
*/

global class CaseRxCreateService {

  //item object
  //create case
  global class Item {      
      webservice String attnprimemailnotes;
      webservice String altphone;
      webservice String altphonetype;
      webservice String ccexpdate;
      webservice String cctype;
      webservice String contactemail;
      webservice String contactphone;
      webservice String contactphonetype;
      webservice String createdby; //created by in legacy system - passes source user email address
    webservice Date dob;
      webservice String groupnum;
      webservice String last4digitscc;
      webservice String memberplan; //pass name - lookup related plan in SFDC based off of name
      webservice String memberid;
      webservice String memberfirstname;
      webservice String memberlastname;
      webservice String nameoncc;
      webservice Boolean nochargeforshipping;
      webservice String nochargeshippingreason;
      webservice String notes;
      webservice String othermembernotes;
      webservice String patientfirstname;
      webservice String patientlastname;
      webservice Boolean permccchange;
      webservice String permaddress1;
      webservice String permaddress2;
      webservice String permcity;
      webservice String permstate;
      webservice String permzip;
      webservice String pharmacy;
      webservice String poptype;
      webservice String prescriberfirstname;
      webservice String prescriberlastname;
      webservice String prescriberphone;
      webservice String prescriberfax;
      webservice String prescribernote;
      webservice String primerecordid;
      webservice Boolean readyfirstfax;
      webservice Boolean readyrecordreview;
      webservice Boolean readycphtcompletion;
      webservice String recordtypeid;
      webservice String rphverification;
      webservice String rphverificationselectby;
      webservice Boolean shippingissame;
      webservice String shippingmethod;
      webservice String shipaddress1;
      webservice String shipaddress2;
      webservice String shipcity;
      webservice String shipstate;
      webservice String shipzip;
      webservice String source;
      webservice Boolean tempccchange;
  }
  
  //rx object
  //create as rx objects then pass as colletion to method
  global class Rx {    
      webservice Boolean controlleddrug;
      webservice Double dayssupply;
      webservice String directions;
      webservice String drugname;
      webservice Date expecteddatefill;
      webservice Date lastdatefilled;
      webservice Boolean patientdaw;
      webservice String patientname;
      webservice Boolean prescriberdaw;
      webservice String primerecordid;      
      webservice Boolean profilerx;
      webservice String quantity;
      webservice String recordtypeid;
      webservice String rxnum;
      webservice String strength;    
  }
  
  //response object
  global class response {
     webservice Boolean success;
     webservice String id;
     webservice String casenumber;
     webservice String statuscode;
     webservice String message;
  }  
  
  //method inserting case and related rx's
  webservice static List<response> insertCaseRx(Item i, List<Rx> lstRx) {
  List<Rx__c> rxToInsert = new List<Rx__c>();
  boolean caseInserted=FALSE;
  List<response> respMsg = new List<response>();
  Savepoint sp = Database.setSavepoint();  
  
  //determine legacy app created user
  string useremail=i.createdby;
  string userid=null;

  List<User> uRecord = [SELECT id FROM User where email = :useremail];
  if(uRecord.size() > 0){
    userid=uRecord[0].Id;  //matched user id
  } else {
    userid=null;
  }
  system.debug('userID : '+ userid);  
  
  //create case stub containing externalid
  Case cReference = new Case(
    Prime_Record_Number__c=i.primerecordid
  );
  
  //loop through colletion of rx and associate to passed item
  for(Rx newRx : lstRx){
    //create rx
    Rx__c rx = new Rx__c(              
          Controlled_Drug_TF__c=newRx.controlleddrug,
      Days_Supply__c=newRx.dayssupply,
      Directions__c=newRx.directions,
      Drug_Name__c=newRx.drugname,
      Expected_Date_of_Fill__c=newRx.expecteddatefill,
      Last_Date_Filled__c=newRx.lastdatefilled,
      Patient_DAW__c=newRx.patientdaw,
      Patient_Name__c=newRx.patientname,
      Prescriber_DAW__c=newRx.prescriberdaw,
      Profile_Rx__c=newRx.profilerx,
      Quantity__c=newRx.quantity,
      RecordTypeId=newRx.recordtypeid,
      Related_Case__r=cReference,
      Rx__c=newRx.rxnum,
      Strength__c=newRx.strength          
    );    
    rxToInsert.add(rx);    
  }
  
  //finish creating the case
  //associate qb plan to sfdc plan
  string planname=i.memberplan;
  string planid=null;
  UnknownPlanRecordID__c unknownPlanID = UnknownPlanRecordID__c.getInstance('UnknownPlanRecordID');
  string planUnknown = unknownPlanID.Unknown_Plan_ID__c;

  List<Plan__c> planKnown = [SELECT id FROM Plan__c where name = :planname AND Plan_Status__c='Active' LIMIT 1];
  
  if(planKnown.size() > 0){
    planid=planKnown[0].Id;  //matched plan id
  } else {
    planid=planUnknown;  //UNKNOWN plan id
  }
  system.debug('planKnownID : '+ planid);
  
  Case c = new Case(    
    Alternate_Phone__c=i.altphone,
    Alt_Phone_Type__c=i.altphonetype,
    Attention_PrimeMail_Notes__c=i.attnprimemailnotes,
    Contact_Email__c=i.contactemail,
    Contact_Phone__c=i.contactphone,
    Contact_Phone_Type__c=i.contactphonetype,
    Credit_Card_Expiration_Date__c=i.ccexpdate,
    Credit_Card_Type__c=i.cctype,
    DOB__c=i.dob,
    Group_Number__c=i.groupnum,
    Information_Description_to_Add__c=i.notes,
    Last_4_Digits_CC__c=i.last4digitscc,
    Member_First_Name__c=i.memberfirstname,
    Member_ID__c=i.memberid,
    Member_Last_Name__c=i.memberlastname,
    Member_Plan_Lookup__c=planid,
    Name_on_Credit_Card__c=i.nameoncc,
    No_Charge_for_Shipping__c=i.nochargeforshipping,
    No_Charge_for_Shipping_Reason__c=i.nochargeshippingreason,
    Note_to_Prescriber__c=i.prescribernote,
    Original_Created_By_User__c=userid,
    Original_Created_By_User_Email__c=i.createdby,
    Other_Address_1__c=i.permaddress1,
    Other_Address_2__c=i.permaddress2,
    Other_City__c=i.permcity,
    Other_State__c=i.permstate,
    Other_ZIP__c=i.permzip,
    Other_Member_Notes__c=i.othermembernotes,
    Patient_First_Name__c=i.patientfirstname,
    Patient_Last_Name__c=i.patientlastname,
    Pharmacy__c=i.pharmacy,
    //POP_Type__c=i.poptype,
    Permanent_CC_Change__c=i.permccchange,
    Prescribers_Fax_Number__c=i.prescriberfax,
   // Prescribers_First_Name__c=i.prescriberfirstname,
   // Prescribers_Last_Name__c=i.prescriberlastname,
   // Prescribers_Phone_Number__c=i.prescriberphone,
    Prime_Record_Number__c=i.primerecordid,
    Ready_for_1st_Fax__c=i.readyfirstfax,
    Ready_for_Record_Review__c=i.readyrecordreview,
    Ready_for_CPhT_Completion__c=i.readycphtcompletion,
    RecordTypeId=i.recordtypeid,
   // RPh_Verification__c=i.rphverification,
    //RPh_Verification_Selected_By__c=i.rphverificationselectby,
    Shipping_Address_1__c=i.shipaddress1,
    Shipping_Address_2__c=i.shipaddress2,
    Shipping_City__c=i.shipcity,
    Shipping_is_Same__c=i.shippingissame,
    Shipping_Method__c=i.shippingmethod,
    Shipping_State__c=i.shipstate,
    Shipping_ZIP__c=i.shipzip,
    Source__c=i.source,
    Temporary_CC_Change__c=i.tempccchange    
  );
  
  //insert records
  //case  
  try {
    insert c;
    
    string caseid=null;
      caseid=c.id;
      Case cr = Database.query('select casenumber from case where id=:caseid');
      
      caseInserted=TRUE;
    response msgResponse = new response();
    caseInserted=TRUE;
    msgResponse.success=TRUE;
    msgResponse.id=c.Id;
    msgResponse.casenumber=cr.CaseNumber;
    
      //add successful case insert response
     respMsg.add(msgResponse);
  } catch (System.DmlException e) {
      response msgResponse = new response();
    msgResponse.success=FALSE;
    
      for(integer n=0; n < e.getNumDml(); n++){
        msgResponse.statuscode=String.ValueOf(e.getDmlType(n));
        msgResponse.message=e.getDmlFieldNames(n)+': '+e.getDmlMessage(n);
    }

    //add unsuccessful case insert response
    respMsg.add(msgResponse);  
  }
  
  if (caseInserted==TRUE){
    try {
       insert rxToInsert;
     } catch(System.DmlException e) {
        //remove successfull case insert response 
        respMsg.clear();

      response msgResponse = new response();
        msgResponse.success=FALSE;
        
        for(integer n=0; n < e.getNumDml(); n++){
          msgResponse.statuscode=String.ValueOf(e.getDmlType(n));
          msgResponse.message=e.getDmlFieldNames(n)+': '+e.getDmlMessage(n);
        }

          //add unsuccessful rx insert response
        respMsg.add(msgResponse);
        
        //rollback case insert          
        Database.rollback(sp);                         
      }
   }
  //return status
    return respMsg;
  }
}