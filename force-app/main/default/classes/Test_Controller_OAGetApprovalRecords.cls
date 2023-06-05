@istest
public with sharing class Test_Controller_OAGetApprovalRecords { 

    @TestSetup
    static void makeData(){
        InterfaceParam__c ic = new InterfaceParam__c();
        ic.name ='OAApprovalRecords';
        ic.SyncDate__c = Datetime.now().date();
        insert ic;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
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

        Opportunity oppUpdate = new Opportunity();
        oppUpdate.Name = 'ccc';
        oppUpdate.StageName = '线索管理';
        oppUpdate.CloseDate = System.today();
        insert oppUpdate;
        
        String psafid = Schema.SObjectType.Project_Scheme_Application_Form__c.getRecordTypeInfosByDeveloperName().get('Roadsurvey').getRecordTypeId();
        Project_Scheme_Application_Form__c psaf = new Project_Scheme_Application_Form__c();
        psaf.RecordTypeId = psafid;
        psaf.Schemetype__c = '微观选址';
        psaf.Process_Id__c = 'test';
        // psaf.Oppty__c = oppUpdate.Id;
        psaf.Technicalscheme__c = '是';
        psaf.Address__c = '北极';
        psaf.BeginDate__c =  System.today();
        psaf.EndDate__c = Date.newInstance(2021, 12, 8);
        // psaf.EndDate__c =  System.today();
        insert psaf;

        List<Utils.PickListValue> picklist = Utils.getPickListValue('Project_Scheme_Application_Form__c','Schemetype__c');

        // Project_Scheme_Application_Form__c psafff = new Project_Scheme_Application_Form__c();
        // psafff.RecordTypeId = psafid;
        // psafff.Schemetype__c = '投标项目(整体解决方案)';
        // psafff.Process_Id__c = 'testtt';
        // psafff.Oppty__c = oppUpdate.Id;
        // psafff.Technicalscheme__c = '是';
        // psafff.Address__c = '北极';
        // psafff.BeginDate__c =  System.today();
        // psafff.EndDate__c = Date.newInstance(2021, 12, 8);
        // // psaf.EndDate__c =  System.today();
        // insert psafff;


        //------
        Resource_Project_Scheme_Application__c rrr = new Resource_Project_Scheme_Application__c();
        rrr.Wind_Farm_Project_Name__c = 'aaaa';
       // rrr.Require_Type__c = '设备运输道路踏勘';
        insert rrr ; 

        String psafid1 = Schema.SObjectType.Project_Scheme_Application_Form__c.getRecordTypeInfosByDeveloperName().get('Roadsurvey').getRecordTypeId();
        Project_Scheme_Application_Form__c psaf1 = new Project_Scheme_Application_Form__c();
        psaf1.RecordTypeId = psafid1;
        psaf1.Schemetype__c = '安全性复核';
        psaf1.Process_Id__c = 'test';
        // psaf1.Oppty__c = oppUpdate.Id;
        psaf1.Technicalscheme__c = '是';
        psaf1.Address__c = '北极';
        psaf1.BeginDate__c =  System.today();
        psaf1.EndDate__c = Date.newInstance(2021, 12, 8);
        // psaf.EndDate__c =  System.today();
        insert psaf1;


        String psafid2 = Schema.SObjectType.Project_Scheme_Application_Form__c.getRecordTypeInfosByDeveloperName().get('Roadsurvey').getRecordTypeId();
        Project_Scheme_Application_Form__c psaf2 = new Project_Scheme_Application_Form__c();
        psaf2.RecordTypeId = psafid2;
        psaf2.RoadSurveyType__c = '投标项目方案路堪';
        psaf2.Process_Id__c = 'test2';
        // psaf2.Oppty__c = oppUpdate.Id;
        psaf2.Technicalscheme__c = '是';
        psaf2.Address__c = '北极';
        psaf2.BeginDate__c =  System.today();
        psaf2.EndDate__c = Date.newInstance(2021, 12, 8);
        psaf2.Demandtype__c = '项目技术方案';
        // psaf.EndDate__c =  System.today();
        insert psaf2;



        //===
        String recTypeIddd = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c docMappp = new Integrated_Middle_Table__c();
        docMappp.RecordTypeId = recTypeIddd;
        // midTable.Process_Id__c = '012p0000000INTHAA4';
        docMappp.Process_Id__c = 'testtt';
        docMappp.Approvalstatus__c = '30';
        docMappp.Object_API__c = 'Resource_Project_Scheme_Application__c';
        docMappp.Mapping_Object_Id__c = rrr.Id;
        docMappp.Approval_Parent_Id__c = oppUpdate.Id;
        //docMappp.Scheme_Type__c = '投标项目方案路堪';
        docMappp.Require_Type__c = '设备运输道路踏勘';
        insert docMappp;

        
        String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c docMap = new Integrated_Middle_Table__c();
        docMap.RecordTypeId = recTypeId;
        // midTable.Process_Id__c = '012p0000000INTHAA4';
        docMap.Process_Id__c = 'test';
        docMap.Approvalstatus__c = '20';
        docMap.Object_API__c = 'Project_Scheme_Application_Form__c';
        docMap.Mapping_Object_Id__c = psaf.Id;
        docMap.Approval_Parent_Id__c = oppUpdate.Id;
        docMap.Scheme_Type__c = '微观选址';
        insert docMap;

        String recTypeId1 = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c docMap1 = new Integrated_Middle_Table__c();
        docMap1.RecordTypeId = recTypeId;
        // midTable.Process_Id__c = '012p0000000INTHAA4';
        docMap1.Process_Id__c = 'test1';
        docMap1.Approvalstatus__c = '20';
        docMap1.Object_API__c = 'Project_Scheme_Application_Form__c';
        docMap1.Mapping_Object_Id__c = psaf1.Id;
        docMap1.Approval_Parent_Id__c = oppUpdate.Id;
        docMap1.Scheme_Type__c = '安全性复核';
        insert docMap1;

        String recTypeId2 = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c docMap2 = new Integrated_Middle_Table__c();
        docMap2.RecordTypeId = recTypeId2;
        // midTable.Process_Id__c = '012p0000000INTHAA4';
        docMap2.Process_Id__c = 'test2';
        docMap2.Approvalstatus__c = '20';
        docMap2.Object_API__c = 'Project_Scheme_Application_Form__c';
        docMap2.Mapping_Object_Id__c = psaf2.Id;
        docMap2.Approval_Parent_Id__c = oppUpdate.Id;
        docMap2.Scheme_Type__c = '投标项目方案路堪';
        insert docMap2;

        //合同商务
        oppUpdate.StageName = '招投标';
        update oppUpdate;
        Contractmanagement__c contractUpdate = new Contractmanagement__c();
        contractUpdate.Process_Id__c = 'commercialContract';
        contractUpdate.ObjectName__c = oppUpdate.Id ; 
        insert contractUpdate;

        String htsw = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c htswtb = new Integrated_Middle_Table__c();
        htswtb.RecordTypeId = recTypeId2;
        htswtb.Process_Id__c = 'commercialContract';
        htswtb.Approvalstatus__c = '20';
        htswtb.Object_API__c = 'Contractmanagement__c';
        htswtb.Mapping_Object_Id__c = contractUpdate.Id;
        htswtb.Approval_Parent_Id__c = oppUpdate.Id;
        htswtb.Scheme_Type__c = '投标项目方案路堪';
        insert htswtb;

        //营销合同补充协议
        ContractSupplement__c contractSupplement = new ContractSupplement__c();
        contractSupplement.Process_Id__c = '1816b9b6a1501244b90e09448edb24b8';
        insert contractSupplement;

        String recTypeId3 = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        
        Integrated_Middle_Table__c imtContractSup = new Integrated_Middle_Table__c();
        imtContractSup.RecordTypeId = recTypeId3;
        imtContractSup.Process_Id__c = '1816b9b6a1501244b90e09448edb24b8';
        imtContractSup.Approvalstatus__c = '20';
        imtContractSup.Object_API__c = 'ContractSupplement__c';
        imtContractSup.Mapping_Object_Id__c = contractSupplement.Id;
        imtContractSup.Scheme_Type__c = '营销合同补充协议';
        insert imtContractSup;
        
        Resource_Development__c resDevUpdate = new Resource_Development__c();
        resDevUpdate.Name = '测试';
        insert resDevUpdate;

        ResourceProjectApplication__c reso = new ResourceProjectApplication__c();
        reso.Process_Id__c = 'test3';
        reso.ResourceName__c = resDevUpdate.Id;
        insert reso;

        String resourceDevelopment  = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c resourceDevelopmentTab = new Integrated_Middle_Table__c();
        resourceDevelopmentTab.RecordTypeId = resourceDevelopment;
        resourceDevelopmentTab.Process_Id__c = 'test3';
        resourceDevelopmentTab.Approvalstatus__c = '20';
        resourceDevelopmentTab.Object_API__c = 'ResourceProjectApplication__c';
        resourceDevelopmentTab.Mapping_Object_Id__c = reso.Id;
        resourceDevelopmentTab.Approval_Parent_Id__c = resDevUpdate.Id;
        resourceDevelopmentTab.Scheme_Type__c = '投标项目方案路堪';
      
        insert resourceDevelopmentTab;

        //战略数据
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
        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        Integrated_Middle_Table__c imt = new Integrated_Middle_Table__c();
        imt.Mapping_Object_Id__c = rc.id;
        imt.RecordTypeId = imtRecordType.id;
        imt.Process_Id__c = '181ffead57c43260e551d8f42218a176';
        imt.Approvalstatus__c = '20'; //驳回状态
        imt.Object_API__c = 'StrategicCooperationContract__c';
        insert imt;

        Controller_OAGetApprovalRecords.Data da = new Controller_OAGetApprovalRecords.Data();
        da.processId  = '1';     
        // da.nodeId     = '2';     
        // da.parentId   = '3';     
        da.createTime = '4';     
        da.nodeName   = '5';     
        // da.handlerId  = '6';     
        // da.actionInfo = '7';     
        // da.actionNote = '8';     
        da.docStatus  = '9';     
        da.childId    = '10'; 
   
    }   

    static testMethod void testOAGetApprovalRecords(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }

    static testMethod void testOAGetApprovalRecords888(){

        Project_Scheme_Application_Form__c psaf1 = [select id from Project_Scheme_Application_Form__c where Schemetype__c = '安全性复核'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock1());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }

    static testMethod void testOAGetApprovalRecords2(){

        Project_Scheme_Application_Form__c psaf1 = [select id from Project_Scheme_Application_Form__c where Schemetype__c = '安全性复核'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }


    static testMethod void testOAGetApprovalRecords3(){

        Project_Scheme_Application_Form__c psaf1 = [select id from Project_Scheme_Application_Form__c where Schemetype__c = '微观选址'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }

    static testMethod void testOAGetApprovalRecords4(){

        Contractmanagement__c psaf1 = [select id from Contractmanagement__c  where Process_Id__c = 'commercialContract'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }


    static testMethod void testOAGetApprovalRecords5(){

        Resource_Project_Scheme_Application__c psaf1 = [select id from Resource_Project_Scheme_Application__c  where Wind_Farm_Project_Name__c = 'aaaa'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }

    static testMethod void testOAGetApprovalRecords6(){

        ResourceProjectApplication__c psaf1 = [select id from ResourceProjectApplication__c  where Process_Id__c = 'test3'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }



    static testMethod void testOAGetApprovalRecords7(){


        ResourceProjectApplication__c psaf1 = [select id from ResourceProjectApplication__c  where Process_Id__c = 'test3'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock20());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }

    // 测试方法 战略合作协议/合同审批单
    static testMethod void testOAGetApprovalRecords_Stra(){
        StrategicCooperationContract__c str = [select id from StrategicCooperationContract__c  where Process_Id__c = '181ffead57c43260e551d8f42218a176'];
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock_Stra());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(str.id);
        System.Test.stopTest();
    }

    class OAGetApprovalRecords_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "CRM调用oa审批记录接口成功！","data": [{"processId": "test","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"},{"processId": "test1","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"},{"processId": "test2","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"},{"processId": "commercialContract","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"},{"processId": "test3","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"}]}');
			return response;
		}

	}

    class OAGetApprovalRecords_Mock20 implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "CRM调用oa审批记录接口成功！","data": [{"processId": "test","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20"},{"processId": "test1","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20"},{"processId": "test2","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20"},{"processId": "commercialContract","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20"},{"processId": "test4","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20"}]}');
			return response;
		}

	}

