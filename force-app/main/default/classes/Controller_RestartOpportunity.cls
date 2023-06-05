/*
 * @Descripttion: 重启商机控制类
 * @Author: Devin
 * @Date: 2021-12-29 11:04:20
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-25 17:57:23
 */
public without sharing class Controller_RestartOpportunity {
    
    /**
     * @Descripttion: 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */
    @AuraEnabled
    public static ResponseVo restartOpportunity(String recordId) {

        ResponseVo vo = new ResponseVo();
        try {

            //当前登录人Id
            String userId = UserInfo.getUserId();

            Opportunity opp = [SELECT Id,OwnerId FROM Opportunity WHERE Id =: recordId];

            //只有商机所有人才能 重启商机
            if (userId == opp.OwnerId) {
                Opportunity restartOpp = new Opportunity();
                restartOpp.Id = recordId;
                restartOpp.Close__c = false;//商机已关闭
                restartOpp.CloseType__c = null;//关闭类型
                restartOpp.Competitor__c = null;//其他赢单对手备注
                restartOpp.Lostreason__c = null;//丢标原因分类
                restartOpp.Other__c = null;//丢标原因描述
                restartOpp.Pausereason__c = null;//中断原因
                restartOpp.Reason__c = null;//项目作废原因
                restartOpp.Winningopponent__c = null;//赢标对手
                update restartOpp;
                vo.stateType = 'success';
                vo.message = '重启成功!';

            } else {
                vo.stateType = 'warn';
                vo.message = '您不能重启商机, 只有商机所有人才能重启!';
            }
        } catch (Exception e) {
            vo.stateType = 'error';
            vo.message = '重启失败! 失败信息:'+ e.getMessage();
        }

        return vo;

    }

    public class ResponseVo {
        @AuraEnabled
        public String stateType{get;set;}
        @AuraEnabled
        public String message{get;set;}
    }
}