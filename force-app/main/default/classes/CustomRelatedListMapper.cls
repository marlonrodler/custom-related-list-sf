public without sharing class CustomRelatedListMapper {

    @AuraEnabled public Map<String,String> mapRelatedListFields {get;set;}
    @AuraEnabled public List<String> relatedListApiNames {get;set;}
    @AuraEnabled public String error {get;set;}

    public CustomRelatedListMapper(Map<String,String> relatedListFields, List<String> relatedListApiNames, String error){
        this.mapRelatedListFields = relatedListFields;
        this.relatedListApiNames = relatedListApiNames;
        this.error = error;
    }
}
