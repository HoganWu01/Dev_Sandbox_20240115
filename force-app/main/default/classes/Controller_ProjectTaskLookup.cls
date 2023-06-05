/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-10-19 17:41:53
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-04 15:56:01
 */
public without sharing class Controller_ProjectTaskLookup {
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value,String parentId) {

        System.debug('parentId---------'+parentId);
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\'';
            } else {
                query += ' WHERE '+filterField+
                 ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
            }

            if (String.isNotBlank(parentId)) {
                query += ' AND Project__c = \''+parentId+'\'';
            }

            query += ' LIMIT 49999';

            System.debug('query----------'+query);
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
        }
    }
 
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}