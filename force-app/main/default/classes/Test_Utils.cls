@isTest
public with sharing class Test_Utils {
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


    }   

    static testMethod void testGetToken(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Utils.getToken();
        System.Test.stopTest();
    }
    
    static testMethod void testSendMail(){
      Set<String> strs= new Set<String>();
      strs.add('wuchaohui@mywind.com.cn');
      Utils.sendMail(strs,'测试subject','测试body');
    }

    static testMethod void testCallOut(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }
    
    static testMethod void testCallOut12(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock3());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }
    
    static testMethod void testCallOut13(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock4());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }
    
    static testMethod void testCallOut14(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock5());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }

    static testMethod void testCallOut15(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock6());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }

    static testMethod void testCallOut2(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut2(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }

    static testMethod void testCallOut22(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock3());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut2(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }

    static testMethod void testCallOut23(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock4());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut2(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        System.Test.stopTest();
    }

    static testMethod void testCallOut24(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock5());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        Utils.callOut2(JSON.serialize(response),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        Utils.getPickListValue('Projectapplication__c', 'Salesdepartment__c');
        Set<String> recipientsIds= new Set<String>();
        recipientsIds.add('1');
        Utils.notifyUsers(recipientsIds, 'targetId', 'setTitle', 'setBody');
        System.Test.stopTest();
    }

    class OAGetApprovalRecords_Mock implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"access_token":"c42de31d-5ff4-47e7-b838-dab87fe699c1","token_type":"bearer","refresh_token":"1052f13b-c507-4d27-8fb6-3a5608ff7150","expires_in":99999,"scope":"api1 userProfile","openid":"521677655146233856","domain":"@admin.com"}');
			return response;
		}
	}

    class OAGetApprovalRecords_Mock2 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":200,"message":"CRM调用oa审批记录接口成功！","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20230202145322","status":{}}');
			return response;
		}
	}

    class OAGetApprovalRecords_Mock3 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code":2000,"message":"CRM调用oa审批记录接口成功！","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20230202145322","status":{}}');
			return response;
		}
	}

    class OAGetApprovalRecords_Mock4 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code":2001,"message":"CRM调用oa审批记录接口成功！","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20230202145322","status":{}}');
			return response;
		}
	}

    class OAGetApprovalRecords_Mock5 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(501);
			response.setStatus('OK');
			response.setBody('{"code":2001,"message":"CRM调用oa审批记录接口成功！","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20230202145322","status":{}}');
			return response;
		}
	}

    class OAGetApprovalRecords_Mock6 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(501);
			response.setStatus('OK');
			response.setBody('InvalidTokenException');
			return response;
		}
	}
}