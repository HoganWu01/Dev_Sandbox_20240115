/*
 * @Descripttion: 督办事项触发器Handler
 * @Author: Hogan
 * @Date: 2023-04-27 15:21:16
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-04-27 18:38:43
 */
public without sharing class MattersHandler implements Triggers.Handler {

    public void handle() {

        if (Trigger.isAfter && Trigger.isUpdate) {

            for(SupervisoryMatters__c newMatters : (List<SupervisoryMatters__c>)Trigger.new) {
                SupervisoryMatters__c oldMatters = (SupervisoryMatters__c)Trigger.oldMap.get(newMatters.Id);

                //发布事项 进行相关通知
                if (newMatters.MattersStatus__c == '1' && newMatters.MattersStatus__c != oldMatters.MattersStatus__c) {

                     //负责人
                    SupervisoryMatters__c matters = [SELECT Id, OwnerId, Owner.Email, ChargePerson__c, ChargePerson__r.Email FROM SupervisoryMatters__c WHERE Id =: newMatters.Id];
                    //协作人
                    List<MattersCollaboration__c> mattersCollList = [SELECT Id, Collaborators__c, Collaborators__r.Email FROM MattersCollaboration__c WHERE SupervisoryMatters__c =: newMatters.Id];

                    Set<String> userIdSet = new Set<String>();
                    Set<String> emailSet = new Set<String>();
                    if (mattersCollList.size()>0) {
                        for (MattersCollaboration__c maColl : mattersCollList) {
                            userIdSet.add(maColl.Collaborators__c);
                            if (maColl.Collaborators__r.Email!=null) {
                                emailSet.add(maColl.Collaborators__r.Email);
                            } 
                        }
                    }
                    if (matters.ChargePerson__c!=null) {
                        userIdSet.add(matters.ChargePerson__c);
                        if (matters.ChargePerson__r.Email!=null) {
                            emailSet.add(matters.ChargePerson__r.Email);
                        }
                    }
                    userIdSet.add(matters.OwnerId);
                    if (matters.Owner.Email!=null) {
                        emailSet.add(matters.Owner.Email);
                    }

                    String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+newMatters.Id ; 
                    String content = '您有新发布的督办事项，请及时跟进。点击以查看督办事项：【' +newMatters.Name+ '】' +Recordlink;
                    System.debug('督办发布提醒内容》》》'+content);

                    if (userIdSet.size()>0) {
                        //发送小铃铛通知
                        Utils.notifyUsers(userIdSet, newMatters.Id, '督办事项发布成功',content);
                    }

                    if (emailSet.size()>0) {
                        //发送邮件通知
                        Utils.sendMail(emailSet,'督办事项发布成功',content);
                    }
                }

                //发布事项 共享事项给负责人、协作人
                if (newMatters.MattersStatus__c == '1' && newMatters.MattersStatus__c != oldMatters.MattersStatus__c){
                    shareTrigger(newMatters);
                }

                // //发布事项 锁定记录
                // if (newMatters.MattersStatus__c == '1' && newMatters.MattersStatus__c != oldMatters.MattersStatus__c){
                //     autoLockTrigger(newMatters);
                // }

                // //发布事项 解锁记录
                // if (newMatters.MattersStatus__c == '0' && newMatters.MattersStatus__c != oldMatters.MattersStatus__c){
                //     autoUnLockTrigger(newMatters);
                // }
            }
        }

        List<String> matterIds = new List<String>();
        if (Trigger.isAfter && Trigger.isUpdate) {

            for(SupervisoryMatters__c newMatters : (List<SupervisoryMatters__c>)Trigger.new) {
                SupervisoryMatters__c oldMatters = (SupervisoryMatters__c)Trigger.oldMap.get(newMatters.Id);
                if (newMatters.ChargeDept__c != oldMatters.ChargeDept__c) {
                    matterIds.add(newMatters.Id);
                }
            }

        }
        if (Trigger.isAfter && Trigger.isInsert) {
            for(SupervisoryMatters__c ma : (List<SupervisoryMatters__c>)Trigger.new) {

                matterIds.add(ma.id);
            }
        }
        if (matterIds.size() > 0) {
            Execute(matterIds);
        }
    }

    public static void Execute(List<String> matterIds){

        SupervisoryMatters__c newMatters = [ Select Id, ChargeDept__c, ProjectArea__c, ResponsibilityBidDept__c From SupervisoryMatters__c Where id = :matterIds[0] ];

        Schema.DescribeFieldResult fieldResult = SupervisoryMatters__c.ProjectArea__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        Map<String,String> MapValueLabel = new Map<String,String>();
        
        for( Schema.PicklistEntry v : values) {
            MapValueLabel.put(v.getValue(),v.getLabel());        
        }
        
        //督办事项填入总经理、副总经理、分部总经理、售前项目经理
        if (newMatters.ChargeDept__c == '销售大区' && newMatters.ProjectArea__c != null){ //选择销售大区&大区信息不为空
            List<Integrated_Middle_Table__c> middleTableList = [SELECT Id,OppAssistantgeneralmanager__c, OppChiefgeneralmanager__c, Pre_Sales_Project_Manager__c
                                            FROM Integrated_Middle_Table__c 
                                            WHERE RecordTypeId = '0122u0000008V2DAAU' AND Salesdepartment__c =: MapValueLabel.get(newMatters.ProjectArea__c)];
            if (middleTableList.size() > 0) {
                newMatters.OppAssistantgeneralmanager__c = middleTableList[0].OppAssistantgeneralmanager__c; //副总经理
                newMatters.OppChiefgeneralmanager__c = middleTableList[0].OppChiefgeneralmanager__c; //总经理
                newMatters.PreSalesProjectManager__c = middleTableList[0].Pre_Sales_Project_Manager__c; //售前项目经理
                newMatters.OppGeneralManager__c = null; //客户分部总经理
                // update newMatters;
            }
        }else if (newMatters.ChargeDept__c == '客户分部' && newMatters.ResponsibilityBidDept__c != null) {
            List<MarketBidDept__c> deptList = [select id,General_Manager_User__c from MarketBidDept__c where DeptId__c =: newMatters.ResponsibilityBidDept__c ];
            if (deptList.size() > 0) {
                newMatters.OppAssistantgeneralmanager__c = null; //副总经理
                newMatters.OppChiefgeneralmanager__c = null; //总经理
                newMatters.PreSalesProjectManager__c = null; //售前项目经理
                newMatters.OppGeneralManager__c = deptList[0].General_Manager_User__c; //客户分部总经理
                // update newMatters;
            }
        }else {
                newMatters.OppAssistantgeneralmanager__c = null; //副总经理
                newMatters.OppChiefgeneralmanager__c = null; //总经理
                newMatters.PreSalesProjectManager__c = null; //售前项目经理
                newMatters.OppGeneralManager__c = null; //客户分部总经理
                // update newMatters;
        }

        update newMatters;

    }

    
    /**
	* @description: 共享记录
	* @param  {*}
	* @return {*}
	*/
	public void shareTrigger(SupervisoryMatters__c matters) {
        //协作人
        List<MattersCollaboration__c> mattersCollList = [SELECT Id, Collaborators__c, Collaborators__r.Email FROM MattersCollaboration__c WHERE SupervisoryMatters__c =: matters.Id];

        Set<String> userIdSet = new Set<String>();
        if (mattersCollList.size()>0) {
            for (MattersCollaboration__c maColl : mattersCollList) {
                if (maColl.Collaborators__c!=null) {
                    userIdSet.add(maColl.Collaborators__c);
                }
            }
        }
        if (matters.ChargePerson__c!=null) {
            userIdSet.add(matters.ChargePerson__c);
        }

        List<SupervisoryMatters__share> shareList = new List<SupervisoryMatters__share>();

        for(String userId : userIdSet) {
            List<SupervisoryMatters__share> isShare = [select id from SupervisoryMatters__share where ParentId =: matters.Id and UserOrGroupId =: userId ];
            if (isShare.size() == 0) { //不存在共享记录
                List<User> userList = [select id,IsActive from user where id =: userId];
                if (userList.size() > 0 && userList[0].IsActive == true) {
                    SupervisoryMatters__share share = new SupervisoryMatters__share();
                    share.ParentId = matters.Id;
                    share.UserOrGroupId = userId;//分配给商机所有人
                    share.AccessLevel = 'Edit';
                    shareList.add(share);
                }
            }
        }

        System.debug('shareList--------'+shareList);

        Database.insert(shareList,true);
	}

    /**
	* @description: 锁定对象
	* @param  {*}
	* @return {*}
	*/
	// public void autoLockTrigger(SupervisoryMatters__c matters) {
    //     if (!Approval.isLocked(matters.Id)) {
    //         Approval.lock(matters.Id);//锁定
    //     }	
	// }

	/**
	 * @description: 解锁对象
	* @param  {*}
	* @return {*}
	*/
	// public void autoUnLockTrigger(SupervisoryMatters__c matters) {
    //     if (Approval.isLocked(matters.Id)) {
    //         Approval.unlock(matters.Id);//解锁
    //     }
    
	// }
}