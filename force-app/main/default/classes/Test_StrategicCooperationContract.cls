/**
     * @description: 战略合作协议/合同审批单 测试类 create by hogan
     * @date: 2022-7-19
     * @param  {*}
     * @return {*}
     */  
@isTest
public with sharing class Test_StrategicCooperationContract {
    static testMethod void testProprietorRequireReview(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaStrategicCooperationContractAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaStrategicCooperationContractAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

        OpenPlatformApi__c open = new OpenPlatformApi__c();
        open.Name = 'GetToken';
        open.Client_Id__c = 'aHI6XXcIxmO5CVfXkPE80sPA';
        open.Client_Secret__c = 'vSaQLaO7Bhp5jK0CGgkoJO4NpO41b4ZZ';
        open.Grant_Type__c = 'client_credentials';
        open.IP__c = 'http://61.142.78.5:8011';
        open.URL__c = 'http://61.142.78.5:8011/admin/oauth/token';
        insert open;

        Account acc = new Account();
        acc.name = 'aaa';
        acc.parentId = null ; 
        acc.BeenGroup__c = true ; 
        insert acc ; 

        StrategicCooperationContract__c rc = new StrategicCooperationContract__c();
        rc.Name = 'aaa';
        rc.Introduction__c = 'bbb';
        rc.Sign_Type__c = '客户';
        rc.Sign_Unit_Account__c = acc.Id;
        rc.Is_Apply_Seal__c = false;
        rc.Approvalstatus__c = '11';
        rc.Process_Id__c = null ;
        insert rc ; 

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Strategic_Cooperation_Contract__c = rc.id ; 
        insert sc ; 
        

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        
        Integrated_Middle_Table__c ic = new Integrated_Middle_Table__c();
        ic.Mapping_Object_Id__c = rc.id;
        ic.RecordTypeId = imtRecordType.id;
        insert ic;

        

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new ProprietorRequireReview_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        ControllerStrategicCooperationContract.toCreateStrategicCooperationContract(rc.id);
        System.Test.stopTest();

    }

    static testMethod void testProprietorRequireReview1(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaStrategicCooperationContractAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaStrategicCooperationContractAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

        ResourceAccount__c acc = new ResourceAccount__c();
        acc.name = 'aaa';
        acc.ResourceAccountType__c = '政府'; 
        insert acc ; 

        StrategicCooperationContract__c rc = new StrategicCooperationContract__c();
        rc.Name = 'aaa';
        rc.Introduction__c = 'bbb';
        rc.Sign_Type__c = '资源客户';
        rc.Sign_Unit_Res_Acc__c = acc.Id;
        rc.Is_Apply_Seal__c = true;
        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '青海基地';
        rc.Approvalstatus__c = '11';
        rc.Process_Id__c = null ;
        insert rc ; 

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Strategic_Cooperation_Contract__c = rc.id ; 
        insert sc ; 
        

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        
        Integrated_Middle_Table__c ic = new Integrated_Middle_Table__c();
        ic.Mapping_Object_Id__c = rc.id;
        ic.RecordTypeId = imtRecordType.id;
        insert ic;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new ProprietorRequireReview_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        ControllerStrategicCooperationContract.toCreateStrategicCooperationContract(rc.id);
        System.Test.stopTest();

    }

    class ProprietorRequireReview_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17d04b3b98d9e690c169b1947e398e78","docSubject": "检测前沿开发组_何建斌_营销资源开发协议/合同审批单_2021-11-09_MS-FZYXYHQ-20211109002","fdNumber": "MS-FZYXYHQ-20211109002","Data": null,"data": null}}');
			return response;
		}
	}

    //模拟锁定记录、解锁记录
    static testMethod void testLockOrUnlock(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaStrategicCooperationContractAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaStrategicCooperationContractAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

        ResourceAccount__c acc = new ResourceAccount__c();
        acc.name = 'aaa';
        acc.ResourceAccountType__c = '政府'; 
        insert acc ; 

        StrategicCooperationContract__c rc = new StrategicCooperationContract__c();
        rc.Name = 'aaa';
        rc.Introduction__c = 'bbb';
        rc.Sign_Type__c = '资源客户';
        rc.Sign_Unit_Res_Acc__c = acc.Id;
        rc.Is_Apply_Seal__c = true;
        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '青海基地';
        rc.Approvalstatus__c = '20';
        rc.Process_Id__c = '181ffead57c43260e551d8f42218a176' ;
        insert rc ; 

        // Seal_Related_Information__c sc = new Seal_Related_Information__c();
        // sc.Document_Category__c = '1';
        // sc.Document_Name__c = '111';
        // sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        // sc.Seal_Type__c = '公章';
        // sc.Seal_Numble__c = '11';
        // sc.Strategic_Cooperation_Contract__c = rc.id ; 
        // insert sc ; 
        

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        
        Integrated_Middle_Table__c ic = new Integrated_Middle_Table__c();
        ic.Mapping_Object_Id__c = rc.id;
        ic.RecordTypeId = imtRecordType.id;
        ic.Process_Id__c = '181ffead57c43260e551d8f42218a176';
        ic.Approvalstatus__c = '20'; //驳回状态
        insert ic;

        System.Test.startTest();
        StrategicCooperationContract__c updateStr = [select Id,Approvalstatus__c from StrategicCooperationContract__c where Id =: rc.Id];
        updateStr.Approvalstatus__c = '11';
        update updateStr;
        System.test.setMock(HttpCalloutMock.class,new TestLockOrUnlock_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        // ControllerStrategicCooperationContract.toCreateStrategicCooperationContract(rc.id);
        System.Test.stopTest();

    }

    //模拟锁定记录、解锁记录
    class TestLockOrUnlock_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":200,"message":"CRM调用oa审批记录接口成功！","data":[{"processId":"181ffead57c43260e551d8f42218a176","nodeId":"181ffead7164ffafa7441fd4804a1a9d","parentId":null,"createTime":"2022-07-15 11:34:55","nodeName":"流程启动通道","handlerId":null,"actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%CRM","actionNote":null,"docStatus":"11","childId":"","crmFileUploadType":"N"},{"processId":"181ffead57c43260e551d8f42218a176","nodeId":"181ffead6829be5ef11b7404b47862fb","parentId":null,"createTime":"2022-07-15 11:34:54","nodeName":"起草节点","handlerId":"A07280","actionInfo":"sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote":null,"docStatus":"11","childId":"","crmFileUploadType":"N"}]}');
			return response;
		}
	}
}