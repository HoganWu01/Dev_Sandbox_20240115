/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-01-25 19:29:00
 * @Descripttion: 营销项目立项申请单handler
 */
public without sharing class ProjectapplicationTriggerHandler {


 	/**
	*新建营销项目立项 看看商机下有么有竞争对手和机型选比  有就直接拉取
	*/
	public class SyncOppCompetitorToPA implements Triggers.Handler{
		public void handle() {
			if(Trigger.isAfter && Trigger.isInsert) {
				Set<String> paIdSet = new Set<String>();

				for(Projectapplication__c pa : (List<Projectapplication__c>)Trigger.new) {
					//项目立项的业务机会不为空  在商机下建的项目立项
					if (pa.Oppty__c!=null) {
						paIdSet.add(pa.id);
					}
				}

				if (paIdSet.size()>0) {
					
					List<Projectapplication__c> paList = [select id,name,Oppty__c from Projectapplication__c where id in:paIdSet];

					List<String> oppList = new List<String>();

					for (Projectapplication__c pa : paList) {
						oppList.add(pa.Oppty__c);
					}

					List<Competitor__c> comList = [select id,name,ObjectName__c,Application__c from Competitor__c where ObjectName__c in :oppList];

					//有商机不一定有竞争对手   如果竞争对手为空  没数据 不同步到项目立项
					if (comList==null || comList.size()==0) {
						return ; 
					}

					for (Competitor__c c : comList) {
						c.Application__c = paList[0].id ; 
					}

					update comList ; 

					List<Matter_Selected_Impeller__c> matterList = [select id,name,Name__c,Application__c from Matter_Selected_Impeller__c where Name__c in :oppList];

					//有商机不一定有机型选比   如果机型选比为空  没数据 不同步到项目立项
					if (matterList==null || matterList.size()==0) {
						return ; 
					}

					for (Matter_Selected_Impeller__c m : matterList) {
						m.Application__c = paList[0].id ; 
					}

					update matterList ; 
				}

			}
		}
	}

     /**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle = '申请单驳回通知';
    		String body = '申请单需要调整并重新提交';
    		if(Trigger.isAfter && Trigger.isUpdate) {
                Map<String, Projectapplication__c> idMap = new Map<String,Projectapplication__c>();
    			Map<Id, Projectapplication__c> csMap = (Map<Id, Projectapplication__c>)Trigger.newMap;
    			List<Projectapplication__c> csList = Trigger.old;
                //这是发送小铃铛的
    			for (String csId : csMap.keySet()) {
    				for (Projectapplication__c cs : csList) {
    					if (csId == cs.Id) {
    						if (cs.Approvalstatus__c != csMap.get(csId).Approvalstatus__c
    						 && csMap.get(csId).Approvalstatus__c == '11' ) {
    						 	Set<String> rpuser = new Set<String>();
    							rpuser.add(cs.OwnerId);
    							Utils.notifyUsers(rpuser,cs.Id,subjectTitle,body);
    						}
    					}
    				}   			
    			}

                //这是给商机的立项审批状态赋值的
                for (Projectapplication__c pa : csMap.values()) {
                    for (Projectapplication__c opa : (List<Projectapplication__c>)Trigger.old) {
                        if (pa.Id == opa.Id && pa.Approvalstatus__c != opa.Approvalstatus__c) {
                            idMap.put(pa.Oppty__c, pa);
                        }
                    }
                  }
                  if (!idMap.isEmpty()) {
                    List<Opportunity> oppList = [SELECT Id,Name,Approvalstatus__c 
                                                FROM Opportunity WHERE Id IN:idMap.keySet()];
                  if(oppList.size() > 0) {
                    for (Opportunity opp : oppList) {
                        opp.Approvalstatus__c = idMap.get(opp.Id).Approvalstatus__c;
                    }
                    update oppList;
                  }

                  }
            }
    	}	
    }

    public class AssignToOpportunity implements Triggers.Handler{
        public void handle() {
                if(Trigger.isAfter && Trigger.isInsert) {
                  Map<String, Projectapplication__c> idMap = new Map<String,Projectapplication__c>();
                  Map<Id, Projectapplication__c> newMap = (Map<Id, Projectapplication__c>)Trigger.newMap;
                  for (Projectapplication__c pa : newMap.values()) {
                      idMap.put(pa.Oppty__c, pa);
                  }
                  List<Opportunity> oppList = [SELECT Id,Name,Approvalstatus__c 
                                                FROM Opportunity WHERE Id IN:idMap.keySet()];
                  if(oppList.size() > 0) {
                    for (Opportunity opp : oppList) {
                        opp.Approvalstatus__c = idMap.get(opp.Id).Approvalstatus__c;
                    }
                    update oppList;
                  }
                }
        }
    }
    
    /**
	 * @description: 插入或更新前判断二级公司总经理/大客户总经理是否为空，为空则去查找集成中间表/客户分部表
	* @param  {*}
	* @return {*}
	*/	
	public void autoSetValueTrigger(List<Projectapplication__c> appList) {
		String recordType = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('OppSubCompany_RecordType').getRecordTypeId();
		//存储 key:所属大区 和 value:营销项目立项申请单
		Map<String,Integrated_Middle_Table__c> areaWindMap = new Map<String,Integrated_Middle_Table__c>();
		for (Integrated_Middle_Table__c form : [SELECT Id,General_Manager_Company__c,Pre_Sales_Project_Manager__c,Salesdepartment__c FROM Integrated_Middle_Table__c WHERE RecordTypeId =: recordType]) {
			areaWindMap.put(form.Salesdepartment__c,form);
		}
		for (Projectapplication__c app : appList) {
			//项目所属大区-大区总经理
			if (areaWindMap.containsKey(app.Salesdepartment__c)&&areaWindMap.get(app.Salesdepartment__c).General_Manager_Company__c!=null) {
                //Devin 2021-11-11 取消 集成中间表【Manager_Secondary_Company__c】改为 【General_Manager_Company__c】
                //                 取消 营销项目立项申请【Chiefgeneralmanager__c】 改为 【Manager_Secondary_Company__c】
				app.Manager_Secondary_Company__c = areaWindMap.get(app.Salesdepartment__c).General_Manager_Company__c;
			}else {
				app.addError('无法匹配到所属大区所对应的大区总经理，请联系管理员!');
			}
			//项目所属大区-售前项目经理
			if (areaWindMap.containsKey(app.Salesdepartment__c)&&areaWindMap.get(app.Salesdepartment__c).Pre_Sales_Project_Manager__c!=null) {
				app.Pre_Sales_Project_Manager__c = areaWindMap.get(app.Salesdepartment__c).Pre_Sales_Project_Manager__c;
			}else {
				app.addError('无法匹配到所属大区所对应的售前项目经理，请联系管理员!');
			}
		}

		//匹配客户分部总经理
		for (Projectapplication__c app : appList) {

			//如果选择了不涉及大客户，则不配置大客户总经理
			// if (app.MarketBidDept__c == '999999') {
			// 	app.General_Manager__c = null;
			// 	break;
			// }

			//客户分部
			List<MarketBidDept__c> tableList = [SELECT Id,DeptPickList__c,General_Manager_Emp__c FROM MarketBidDept__c 
			WHERE DeptPickList__c =:app.MarketBidDept__c];

			if (tableList.size() > 0 && tableList[0].General_Manager_Emp__c != null) {
				app.General_Manager__c = tableList[0].General_Manager_Emp__c;
			}else {
				app.addError('无法匹配到客户分部所对应的大客户总经理，请联系管理员!');
			}
		}
	}
/**
     * @Descripttion: 不能同时存在两条审批中的立项
     * @Author: irving
     * @param {*}
     * @return {*}
     */   
	public class cheakStatusRecords implements Triggers.Handler{

		public void handle() {
            if(Trigger.isBefore && Trigger.isUpdate) {
                for(Projectapplication__c management : (List<Projectapplication__c>)Trigger.new) {
					Projectapplication__c oldmanagement = (Projectapplication__c)Trigger.oldMap.get(management.Id);
					if (management.Oppty__c != null &&management.Approvalstatus__c=='20' &&oldmanagement.Approvalstatus__c=='10') {
						Integer records = [SELECT count() FROM Projectapplication__c WHERE Oppty__c =: management.Oppty__c AND Approvalstatus__c='20'];
						if (records>0) {
							management.addError('已有一条立项处于审批中');
						}
					}
				}
			}
		}

	}


    /**
     * @Descripttion: 商机下只有一条 项目立项 数据
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public class cheakRecords implements Triggers.Handler{

        public void handle() {
            if(Trigger.isBefore && Trigger.isInsert) {
                for(Projectapplication__c management : (List<Projectapplication__c>)Trigger.new) {
                    //一个商机只能有一条项目立项记录
                    if (management.Oppty__c != null) {
                        //Integer records = [SELECT count() FROM Projectapplication__c WHERE Oppty__c =: management.Oppty__c];
						// irving  2021/12/15   弃用
						//Integer records = [SELECT count() FROM Projectapplication__c WHERE Oppty__c =: management.Oppty__c AND Approvalstatus__c!='00' ];
                        // if (records > 0) {
                        //     management.addError('已有可用项目立项申请,请勿新建!');
                        // }
						// Integer record = [SELECT count() FROM Projectapplication__c WHERE Oppty__c =: management.Oppty__c AND Approvalstatus__c='10'];
						// if (record > 0) {
                        //     management.addError('已有可用项目立项申请,请勿新建!');
                        // }
						// Integer r = [SELECT count() FROM Projectapplication__c WHERE Oppty__c =: management.Oppty__c AND Approvalstatus__c='11'];
						// if (r > 0) {
                        //     management.addError('已有可用项目立项申请,请勿新建!');
                        // }
						// Integer rr = [SELECT count() FROM Projectapplication__c WHERE Oppty__c =: management.Oppty__c AND Approvalstatus__c='20'];
						// if (rr > 0) {
                        //     management.addError('已有可用项目立项申请,请勿新建!');
                        // }

                    }
                }
            }
        }
    }

    /**
	 * @description: 审批状态修改并且审批状态为审批中时锁定对象
	* @param  {*}
	* @return {*}
	*/
	public void autoLockTrigger(List<Projectapplication__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		for (Projectapplication__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
		}
		for (Matter_Selected_Impeller__c mem : [SELECT Id FROM Matter_Selected_Impeller__c WHERE Application__c IN: idAllList]) {
			if (!Approval.isLocked(mem.Id)) {
				idList.add(mem.Id);
			}
		}
		Approval.lock(idList);//锁定审批单
	}

	/**
	 * @description: 审批状态修改并且审批状态为已驳回时解锁对象
	* @param  {*}
	* @return {*}
	*/
	public void autoUnLockTrigger(List<Projectapplication__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (Projectapplication__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
		for (Matter_Selected_Impeller__c mem : [SELECT Id FROM Matter_Selected_Impeller__c WHERE Application__c IN: idAllList]) {
			if (Approval.isLocked(mem.Id)) {
				idList.add(mem.Id);
			}
		}
		Approval.unlock(idList);//解锁审批单
	}

	 /**
     * @Descripttion: 项目组成员，拼接商机团队成员姓名
	 * @Date: ###### Thu Jun 8 15:44:39 CST 2023
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    public class contractOppTeamMember implements Triggers.Handler{

        public void handle() {
            if(Trigger.isAfter && Trigger.isInsert) {
				for(Projectapplication__c pro : (List<Projectapplication__c>)Trigger.new) {
					Projectapplication__c p = [select id,Oppty__r.Id from Projectapplication__c where id =: pro.Id];
					String memberStr = contractFun(p.Oppty__r.Id);
					p.ProjectMember__c = memberStr;
					update p;

					CompetitorAnalysis__c ca = new CompetitorAnalysis__c();
					ca.Projectapplication__c = p.Id;
					ca.Name = '明阳';
					insert ca;

				}
            }

			if(Trigger.isAfter && Trigger.isUpdate) {
				for(Projectapplication__c newPro : (List<Projectapplication__c>)Trigger.new) {
					Projectapplication__c oldPro = (Projectapplication__c)Trigger.oldMap.get(newPro.Id);

					if(newPro.Oppty__c != oldPro.Oppty__c && String.isNotBlank(newPro.Oppty__c)){ //商机发生变更
						Projectapplication__c p = [select id,Oppty__r.Id from Projectapplication__c where id =: newPro.Id];
						String memberStr = contractFun(p.Oppty__r.Id);
						p.ProjectMember__c = memberStr;
						update p;
					}


                }
			}
        }

		public String contractFun(String oppId) {
			System.debug('>>>>>>>>>>>商机Id：'+ oppId);
			List<OpportunityTeamMember> oppTeamList = [SELECT ID,User.Name FROM OpportunityTeamMember 
						WHERE OpportunityId =: oppId];
			String str = '';
			System.debug('>>>>>>>>>>>商机团队成员：'+ oppTeamList);
			for (OpportunityTeamMember oppTeam : oppTeamList) {
				str = str + oppTeam.User.Name + '，';
			}
			System.debug('>>>>>>>>>>>商机团队成员拼接：'+ str);
			if (str.length() > 0) {
				str = str.substring(0, str.length()-1);
			}
			return str;
		}
    }

}