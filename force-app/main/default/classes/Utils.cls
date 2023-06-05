global without sharing class Utils {
    /**
     * @description: 
     * @param  {sysName:系统标识,methodName:方法名,source:{1为OA,2为sap,3为eam},timeSpan:时间戳,sKey:鉴权}
     * @return {*}
     */    
    // global static String AesEncrypt(String sysName,String methodName,String source,String timeSpan,String sKey,String Iv) {
    //     String sSrc = sysName +'@'+ methodName +'@'+ source +'@'+ timeSpan;
    //     List<Integer> rawList = new List<Integer>();
    //     if (sKey.length()<16) {
    //         sKey = sKey.rightPad(16, '0');
    //     }else {
    //         sKey = sKey.substring(0,16);
    //     }
    //     Blob key = Blob.valueOf(sKey);
    //     Blob exampleIv = Blob.valueOf(Iv);
    //     Blob data = Blob.valueOf(sSrc);
    //     Blob encrypted = Crypto.encrypt('AES128', key, exampleIv, data);

    //     // String MY_KEY = '2907f6af61e44988'; key值
    //     // String MY_IV = 'bWluZ3lhbmd6aGlu'; 初始化向量
    //     // String ALGORITHM_NAME = 'AES128';
    //     // Blob key = Blob.valueOf(MY_KEY);
    //     // Blob iv = Blob.valueOf(MY_IV);
    //     // Blob data = Blob.valueOf('crm@oaTestAdd@1@1631544164977');  明文
    //     // system.debug(EncodingUtil.base64Encode(Crypto.encrypt(ALGORITHM_NAME, key, iv, data)));
    //     //system.debug('2907f6af61e44988a8de4a01f2248e10'.substring(0,16));
    //     //system.debug(EncodingUtil.base64Encode(Blob.valueOf('mingyangzhineng2021'))); 初始化向量的生成，取16位
    //     //bWluZ3lhbmd6aGluZW5nMjAyMQ== 生成的初始化向量
    //     //TimeZone tz = UserInfo.getTimeZone();
    //     //DateTime dt = Datetime.now();
    //     //Long timeLocal = dt.addSeconds((tz.getOffset(dt)/1000)).getTime(); 获取时间戳
    //     //system.debug('时间戳'+timeLocal);
    //     //1631544164977 获取到的时间戳
    //     //token->w6o/NovWcYt+7XWjk/FAj+Us/rcku18BuaW3/uYr2mI=

    //     return EncodingUtil.base64Encode(encrypted);
    // }

     /**
     * @Descripttion: 获取token
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */ 
    public static String getToken(){
        OpenPlatformApi__c open = OpenPlatformApi__c.getValues('GetToken');
        String strUrl = open.URL__c + '?grant_type=' + open.Grant_Type__c + '&client_id=' + open.Client_Id__c + '&client_secret=' + open.Client_Secret__c;
        System.debug('接口平台获取token URL:'+ strUrl);
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint(strUrl);
        r.setMethod('GET');
        r.setTimeout(120000);
        HTTPResponse resp = h.send(r);
        System.debug('接口平台获取token response:'+ resp.getBody());
        ResponseBody resBody = (ResponseBody)System.JSON.deserialize(resp.getBody(), ResponseBody.class);
        System.debug('接口平台获取token:'+ resBody.access_token);
        // OpenPlatformApi__c upOpen = new OpenPlatformApi__c();
        // upOpen.Id = open.Id;
        // upOpen.Token__c = resBody.access_token;
        // update upOpen;
        staticToken = resBody.access_token;
        return resBody.access_token;
    }

    global static String callOut(String requestBodyObj,String URL,String className,String source, String mothd,String sysKey,String Iv) {
        Interface_Log__c logInfo = new Interface_Log__c();
        OpenPlatformApi__c open = OpenPlatformApi__c.getValues('GetToken');//add by hogan
        String IPURL = open.IP__c + URL;
        Boolean isAtt = false;
		try {
			String requestBody = requestBodyObj;
			HTTP h = new HTTP();
			HTTPRequest r = new HTTPRequest();
            r.setHeader('Content-Type', 'application/json; charset=utf-8');
            r.setHeader('accept','application/json');
            if(String.isBlank(staticToken)){
                getToken(); 
            }
            System.debug('获取的token'+staticToken);
            r.setEndpoint(IPURL);
			r.setHeader('Authorization','Bearer '+staticToken);
			r.setMethod('POST');
            r.setTimeout(120000);
			if (requestBodyObj!=null) {
				r.setBody(requestBody);
			}
			HTTPResponse resp = h.send(r);
            //返回体日志去不同的调用类解析返回体并插入日志
            if (resp.getBody().indexOf('InvalidTokenException')>-1) {
                if(callNumber>=5){
                    return 'Error：InvalidTokenException，请联系管理员！';
                }else {
                    getToken();
                    callNumber++;
                    System.debug('>>>>>>>callNumber:'+callNumber);
                    return callout(requestBodyObj,URL,className,source,mothd,sysKey,Iv);
                }
                // logInfo.RequestURL__c = URL;
                // logInfo.ClassName__c = className;
                // logInfo.RequestBody__c = JSON.serialize(requestBodyObj);
                // logInfo.RespondBody__c = resp.getBody();
                // insert logInfo;
                // Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                // return 'Error：接口返回异常！详情见日志编号：'+newLog.Name;
            }
            ResponseBody resBody = (ResponseBody)System.JSON.deserialize(resp.getBody(), ResponseBody.class);
            if (resp.getStatusCode() == 200) {
                logInfo.RequestURL__c = IPURL;
                logInfo.ClassName__c = className;
                logInfo.RequestBody__c = JSON.serialize(requestBodyObj);
                // logInfo.RespondBody__c = resp.getBody();
                logInfo.ErrorMessage__c ='请求状态'+resp.getStatusCode();
                if (resp.getBody().length()>130000) {
                    logInfo.RespondBody__c = '见附件';
                    isAtt = true;
                }else {
                    logInfo.RespondBody__c = resp.getBody();
                }
                insert logInfo;
                if (isAtt) {
                    Attachment insertAtt = new Attachment();
                    insertAtt.ParentId = logInfo.Id;
                    insertAtt.Body = Blob.valueOf(Json.serialize(resp.getBody()));
                    insertAtt.Name = 'ResponseBody.txt';
                    insertAtt.ContentType = 'text/plain';
                    insert insertAtt;
                }
                return resp.getBody();  
            }else if(resp.getStatusCode() == 401){ 
                if(resBody.code==2000){//2000代号，重新获取最新token
                    if(callNumber>=5){
                        return 'Error：Token失效，请重新操作！';
                    }else {
                        getToken();
                        callNumber++;
                        System.debug('>>>>>>>callNumber:'+callNumber);
                        return callout(requestBodyObj,URL,className,source,mothd,sysKey,Iv);
                    }
                }else {
                    logInfo.RequestURL__c = IPURL;
                    logInfo.ClassName__c = className;
                    logInfo.RequestBody__c = JSON.serialize(requestBodyObj);
                    // logInfo.RespondBody__c = resp.getBody();
                    logInfo.ErrorMessage__c ='请求状态'+resp.getStatusCode();
                    if (resp.getBody().length()>130000) {
                        logInfo.RespondBody__c = '见附件';
                        isAtt = true;
                    }else {
                        logInfo.RespondBody__c = resp.getBody();
                    }
                    insert logInfo;
                    if (isAtt) {
                        Attachment insertAtt = new Attachment();
                        insertAtt.ParentId = logInfo.Id;
                        insertAtt.Body = Blob.valueOf(Json.serialize(resp.getBody()));
                        insertAtt.Name = 'ResponseBody.txt';
                        insertAtt.ContentType = 'text/plain';
                        insert insertAtt;
                    }
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
            }else {
                System.debug('出错了-------'+resp.getStatusCode());
                logInfo.RequestURL__c = IPURL;
                logInfo.ClassName__c = className;
                logInfo.RequestBody__c = JSON.serialize(requestBodyObj);
                // logInfo.RespondBody__c = resp.getBody();
                logInfo.ErrorMessage__c ='请求状态'+resp.getStatusCode();
                if (resp.getBody().length()>130000) {
                    logInfo.RespondBody__c = '见附件';
                    isAtt = true;
                }else {
                    logInfo.RespondBody__c = resp.getBody();
                }
                insert logInfo;
                if (isAtt) {
                    Attachment insertAtt = new Attachment();
                    insertAtt.ParentId = logInfo.Id;
                    insertAtt.Body = Blob.valueOf(Json.serialize(resp.getBody()));
                    insertAtt.Name = 'ResponseBody.txt';
                    insertAtt.ContentType = 'text/plain';
                    insert insertAtt;
                }
                Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
            }
			
		} catch (Exception e) {
            System.debug('catch-------'+e.getMessage() + '行数：'+e.getLineNumber());
            logInfo.RequestURL__c = IPURL;
			logInfo.ClassName__c = className;
			logInfo.RequestBody__c = requestBodyObj;
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
			return 'Error'+logInfo.ErrorMessage__c+'日志Id:'+logInfo.Id;
		}
	}

    //循环调用外部接口
    global static String callOut2(String requestBodyObj,String URL,String className,String source, String mothd,String sysKey,String Iv) {
        OpenPlatformApi__c open = OpenPlatformApi__c.getValues('GetToken');//add by hogan
        String IPURL = open.IP__c + URL;
        Boolean isAtt = false;
		try {
			String requestBody = requestBodyObj;
			HTTP h = new HTTP();
			HTTPRequest r = new HTTPRequest();
            r.setHeader('Content-Type', 'application/json; charset=utf-8');
            r.setHeader('accept','application/json');
            if(String.isBlank(staticToken)){
                getToken(); 
            }
            System.debug('获取的token'+staticToken);
            r.setEndpoint(IPURL);
			r.setHeader('Authorization','Bearer '+staticToken);
			r.setMethod('POST');
            r.setTimeout(120000);
			if (requestBodyObj!=null) {
				r.setBody(requestBody);
			}
			HTTPResponse resp = h.send(r);
            //返回体日志去不同的调用类解析返回体并插入日志
            if (resp.getBody().indexOf('InvalidTokenException')>-1) {
                if(callNumber>=5){
                    return 'Error：InvalidTokenException，请联系管理员！';
                }else {
                    getToken();
                    callNumber++;
                    System.debug('>>>>>>>callNumber:'+callNumber);
                    return callout(requestBodyObj,URL,className,source,mothd,sysKey,Iv);
                }
            }
            ResponseBody resBody = (ResponseBody)System.JSON.deserialize(resp.getBody(), ResponseBody.class);
            if (resp.getStatusCode() == 200) {
                return resp.getBody();  
            }else if(resp.getStatusCode() == 401){ 
                if(resBody.code==2000){//2000代号，重新获取最新token
                    if(callNumber>=5){
                        return 'Error：Token失效，请重新操作！';
                    }else {
                        getToken();
                        callNumber++;
                        System.debug('>>>>>>>callNumber:'+callNumber);
                        return callout(requestBodyObj,URL,className,source,mothd,sysKey,Iv);
                    }
                }else {
                    return 'Error'+resBody.message;
                }
            }else {
                System.debug('出错了-------'+resp.getStatusCode());
                return 'Error'+resBody.message;
            }
		} catch (Exception e) {
            System.debug('catch-------'+e.getMessage() + '行数：'+e.getLineNumber());
			return 'Error' + e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
		}
	}

    // global static String logFun(String IPURL, String className, String requestBodyObj, String resp){
    //     Interface_Log__c logInfo = new Interface_Log__c();
    //     Boolean isAtt = false;
    //     logInfo.RequestURL__c = IPURL;
    //     logInfo.ClassName__c = className;
    //     logInfo.RequestBody__c = JSON.serialize(requestBodyObj);
    //     // logInfo.ErrorMessage__c ='请求状态'+resp.getStatusCode();
    //     if (resp.length()>130000) {
    //         logInfo.RespondBody__c = '见附件';
    //         isAtt = true;
    //     }else {
    //         logInfo.RespondBody__c = resp;
    //     }
    //     insert logInfo;
    //     if (isAtt) {
    //         Attachment insertAtt = new Attachment();
    //         insertAtt.ParentId = logInfo.Id;
    //         insertAtt.Body = Blob.valueOf(Json.serialize(resp));
    //         insertAtt.Name = 'ResponseBody.txt';
    //         insertAtt.ContentType = 'text/plain';
    //         insert insertAtt;
    //     }
    //     Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
    //     return newLog.Name;
    // }

    // global static String callOut(String requestBodyObj,String URL,String className,String source, String mothd,String sysKey,String Iv) {
    //     Interface_Log__c logInfo = new Interface_Log__c();
	// 	try {
	// 		String requestBody = requestBodyObj;
	// 		HTTP h = new HTTP();
	// 		HTTPRequest r = new HTTPRequest();
	// 		r.setEndpoint(URL);
    //         r.setHeader('Content-Type', 'application/json; charset=utf-8');
	// 		r.setHeader('mothd', mothd);
    //         r.setTimeout(120000);
	// 		r.setHeader('source', source);
	// 		r.setHeader('sysName', 'crm');
    //         TimeZone tz = UserInfo.getTimeZone();
    //         DateTime dt = Datetime.now();
    //         Long timeLocal = dt.addSeconds((tz.getOffset(dt)/1000)).getTime();
	// 		r.setHeader('timespan', String.valueOf(timeLocal));
    //         System.debug('时间戳'+ String.valueOf(timeLocal));
    //         String getToken = AesEncrypt('crm',mothd,source,String.valueOf(timeLocal),sysKey,Iv);
    //         System.debug('获取的token'+getToken);
	// 		r.setHeader('token',getToken);
	// 		r.setMethod('POST');
	// 		if (requestBodyObj!=null) {
	// 			r.setBody(requestBody);
	// 		}

	// 		HTTPResponse resp = h.send(r);
    //         //返回体日志去不同的调用类解析返回体并插入日志
    //         if (resp.getStatusCode() == 200) {
    //             return resp.getBody();
    //         }else {
    //             System.debug('出错了-------'+resp.getStatusCode());
    //             logInfo.RequestURL__c = URL;
    //             logInfo.ClassName__c = className;
    //             logInfo.RequestBody__c = JSON.serialize(requestBodyObj);
    //             logInfo.RespondBody__c = resp.getBody();
    //             logInfo.ErrorMessage__c ='请求状态'+resp.getStatusCode();
    //             insert logInfo;
    //             Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
    //             return 'Error'+resp.getBody()+'\n日志编号:'+newLog.Name;
    //         }
			
	// 	} catch (Exception e) {
    //         System.debug('catch-------'+e.getMessage() + '行数：'+e.getLineNumber());
    //         logInfo.RequestURL__c = URL;
	// 		logInfo.ClassName__c = className;
	// 		logInfo.RequestBody__c = requestBodyObj;
	// 		logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
    //         insert logInfo;
	// 		return 'Error'+logInfo.ErrorMessage__c+'日志Id:'+logInfo.Id;
	// 	}
	// }

    /**
     * @Descripttion: 获取下拉选项值
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public static List<PickListValue> getPickListValue(String objectName,String fieldName) {
        //返回值集合
        List<PickListValue> value = new List<PickListValue>();
        //根据对象名和字段名获得选项值
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for(Schema.PicklistEntry a : pick_list_values) {
            PickListValue listValue = new PickListValue();
            listValue.FieldValue = a.getValue();
            listValue.FieldLabel = a.getLabel();
            value.add(listValue);
        }
        return value;
    }

    /**
     * @Descripttion: 小铃铛通知
     * @Author: Keiran
     * @param {*}
     * @return {*}
     */
    public static void notifyUsers(Set<String> recipientsIds, String targetId,String setTitle, String setBody) {
        // 获取自定义通知
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='sendNotify']; 
        
        // 创建一个新的自定义通知
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
 
        // 提醒内容
        notification.setTitle(setTitle);
        notification.setBody(setBody);
 
        // 发送提醒的ID和页面记录id
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // 发送提醒
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    /**
     * @name: 发送邮件
     * @message: 
     * @param {*} 收件邮箱地址集合、邮件主题、邮件内容
     * @return {*}
     */    
    public static void sendMail(Set<String> strs,String subject,String messageBody){
        System.debug('strs---------' + strs);
        System.debug('subject---------' + subject);
        System.debug('messageBody---------' + messageBody);
        List<String> toAddStr = new List<String>();
        if(strs != null){
            for (String str : strs) {
                toAddStr.add(str);
            }
        }
        if (toAddStr.size()>0) {
            Id oweaId = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName like '%系统邮件%'][0].Id;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toAddStr;
            // message.optOutPolicy = 'FILTER';
            message.subject = subject;
            message.htmlbody = messageBody;
            if (oweaId!=null) {
                message.orgwideemailaddressid = oweaId;
            }
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            System.debug('results---------' + results);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }

    /**
     * @Descripttion: 锁定记录
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    @InvocableMethod(label='Lock Record' description='Lock data record, not allow edit data.' category='')
    public static void LockRecordAction(List<ID> ids) {
		Approval.lock(ids);//锁定记录
    }

    private static Integer callNumber = 0;
    private static String staticToken;

    public class PickListValue {
        @AuraEnabled
        public String FieldLabel{get;set;}
        @AuraEnabled
        public String FieldValue{get;set;}
    }

    public class ResponseBody {
        public String access_token{get;set;}
        public String token_type{get;set;}
        public Integer code{get;set;}
        public String message{get;set;}
    }
}