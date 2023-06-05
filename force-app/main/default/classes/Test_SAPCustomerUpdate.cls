@isTest
public with sharing class Test_SAPCustomerUpdate {


  @TestSetup 
    static void setData() {
      // Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
      // User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
      // insert user;

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = 'celnet'];
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapUpdateCustomer';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/sapUpdateCustomer';
        ext.Request_Source__c = '2';
        ext.Request_Method__c = 'sapTestAdd';
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

        InterfaceParam__c inter = new InterfaceParam__c();
        inter.name = 'SAPCustomerUpdate';
        inter.SyncDate__c = Datetime.now().date();
        insert inter ; 
 
         Company__c com = new Company__c();
         com.name = '内蒙古';
         com.CompanySelfCode__c = '6666';
         insert com;
         
         Controller_SAPCustomerUpdate.RequestBody r =new Controller_SAPCustomerUpdate.RequestBody();
         r.kunnr = '12';
         r.stcd = '12';


          Controller_SAPCustomerUpdate.ResponseBody re =new Controller_SAPCustomerUpdate.ResponseBody();
          re.message = '12';
  
    }

    static testMethod void testSAPCustomerUpdate(){

      Interface_Log__c logInfo = new Interface_Log__c();
      insert logInfo ; 

      

      Company__c com = [SELECT ID,NAME,CompanySelfCode__c FROM Company__c WHERE NAME = '内蒙古'];

      Account acc = new Account();
      acc.Name = '隆多';
      acc.ReconciliationSubjects__c = '1121010000';
      acc.CompanyCode__c = com.id;
      acc.PricingProcess__c = '1';
      acc.PriceGroup__c = '01';
      acc.CustomerAccountGroup__c = 'ZD01';
      acc.AccountNumber = '0000200000';
      acc.Country__c = 'CN';
      acc.Area__c = '	CN_010';
      acc.Shortname__c = '隆多';
      acc.ProductGroup__c = '10';
      acc.Officialcode__c = '123456789';
      acc.Street__c = '昌岗';
      acc.TaxType__c = '0';
      acc.SalesrOrganization__c = '6001';
      acc.ShippingConditions__c = '01';
      acc.DistributionChannels__c = '90';
      acc.PaymentTerms__c = 'Z014';
      acc.BeenGroup__c = true ; 
      insert acc; 


      System.Test.startTest();
      System.test.setMock(HttpCalloutMock.class,new SAPCustomer_Mock());
      RestRequest request = new RestRequest();
      RestResponse response = new RestResponse();
      RestContext.response = response;
      RestContext.request = request;
      
      Controller_SAPCustomerUpdate.SAPCustomerUpdate();

      System.Test.stopTest();
    }

    @IsTest static void test_SAPCustomer_Job(){
		System.Test.startTest();
		System.test.setMock(HttpCalloutMock.class,new SAPCustomer_Mock());
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
		// System.schedule('test','0 0 0 * * ?',new Schedule_SAPCustomerUpdate());
		// Database.executeBatch(new Batch_SAPCustomerUpdate(true));
		// Database.executeBatch(new Batch_SAPCustomerUpdate(false));
		System.Test.stopTest();

	}

    class SAPCustomer_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			//response.setBody('{"code": 200,"message":null,"data":[{"kunnr": "0000200000","bukrs": "6630","vkorg": "6548","vtweg": "50","spart": "00","ktokd": "ZD02","name1Kna1": "明阳智慧能源集团股份公司(广东明阳）","sortl": "广东明阳","street": "","regio": "CN_010","land1": "CN","telf1": " ","telfx": " ","stcd5": "442000789438199","akont": "1122010200","vbund": "006000","konda": "01","kalks": "1","vsbed": "01","zterm": "0001","ktgrd": "01","taxkd": "1","updat": "20211020"}]}');
      response.setBody('{"code": 200,"message": null,"data": [{"kunnr": "0000200000","name1Kna1": "新建测试客户20211210测已交易客户","sortl": "20211210","street": " ","regio": " ","land1": "CN","stcd5": "99887766554433"}]}');
			return response;
		}
	}

  @IsTest static void test_Schedule_SAPCustomerUpdate(){
    Schedule_SAPCustomerUpdate ss = new Schedule_SAPCustomerUpdate();
    
    ss.execute(null);
  }

  // @IsTest static void test_Batch_SAPCustomerUpdate(){
  //   Account acc = new Account();
  //   acc.Name = '广州风机';
  //   acc.BeenGroup__c = true;
  //   insert acc;
  //   List<Account> accList = new List<Account> ();
  //   accList.add(acc);

  //   Database.BatchableContext BC ;
  //   Batch_SAPCustomerUpdate bs = new Batch_SAPCustomerUpdate();
  //   bs.execute(BC, accList);
  //   bs.start(BC);
  //   bs.finish(BC);

  // }

}