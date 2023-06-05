/**
 * Date: 2020-07-20
 * Function: Controller class for AccountMembership
 **/
public without sharing class AccountMembershipController { 

    @AuraEnabled
    public static Map<String,Object> getAccountWithContactMembership(String accountId){
        List<Account> accs = [Select Id, Name, OwnerId, Owner.Name, Accounttype__c,
                              	(Select Id, Name, gender__c, Department, Relationship__c, Phone, AccountId, ReportsToId, 
                                 	Title, Is_Account_Membership__c, Parent_Contact_In_Account_Membership__c 
                                 From Contacts)
                              From Account Where Id =: accountId];
    
        
        if(accs.isEmpty()){
            return null;
        } else {
            Account acc = accs[0];
            
            Map<String,Object> contactsMap = getContactsMap(acc.Contacts);
            contactsMap.put('acc',acc);
            
            return contactsMap;
        }

        // Contact Fields
        // Name 姓名
        // gender__c 性别
        // Department 部门
        // Relationship__c 成熟度（目前关系）
        // Phone 电话
        // AccountId 客户
        // ReportsToId 直属上司 （联系人）
        // Title 职务
        // Id
        // Is_Account_Membership__c
        // Parent_Contact_In_Account_Membership__c
        
        // Account Fields
        // Name
        // OwnerId
        // accountStatus__c 
        // category__c 
        // Accounttype__c 
    }

    @AuraEnabled
    public static List<Contact> getAvailableContacts(String accountId){
        return [Select Id, Name, gender__c, Department, Relationship__c, Phone, AccountId, ReportsToId, 
                        Title, Is_Account_Membership__c, Parent_Contact_In_Account_Membership__c 
                From Contact 
                Where AccountId =: accountId 
                And Is_Account_Membership__c = false];
    }
    
    @AuraEnabled
    public static void removeContact(String contactId){
        // Remove this contact and children contacts
        Contact con = [Select Id, Name, AccountId From Contact Where Id =: contactId];
        List<Contact> updateContacts = new List<Contact>{con};
        
        List<Account> accs = [Select Id, Name, OwnerId, Owner.Name, Accounttype__c,
                              	(Select Id, Name, gender__c, Department, Relationship__c, Phone, AccountId, ReportsToId, 
                                 	Title, Is_Account_Membership__c, Parent_Contact_In_Account_Membership__c 
                                 From Contacts)
                              From Account Where Id =: con.AccountId];
        
        if(!accs.isEmpty()){
            Map<String,Object> contactsMap = getContactsMap(accs[0].Contacts);
            Map<String,List<Contact>> contactsHierarchyMap = (Map<String,List<Contact>>)contactsMap.get('parentContactsWithMembershipChildrenMap');
            addRelatedContacts(con,contactsHierarchyMap,updateContacts);
        }
        
        for(Contact c : updateContacts){
            c.Is_Account_Membership__c = false;
            c.Parent_Contact_In_Account_Membership__c = null;
        }
        
        update updateContacts;
    }
    
    private static void addRelatedContacts(Contact con, Map<String,List<Contact>> contactsHierarchyMap, List<Contact> relatedContacts){
        if(contactsHierarchyMap.containsKey(con.Id) && contactsHierarchyMap.get(con.Id).size() > 0){
            for(Contact c : contactsHierarchyMap.get(con.Id)){
                relatedContacts.add(c);
                addRelatedContacts(c,contactsHierarchyMap,relatedContacts);
            }
        }
    }

    private static Map<String,Object> getContactsMap(List<Contact> contacts){
        
        List<Contact> parentContactsWithMembership = new List<Contact>();
        Map<String,List<Contact>> parentContactsWithMembershipChildrenMap = new Map<String,List<Contact>>();
        List<Contact> contactsWithoutMembership = new List<Contact>();
        
        for(Contact con : contacts){
            if(con.Is_Account_Membership__c){
                if(con.Parent_Contact_In_Account_Membership__c == null){
                    parentContactsWithMembership.add(con);
                    if(!parentContactsWithMembershipChildrenMap.containsKey(con.Id)){
                        parentContactsWithMembershipChildrenMap.put(con.Id, new List<Contact>());
                    }
                } else {
                    Id parentContactId = con.Parent_Contact_In_Account_Membership__c;
                    if(parentContactsWithMembershipChildrenMap.containsKey(parentContactId)){
                        parentContactsWithMembershipChildrenMap.get(parentContactId).add(con);
                    } else {
                        parentContactsWithMembershipChildrenMap.put(parentContactId, new List<Contact>{con});
                    }
                }
            } else {
                contactsWithoutMembership.add(con);
            }
        }
        
        return new Map<String,Object>{
            'parentContactsWithMembership' => parentContactsWithMembership,
            'parentContactsWithMembershipChildrenMap' => parentContactsWithMembershipChildrenMap
        };
    }

    //搜索联系人
    @AuraEnabled
    public static List<Contact> searchContact(String name,String accountId) {
        String userId = UserInfo.getUserId();
        List<Contact> conList = [SELECT Name, Id From Contact where OwnerId =: userId And Name LIKE: ('%' + name + '%')
         And AccountId =: accountId 
         And Is_Account_Membership__c = false];
        return conList;
    }
}