//mock战略
class OAGetApprovalRecords_Mock_Stra implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest param1) {
        HttpResponse response=new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"code":200,"message":"CRM调用oa审批记录接口成功！","data":[{"processId":"181ffead57c43260e551d8f42218a176","nodeId":"181ffead7164ffafa7441fd4804a1a9d","parentId":null,"createTime":"2022-07-15 11:34:55","nodeName":"流程启动通道","handlerId":null,"actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%CRM","actionNote":null,"docStatus":"11","childId":"","crmFileUploadType":"N"},{"processId":"181ffead57c43260e551d8f42218a176","nodeId":"181ffead6829be5ef11b7404b47862fb","parentId":null,"createTime":"2022-07-15 11:34:54","nodeName":"起草节点","handlerId":"A07280","actionInfo":"sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote":null,"docStatus":"11","childId":"182345da0df518a5405253042cdaa814","crmFileUploadType":"N"}]}');
        return response;
    }
}
    
    static testMethod void testOAGetApprovalRecords1(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock1());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }

    static testMethod void testSchedule_OAGetApprovalRecords(){

        System.Test.startTest();
        System.schedule('每天晚上11点调用','0 0 11 * * ?',new Schedule_OAGetApprovalRecords());
        System.Test.stopTest();
    }

    static testMethod void newTestFile1(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }
    class OAGetApprovalRecords_Mock1 implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": "8888","message": "CRM调用oa审批记录接口成功！","data": [{"processId": "test","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"},{"processId": "test1","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30"}]}');
			return response;
		}

	}

    class OAGetApprovalRecords_Mock2 implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "CRM调用oa审批记录接口成功！","data": [{"processId": "test","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20","crmFileUploadType": "Y"},{"processId": "test1","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "20","crmFileUploadType": "Y"},{"processId": "test1","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": "1111","createTime": "2021-10-12 08:24:49","nodeName": "结束节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "11","crmFileUploadType": "Y"}]}');
			return response;
		}

	}

    //测试营销合同补充协议
    static testMethod void newTestFile3(){
        ContractSupplement__c psaf1 = [select id from ContractSupplement__c  where Process_Id__c = '1816b9b6a1501244b90e09448edb24b8'];
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock3());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.callGetApprovalRecords(psaf1.id);
        System.Test.stopTest();
    }

    class OAGetApprovalRecords_Mock3 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":200,"message":"CRM调用oa审批记录接口成功！","path":"","data":[{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1823332baadea1fa8e90a0f4a83adc40","parentId":"","createTime":"2022-07-25 10:32:17","nodeName":"结束节点","handlerId":"","actionInfo":"sys-lbpm-engine:lbpmOperations.fdOperType.system.processend","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1823332ba9c2455e04418d4492aaf616","parentId":"","createTime":"2022-07-25 10:32:17","nodeName":"启动归档子流程","handlerId":"","actionInfo":"sys-lbpmservice:lbpmNode.opInfo.subprocess.start.process%%1","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1823332b9d8d25f224d798b4d3680f35","parentId":"","createTime":"2022-07-25 10:32:17","nodeName":"启动子流程节点","handlerId":"","actionInfo":"sys-lbpmservice:lbpmNode.opInfo.subprocess.start.process%%1","actionNote":"","docStatus":"30","childId":"1823332b9288b70733dc255448288e92","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1823332b8994c92c237b81c49499c684","parentId":"","createTime":"2022-07-25 10:32:16","nodeName":"国别判断","handlerId":"","actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%其它","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1823332b883c76e2c178085410082b2a","parentId":"","createTime":"2022-07-25 10:32:16","nodeName":"是否申请盖章","handlerId":"","actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%是","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1823332846d7dbb0f44cdf84908bd4e8","parentId":"","createTime":"2022-07-25 10:32:16","nodeName":"董事长审核","handlerId":"A03260","actionInfo":"通过","actionNote":"同意","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"182239c835c15e1b02d355d451f8ff41","parentId":"","createTime":"2022-07-22 09:53:54","nodeName":"董事长审核","handlerId":"","actionInfo":"sys-lbpmservice:lbpmNode.opInfo.authorize.handle%%张传卫##陈爽","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"182239c14ef94d1e947a24948abb054e","parentId":"","createTime":"2022-07-22 09:53:54","nodeName":"执行总裁","handlerId":"A01901","actionInfo":"通过","actionNote":"同意","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"181ad9ac927ca940b7f7a95413fb8298","parentId":"","createTime":"2022-06-29 11:58:23","nodeName":"运营中心执行主任审核","handlerId":"A00330","actionInfo":"通过","actionNote":"同意","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"181ad70ae10eb02df5a730e434785f96","parentId":"","createTime":"2022-06-29 11:12:42","nodeName":"首席财务官审核","handlerId":"A00495","actionInfo":"通过","actionNote":"同意","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"181a47ded044edbae5867574e64b94b3","parentId":"","createTime":"2022-06-27 17:30:44","nodeName":"首席财务官审核","handlerId":"A01699","actionInfo":"转办: 任劲文","actionNote":"请审核！","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"181a47ceffc371e977364a846828960e","parentId":"","createTime":"2022-06-27 17:27:40","nodeName":"结束并行分支","handlerId":"","actionInfo":"lbpmOperations.fdOperType.system.branchjoinInfo%%N30.法务部审核, 国内项目, N28.合同商务部总监审核, N35.国别判断, N31.项目管理部审核","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"181a47c8cfc602bd66c034b45319986e","parentId":"","createTime":"2022-06-27 17:27:39","nodeName":"合同商务部总监审核","handlerId":"A03113","actionInfo":"通过","actionNote":"同意","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"18170a18e018943177f82254deca35b3","parentId":"","createTime":"2022-06-17 15:47:24","nodeName":"合同商务部部长审核","handlerId":"A00503","actionInfo":"sys-lbpmservice-operation-admin:lbpmOperations.fdOperType.processor.modifyflow","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816ba22702dda02ff17ab849eaaad98","parentId":"","createTime":"2022-06-16 16:30:02","nodeName":"CRM附件上传节点","handlerId":"S00476","actionInfo":"通过","actionNote":"同意","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816ba2111ed40e9ddb304c4a5981fcb","parentId":"","createTime":"2022-06-16 16:29:52","nodeName":"单据国别判断","handlerId":"","actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%国内项目","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816ba210f588a3921c1e054bcd90ca5","parentId":"","createTime":"2022-06-16 16:29:52","nodeName":"判断表单是否由crm发起","handlerId":"","actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%是","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816b9bba023b5f1bec49784449b4044","parentId":"","createTime":"2022-06-16 16:29:51","nodeName":"起草节点","handlerId":"S00476","actionInfo":"sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote":"1）内部评审意见见下方截图；2）针对法务意见回复如下：相关权利义务转让相关的协议已付，开票金额财务已确认无误，保函不受影响。","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816b9b90fc8ec658525fbe4be88e445","parentId":"","createTime":"2022-06-16 16:22:46","nodeName":"CRM附件上传节点","handlerId":"S00476","actionInfo":"撤回","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816b9b6c89aa3d0fa6ecc54b979bd45","parentId":"","createTime":"2022-06-16 16:22:36","nodeName":"单据国别判断","handlerId":"","actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%国内项目","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816b9b6c63697dcb780429491c8cccf","parentId":"","createTime":"2022-06-16 16:22:36","nodeName":"判断表单是否由crm发起","handlerId":"","actionInfo":"sys-lbpmservice:lbpmOperations.fdOperType.system.autobranchInfo%%是","actionNote":"","docStatus":"30","childId":"","crmFileUploadType":"N"},{"processId":"1816b9b6a1501244b90e09448edb24b8","nodeId":"1816b9b6baa08efad45a8c644b0bd971","parentId":"","createTime":"2022-06-16 16:22:36","nodeName":"起草节点","handlerId":"S00476","actionInfo":"sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote":"请审批","docStatus":"30","childId":"","crmFileUploadType":"N"}],"extra":{},"extraStr":{},"timestamp":"20230318150550","status":{}}');
			return response;
		}
	}

    //测试token异常
    static testMethod void testTokenException(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Mock_Token_Excep());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }
    class Mock_Token_Excep implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code": 2000,"message": "Token过期！"}');
			return response;
		}

	}

    //测试401 非2000异常
    static testMethod void testErrorException(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Mock_Token_Excep_Error());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }
    class Mock_Token_Excep_Error implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code": 5005,"message": "程序异常！"}');
			return response;
		}

	}

    //测试500异常
    static testMethod void testError2Exception(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Mock_Token_Excep_Error2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }
    class Mock_Token_Excep_Error2 implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(500);
			response.setStatus('OK');
			response.setBody('{"code": 5005,"message": "程序异常！"}');
			return response;
		}

	}
}