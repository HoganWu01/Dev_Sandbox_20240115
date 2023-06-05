public without sharing class ResourceDevelopmentController {
     @AuraEnabled
    public static String resourceCloseApproval(String recordId) {
            Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
            System.debug('-----------进来了--------' + recordId);
            apsr.setProcessDefinitionNameOrId('ApprovalStop');
            //留言内容和对象ID
            
            apsr.setComments('请审批');
            apsr.setObjectId(recordId);
            apsr.setSubmitterId(UserInfo.getUserId());
            // 是否跳过标准
            apsr.setSkipEntryCriteria(true);
            //提交审批结果
            Approval.ProcessResult rt;
            try{
                rt = Approval.process(apsr);
                if(rt.isSuccess()){
                    System.debug('调用commit审批过程成功！');
                }
            }catch(Exception e){
                System.debug('调用commit审批过程产生异常：' + e.getMessage()); 
                System.debug('原因：' + e.getCause()); 
                return '调用审批流异常，提交失败';       
            }
            return '提交成功'; 
    }
        
}