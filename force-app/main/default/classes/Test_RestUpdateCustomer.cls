@isTest
public with sharing class Test_RestUpdateCustomer {


  @TestSetup 
    static void setData() {
        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        acc.Officialcode__c='123444';
        insert acc;

        Company__c com = new Company__c();
        com.name = '明阳集团';
        com.CompanySelfCode__c = '8000';
        insert com;
         
    }

    static testMethod void testUpdate(){
      Interface_Log__c logInfo = new Interface_Log__c();
      insert logInfo ; 
      Company__c com = [SELECT ID,NAME,CompanySelfCode__c FROM Company__c WHERE NAME = '明阳集团'];
      Account acc = [SELECT ID,Officialcode__c FROM Account WHERE Officialcode__c = '123444'];
      System.Test.startTest();
      RestRequest request = new RestRequest();
      request.requestBody=Blob.valueOf('{"zid":"","kunnr":"100197","ktokd":"Z001","name1":"测试客户66677788","name2":"","sortl":"测试","bu_sort2_txt":"","stras":"","pstlz":"999999","land1":"CN","ort01":"上海","regio":"","telf1":"","telfx":"","telf2":"","name_co":"","location":"","smtp_addr":"","spras":"1","kukla":"","bran1":"","taxtype":"CN0","taxnum":"123444","xblck":"","zyl001":"","zyl002":"","zyl003":"","zyl004":"","zyl005":"","zyl006":"","zyl007":"","zyl008":"","zyl009":"","zyl010":"","bukrs":"8000","akont":"1122010200","zuawa":"","zterm1":"Z003","lnrze":"","vkorg":"8000","vtweg":"00","spart":"00","bzirk":"","kdgrp":"","vkbur":"","vkgrp":"","waers":"CNY","zterm":"Z003","konda":"01","kalks":"1","versg":"","kzazu":"","vsbed":"01","vwerk":"","kztlf":"","inco1":"","inco2":"","ktgrd":"01","aland":"CN","takld":"1","parvw":"AG","kunn2":"0000100197","banks":"","bankl":"","koinh":"","bkref":"","banka":"","bankn":"","bkValidFrom":"","bkValidTo":""}');
      RestResponse response = new RestResponse();
      RestContext.response = response;
      RestContext.request = request;

      Rest_UpdateCustomer.doPost();
      System.Test.stopTest();
    }

    static testMethod void testUpdate2(){
      Interface_Log__c logInfo = new Interface_Log__c();
      insert logInfo ; 
      Company__c com = [SELECT ID,NAME,CompanySelfCode__c FROM Company__c WHERE NAME = '明阳集团'];
      Account acc = [SELECT ID,Officialcode__c FROM Account WHERE Officialcode__c = '123444'];
      System.Test.startTest();
      RestRequest request = new RestRequest();
      request.requestBody=Blob.valueOf('{"zid":"","ktokd":"Z001","name1":"测试客户66677788","name2":"","sortl":"测试","bu_sort2_txt":"","stras":"","pstlz":"999999","land1":"CN","ort01":"上海","regio":"","telf1":"","telfx":"","telf2":"","name_co":"","location":"","smtp_addr":"","spras":"1","kukla":"","bran1":"","taxtype":"CN0","taxnum":"123444","xblck":"","zyl001":"","zyl002":"","zyl003":"","zyl004":"","zyl005":"","zyl006":"","zyl007":"","zyl008":"","zyl009":"","zyl010":"","bukrs":"8000","akont":"1122010200","zuawa":"","zterm1":"Z003","lnrze":"","vkorg":"8000","vtweg":"00","spart":"00","bzirk":"","kdgrp":"","vkbur":"","vkgrp":"","waers":"CNY","zterm":"Z003","konda":"01","kalks":"1","versg":"","kzazu":"","vsbed":"01","vwerk":"","kztlf":"","inco1":"","inco2":"","ktgrd":"01","aland":"CN","takld":"1","parvw":"AG","kunn2":"0000100197","banks":"","bankl":"","koinh":"","bkref":"","banka":"","bankn":"","bkValidFrom":"","bkValidTo":""}');
      RestResponse response = new RestResponse();
      RestContext.response = response;
      RestContext.request = request;
      
      Rest_UpdateCustomer.doPost();
      System.Test.stopTest();
    }

    static testMethod void testUpdate3(){
      Interface_Log__c logInfo = new Interface_Log__c();
      insert logInfo ; 
      Company__c com = [SELECT ID,NAME,CompanySelfCode__c FROM Company__c WHERE NAME = '明阳集团'];
      Account acc = [SELECT ID,Officialcode__c FROM Account WHERE Officialcode__c = '123444'];
      System.Test.startTest();
      RestRequest request = new RestRequest();
      request.requestBody=Blob.valueOf('{"zid":"","kunnr":"100197","ktokd":"Z001","name1":"测试客户66677788","name2":"","sortl":"测试","bu_sort2_txt":"","stras":"","pstlz":"999999","land1":"CN","ort01":"上海","regio":"","telf1":"","telfx":"","telf2":"","name_co":"","location":"","smtp_addr":"","spras":"1","kukla":"","bran1":"","taxtype":"CN0","taxnum":"","xblck":"","zyl001":"","zyl002":"","zyl003":"","zyl004":"","zyl005":"","zyl006":"","zyl007":"","zyl008":"","zyl009":"","zyl010":"","bukrs":"8000","akont":"1122010200","zuawa":"","zterm1":"Z003","lnrze":"","vkorg":"8000","vtweg":"00","spart":"00","bzirk":"","kdgrp":"","vkbur":"","vkgrp":"","waers":"CNY","zterm":"Z003","konda":"01","kalks":"1","versg":"","kzazu":"","vsbed":"01","vwerk":"","kztlf":"","inco1":"","inco2":"","ktgrd":"01","aland":"CN","takld":"1","parvw":"AG","kunn2":"0000100197","banks":"","bankl":"","koinh":"","bkref":"","banka":"","bankn":"","bkValidFrom":"","bkValidTo":""}');
      RestResponse response = new RestResponse();
      RestContext.response = response;
      RestContext.request = request;
      
      Rest_UpdateCustomer.doPost();
      System.Test.stopTest();
    }

}