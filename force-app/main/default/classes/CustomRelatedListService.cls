public without sharing class CustomRelatedListService {

    public static CustomRelatedListMapper getRelatedListFields(String objectName, List<String> relatedListNames) {
        Map<String,String> relatedListFields = new Map<String,String>();
        List<String> relatedListApiNames = new List<String>();
        
        for (String item : relatedListNames) {
            Integer countMatches = 0;

            if(item.contains('.')){
                countMatches = item.countMatches('.');
                if(countMatches == 1)
                    objectName = item.substring(0, item.indexOf('.'));
                else if (countMatches == 2)
                    objectName = item.substring(item.indexOf('.') + 1, item.lastIndexOf('.'));
                else if(countMatches > 2) {
                    String newString = '';
                    for(Integer i = 1; i < countMatches; i++){
                        newString = item.substring(0,item.lastIndexOf('.'));
                        newString = newString.substring(newString.lastIndexOf('.') + 1);
                    }
                    objectName = newString;
                }
            }

            if(objectName == 'LastModifiedBy' || objectName == 'CreatedBy' || objectName == 'Owner')
                objectName = 'User';

            relatedListApiNames.add(objectName);

            try{
                Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
                Map<String,Schema.SObjectField> mfields = convertType.getDescribe().fields.getMap();
                Schema.DescribeFieldResult fieldResult;

                if(countMatches == 1)
                    fieldResult = mfields.get(item.substring(item.indexOf('.') + 1)).getDescribe();
                else if(countMatches > 1)
                    fieldResult = mfields.get(item.substring(item.lastIndexOf('.') + 1)).getDescribe();
                else
                    fieldResult = mfields.get(item).getDescribe();
                
                relatedListFields.put(item, fieldResult.getLabel());
            }catch(Exception e){
                return new CustomRelatedListMapper(null, null, 'The object ' + item + ' does not exist. Please check the related list name.');
            }
        }

        return new CustomRelatedListMapper(relatedListFields, relatedListApiNames, '');
    }

    public static List<SObject> getRecords(Id recordId, String objectName, List<String> relatedListNames){
        List<SObject> records = new List<SObject>();

        String relatedField = getRelatedField(recordId, objectName);

        String query = 'SELECT ';
        for (String item : relatedListNames) {
            query += item + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ' + objectName;
        query += ' WHERE ' + relatedField + ' = \'' + recordId + '\'';
        records = Database.query(query);

        return records;
    }

    public static String getRelatedField(Id recordId, String objectName){
        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();

        if(!sobjectName.contains('__c'))
            sobjectName += 'Id';

        if(objectName == 'ContentDocumentLink')
            sobjectName = 'LinkedEntityId';

        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> mfields = convertType.getDescribe().fields.getMap();

        Schema.DescribeFieldResult fieldResult = mfields.get(sobjectName).getDescribe();
        if (fieldResult == null) 
            fieldResult = mfields.get('ParentId').getDescribe();

        return fieldResult.getName();
    }
}
