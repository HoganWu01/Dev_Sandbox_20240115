/*
 * @Author: Hogan
 * @Date: 2021-11-19 11:00:00
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-11-19 11:00:00
 * @Descripttion: SAP项目控制类
 */
global without sharing class Controller_SAP4Project {

    //创建SAP项目
    @future (callout=true)
    global static Void SAP4ProjectAdd(String recordId){

        Opportunity opp = [SELECT Id, Name, ProjectNumber__c, Is_Sap_Proj_Status__c, Province__c FROM Opportunity Where Id = : recordId] ; 

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody reqBody = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapProjectAdd');

        External_System_Param__c ext2 = External_System_Param__c.getValues('sapProjectStatus');

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAP4ProjectAdd';

            if(String.isBlank(opp.Province__c)){
                logInfo.RespondBody__c = '商机省份为空！！！';
                insert logInfo;
                return;
            }
            
            //自定义设置：省份编码和名称mapping
            ZProvince__c  zProv =[SELECT Province_Code__c  FROM ZProvince__c WHERE Province__c =: opp.Province__c ];

            reqBody.post1 = opp.Name ;     //项目名
            // reqBody.pnum = Integer.valueof(pro.InitialNumOfMachine__c )  ; //风机台数--先不填
            reqBody.prart = 'S1' ; //项目类型 S1/S2/E1
            reqBody.pspid = 'L1-20220000' ; //标准项目	L1-20220001
            reqBody.pyear = Datetime.now().year(); //项目年度
            reqBody.province_id = zProv.Province_Code__c; //省份 opp.Province__c
            reqBody.zpost1 = opp.Name; //商机名称
            reqBody.zpost1_id = opp.Id; //商机ID
            reqBody.zproj = opp.Name; //项目全称

            OpenPlatformApi__c open = OpenPlatformApi__c.getValues('GetToken');//add by hogan
            String IPURL = open.IP__c + ext.Request_URL__c;
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            String staticToken = Utils.getToken();
            r.setHeader('Content-Type', 'application/json; charset=utf-8');
            r.setHeader('accept','application/json');
            r.setEndpoint(IPURL);
            r.setHeader('Authorization','Bearer '+staticToken);
            r.setMethod('POST');
            r.setTimeout(120000);
            r.setBody(JSON.serialize(reqBody));
            HTTPResponse resp = h.send(r);

            if(resp.getStatusCode() == 200){
                //创建sap项目成功后同时下达A1节点
                // Interface_Log__c logInfotest = new Interface_Log__c();
                // logInfotest.RequestURL__c = IPURL;
                // logInfotest.RequestBody__c = JSON.serialize(reqBody);
                // logInfotest.RespondBody__c = resp.getBody();
                // insert logInfotest;
                ResponseBody res = (ResponseBody)System.JSON.deserialize(resp.getBody(), ResponseBody.class);
                if (res.data!=null && res.data.size()>0) {
                    Data rd = res.data[0];
                    opp.ProjectNumber__c = rd.pspid ;   //项目编号
                    if(!String.isBlank(rd.pspid)){
                        RequestBody3 reqB = new RequestBody3();  
                        reqB.i_posid = rd.pspid + '-0000.A1' ;     //WBS
                        reqB.i_status2 = 'REL' ; //设置系统状态
                        r.setEndpoint(open.IP__c + ext2.Request_URL__c);
                        r.setBody(JSON.serialize(reqB));
                        HTTPResponse resp2 = h.send(r);
                        if(resp2.getStatusCode() == 200){
                            Interface_Log__c logInfo2 = new Interface_Log__c();
                            logInfo2.RequestURL__c = ext2.Request_URL__c;
                            logInfo2.RequestBody__c = JSON.serialize(reqB);
                            logInfo2.ClassName__c = 'Controller_SAP4ProjectAdd';
                            logInfo2.RespondBody__c = resp2.getBody();
                            logInfo2.IsSuccess__c = true; 
                            insert logInfo2;
                        }
                    }
                }
            }



            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            // String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAP4ProjectAdd',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        
            String response = resp.getBody();

            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if(resp.getStatusCode() != 200){
                opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                update opp;
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回data

                    if (resBody.data==null || resBody.data.size()==0) {
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '返回数据为空';
                        System.debug('resBody.data===》》'+resBody.data);
                        opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                        update opp;
                        insert logInfo ; 
                        return ; 
                    }

                    System.debug('resBody.message========>>>>'+resBody.message);
                    logInfo.IsSuccess__c = true; 

                    Data rd = resBody.data[0];

                    opp.ProjectNumber__c = rd.pspid ;   //项目编号
                    opp.Is_Sap_Proj_Status__c = '1'; //SAP项目创建状态

                    update opp ; 
                    System.debug('创建SAP项目完成');


                    // String content = '你的项目已经成功同步到SAP,项目名由【】更新为【'+reqBody.post1+'】';
                    // System.debug('内容content==========》》》'+content);

                    // System.debug('小铃铛通知');
                    // if (userIdSet.size()>0) {
                    //     Utils.notifyUsers(userIdSet, pro.id, '同步SAP项目成功',content );
                    // }
                    

                    // System.debug('邮箱通知');
                    // Set<String> emailSet = new Set<String>();

                    // if (userList.size()>0) {
                    //     for (User user : userList) {
                    //         emailSet.add(user.email); 
                    //     }
                    // }
                    
                    // String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+pro.id ; 

                    // if (emailSet.size()>0) {
                    //  sendMail(emailSet,'同步SAP项目成功','你的项目已经成功同步到SAP,项目名已更改,项目名更新为【'+reqBody.post1+'】,详情请点击'+'\r\n'+Recordlink);
                    // }
                   
                    // System.debug('发送邮件完成');

                }else{
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                    
                    opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                    update opp ; 
                }
                insert logInfo ; 


            }

        }catch(Exception e){
            System.debug(e.getMessage());
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
            logInfo.IsSuccess__c = false;
            logInfo.RespondBody__c = msg;
            insert logInfo;
        }

    }

    //创建SAP标段项目
    @future (callout=true)
    global static Void SAP4SectionProjectAdd(String recordId, String contractId){ //商机ID、合同商务ID

        Opportunity opp = [SELECT Id, Name, ProjectNumber__c, Is_Sap_Proj_Status__c, Province__c FROM Opportunity Where Id = : recordId] ; 

        Contractmanagement__c con = [SELECT Id, Name, WBS__c,Is_Sap_Proj_Status__c, Objectname2__c FROM Contractmanagement__c Where Id = : contractId] ; 

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody reqBody = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapProjectAdd');

        External_System_Param__c ext2 = External_System_Param__c.getValues('sapProjectStatus');

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAP4ProjectAdd';

            if(String.isBlank(opp.Province__c)){
                logInfo.RespondBody__c = '商机省份为空！！！';
                insert logInfo;
                return;
            }
            
            //自定义设置：省份编码和名称mapping
            ZProvince__c  zProv =[SELECT Province_Code__c  FROM ZProvince__c WHERE Province__c =: opp.Province__c ];

            reqBody.post1 = con.Objectname2__c ;     //合同标段项目名名
            // reqBody.pnum = Integer.valueof(pro.InitialNumOfMachine__c )  ; //风机台数--先不填
            reqBody.prart = 'S1' ; //项目类型 S1/S2/E1
            reqBody.pspid = 'L1-20220000' ; //标准项目	L1-20220001
            reqBody.pyear = Datetime.now().year(); //项目年度
            reqBody.province_id = zProv.Province_Code__c; //省份 opp.Province__c
            reqBody.zpost1 = opp.Name; //商机名称
            reqBody.zpost1_id = opp.Id; //商机ID
            reqBody.zproj = con.Objectname2__c; //项目全称

            OpenPlatformApi__c open = OpenPlatformApi__c.getValues('GetToken');//add by hogan
            String IPURL = open.IP__c + ext.Request_URL__c;
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            String staticToken = Utils.getToken();
            r.setHeader('Content-Type', 'application/json; charset=utf-8');
            r.setHeader('accept','application/json');
            r.setEndpoint(IPURL);
            r.setHeader('Authorization','Bearer '+staticToken);
            r.setMethod('POST');
            r.setTimeout(120000);
            r.setBody(JSON.serialize(reqBody));
            HTTPResponse resp = h.send(r);

            if(resp.getStatusCode() == 200){
                //创建sap项目成功后同时下达A1节点
                // Interface_Log__c logInfotest = new Interface_Log__c();
                // logInfotest.RequestURL__c = IPURL;
                // logInfotest.RequestBody__c = JSON.serialize(reqBody);
                // logInfotest.RespondBody__c = resp.getBody();
                // insert logInfotest;
                ResponseBody res = (ResponseBody)System.JSON.deserialize(resp.getBody(), ResponseBody.class);
                if (res.data!=null && res.data.size()>0) {
                    Data rd = res.data[0];
                    con.WBS__c = rd.pspid ;   //项目编号

                    if(!String.isBlank(rd.pspid)){
                        RequestBody3 reqB = new RequestBody3();  
                        reqB.i_posid = rd.pspid + '-0000.A1' ;     //WBS
                        reqB.i_status2 = 'REL' ; //设置系统状态
                        r.setEndpoint(open.IP__c + ext2.Request_URL__c);
                        r.setBody(JSON.serialize(reqB));
                        HTTPResponse resp2 = h.send(r);
                        if(resp2.getStatusCode() == 200){
                            Interface_Log__c logInfo2 = new Interface_Log__c();
                            logInfo2.RequestURL__c = ext2.Request_URL__c;
                            logInfo2.RequestBody__c = JSON.serialize(reqB);
                            logInfo2.ClassName__c = 'Controller_SAP4ProjectAdd';
                            logInfo2.RespondBody__c = resp2.getBody();
                            logInfo2.IsSuccess__c = true; 
                            insert logInfo2;
                        }
                    }
                }
            }



            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            String response = resp.getBody();

            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if(resp.getStatusCode() != 200){
                con.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                update con;
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回data

                    if (resBody.data==null || resBody.data.size()==0) {
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '返回数据为空';
                        System.debug('resBody.data===》》'+resBody.data);
                        con.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                        update con;
                        insert logInfo ; 
                        return ; 
                    }

                    System.debug('resBody.message========>>>>'+resBody.message);
                    logInfo.IsSuccess__c = true; 

                    Data rd = resBody.data[0];

                    con.WBS__c = rd.pspid ;   //项目编号
                    con.Is_Sap_Proj_Status__c = '1'; //SAP项目创建状态

                    update con ; 
                    System.debug('创建SAP标段项目完成');


                    // String content = '你的项目已经成功同步到SAP,项目名由【】更新为【'+reqBody.post1+'】';
                    // System.debug('内容content==========》》》'+content);

                    // System.debug('小铃铛通知');
                    // if (userIdSet.size()>0) {
                    //     Utils.notifyUsers(userIdSet, pro.id, '同步SAP项目成功',content );
                    // }
                    

                    // System.debug('邮箱通知');
                    // Set<String> emailSet = new Set<String>();

                    // if (userList.size()>0) {
                    //     for (User user : userList) {
                    //         emailSet.add(user.email); 
                    //     }
                    // }
                    
                    // String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+pro.id ; 

                    // if (emailSet.size()>0) {
                    //  sendMail(emailSet,'同步SAP项目成功','你的项目已经成功同步到SAP,项目名已更改,项目名更新为【'+reqBody.post1+'】,详情请点击'+'\r\n'+Recordlink);
                    // }
                   
                    // System.debug('发送邮件完成');

                }else{
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                    
                    con.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                    update con ; 
                }
                insert logInfo ; 


            }

        }catch(Exception e){
            System.debug(e.getMessage());
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
            logInfo.IsSuccess__c = false;
            logInfo.RespondBody__c = msg;
            insert logInfo;
        }

    }

    //修改SAP项目名称
    @future (callout=true)
    global static Void SAP4ProjectNameUpdate(String projectName, String ProjectNumber, String opportunityName){

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody2 reqBody = new RequestBody2();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapProjectModify');

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAP4ProjectNameUpdate';

            reqBody.i_post1 = projectName ;     //项目名称
            reqBody.i_pspid = ProjectNumber ; //项目定义
            reqBody.i_zpost1 = opportunityName; //商机名称
            reqBody.i_zproj = projectName; //项目全称

            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAP4ProjectNameUpdate',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        
            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if(response.substring(0,5) == 'Error'){
                // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                // update opp;
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回data

                    if (resBody.data==null || resBody.data.size()==0) {
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '返回数据为空';
                        System.debug('resBody.data===》》'+resBody.data);
                        // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                        // update opp;
                        insert logInfo ; 
                        return ; 
                    }

                    System.debug('resBody.message========>>>>'+resBody.message);
                    logInfo.IsSuccess__c = true; 

                    Data rd = resBody.data[0];

                    // opp.ProjectNumber__c = rd.pspid  ;   //项目编号
                    // opp.Is_Sap_Proj_Status__c = '1';//更新SAP项目创建状态

                    // update opp ; 
                    System.debug('更新SAP项目名称完成');

                }else{
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                    
                    // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                    // update opp ; 
                }
                insert logInfo ; 


            }

        }catch(Exception e){
            System.debug(e.getMessage());
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
        }

    }

    //修改项目系统状态
    // @future (callout=true)
    // global static Void SAP4ProjectStatusUpdate(String recordId){

    //     Opportunity opp = [SELECT Id, Name, ProjectNumber__c, Is_Sap_Proj_Status__c, StageName FROM Opportunity Where Id = : recordId] ; 

    //     Interface_Log__c logInfo = new Interface_Log__c();

    //     RequestBody3 reqBody = new RequestBody3();  

    //     External_System_Param__c ext = External_System_Param__c.getValues('sapProjectStatus');

    //     try {

    //         logInfo.RequestURL__c = ext.Request_URL__c;
    //         logInfo.ClassName__c = 'Controller_SAP4ProjectStatusUpdate';

    //         if(String.isBlank(opp.ProjectNumber__c)){
    //             logInfo.IsSuccess__c = false;
    //             logInfo.ErrorMessage__c = '项目编号为空！！！'; 
    //             insert logInfo;
    //             return;
    //         }

    //         if (opp.StageName == '线索管理') {
    //             reqBody.i_posid = opp.ProjectNumber__c + '-0000.A1' ;     //WBS
    //             reqBody.i_status2 = 'REL' ; //设置系统状态
    //         }else if (opp.StageName == '商机管理') {
    //             reqBody.i_posid = opp.ProjectNumber__c + '-0000.A1' ;     //WBS
    //             reqBody.i_status2 = 'REL' ; //设置系统状态
    //         }else if (opp.StageName == '项目立项') {
    //             reqBody.i_posid = opp.ProjectNumber__c + '-0000.A2' ;     //WBS
    //             reqBody.i_status2 = 'REL' ; //设置系统状态
    //         }else if (opp.StageName == '招投标') {
    //             reqBody.i_posid = opp.ProjectNumber__c + '-0000.A3' ;     //WBS
    //             reqBody.i_status2 = 'REL' ; //设置系统状态
    //         }else if (opp.StageName == '中标/赢单') {
                
    //         }else if (opp.StageName == '合同商务') {
    //             reqBody.i_posid = opp.ProjectNumber__c ;     //WBS
    //             reqBody.i_status2 = 'REL' ; //设置系统状态
    //         }else if (opp.StageName == 'Closed Won') {
                
    //         }else {
    //             // return;
    //         }

    //         System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

    //         String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAP4ProjectStatusUpdate',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        
    //         System.debug('调用成功，response响应结果--->>>>>'+response);

    //         logInfo.RequestBody__c = JSON.serialize(reqBody);

    //         if(response.substring(0,5) == 'Error'){
    //             // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
    //             // update opp;
    //             logInfo.RespondBody__c = response;
    //             insert logInfo;
    //             return ;
    //         }else{
    //             ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

    //             logInfo.RespondBody__c = response;
    //             if (resBody.code == 200) {
    //                 System.debug('resBody.data---'+resBody.data);  //返回data

    //                 if (resBody.data==null || resBody.data.size()==0) {
    //                     logInfo.IsSuccess__c = false;
    //                     logInfo.ErrorMessage__c = '返回数据为空';
    //                     System.debug('resBody.data===》》'+resBody.data);
    //                     // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
    //                     // update opp;
    //                     // insert logInfo ; 
    //                     return ; 
    //                 }

    //                 System.debug('resBody.message========>>>>'+resBody.message);
    //                 logInfo.IsSuccess__c = true; 

    //                 Data rd = resBody.data[0];

    //                 // opp.ProjectNumber__c = rd.pspid  ;   //项目编号
    //                 // opp.Is_Sap_Proj_Status__c = '1';//更新SAP项目创建状态

    //                 // update opp ; 
    //                 System.debug('更新SAP项目状态完成');

    //             }else{
    //                 logInfo.IsSuccess__c = false;
    //                 logInfo.ErrorMessage__c = resBody.message; 
                    
    //                 // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
    //                 // update opp ; 
    //             }
    //             insert logInfo ; 


    //         }

    //     }catch(Exception e){
    //         System.debug(e.getMessage());
    //         String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
    //         System.debug('error---msg'+msg);
    //     }

    // }

   //修改项目用户状态
   @future (callout=true)
   global static Void SAP4ProjectStatusUpdate2(String recordId){

       Opportunity opp = [SELECT Id, Name, ProjectNumber__c, Is_Sap_Proj_Status__c, StageName, Close__c FROM Opportunity Where Id = : recordId] ; 

       Interface_Log__c logInfo = new Interface_Log__c();

       RequestBody3 reqBody = new RequestBody3();  

       External_System_Param__c ext = External_System_Param__c.getValues('sapProjectStatus');

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAP4ProjectStatusUpdate2';

            //先判断商机是否关闭，再判断商机阶段变更
            if (opp.Close__c == true) {
                reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                reqBody.i_status4 = '商机关闭' ; //设置用户状态
            }else {
                if (opp.StageName == '线索管理') {
                    return;
                }else if (opp.StageName == '商机管理') {
                    reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                    reqBody.i_status4 = '商机'; //设置用户状态 
                }else if (opp.StageName == '项目立项') {
                    reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                    reqBody.i_status4 = '项目立项'; //设置用户状态 
                }else if (opp.StageName == '招投标') {
                    reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                    reqBody.i_status4 = '招投标' ; //设置用户状态
                }else if (opp.StageName == '中标/赢单') {
                    reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                    reqBody.i_status4 = '中标' ; //设置用户状态
                }else if (opp.StageName == '合同商务') {
                    reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                    reqBody.i_status4 = '合同商务' ; //设置用户状态
                }else if (opp.StageName == 'Closed Won') {
                    reqBody.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                    reqBody.i_status4 = '合同签订' ; //设置用户状态
                }else {
                    return;
                }
            }

            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAP4ProjectStatusUpdate',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        
            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if(response.substring(0,5) == 'Error'){
                // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                // update opp;
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回data

                    if (resBody.data==null || resBody.data.size()==0) {
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '返回数据为空';
                        System.debug('resBody.data===》》'+resBody.data);
                        // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                        // update opp;
                        insert logInfo ; 
                        return ; 
                    }

                    System.debug('resBody.message========>>>>'+resBody.message);
                    logInfo.IsSuccess__c = true; 

                    Data rd = resBody.data[0];

                    // opp.ProjectNumber__c = rd.pspid  ;   //项目编号
                    // opp.Is_Sap_Proj_Status__c = '1';//更新SAP项目创建状态

                    // update opp ; 
                    System.debug('更新SAP项目状态完成');

                }else{
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                    
                    // opp.Is_Sap_Proj_Status__c = '2';//更新SAP项目创建状态
                    // update opp ; 
                }
                insert logInfo ; 


            }

        }catch(Exception e){
            System.debug(e.getMessage());
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
        }
    }

   //修改SAP项目名称,同时变更阶段和下达状态
   @future (callout=true)
   global static Void SAP4ProjectNameUpdateAndUpStatus(String recordId){

       String response1;
       String response2;
       String response3;

       RequestBody2 reqBody_p = new RequestBody2();  
       RequestBody3 reqBody_s = new RequestBody3(); 
       RequestBody3 reqBody_s2 = new RequestBody3();
       try {

        External_System_Param__c ext1 = External_System_Param__c.getValues('sapProjectModify');
        External_System_Param__c ext2 = External_System_Param__c.getValues('sapProjectStatus');
        
        Opportunity opp = [SELECT Id, Name, ProjectNumber__c, Is_Sap_Proj_Status__c, StageName, Close__c FROM Opportunity Where Id = : recordId] ; 
        
        List<Contractmanagement__c> listContract = [SELECT Objectname2__c,WBS__c FROM Contractmanagement__c WHERE ObjectName__c =: recordId];
        if (listContract.size() > 0) {
            //更新商机下所有合同的sap项目名称和商机名称
            for(Contractmanagement__c newContract : listContract) {
                reqBody_p.i_post1 = newContract.Objectname2__c ;     //项目名称
                reqBody_p.i_pspid = newContract.WBS__c ; //项目定义
                reqBody_p.i_zpost1 = opp.Name; //商机名称
                reqBody_p.i_zproj = newContract.Objectname2__c; //项目全称
                response1 = Utils.callOut2(JSON.serialize(reqBody_p),ext1.Request_URL__c,'Controller_SAP4ProjectNameUpdate',ext1.Request_Source__c,ext1.Request_Method__c,ext1.Request_Key__c,ext1.Initialization_Vector__c);
            }
        }else {
            //还未生成主合同，根据商机wbs更新sap项目名称和商机名称
            reqBody_p.i_post1 = opp.Name ;     //项目名称
            reqBody_p.i_pspid = opp.ProjectNumber__c ; //项目定义
            reqBody_p.i_zpost1 = opp.Name; //商机名称
            reqBody_p.i_zproj = opp.Name; //项目全称
            response1 = Utils.callOut2(JSON.serialize(reqBody_p),ext1.Request_URL__c,'Controller_SAP4ProjectNameUpdate',ext1.Request_Source__c,ext1.Request_Method__c,ext1.Request_Key__c,ext1.Initialization_Vector__c);
        }

   
            if(String.isNotBlank(opp.ProjectNumber__c)){
               if (opp.StageName == '线索管理') {
                   reqBody_s.i_posid = opp.ProjectNumber__c + '-0000.A1' ;     //WBS
                   reqBody_s.i_status2 = 'REL' ; //设置系统状态
               }else if (opp.StageName == '商机管理') {
                   reqBody_s.i_posid = opp.ProjectNumber__c + '-0000.A1' ;     //WBS
                   reqBody_s.i_status2 = 'REL' ; //设置系统状态
               }else if (opp.StageName == '项目立项') {
                   reqBody_s.i_posid = opp.ProjectNumber__c + '-0000.A2' ;     //WBS
                   reqBody_s.i_status2 = 'REL' ; //设置系统状态
               }else if (opp.StageName == '招投标') {
                   reqBody_s.i_posid = opp.ProjectNumber__c + '-0000.A3' ;     //WBS
                   reqBody_s.i_status2 = 'REL' ; //设置系统状态
               }else if (opp.StageName == '中标/赢单') {
                   
               }else if (opp.StageName == '合同商务') {
                   reqBody_s.i_posid = opp.ProjectNumber__c ;     //WBS
                   reqBody_s.i_status2 = 'REL' ; //设置系统状态
               }else if (opp.StageName == 'Closed Won') {
                   
               }else {
                   // return;
               }
   
               System.debug('JSON.serialize(reqBody_s)---'+JSON.serialize(reqBody_s));
   
               if (string.isNotBlank(reqBody_s.i_posid) && String.isNotBlank(reqBody_s.i_status2)) {
                    response2 = Utils.callOut2(JSON.serialize(reqBody_s),ext2.Request_URL__c,'Controller_SAP4ProjectStatusUpdate',ext2.Request_Source__c,ext2.Request_Method__c,ext2.Request_Key__c,ext2.Initialization_Vector__c);
                }
            }


                 //先判断商机是否关闭，再判断商机阶段变更
                 if (opp.Close__c == true) {
                     reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                     reqBody_s2.i_status4 = '商机关闭' ; //设置用户状态
                 }else {
                     if (opp.StageName == '线索管理') {
                         return;
                     }else if (opp.StageName == '商机管理') {
                        reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                        reqBody_s2.i_status4 = '商机'; //设置用户状态 
                     }else if (opp.StageName == '项目立项') {
                        reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                        reqBody_s2.i_status4 = '项目立项'; //设置用户状态 
                     }else if (opp.StageName == '招投标') {
                        reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                        reqBody_s2.i_status4 = '招投标' ; //设置用户状态
                     }else if (opp.StageName == '中标/赢单') {
                        reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                        reqBody_s2.i_status4 = '中标' ; //设置用户状态
                     }else if (opp.StageName == '合同商务') {
                        reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                        reqBody_s2.i_status4 = '合同商务' ; //设置用户状态
                     }else if (opp.StageName == 'Closed Won') {
                        reqBody_s2.i_posid = opp.ProjectNumber__c + '-0000.A' ;     //WBS
                        reqBody_s2.i_status4 = '合同签订' ; //设置用户状态
                     }else {
                        //  return;
                     }
                 }
     
                 System.debug('JSON.serialize(reqBody_s2)---'+JSON.serialize(reqBody_s2));
     
                 if (String.isNotBlank(reqBody_s2.i_status4)) {
                    response3 = Utils.callOut2(JSON.serialize(reqBody_s2),ext2.Request_URL__c,'Controller_SAP4ProjectStatusUpdate',ext2.Request_Source__c,ext2.Request_Method__c,ext2.Request_Key__c,ext2.Initialization_Vector__c);
                }

                Interface_Log__c logInfo1 = new Interface_Log__c();  
                logInfo1.RequestURL__c = ext1.Request_URL__c;
                logInfo1.ClassName__c = 'Controller_SAP4ProjectNameUpdate';
                logInfo1.RequestBody__c = JSON.serialize(reqBody_p);
                logInfo1.RespondBody__c = response1;
                insert logInfo1;

                Interface_Log__c logInfo2 = new Interface_Log__c();  
                logInfo2.RequestURL__c = ext2.Request_URL__c;
                logInfo2.ClassName__c = 'Controller_SAP4ProjectStatusUpdate';
                logInfo2.RequestBody__c = JSON.serialize(reqBody_s);
                logInfo2.RespondBody__c = response2;
                insert logInfo2;  

                Interface_Log__c logInfo3 = new Interface_Log__c();
                logInfo3.RequestURL__c = ext2.Request_URL__c;
                logInfo3.ClassName__c = 'Controller_SAP4ProjectStatusUpdate2';
                logInfo3.RequestBody__c = JSON.serialize(reqBody_s2);
                logInfo3.RespondBody__c = response3;
                insert logInfo3; 

       }catch(Exception e){
           System.debug(e.getMessage());
           String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
           Interface_Log__c logInfo = new Interface_Log__c();  
           logInfo.ClassName__c = 'SAP4ProjectNameUpdateAndUpStatus';
           logInfo.IsSuccess__c = false;
           logInfo.ErrorMessage__c = msg; 
           insert logInfo;  
           System.debug('error---msg'+msg);
       }

   }

    public class RequestBody {
        // public Integer pfrom{get;set;} //起始号
        // public String plfaz{get;set;} //项目计划开始日期
        // public String plsez{get;set;} //项目计划完成日期
        // public Integer pnum{get;set;} //风机台数,示例值(1)
        public String post1{get;set;} //项目名称描述,示例值(S1-20210020)
        public String prart{get;set;} //项目类型,示例值(S1)
        public String pspid{get;set;} //标准项目,示例值(L1-20120000)	
        public Integer pyear{get;set;} //项目年度,示例值(2021)
        public String province_id{get;set;} //省份
        public String zpost1{get;set;} //商机名称
        public String zpost1_id{get;set;} //商机ID
        public String zproj{get;set;} //项目全称
    }

    public class RequestBody2 {
        public String i_post1{get;set;} //项目名称
        public String i_pspid{get;set;} //项目定义
        public String i_zpost1{get;set;} //商机名称
        public String i_zproj{get;set;} //项目全称
    }

    public class RequestBody3 {
        public String i_posid{get;set;} //WBS
        // public String i_status1{get;set;} //设置系统状态
        public String i_status2{get;set;} //重设系统状态
        // public String i_status3{get;set;} //设置用户状态
        public String i_status4{get;set;} //重设用户状态
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String message{get;set;}  //提示信息
        // public String obj{get;set;}     //出错阶段
        // public String post1{get;set;}   //项目描述
        public String pspid{get;set;} //项目定义
        public String type{get;set;}  //消息类型(S 成功,E 错误,W 警告 I信息 A 中断)
    } 
}