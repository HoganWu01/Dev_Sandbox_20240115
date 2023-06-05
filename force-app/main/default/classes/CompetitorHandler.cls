/*
 * @Author: irving
 * @Date: 2021-12-30 11:30:23
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-30 13:55:47
 * @Descripttion: 竞争对手同步
 */
public without sharing class CompetitorHandler implements Triggers.Handler{

    public void handle() {

        List<String> CompetitorIds = new List<String>();

        if (Trigger.isAfter && Trigger.isInsert) {
            for(Competitor__c c : (List<Competitor__c>)Trigger.new) {
                //新增竞争对手 如果项目立项已经存在过竞争对手 则新增这条到项目立项
                CompetitorIds.add(c.id);
            }
        }

        if (CompetitorIds.size()>0) {
            SyncCompetitor(CompetitorIds);
        }

    }

    public void SyncCompetitor(List<String> CompetitorIds) {

        List<Competitor__c> competitorList = [SELECT id,name,
                                                        ObjectName__c,    //商机
                                                        Application__c     //项目立项
                                                        FROM Competitor__c WHERE id IN :CompetitorIds];

         //在商机下新建竞争对手，并且没有选择对应的项目立项
        List<String> oppId = new List<String>();

        //在商机下的项目立项下建立竞争对手（之前该竞争对手只属于项目立项，并不绑定商机）
        List<String> ApplicationList = new List<String>();

        //在商机下建的竞争对手，项目立项为空--  可在新建竞争对手时选填项目立项
        //在项目立项下新建的竞争对手--商机为空--  可在新建竞争对手时选填商机

        for (Competitor__c c : competitorList) {

            if (c.ObjectName__c!=null &&c.Application__c==null) {
                oppId.add(c.ObjectName__c);
            }

            
            if (c.ObjectName__c==null &&c.Application__c!=null) {
                ApplicationList.add(c.Application__c);
            }
            
        }

        

        if (oppId.size()>0) {
            List<Projectapplication__c> pacList = [select id,name,Oppty__c from Projectapplication__c where  Oppty__c in :oppId];

            //该竞争对手下的商机下没有项目立项 不同步该条竞争对手到立项去
            if (pacList.size()==0) {
                return ; 
            }

            //有项目立项的情况,同步该条竞争对手挂到项目立项去
            for (Competitor__c c : competitorList) {
                c.Application__c = pacList[0].id ; 
            }

            //更新竞争对手
            update competitorList ; 
        }

        //绑定该竞争对手到商机
        if (ApplicationList.size()>0) {

            //根据立项找到商机
            List<Projectapplication__c> pacList = [select id,name,Oppty__c from Projectapplication__c where  id in :ApplicationList];

            //找不到对应的项目立项? impossible
            if (pacList.size()==0) {
                return ; 
            }

            //立项的商机-->竞争对手的商机
            for (Competitor__c c : competitorList) {
                c.ObjectName__c = pacList[0].Oppty__c ; 
            }

            update competitorList ; 
        }



        

    }
}