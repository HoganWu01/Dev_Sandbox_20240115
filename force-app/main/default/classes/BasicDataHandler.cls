/*
 * @Descripttion: 基础数据处理类Handler
 * @Author: Hogan
 * @Date: ###### Tue Nov 7 17:37:27 CST 2023
 * @LastEditors: Please set LastEditors
 * @LastEditTime: ###### Tue Nov 7 17:37:30 CST 2023
 */
public without sharing class BasicDataHandler implements Triggers.Handler {

    public void handle() {

        if (Trigger.isAfter && Trigger.isUpdate) {

            for(BasicData__c newBasicData : (List<BasicData__c>)Trigger.new) {
                BasicData__c oldBasicData = (BasicData__c)Trigger.oldMap.get(newBasicData.Id);

                //主要负责人(用户)变更
                if (newBasicData.MainChargeUser__c != oldBasicData.MainChargeUser__c){
                    // syncOppManager(newBasicData);
                }
            }
        }

    }

    @InvocableMethod(label='SyncOppManager' description='Change manager sync opp data.' category='')
    public static void syncOppManager(List<ID> ids){

    }

}