public class CaseRecursionHandler {
  /*Case Comments*/
  private static boolean alreadySummarizedComment = false;

  public static boolean hasSummarizedComment() {
    return alreadySummarizedComment;
  }
  
  public static void setAlreadySummarizedComment() {
    alreadySummarizedComment = true;
  }

  /*Case*/
  private static boolean alreadyCopiedNotes = false;

  public static boolean hasCopiedNotes() {
    return alreadyCopiedNotes;
  }
  
  public static void setAlreadyCopiedNotes() {
    alreadyCopiedNotes = true;
  }

  public static boolean alreadyCreatedAssignments = false;

  public static boolean hasCreatedAssignments() {
    return alreadyCreatedAssignments;
  }
  
  public static void setAlreadyCreatedAssignments() {
    alreadyCreatedAssignments = true;
  }

  public static boolean alreadyClosedAssignments = false;

  public static boolean hasClosedAssignments() {
    return alreadyCreatedAssignments;
  }
  
  public static void setAlreadyClosedAssignments() {
    alreadyClosedAssignments = true;
  }

  public static boolean alreadyAssignedReviews = false;

  public static boolean hasAssignedReview() {
    return alreadyAssignedReviews;
  }
  
  public static void setalreadyAssignedReviews() {
    alreadyAssignedReviews = true;
  }

  public static boolean alreadyOverwrittenNCQAFields = false;

  public static boolean hasOverwrittenNCQAFields() {
    return alreadyOverwrittenNCQAFields;
  }
  
  public static void setalreadyOverwrittenNCQAFields() {
    alreadyOverwrittenNCQAFields = true;
  }

  public static boolean alreadySetCreatedBy = false;

  public static boolean hasAlreadySetCreatedBy() {
    return alreadySetCreatedBy;
  }
  
  public static void setAlreadySetCreatedBy() {
    alreadySetCreatedBy = true;
  }

  public static boolean alreadySetPharmacy = false;

  public static boolean hasAlreadySetPharmacy() {
    return alreadySetPharmacy;
  }
  
  public static void setAlreadySetPharmacy() {
    alreadySetPharmacy = true;
  }

  public static boolean alreadyPopulatedIntegrationQueue = false;

  public static boolean hasAlreadyPopulatedIntegrationQueue() {
    return alreadyPopulatedIntegrationQueue;
  }
  
  public static void setAlreadyPopulatedIntegrationQueue() {
    alreadyPopulatedIntegrationQueue = true;
  }

  public static boolean alreadyCreatedPlanSharingRecords = false;

  public static boolean hasAlreadyCreatedPlanSharingRecords() {
    return alreadyCreatedPlanSharingRecords;
  }
  
  public static void setAlreadyCreatedPlanSharingRecords() {
    alreadyCreatedPlanSharingRecords = true;
  }

  public static boolean alreadyFormattedCaseComments = false;

  public static boolean hasAlreadyFormattedCaseComments() {
    return alreadyCreatedPlanSharingRecords;
  }
  
  public static void setAlreadyFormattedCaseComments() {
    alreadyFormattedCaseComments = true;
  }
}