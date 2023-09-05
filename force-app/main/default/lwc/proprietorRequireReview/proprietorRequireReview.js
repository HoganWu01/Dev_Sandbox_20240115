/*
 * @Author: Conner
 * @Date: 2021-09-09 13:57:17
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-10 15:43:34
 * @Descripttion: 
 */
import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import toCreateApprove from '@salesforce/apex/ControllerProprietorRequireReview.toCreateApprove';
import authenticationUser from '@salesforce/apex/ControllerProprietorRequireReview.authenticationUser';
import toCreateApproveMarketing from '@salesforce/apex/ControllerMarketingProjectInitiation.toCreateApproveMarketing';
import toCreateMarketingDevelop from '@salesforce/apex/ControllerMarketingDevelopment.toCreateMarketingDevelop';
import toCreateMarketingContract from '@salesforce/apex/ControllerMarketingContract.toCreateMarketingContract';
import SealApplicationAdd from '@salesforce/apex/Controller_SealApplicationAdd.SealApplicationAdd';
import ResourceApprovalAdd from '@salesforce/apex/Controller_OAResourceApprovalAdd.ResourceApprovalAdd';
import MarketingPlanAdd from '@salesforce/apex/Controller_OAMarketingPlanAdd.MarketingPlanAdd';
import ResourcesPlanAdd from '@salesforce/apex/Controller_OAMarketingPlanAdd.ResourcesPlanAdd';
import OASubsidiariesChange from '@salesforce/apex/Controller_OASubsidiariesChange.OASubsidiariesChange';
import toCreateStrategicCooperationContract from '@salesforce/apex/ControllerStrategicCooperationContract.toCreateStrategicCooperationContract';
import FORM_FACTOR from '@salesforce/client/formFactor'
import { loadStyle } from 'lightning/platformResourceLoader';
import toast from '@salesforce/resourceUrl/toast';
export default class ProprietorRequireReview extends LightningElement {
    isCssLoaded = false;
    @api recordId;
    @api isAndroid;
    @api objectApiName;
    isLoadedOrderUI = false;
    hrefURL = '';
    isShowButton = false;
    connectedCallback() {
      authenticationUser({recordId:this.recordId,objectName:this.objectApiName})
        .then((result) => {
          console.log('打印返回值'+result);
          if(result == 'Error'){
            let eventT = new ShowToastEvent({
                title: '警告',
                message: '只有记录所有人才能提交表单!!!',
                variant: 'warning'
            });
            this.dispatchEvent(eventT);
            this.isLoadedOrderUI = true;
            this.dispatchEvent(new CustomEvent('close'));
          }else{
            console.log('>>>>this.objectApiName', this.objectApiName)
            if(this.objectApiName=='Requirementsreview__c'){
              toCreateApprove({recordId:this.recordId})
                .then((result) => {
                  if(result.substring(0,5)=='Error'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: result.substring(5),
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,7)=='SUCCESS'){
                        let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批!!!',
                            variant: 'SUCCESS'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          if(this.isAndroid==true){
                            window.open(result.substring(7));
                            this.dispatchEvent(new CustomEvent('close'));
                            
                          }else{
                            let eventT = new ShowToastEvent({
                              title: 'SUCCESS',
                              message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                              variant: 'SUCCESS'
                            });
                            this.dispatchEvent(eventT);
                            this.isLoadedOrderUI = true;
                            this.dispatchEvent(new CustomEvent('close'));
                          }
                          
                        }
                        
                    }else{
                        let eventT = new ShowToastEvent({
                            title: 'ERROR',
                            message: '错误提交到OA审批，请联系管理员!!!',
                            variant: 'error'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                  }
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='Projectapplication__c'){
              toCreateApproveMarketing({recordId:this.recordId})
                .then((result) => {
                  if(result=='RequiredIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '请先完善所属阶段、招标方式等必填信息!!!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='ApplicationIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '机型选比叶轮or轮毂高度/竞争对手不能为空!!!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='XmProjectApplicationIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '【项目公司】为“已获悉”，必须填写相关项目公司信息！',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='ErjiProjectApplicationIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '【二级公司】为“已获悉”，必须填写相关二级公司信息！',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='JituanProjectApplicationIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '【集团公司】为“已获悉”，必须填写相关集团公司信息！',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='DesignProjectApplicationIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '【设计院】为“已获悉”，必须填写相关设计院信息！',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='GovernmentProjectApplicationIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '【政府侧】为“已获悉”，必须填写相关政府侧信息！',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else if(result=='ParticipantAnalysisIsNull'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '200MW以上的项目，必须填写“赛局分析-参与者分析”!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,5)=='Error'){
                      let eventT = new ShowToastEvent({
                          title: 'ERROR',
                          message: result.substring(5),
                          variant: 'error'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      this.dispatchEvent(new CustomEvent('close'));
                    }else{
                      if(result.substring(0,7)=='SUCCESS'){
                          let eventT = new ShowToastEvent({
                              title: 'SUCCESS',
                              message: '成功提交审批!!!',
                              variant: 'SUCCESS'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          console.log(FORM_FACTOR+'是否安卓'+this.isAndroid);
                          if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                            console.log('进入电脑端页面跳转');
                            window.open(result.substring(7));
                            this.dispatchEvent(new CustomEvent('close'));
                          }else{
                            if(this.isAndroid==true){
                              window.open(result.substring(7));
                              this.dispatchEvent(new CustomEvent('close'));
                            }else{
                              let eventT = new ShowToastEvent({
                                title: 'SUCCESS',
                                message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                                variant: 'SUCCESS'
                              });
                              this.dispatchEvent(eventT);
                              this.isLoadedOrderUI = true;
                              this.dispatchEvent(new CustomEvent('close'));
                            }
                          }
                      }else{
                          let eventT = new ShowToastEvent({
                              title: 'ERROR',
                              message: '错误提交到OA审批，请联系管理员!!!',
                              variant: 'error'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                      }
                    }
                  }
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='ResourceApproval__c'){
              toCreateMarketingDevelop({recordId:this.recordId})
                .then((result) => {
                  if(result=='NoSeal'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '请创建印章相关信息!!!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,5)=='Error'){
                      let eventT = new ShowToastEvent({
                          title: 'ERROR',
                          message: result.substring(5),
                          variant: 'error'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      this.dispatchEvent(new CustomEvent('close'));
                    }else{
                      if(result.substring(0,7)=='SUCCESS'){
                        let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批!!!',
                            variant: 'SUCCESS'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          if(this.isAndroid==true){
                            window.open(result.substring(7));
                            this.dispatchEvent(new CustomEvent('close'));
                            
                          }else{
                            let eventT = new ShowToastEvent({
                              title: 'SUCCESS',
                              message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                              variant: 'SUCCESS'
                            });
                            this.dispatchEvent(eventT);
                            this.isLoadedOrderUI = true;
                            this.dispatchEvent(new CustomEvent('close'));
                          }
                          
                        }
                        
                      }else{
                          let eventT = new ShowToastEvent({
                              title: 'ERROR',
                              message: '错误提交到OA审批，请联系管理员!!!',
                              variant: 'error'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                      }
                    }
                  }
                  
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            // By Hogan 战略合作协议/合同审批单
            if(this.objectApiName=='StrategicCooperationContract__c'){
              toCreateStrategicCooperationContract({recordId:this.recordId})
                .then((result) => {
                  if(result=='NoSeal'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '请创建印章相关信息!!!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,5)=='Error'){
                      let eventT = new ShowToastEvent({
                          title: 'ERROR',
                          message: result,
                          variant: 'error'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      this.dispatchEvent(new CustomEvent('close'));
                    }else{
                      if(result.substring(0,7)=='SUCCESS'){
                        let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批!!!',
                            variant: 'SUCCESS'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          if(this.isAndroid==true){
                            window.open(result.substring(7));
                            this.dispatchEvent(new CustomEvent('close'));
                            
                          }else{
                            let eventT = new ShowToastEvent({
                              title: 'SUCCESS',
                              message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                              variant: 'SUCCESS'
                            });
                            this.dispatchEvent(eventT);
                            this.isLoadedOrderUI = true;
                            this.dispatchEvent(new CustomEvent('close'));
                          }
                          
                        }
                        
                      }else{
                          let eventT = new ShowToastEvent({
                              title: 'ERROR',
                              message: '错误提交到OA审批，请联系管理员!!!',
                              variant: 'error'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                      }
                    }
                  }
                  
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='ContractSupplement__c'){
              toCreateMarketingContract({recordId:this.recordId})
                .then((result) => {
                  if(result=='NoSeal'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '请创建印章相关信息!!!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,5)=='Error'){
                      let eventT = new ShowToastEvent({
                          title: 'ERROR',
                          message: result.substring(5),
                          variant: 'error'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      this.dispatchEvent(new CustomEvent('close'));
                    }else{
                      if(result.substring(0,7)=='SUCCESS'){
                        let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批!!!',
                            variant: 'SUCCESS'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          if(this.isAndroid==true){
                            window.open(result.substring(7));
                            this.dispatchEvent(new CustomEvent('close'));
                            
                          }else{
                            let eventT = new ShowToastEvent({
                              title: 'SUCCESS',
                              message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                              variant: 'SUCCESS'
                            });
                            this.dispatchEvent(eventT);
                            this.isLoadedOrderUI = true;
                            this.dispatchEvent(new CustomEvent('close'));
                          }
                          
                        }
                        
                      }else{
                          let eventT = new ShowToastEvent({
                              title: 'ERROR',
                              message: '错误提交到OA审批，请联系管理员!!!'+result,
                              variant: 'error'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                      }
                    }
                  }
                  
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='Seal_Approval__c'){
              SealApplicationAdd({recordId:this.recordId})
                .then((result) => {
                  if(result == 'NullProcessId'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: '无流程Id，请联系管理员!!!',
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }
                  if(result.substring(0,5)=='Error'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: result.substring(5),
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,7)=='SUCCESS'){
                      let eventT = new ShowToastEvent({
                          title: 'SUCCESS',
                          message: '成功提交审批!!!',
                          variant: 'SUCCESS'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                        window.open(result.substring(7));
                        this.dispatchEvent(new CustomEvent('close'));
                        
                      }else{
                        if(this.isAndroid==true){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                            variant: 'SUCCESS'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                        }
                        
                      }
                      
                    }else{
                        let eventT = new ShowToastEvent({
                            title: 'ERROR',
                            message: '错误提交到OA审批，请联系管理员!!!',
                            variant: 'error'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                  }
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='ResourceProjectApplication__c'){
              ResourceApprovalAdd({recordId:this.recordId})
                .then((result) => {
                  if(result.substring(0,5)=='Error'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: result.substring(5),
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,7)=='SUCCESS'){
                      let eventT = new ShowToastEvent({
                          title: 'SUCCESS',
                          message: '成功提交审批!!!',
                          variant: 'SUCCESS'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                        window.open(result.substring(7));
                        this.dispatchEvent(new CustomEvent('close'));
                        
                      }else{
                        if(this.isAndroid==true){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                            variant: 'SUCCESS'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                        }
                        
                      }
                      
                    }else{
                        let eventT = new ShowToastEvent({
                            title: 'ERROR',
                            message: '错误提交到OA审批，请联系管理员!!!',
                            variant: 'error'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                  }
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='Project_Scheme_Application_Form__c'){
              MarketingPlanAdd({recordId:this.recordId})
                .then((result) => {
                  if(result.substring(0,5)=='Error'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: result.substring(5),
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,7)=='SUCCESS'){
                      let eventT = new ShowToastEvent({
                          title: 'SUCCESS',
                          message: '成功提交审批!!!',
                          variant: 'SUCCESS'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                        window.open(result.substring(7));
                        this.dispatchEvent(new CustomEvent('close'));
                        
                      }else{
                        if(this.isAndroid==true){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                            variant: 'SUCCESS'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                        }
                        
                      }
                      
                    }else{
                        let eventT = new ShowToastEvent({
                            title: 'ERROR',
                            message: '错误提交到OA审批，请联系管理员!!!',
                            variant: 'error'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                  }
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='Resource_Project_Scheme_Application__c'){
              ResourcesPlanAdd({recordId:this.recordId})
                .then((result) => {
                  if(result.substring(0,5)=='Error'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: result.substring(5),
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,7)=='SUCCESS'){
                      let eventT = new ShowToastEvent({
                          title: 'SUCCESS',
                          message: '成功提交审批!!!',
                          variant: 'SUCCESS'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                        window.open(result.substring(7));
                        this.dispatchEvent(new CustomEvent('close'));
                        
                      }else{
                        if(this.isAndroid==true){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                            variant: 'SUCCESS'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                        }
                        
                      }
                      
                    }else{
                        let eventT = new ShowToastEvent({
                            title: 'ERROR',
                            message: '错误提交到OA审批，请联系管理员!!!',
                            variant: 'error'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                  }
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
            if(this.objectApiName=='CompanyRegisterApplication__c'){
              OASubsidiariesChange({recordId:this.recordId})
                .then((result) => {
                  if(result.substring(0,5)=='Error'){
                    let eventT = new ShowToastEvent({
                        title: 'ERROR',
                        message: result.substring(5),
                        variant: 'error'
                    });
                    this.dispatchEvent(eventT);
                    this.isLoadedOrderUI = true;
                    this.dispatchEvent(new CustomEvent('close'));
                  }else{
                    if(result.substring(0,7)=='SUCCESS'){
                      let eventT = new ShowToastEvent({
                          title: 'SUCCESS',
                          message: '成功提交审批!!!',
                          variant: 'SUCCESS'
                      });
                      this.dispatchEvent(eventT);
                      this.isLoadedOrderUI = true;
                      if(this.isAndroid==false&&FORM_FACTOR!='Small'){
                        window.open(result.substring(7));
                        this.dispatchEvent(new CustomEvent('close'));
                        
                      }else{
                        if(this.isAndroid==true){
                          window.open(result.substring(7));
                          this.dispatchEvent(new CustomEvent('close'));
                          
                        }else{
                          let eventT = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '成功提交审批,IOS手机端请点击【IOS手机端附件上传】按钮进行下一步操作!!!',
                            variant: 'SUCCESS'
                          });
                          this.dispatchEvent(eventT);
                          this.isLoadedOrderUI = true;
                          this.dispatchEvent(new CustomEvent('close'));
                        }
                        
                      }
                      
                    }else{
                        let eventT = new ShowToastEvent({
                            title: 'ERROR',
                            message: '错误提交到OA审批，请联系管理员!!!',
                            variant: 'error'
                        });
                        this.dispatchEvent(eventT);
                        this.isLoadedOrderUI = true;
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                  }
                  
                })
                .catch((error) => {
                  console.log('>>>>>>提交OA页面错误：', error)
                  let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: '错误提交到OA审批，请联系管理员!!!'+error.body.message,
                    variant: 'error'
                  });
                  this.dispatchEvent(eventT);
                  this.isLoadedOrderUI = true;
                  this.dispatchEvent(new CustomEvent('close'));
                }); 
            }
          }
        })
        .catch((error)=>{
          let eventT = new ShowToastEvent({
            title: 'ERROR',
            message: error.body.message+'错误提交到OA审批，请联系管理员!!!'+error.body.message,
            variant: 'error'
          });
          this.dispatchEvent(eventT);
          this.isLoadedOrderUI = true;
          this.dispatchEvent(new CustomEvent('close'));
        })
      
    }

    renderedCallback(){
      if(this.isCssLoaded) return
      this.isCssLoaded = true;
      loadStyle(this,toast).then(()=>{
          console.log('loaded');
      })
      .catch(error=>{
          console.log('error to load');
      });
    }
    // mobileClick(event){
    //   var winRef = window.open(" ","_blank");
    //   //window.location.href = this.hrefURL;
    //   winRef.location = this.hrefURL;
    // }
    // mobilePhoneClick(event){
    //   //window.open(this.hrefURL);
    //   setTimeout(()=>{
    //     window.location.href = this.hrefURL;
    //   },0)
    //   this.dispatchEvent(new CustomEvent('close'));
    //   //window.location.href = this.hrefURL;
      
    // }
}