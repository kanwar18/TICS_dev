public Class UserRecursionHandler {
  public static boolean alreadySynchedPermissionSet = false;
 
  public static boolean hasSynchedPermissionSet() {
    return alreadySynchedPermissionSet;
  }
  
  public static void setAlreadySynchedPermissionSet() {
    alreadySynchedPermissionSet = true;
  }
}