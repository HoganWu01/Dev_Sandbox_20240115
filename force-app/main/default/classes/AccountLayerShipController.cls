/**
 * Author: keiran
 * Date: 2021-08-27
 * Function: Controller class for AccountLayership
 **/
public without sharing class AccountLayerShipController {
	public static List<Account> lists = new List<Account>{};

    public static List<Account> subRemoveAccount = new List<Account>();
	@AuraEnabled
    public static Map<String,Object> getAccountWithLayership(String accountId){
        /**
        * 通过当前客户id找出和当前客户相关的所以共公司（客户），分两个方向找
        * 1.先用当前客户id作为id查出母公司，再用母公司的id作为id继续往上找，直到结果为null，返回最顶层的acc
        * 2.通过步骤1 拿到最顶层的acc后，再递归往下找子公司
        */
        List<String> accIds = new List<String>();
        Account topParentAccount = getParentAccount(accountId);
        System.debug('顶级母公司=============' + topParentAccount.Name);
        accIds.add(topParentAccount.Id);
        getSubAccount(accIds);
        System.debug('lists=============' + lists);
        lists.add(topParentAccount);
        Map<String,Object> accountMap = getAccountMap(lists);
        system.debug('分类完成。' + accountMap);
        return accountMap;
    }

    // 找顶级母公司的递归调用
        private static Account getParentAccount(String accId) {
            System.debug('查询了');
        	Account acc = [SELECT Id, Name, OwnerId, Owner.Name, Accounttype__c, Region__c, parentId FROM Account where Id =: accId][0];
        	System.debug('查询到ParentId=' + acc.ParentId);
            if (acc.ParentId == null) {
        		return acc;
        	} else {
        		return getParentAccount(acc.parentId);
        	}
        }

        // 找出所有子公司
        private static void getSubAccount(List<String> ids) {
        	List<Account> accs = [SELECT Id, Name, OwnerId, Owner.Name, Accounttype__c, Region__c, parentId FROM Account where ParentId IN: ids];
        	if (accs.size() != 0) {
        	// 	 List<Account> ls = new List<Account>();
        	// 	 ls = [SELECT Id, Name, OwnerId, Owner.Name, category__c, parentId FROM Account where Id IN: ids];
        	// 	 lists.addAll(ls);
        	// } else {
        		List<String> strs = new List<String>();
        		for (Account temp : accs) {
        			strs.add(temp.Id);
        		}
                lists.addAll(accs);
        		getSubAccount(strs);
                
        	}
        }

    private static Map<String,Object> getAccountMap(List<Account> accounts){
        
        List<Account> parentAccountLayerShip = new List<Account>();
        Map<String,List<Account>> parentAccountLayerShipChildrenMap = new Map<String,List<Account>>();
        for(Account acc : accounts){
                if(acc.ParentId == null){
                    parentAccountLayerShip.add(acc);
                    if(!parentAccountLayerShipChildrenMap.containsKey(acc.Id)){
                        parentAccountLayerShipChildrenMap.put(acc.Id, new List<Account>());
                    }
                } else {
                    String parentAccountId = acc.ParentId;
                    if(parentAccountLayerShipChildrenMap.containsKey(parentAccountId)){
                        parentAccountLayerShipChildrenMap.get(parentAccountId).add(acc);
                    } else {
                        parentAccountLayerShipChildrenMap.put(parentAccountId, new List<Account>{acc});
                    }
                }
        }
        
        return new Map<String,Object>{
            'parentAccountLayerShip' => parentAccountLayerShip,
            'parentAccountLayerShipChildrenMap' => parentAccountLayerShipChildrenMap
        };
    }

    @AuraEnabled
    public static List<Account> getAvailableAccount (String accountId) {
        system.debug('accountid ==========' + accountId);
        return [SELECT Name, Id, parentId FROM Account WHERE id !=: accountId AND parentId = NULL];
    }

    @AuraEnabled
    public static void removeAccount(String accountId){
        system.debug('进到删除方法' + accountId);
        Account acc = [SELECT parentId from Account where Id =:accountId][0];
        acc.ParentId = NULL;
        acc.BeenGroup__c = true;
        subRemoveAccount.add(acc);
        getRemoveSubAccount(accountId);
        for (Account acco : subRemoveAccount) {
            acco.ParentId = null;
            acco.BeenGroup__c = true;
        } 
        update subRemoveAccount;
    }

    private static void getRemoveSubAccount(String accountId) {
        List<Account> accs = [SELECT Name, Id, ParentId FROM Account where parentId =: accountId];
        if (!accs.isEmpty()) {
            subRemoveAccount.add(accs.get(0));
            if (accs.get(0).ParentId != null) {
            getRemoveSubAccount(accs.get(0).Id);
        }
        }
        
    }

    @AuraEnabled
    public static List<Account> searchAccount(String name) {
        return [SELECT Name, Id, parentId FROM Account WHERE Name LIKE: ('%' + name + '%') AND parentId = NULL];
    }
}