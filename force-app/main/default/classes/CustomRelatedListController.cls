public without sharing class CustomRelatedListController {
    
    @AuraEnabled
    public static CustomRelatedListMapper getRelatedListFields(String objectName, List<String> relatedListNames){
        try {
            return CustomRelatedListService.getRelatedListFields(objectName, relatedListNames);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SObject> getRecords(Id recordId, String objectName, List<String> relatedListNames){
        try {
            return CustomRelatedListService.getRecords(recordId, objectName, relatedListNames);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
