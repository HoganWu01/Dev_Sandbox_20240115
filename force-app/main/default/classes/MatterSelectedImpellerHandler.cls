/*
 * @Author: Hogan
 * @Date: 2022-12-19 16:30:00
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-12-19 16:30:00
 * @Descripttion: 机型选比同步
 */
public without sharing class MatterSelectedImpellerHandler implements Triggers.Handler{

    public void handle() {

        List<String> MatterSelectedImpellerIds = new List<String>();

        if (Trigger.isAfter && Trigger.isInsert) {
            for(Matter_Selected_Impeller__c c : (List<Matter_Selected_Impeller__c>)Trigger.new) {
                //新增机型选比 如果项目立项已经存在过机型选比 则新增这条到项目立项
                MatterSelectedImpellerIds.add(c.id);
            }
        }

        if (MatterSelectedImpellerIds.size()>0) {
            SyncMatter(MatterSelectedImpellerIds);
        }

    }

    public void SyncMatter(List<String> MatterSelectedImpellerIds) {

        List<Matter_Selected_Impeller__c> matterList = [SELECT id,name,
                                                        Name__c,    //商机
                                                        Application__c     //项目立项
                                                        FROM Matter_Selected_Impeller__c WHERE id IN :MatterSelectedImpellerIds];

         //在商机下新建机型选比，并且没有选择对应的项目立项
        List<String> oppId = new List<String>();

        //在商机下的项目立项下建立机型选比（之前该机型选比只属于项目立项，并不绑定商机）
        List<String> ApplicationList = new List<String>();

        //在商机下建的机型选比，项目立项为空--  可在新建机型选比时选填项目立项
        //在项目立项下新建的机型选比--商机为空--  可在新建机型选比时选填商机

        for (Matter_Selected_Impeller__c c : matterList) {

            if (c.Name__c!=null &&c.Application__c==null) {
                oppId.add(c.Name__c);
            }

            
            if (c.Name__c==null &&c.Application__c!=null) {
                ApplicationList.add(c.Application__c);
            }
            
        }

        

        if (oppId.size()>0) {
            List<Projectapplication__c> pacList = [select id,name,Oppty__c from Projectapplication__c where  Oppty__c in :oppId];

            //该机型选比下的商机下没有项目立项 不同步该条机型选比到立项去
            if (pacList.size()==0) {
                return ; 
            }

            List<Matter_Selected_Impeller__c> upMaList = new List<Matter_Selected_Impeller__c>();

            //有项目立项的情况,同步该条机型选比挂到项目立项去
            for (Matter_Selected_Impeller__c c : matterList) {
                c.Application__c = pacList[0].id ; 
                upMaList.add(c);
            }

            //更新机型选比
            update upMaList ; 
        }

        //绑定该机型选比到商机
        if (ApplicationList.size()>0) {

            //根据立项找到商机
            List<Projectapplication__c> pacList = [select id,name,Oppty__c from Projectapplication__c where  id in :ApplicationList];

            //找不到对应的项目立项? impossible
            if (pacList.size()==0) {
                return ; 
            }

            List<Matter_Selected_Impeller__c> upMatterList = new List<Matter_Selected_Impeller__c>();

            //立项的商机-->机型选比的商机
            for (Matter_Selected_Impeller__c c : matterList) {
                c.Name__c = pacList[0].Oppty__c ; 
                upMatterList.add(c);
            }

            update upMatterList ; 
        }



        

    }
}