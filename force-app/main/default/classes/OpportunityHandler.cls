/*
 * @Descripttion: 商机触发器
 * @Author: Devin
 * @Date: 2021-10-09 11:08:00
 * @LastEditors: Hogan
 * @LastEditTime: 2022-11-18 14:48:48
 */
public without sharing class OpportunityHandler implements Triggers.Handler{

    List<String> oppListFindManagerBySWZ = new List<String>();//大区

    List<String> oppListFindManagerByMBD = new List<String>();//客户分部

    // List<String> capacityList = new List<String>();

    public void handle() {

        //2022-01-11  irving
        if (Trigger.isBefore && Trigger.isInsert) {

            for(Opportunity opp : (List<Opportunity>)Trigger.new) {
                //如果商机的项目名称已经在系统存在
                Integer records = [SELECT count() FROM Opportunity WHERE Name =: opp.Name  ];
                if (records > 0) {
                    opp.addError('商机名称已重复，无法新建！请检查【风场项目名】、【期数】、【区县】字段是否补充完整，补充完整后可降低重复概率。若补充完整依然提示重复，则系统已存在相同商机，请勿新建！');
                }
            }

        }

        //更新之前
        if (Trigger.isBefore && Trigger.isUpdate) {
            //【商机已关闭】 值发生改变时, 加锁/解锁
            Set<Opportunity> closeOpportunitySet = new Set<Opportunity>();

            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);
            
                //2021-12-28 【商机已关闭】 值发生改变时, 商机关闭 锁住记录/ 商机重启 解锁记录
                if (newOpp.Close__c != oldOpp.Close__c) {
                    closeOpportunitySet.add(newOpp);
                }
            }
            
            if (closeOpportunitySet.size() > 0) {
                LockAndUnLockOpportunity(closeOpportunitySet);
            }
        }

        //更新之后
        if (Trigger.isAfter && Trigger.isUpdate) {
            
            List<String> opportunityIdList = new List<String>();

            List<String> oppOwnerIdList = new List<String>();

            // Set<Id> shareOppSet = new Set<Id>();

            // List<Opportunity> manualOppList = new List<Opportunity>();

            System.debug('触发器进来了');
            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);

                //满足条件的话，初始化新建SAP项目
                if (newOpp.ProjectSubmission__c!='历史项目' 
                && String.isEmpty(newOpp.ProjectNumber__c)
                && newOpp.OpportunityApprovalStatus__c != oldOpp.OpportunityApprovalStatus__c
                && (newOpp.OpportunityApprovalStatus__c == '线索提报通过' || newOpp.OpportunityApprovalStatus__c == '商机提报通过')) {
                    Controller_SAP4Project.SAP4ProjectAdd(newOpp.Id);
                }

                //sap项目创建，成功回传项目编号写入商机，则下达系统状态A1节点
                // if(!String.isEmpty(newOpp.ProjectNumber__c) && newOpp.ProjectNumber__c != oldOpp.ProjectNumber__c){
                //     Interface_Log__c logInfo = new Interface_Log__c();
                //     logInfo.IsSuccess__c = false;
                // logInfo.ErrorMessage__c = '！！！' + newOpp.ProjectNumber__c; 
                // insert logInfo;
                //     Controller_SAP4Project.SAP4ProjectStatusUpdate(newOpp.Id);
                // }

                if ((newOpp.Name != oldOpp.Name || newOpp.Periods__c != oldOpp.Periods__c || newOpp.AccountId != oldOpp.AccountId || newOpp.Province__c != oldOpp.Province__c || newOpp.City__c != oldOpp.City__c || newOpp.County__c != oldOpp.County__c || newOpp.Wind_Farm_Project_Name__c != oldOpp.Wind_Farm_Project_Name__c || newOpp.capacity__c != oldOpp.capacity__c) 
                    && (newOpp.StageName != oldOpp.StageName || newOpp.Close__c != oldOpp.Close__c) 
                    && String.isNotBlank(newOpp.ProjectNumber__c)) {
                        Controller_SAP4Project.SAP4ProjectNameUpdateAndUpStatus(newOpp.Id);
                }else {
                    //商机名称变更，更新SAP项目名称
                    if(newOpp.Name != oldOpp.Name){
                        List<Contractmanagement__c> listContract = [SELECT Objectname2__c,WBS__c FROM Contractmanagement__c WHERE ObjectName__c =: newOpp.Id];
                        if (listContract.size() > 0) {
                            //更新商机下所有合同的sap项目名称和商机名称
                            for(Contractmanagement__c newContract : listContract) {
                                Controller_SAP4Project.SAP4ProjectNameUpdate(newContract.Objectname2__c, newContract.WBS__c, newOpp.Name);
                            }
                        }else {
                            //还未生成主合同，根据商机wbs更新sap项目名称和商机名称
                            Controller_SAP4Project.SAP4ProjectNameUpdate(newOpp.Name, newOpp.ProjectNumber__c, newOpp.Name);
                        }
                    }
                    //商机阶段变更
                    if((newOpp.StageName != oldOpp.StageName || newOpp.Close__c != oldOpp.Close__c) && String.isNotBlank(newOpp.ProjectNumber__c)){
                        // //设置SAP项目系统状态
                        // Controller_SAP4Project.SAP4ProjectStatusUpdate(newOpp.Id);
                        // //设置SAP项目用户状态
                        // Controller_SAP4Project.SAP4ProjectStatusUpdate2(newOpp.Id);
                        Controller_SAP4Project.SAP4ProjectNameUpdateAndUpStatus(newOpp.Id);
                    }
                }

                //商机关闭
                if(newOpp.Close__c != oldOpp.Close__c && String.isNotBlank(newOpp.ProjectNumber__c)){
                    //设置SAP项目用户状态
                    Controller_SAP4Project.SAP4ProjectStatusUpdate2(newOpp.Id);
                }

                // if (newOpp.capacity__c!=oldOpp.capacity__c) {
                //     capacityList.add(newOpp.id);
                // }

                if (newOpp.Salesdepartment__c!=oldOpp.Salesdepartment__c) {
                    oppListFindManagerBySWZ.add(newOpp.Id);
                }

                if (newOpp.MarketBidDept__c!=oldOpp.MarketBidDept__c) {
                    oppListFindManagerByMBD.add(newOpp.Id);
                }

                //立项审批通过，初始化商机的合同商务
                if(newOpp.Approvalstatus__c == '30' && newOpp.Approvalstatus__c != oldOpp.Approvalstatus__c){
                    opportunityIdList.add(newOpp.Id);
                }

                //OwnerId 发生改变时
                if (newOpp.OwnerId != oldOpp.OwnerId) {
                    oppOwnerIdList.add(newOpp.Id);
                }

                // if (newOpp.OpportunityApprovalStatus__c=='审批中') {
                //     shareOppSet.add(newOpp.id);
                // }

                //2022-02-21 防止用户手工修改 商机 阶段
                // if (newOpp.Is_Manual_Modification__c == false && newOpp.Is_Manual_Modification__c != oldOpp.Is_Manual_Modification__c) {
                //     manualOppList.add(newOpp);
                // }

            }

            // if (shareOppSet.size()>0) {
            //     shareAuthority(shareOppSet);
            // }
    
            // if(opportunityIdList.size() >0 ){
            //     createContractmanagement(opportunityIdList);
            // }

            if (oppOwnerIdList.size() > 0) {
                shareToOpportunityDepend(oppOwnerIdList);
            }

            if (oppListFindManagerBySWZ.size()>0) {
                FindManagerBySWZ(oppListFindManagerBySWZ);
            }

            if (oppListFindManagerByMBD.size()>0) {
                FindManagerByMBD(oppListFindManagerByMBD);
            }

            // if (manualOppList.size() > 0) {

            //     List<Opportunity> updateManuaList = new List<Opportunity>();

            //     List<Id> lockOpportunityIdList = new List<Id>();

            //     for (Opportunity manua : manualOppList) {
            //         Opportunity updateManua = new Opportunity();
            //         updateManua.Id = manua.Id;
            //         if(Approval.isLocked(manua.Id)){
            //             Approval.unlock(manua.Id, false);
            //             lockOpportunityIdList.add(manua.Id);
            //         }
            //         updateManua.Is_Manual_Modification__c = true;//防止用户手工修改 商机阶段， 只能由系统逻辑自动修改
            //         updateManuaList.add(updateManua);
            //     }

            //     update updateManuaList;

            //     //重新给需要加锁的商机，加锁
            //     Approval.lock(lockOpportunityIdList, false);
            // }

        }

        //插入之后
        if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('进入到商机新增触发器');
            Map<Id,Opportunity> newMap = (Map<Id,Opportunity>)Trigger.newMap;

            // for (Opportunity opp :newMap.values()) {
            //   if (opp.capacity__c!=null) {
            //     capacityList.add(opp.id);
            //   }  
            // }
            
            //初始化新建合同商务
            // List<Contractmanagement__c> cmList = new List<Contractmanagement__c>();
            // for (String oppId : newMap.keySet()) {
            //     Contractmanagement__c cm = new Contractmanagement__c();
            //     cm.ObjectName__c = oppId;
            //     cmList.add(cm);
            // }
            // insert cmList;

            for (Opportunity opp : newMap.values()) {

                //商机阶段初始化，更新SAP项目状态
                // Controller_SAP4Project.SAP4ProjectStatusUpdate(newOpp.Id);

               if (opp.Salesdepartment__c!=null) {
                oppListFindManagerBySWZ.add(opp.Id);
               }

               if (opp.MarketBidDept__c!=null) {
                oppListFindManagerByMBD.add(opp.Id);
               }
            }

            if (oppListFindManagerBySWZ.size()>0) {
                FindManagerBySWZ(oppListFindManagerBySWZ);
            }

            if (oppListFindManagerByMBD.size()>0) {
                FindManagerByMBD(oppListFindManagerByMBD);
            }
        }

        // if (capacityList.size()>0) {
        //     capacityMethod(capacityList);
        // }


        //插入之后
        // if (Trigger.isAfter && Trigger.isInsert) {
        //     for(Opportunity opp : (List<Opportunity>)Trigger.new) {
        //         //新增商机团队：大区/二级公司总经理
        //         if(opp.Chiefgeneralmanager__c != null){
        //             OpportunityTeamMember insertTeam1 = new OpportunityTeamMember();
        //             insertTeam1.OpportunityId = opp.Id;
        //             insertTeam1.OpportunityAccessLevel = 'read';
        //             insertTeam1.TeamMemberRole = '区域总经理';
        //             insertTeam1.UserId = opp.Chiefgeneralmanager__c;
        //             insert insertTeam1;
        //         }

        //         //新增商机团队：大客户总经理
        //         if(opp.Key_Account_General_Manager__c != null){
        //             OpportunityTeamMember insertTeam2 = new OpportunityTeamMember();
        //             insertTeam2.OpportunityId = opp.Id;
        //             insertTeam2.OpportunityAccessLevel = 'read';
        //             insertTeam2.TeamMemberRole = '大客户总经理';
        //             insertTeam2.UserId = opp.Key_Account_General_Manager__c;
        //             insert insertTeam2;
        //         }

        //         //新增商机团队：售前项目经理
        //         if(opp.Pre_Sales_Project_Manager__c != null){
        //             OpportunityTeamMember insertTeam3 = new OpportunityTeamMember();
        //             insertTeam3.OpportunityId = opp.Id;
        //             insertTeam3.OpportunityAccessLevel = 'read';
        //             insertTeam3.TeamMemberRole = '售前项目经理';
        //             insertTeam3.UserId = opp.Pre_Sales_Project_Manager__c;
        //             insert insertTeam3;
        //         }
        //     }
        // }
        //更新之后
        if (Trigger.isAfter && Trigger.isUpdate) {

            for(Opportunity newOpp : (List<Opportunity>)Trigger.new) {
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(newOpp.Id);

                //更新商机团队（总经理发生变更：大区/二级公司总经理）
                if(newOpp.Chiefgeneralmanager__c != oldOpp.Chiefgeneralmanager__c){
                    System.debug('>>>>>>>>>>>');
                    String chief = newOpp.Chiefgeneralmanager__c;
                    List<OpportunityTeamMember> oppTeam = [SELECT ID FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newOpp.Id and UserId =: oldOpp.Chiefgeneralmanager__c LIMIT 1];
                    //存在旧的总经理，删除成员
                    if (oppTeam != null) {
                        delete oppTeam;
                    }
                    OpportunityTeamMember insertTeam = new OpportunityTeamMember();
                    insertTeam.OpportunityId = newOpp.Id;
                    insertTeam.OpportunityAccessLevel = 'read';
                    insertTeam.TeamMemberRole = '区域总经理';
                    insertTeam.UserId = newOpp.Chiefgeneralmanager__c;
                    insert insertTeam;
                }
                
                //更新商机团队（总经理发生变更：大客户总经理）
                if(newOpp.Key_Account_General_Manager__c != oldOpp.Key_Account_General_Manager__c){
                    List<OpportunityTeamMember> oppTeam = [SELECT ID FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newOpp.Id and UserId =: oldOpp.Key_Account_General_Manager__c LIMIT 1];
                    //存在旧的总经理，删除成员
                    if (oppTeam != null) {
                        delete oppTeam;
                    }
                    OpportunityTeamMember insertTeam = new OpportunityTeamMember();
                    insertTeam.OpportunityId = newOpp.Id;
                    insertTeam.OpportunityAccessLevel = 'read';
                    insertTeam.TeamMemberRole = '大客户总经理';
                    insertTeam.UserId = newOpp.Key_Account_General_Manager__c;
                    insert insertTeam;
                }

                //更新商机团队（总经理发生变更：售前项目经理）
                if(newOpp.Pre_Sales_Project_Manager__c != oldOpp.Pre_Sales_Project_Manager__c){
                    List<OpportunityTeamMember> oppTeam = [SELECT ID FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newOpp.Id and UserId =: oldOpp.Pre_Sales_Project_Manager__c LIMIT 1];
                    //存在旧的总经理，删除成员
                    if (oppTeam != null) {
                        delete oppTeam;
                    }
                    OpportunityTeamMember insertTeam = new OpportunityTeamMember();
                    insertTeam.OpportunityId = newOpp.Id;
                    insertTeam.OpportunityAccessLevel = 'read';
                    insertTeam.TeamMemberRole = '售前项目经理';
                    insertTeam.UserId = newOpp.Pre_Sales_Project_Manager__c;
                    insert insertTeam;
                }
            }
        }
        
    }

    /**
     * @Descripttion: 文本容量把所有的中文去掉 取前段数字
     * @Author: irving
     * @param {*}
     * @return {*}
     */
    // public void capacityMethod(List<String> capacityList) {

    //     List<Opportunity>  oppList = [select id,name,capacity__c,TotalMW__c from Opportunity where id in:capacityList];

    //     for (Opportunity opp : oppList) {
    //         if (opp.capacity__c==null) {
    //             opp.TotalMW__c = null ; 
    //         }else{
    //         //    String s =  opp.capacity__c.replaceAll('([\u4E00-\u9FA5]+)|([a-zA-Z])', '_').substringBefore('_');

    //         //   if (s.isNumeric()) {
    //         //     Double d = Double.valueOf(s);
    //         //     Integer l  = (Integer)d.round();
    //         //     opp.TotalMW__c = l ; 
    //         //   }
    //             opp.TotalMW__c = opp.capacity__c;
    //         }
          
    //     }

    //     update oppList ; 
    // }

    /**
     * @Descripttion: 商机更改二级战区/公司时查找集成中间表找对应的二级公司经理、售前项目经理
     * @Author: irving
     * @param {*}
     * @return {*}
     */
    public void FindManagerBySWZ(List<String> oppListFindManagerBySWZ) {


        List<Opportunity> oppList = [SELECT ID,
                                            Salesdepartment__c,   //所属大区/二级公司
                                            Chiefgeneralmanager__c,   //大区/二级公司总经理
                                            Pre_Sales_Project_Manager__c //售前项目经理
                                            FROM Opportunity WHERE ID IN:oppListFindManagerBySWZ];

        if (oppList[0].Salesdepartment__c==null) {
            return ; 
        }

        // if (oppList[0].Salesdepartment__c=='海外') {
        //     return ; 
        // }

        // if (oppList[0].Salesdepartment__c=='能源技术公司') {
        //     return ; 
        // }

        String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('OppSubCompany_RecordType').getRecordTypeId();

        List<Integrated_Middle_Table__c> tableList = [SELECT Id,
                                                    OppChiefgeneralmanager__c,
                                                    Pre_Sales_Project_Manager__c,
                                                    Salesdepartment__c 
                                                    FROM Integrated_Middle_Table__c 
                                                    WHERE RecordTypeId =:recTypeId  
                                                    AND Salesdepartment__c =:oppList[0].Salesdepartment__c];


        if (tableList.size()==0 || tableList[0].OppChiefgeneralmanager__c==null) {
            return ; 
        }

        if(tableList[0].OppChiefgeneralmanager__c != null){
            oppList[0].Chiefgeneralmanager__c = tableList[0].OppChiefgeneralmanager__c;
        }

        if(tableList[0].Pre_Sales_Project_Manager__c != null){
            oppList[0].Pre_Sales_Project_Manager__c = tableList[0].Pre_Sales_Project_Manager__c;
        }

        upsert oppList ; 
    }

    /**
     * @Descripttion: 商机更改客户分部时查找《客户/营销分部》找对应的分部总经理
     * @Author: irving
     * @param {*}
     * @return {*}
     */
    public void FindManagerByMBD(List<String> oppListFindManagerByMBD) {


        List<Opportunity> oppList = [SELECT ID,
                                            MarketBidDept__c,   //客户分部
                                            Key_Account_General_Manager__c   //大客户总经理
                                            FROM Opportunity WHERE ID IN:oppListFindManagerByMBD];

        if (oppList[0].MarketBidDept__c==null) {
            return ; 
        }

        List<MarketBidDept__c> tableList = [SELECT Id,
                                                    DeptPickList__c,
                                                    General_Manager_User__c
                                                    FROM MarketBidDept__c 
                                                    WHERE DeptPickList__c =:oppList[0].MarketBidDept__c];


        if (tableList.size()==0 || tableList[0].General_Manager_User__c==null) {
            return ; 
        }

        if(tableList[0].General_Manager_User__c != null){
            oppList[0].Key_Account_General_Manager__c = tableList[0].General_Manager_User__c;
        }

        upsert oppList ; 
    }

    /**
     * @Descripttion: 当系统识别商机阶段为【中标/赢单】，系统自动创建《合同商务》记录
     * @Author: Devin
     * @Editor: 
     * @param {*}
     * @return {*}
     */
    // public void createContractmanagement(List<String> opportunityIdList) {
        
    //     Set<String> existOppIdSet = new Set<String>();
    //     for (Contractmanagement__c cm : [SELECT Id,ObjectName__c FROM Contractmanagement__c WHERE ObjectName__c IN: opportunityIdList]) {
    //         existOppIdSet.add(cm.ObjectName__c);
    //     }
        
    //     List<Contractmanagement__c> cmList = new List<Contractmanagement__c>();
    //     for (String oppId : opportunityIdList) {
    //         //一个商机只有一个合同商务 如果已经存在 则不创建
    //         if (!existOppIdSet.contains(oppId)) {
    //             //查询商机信息
    //             Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE Id =: oppId];

    //             Contractmanagement__c cm = new Contractmanagement__c();
    //             cm.ObjectName__c = oppId;//商机
    //             cmList.add(cm);
    //         }
    //     }
        
    //     insert cmList;


    //     //irving  2022-02-10  中标赢单 共享只读权限给项目的pmo（区分海上陆上） 以及合同管理专员（曾静）

    //     List<Opportunity> oppList = [SELECT ID FROM Opportunity WHERE ID IN :opportunityIdList];

    //     List<OpportunityShare> insertList = new List<OpportunityShare>();

    //     List<Project__c> projectList = [SELECT ID,Opportunity__c,Type__c FROM Project__c WHERE Opportunity__c IN :opportunityIdList];

    //     String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProjectType_RecordType').getRecordTypeId();


    //     Integrated_Middle_Table__c table1 = new Integrated_Middle_Table__c();

    //     //项目存在  通知pmo  取陆上还是海上的pmo  取出角色，根据角色查用户
    //     if (projectList.size()>0 && projectList!=null &&projectList[0].Type__c!=null ) {
    //          table1 = [SELECT Id,
    //                             ProjectType__c,   //项目类型
    //                             RoleName__c     //角色名称               
    //                             FROM Integrated_Middle_Table__c 
    //                             WHERE RecordTypeId =:recTypeId  
    //                             AND ProjectType__c = :projectList[0].Type__c];
    //     }

    //     //根据类型通知角色为陆上pmo或者海上pmo的用户,根据角色-->用户
    //     List<User> userList = new List<User>();
    //     if (table1!=null &&String.isNotBlank(table1.RoleName__c)) {

    //         UserRole  userrole = [select id,name FROM UserRole WHERE Name = :table1.RoleName__c];

    //         userList = [SELECT ID,NAME,UserRoleId  FROM USER WHERE UserRoleId =:userrole.id AND IsActive = true] ;
    //     }
        


    //     String recTypeId1 =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('OppWinBid_RecordType').getRecordTypeId();

    //     //主要取通知陆上&海上的指定简档
    //     Integrated_Middle_Table__c table2 = [SELECT Id,
    //                                                 OppWinBidNotify__c   //简档名称(商机中标后通知)
    //                                                 FROM Integrated_Middle_Table__c 
    //                                                 WHERE RecordTypeId =:recTypeId1  ];

    //     List<User> userListFromProfile  =  new List<User>();

    //     if (String.isNotBlank(table2.OppWinBidNotify__c)) {
    //         List<String> profileNameList = table2.OppWinBidNotify__c.split(';');   
    //         List<Profile> profileList = [SELECT ID FROM Profile WHERE NAME IN :profileNameList]; 
    //         List<String> profileIdList = new List<String>();
    //         for (Profile p : profileList) {
    //             profileIdList.add(p.id);
    //         }

    //         if (profileIdList.size()>0) {
    //             userListFromProfile = [SELECT ID,NAME,ProfileId FROM User WHERE ProfileId IN:profileIdList AND IsActive = true];
    //         }

    //     }
        
        

        


    //     if (userListFromProfile.size()>0) {

    //         for (User u : userListFromProfile) {
                
    //             for (Opportunity opp : oppList) {

    //                 OpportunityShare share = new OpportunityShare();
                                                                    
    //                 share.OpportunityId = opp.Id;
    //                 share.UserOrGroupId = u.id;   //分配给简档查到的用户
    //                 share.OpportunityAccessLevel = 'Read';
    //                 insertList.add(share);
                                                        
    //                 }
    //         }
            
    //     }

        
    //     if (userList.size()>0) {

    //         for (User u : userList) {
                
    //             for (Opportunity opp : oppList) {

    //                 OpportunityShare share = new OpportunityShare();
                    
    //                 share.OpportunityId = opp.Id;
    //                 share.UserOrGroupId = u.id;   //分配给项目pmo
    //                 share.OpportunityAccessLevel = 'Read';
    //                 insertList.add(share);
        
    //             }

    //         }
            
    //     }

    //     System.debug('insertList===='+insertList);

    //     insert insertList ; 
    // }

    /**
     * @Descripttion: 商机下的所有人发生改变时，共享：方案申请、项目立项、修改 Owner合同商务
     * @Author: Devin
     * @param {*}
     * @return {*}
     */
    public void shareToOpportunityDepend(List<String> projectIdSet) {

        List<Opportunity> opportunityList = new List<Opportunity>();

        opportunityList = [SELECT   Id,
                                    OwnerId,
                                    (SELECT Id,ownerId FROM Form_Opp__r),//营销项目方案申请单
                                    (SELECT Id,ownerId FROM Oppty__r)//营销项目立项申请
                                    // (SELECT Id,OwnerId FROM ContractApproval_Opp__r)//合同商务
                                FROM 
                                    Opportunity 
                                WHERE 
                                    Id IN: projectIdSet
                                ];

        //营销项目方案申请单
        List<Project_Scheme_Application_Form__Share> pasfShareList = new List<Project_Scheme_Application_Form__Share>();
        //营销项目立项申请
        List<Projectapplication__Share> applicationShareList = new List<Projectapplication__Share>();
        //合同商务
        // List<Contractmanagement__c> cgOwnerIdListList = new List<Contractmanagement__c>();

        for(Opportunity opp : opportunityList) {

            //营销项目方案申请单
            for (Project_Scheme_Application_Form__c psaf : opp.Form_Opp__r) {
                
                //所有人 和 业务机会的 所有人不一样
                //一样的话  会出现错误
                if (psaf.OwnerId != opp.OwnerId) {
                    Project_Scheme_Application_Form__Share pasfShare = new Project_Scheme_Application_Form__Share();
                    pasfShare.ParentId = psaf.Id;
                    pasfShare.UserOrGroupId = opp.OwnerId;//分配给商机所有人
                    pasfShare.AccessLevel = 'edit';
                    pasfShareList.add(pasfShare);
                }
            }

            //营销项目立项申请
            for (Projectapplication__c application : opp.Oppty__r) {
                
                //所有人 和 业务机会的 所有人不一样
                //一样的话  会出现错误
                if (application.OwnerId != opp.OwnerId) {
                    Projectapplication__Share applicationShare = new Projectapplication__Share();
                    applicationShare.ParentId = application.Id;
                    applicationShare.UserOrGroupId = opp.OwnerId;//分配给商机所有人
                    applicationShare.AccessLevel = 'edit';
                    applicationShareList.add(applicationShare);
                }
            }

            //合同商务
            // for (Contractmanagement__c cg :opp.ContractApproval_Opp__r) {
            //     Contractmanagement__c changeOwnerId = new Contractmanagement__c();
            //     changeOwnerId.Id = cg.Id;
            //     changeOwnerId.OwnerId = opp.OwnerId;//修改所有人
            //     cgOwnerIdListList.add(changeOwnerId);
            // }
        }

        System.debug('pasfShareList---'+pasfShareList);
        System.debug('applicationShareList---'+applicationShareList);
        // System.debug('cgOwnerIdListList---'+cgOwnerIdListList);

        Database.insert(pasfShareList,true);//营销项目方案申请单
        Database.insert(applicationShareList,true);//营销项目立项申请
        // Database.update(cgOwnerIdListList,false);//合同商务
    }


    /**
     * @Descripttion: 发起申报审批时,共享给大区/二级公司总经理  大客户总经理
     * @Author: irving
     * @param {*}
     * @return {*}
     */   
    // public void shareAuthority(Set<Id> shareOppSet) {

    //     List<Opportunity> oppList = new List<Opportunity>();

    //     oppList = [SELECT Id,
    //                         Key_Account_General_Manager__c,  //大客户总经理*
    //                         Chiefgeneralmanager__c  //大区/二级公司总经理*
    //                         FROM Opportunity WHERE Id IN: shareOppSet];

    //     List<OpportunityShare> insertList = new List<OpportunityShare>();

    //     for (Opportunity l : oppList) {
    //         OpportunityShare share = new OpportunityShare();
    //         share.OpportunityId = l.Id;
    //         share.UserOrGroupId = l.Key_Account_General_Manager__c;   //分配给---
    //         share.OpportunityAccessLevel = 'Read';
    //         insertList.add(share);
    //     }

    //     for (Opportunity l : oppList) {
    //         OpportunityShare share = new OpportunityShare();
    //         share.OpportunityId = l.Id;
    //         share.UserOrGroupId = l.Chiefgeneralmanager__c;   //分配给---
    //         share.OpportunityAccessLevel = 'Read';
    //         insertList.add(share);
    //     }

    //     System.debug('insertList---'+insertList);

    //     Database.insert(insertList,false);

    // }

    /**
     * @Descripttion: 【商机已关闭】 值发生改变时, 商机关闭 锁住记录/ 商机重启 解锁记录
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void LockAndUnLockOpportunity(Set<Opportunity> oppSet) {

        //加锁
        List<Opportunity> lockOpportunityList = new List<Opportunity>();
        //解锁
        List<Opportunity> unLockOpportunityList = new List<Opportunity>();

        for (Opportunity opp : oppSet) {
            //商机关闭  加锁
            if (opp.Close__c) {
                lockOpportunityList.add(opp);
            } else {
                //商机重启  解锁
                unLockOpportunityList.add(opp);
            }
        }

        System.debug('lockOpportunityList-----'+lockOpportunityList);
        System.debug('unLockOpportunityList-----'+unLockOpportunityList);

        //加锁
        if (!lockOpportunityList.isEmpty()) {
            List<Approval.LockResult> lrList = Approval.lock(lockOpportunityList, false);
            // Iterate through each returned result
            for(Approval.LockResult lr : lrList) {
                if (lr.isSuccess()) {
                    //Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully locked account with ID: ' + lr.getId());
                }
                else {
                    //Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        //解锁
        if (!unLockOpportunityList.isEmpty()) {
            //Unlock records
            List<Approval.UnlockResult> ulrList = Approval.unlock(unLockOpportunityList, false);
            
            // Iterate through each returned result
            for(Approval.UnlockResult  ulr : ulrList) {
                if (ulr.isSuccess()) {
                    //Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully unlocked account with ID: ' + ulr.getId());
                }
                else {
                    //Operation failed, so get all errors                
                    for(Database.Error err : ulr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
}