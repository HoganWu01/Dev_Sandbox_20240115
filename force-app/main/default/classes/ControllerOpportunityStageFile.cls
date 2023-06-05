/*
 * @Descripttion: 【商机】 上的 《中标文件》 控制类
 * @Author: Devin
 * @Date: 2021-12-28 11:37:45
 * @LastEditors: Devin
 * @LastEditTime: 2021-12-28 11:49:47
 */
public without sharing class ControllerOpportunityStageFile {
    public ControllerOpportunityStageFile() {}

    @AuraEnabled
    public static Map<Object,Object> doInit(String recordId) {

        Map<Object,Object> map_return = new Map<Object,Object>();
        
        List<StageFile__c> sfList = new List<StageFile__c>();
        sfList = [SELECT documentId__c,Type__c,DocumenName__c,DocumenLink__c FROM StageFile__c WHERE ResourceId__c =: recordId];

        //上传中标通知书/相关证明
        List<SFVO> winFileList = new List<SFVO>();

        for (StageFile__c sf : sfList) {
            SFVO vo = new SFVO();
            vo.type = sf.Type__c;
            vo.documentId = sf.DocumentId__c;
            vo.documenLink = sf.DocumenLink__c;
            vo.documentName = sf.DocumenName__c;
            winFileList.add(vo);
        }

        map_return.put('winFiles',winFileList);

        return map_return;
    }

    @AuraEnabled
    public static void saveWinFile(String documentIds, String documentNames,String radioValue, String recordId) {
        System.debug('documentIds----'+documentIds);
        //文件Id
        List<String> documentIdList = documentIds.split(',');
        //文件Name
        List<String> documentNameList = documentNames.split(',');

        List<StageFile__c> sfList = new List<StageFile__c>();

        Integer i = 0;
        for (String docId : documentIdList) {
            //生成【阶段文件】中间表信息
            StageFile__c sf = new StageFile__c();
            sf.DocumentId__c = docId;//文件Id
            sf.DocumenLink__c = '/lightning/r/ContentDocument/'+docId+'/view';//文件链接
            sf.DocumenName__c = documentNameList[i];//文件名
            sf.Type__c = radioValue;
            sf.ResourceId__c = recordId;
            sfList.add(sf);
            i++;
        }

        //【商机】 上的 《上传中标通知书/相关证明》 打勾
        Opportunity updateOpp = new Opportunity();
        updateOpp.Id = recordId;
        updateOpp.WinningNotice__c = true;//上传中标通知书/相关证明

        insert sfList;

        update updateOpp;
    }

    /**
     * @Descripttion: 删除附件信息
     * @Author: Devin
     * @param {*}
     * @return {*}
     */
    @AuraEnabled
    public static Map<Object,Object> deleteDocument(String documentId) {

        System.debug('documentId---------'+documentId);

        Map<Object,Object> map_return = new Map<Object,Object>();

        try {
            
            //删除附件信息
            ContentDocument deleteContent = [SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument WHERE Id =: documentId];
    
            //删除【阶段文件】表数据
            StageFile__c deleteStageFile = [SELECT Id,ResourceId__c,Type__c FROM StageFile__c WHERE DocumentId__c =: documentId];

            //文件类型 + 资源Id  是否有同一个类型下的文件
            List<StageFile__c> remainderList = new List<StageFile__c>();

            remainderList = [SELECT Id 
                                FROM 
                                    StageFile__c 
                                WHERE 
                                    ResourceId__c =: deleteStageFile.ResourceId__c 
                                AND 
                                    Type__c =: deleteStageFile.Type__c
                                AND 
                                    DocumentId__c !=: documentId
                            ];
            
            if (remainderList.size() == 0) {
                //【商机】 上的 《上传中标通知书/相关证明》 勾 取消
                Opportunity cancelOpp = new Opportunity();
                cancelOpp.Id = deleteStageFile.ResourceId__c;
                cancelOpp.WinningNotice__c = false;//上传中标通知书/相关证明

                update cancelOpp;
            }
    
            delete deleteContent;
            delete deleteStageFile;

            map_return.put('Messages','删除成功!');
            map_return.put('Type','S');
        } catch (Exception e) {
            System.debug('错误信息:'+e.getMessage());
            map_return.put('Messages','删除失败, 请联系系统管理员! 错误信息:'+e.getMessage());
            map_return.put('Type','E');
        }

        return map_return;

    }

    /**
     * @Descripttion: 只删除附件信息
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> deleteOnlyDocument(String documentIds) {

        System.debug('documentIds---------'+documentIds);

        Map<Object,Object> map_return = new Map<Object,Object>();

        try {

            //文件Id
            List<String> documentIdList = documentIds.split(',');
            
            //删除附件信息
            List<ContentDocument> deleteContent = [SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument WHERE Id IN: documentIdList];

            System.debug('deleteContent----'+deleteContent);
    
            delete deleteContent;

            map_return.put('Messages','删除成功!');
            map_return.put('Type','S');
        } catch (Exception e) {
            map_return.put('Messages','删除失败, 请联系系统管理员! 错误信息:'+e.getMessage());
            map_return.put('Type','E');
        }

        return map_return;

    }

    public class SFVO {
        @AuraEnabled
        public String type{get; set;}
        @AuraEnabled
        public String documentId{get; set;}
        @AuraEnabled
        public String documenLink{get; set;}
        @AuraEnabled
        public String documentName{get; set;}
    }
}