public without sharing class OpportunityMembershipController {

    public static List<String> allContactIds = new List<String>();
   @AuraEnabled
    public static Map<String,Object> getOpportunityWithContactMembership(String accountId){
        System.debug('进来了oppid' + accountId);
        List<Opportunity> opps = [Select Id, Name, OwnerId, Owner.Name, StageName, Salesdepartment__c, Group__r.name
                                  From Opportunity Where Id =: accountId];
    	System.debug('opps==== ' + opps);
    	if(opps.isEmpty()){
            return null;
        } else {
        	Opportunity opp = opps.get(0);
            List<OpportunityContactRole> ocrs = [SELECT OpportunityId, 
            ContactId FROM OpportunityContactRole WHERE OpportunityId =: 
            accountId];
    		List<String> contractIdList = new List<String>();
    		for (OpportunityContactRole temp : ocrs) {
    			contractIdList.add(temp.ContactId);
    		}
            getAllRelatedContact(contractIdList);
            allContactIds.addAll(contractIdList);
            System.debug('allContactIds====' + allContactIds);
        List<Contact> contactlist = [SELECT Id, Name, AssociationType__c, gender__c, Department, Relationship__c, Phone, 
                                 	Title, Parent_Contact_In_Account_Membership__c 
                                 	From Contact WHERE Id IN: allContactIds];
            Map<String,Object> contactsMap = getContactsMap(contactlist);
            contactsMap.put('opp',opp);
            System.debug('contactlist====' + contactlist.size());
            return contactsMap;
        }
    	      
    }

    //获取所以有关联的联系人
    private static void getAllRelatedContact(List<String> conList) {
        List<Contact> cons = [Select Id,Name FROM Contact WHERE Parent_Contact_In_Account_Membership__c IN: conList];
        List<String> temps = new List<String>();
        for (Contact con : cons) {
           System.debug('con.name====' + con.Name);
            temps.add(con.Id);
        }
        allContactIds.addAll(temps);
        if (!temps.isEmpty()) {
            getAllRelatedContact(temps);
        }
    }
    
    @AuraEnabled
    public static List<Contact> getAvailableContacts(String oppotunityId){
                System.debug('商机id====' + oppotunityId);
                List<OpportunityContactRole> ocrs = [SELECT ContactId FROM OpportunityContactRole where OpportunityId =: oppotunityId];
                List<String> contactIds = new List<String>();
                for (OpportunityContactRole orc : ocrs) {
                    contactIds.add(orc.ContactId);
                }
                allContactIds.addAll(contactIds);
                getAllRelatedContact(contactIds);
            return [Select Id, Name, gender__c, Department, Relationship__c, Phone, AccountId, ReportsToId, 
                       Parent_Contact_In_Account_Membership__c, Title 
                From Contact WHERE Id NOT IN: allContactIds];
    }

    //获取要解除关系的所有联系人
    private static void getContactList(List<String> conList, List<Contact> updateContacts){
        List<Contact> cons = [SELECT ID FROM Contact WHERE Parent_Contact_In_Account_Membership__c IN: conList];
        if (!cons.isEmpty()) {
            List<String> temps = new List<String>();
            for (Contact con : cons) {
               updateContacts.add(con); 
               temps.add(con.Id);
            }
            
            getContactList(temps, updateContacts);
        }
        
    }
    @AuraEnabled
    public static void removeContact(String contactId){
        System.debug('进到删除代码');
        // Remove this contact and children contacts
        Contact con = [Select Id, Name, AccountId From Contact Where Id =: contactId];
        List<Contact> updateContacts = new List<Contact>{con};
        List<OpportunityContactRole> ocrs = [SELECT OpportunityId, ContactId, Id FROM OpportunityContactRole WHERE ContactId =:contactId];
        if (!ocrs.isEmpty()) {
            delete ocrs;
        }
        List<String> conList = new List<String>();
        conList.add(con.Id);
        getContactList(conList, updateContacts);
        for(Contact c : updateContacts){
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
        }
        
        return new Map<String,Object>{
            'parentContactsWithMembership' => parentContactsWithMembership,
            'parentContactsWithMembershipChildrenMap' => parentContactsWithMembershipChildrenMap
        };
    }

    @AuraEnabled
    public static void addRelation(String opportunityId, String contactId) {
        if (String.isNotEmpty(opportunityId) && String.isNotEmpty(contactId)) {
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.ContactId = contactId;
            ocr.OpportunityId = opportunityId;
            insert ocr;
        }
        
    }
    //搜索联系人
    @AuraEnabled
    public static List<Contact> searchContact(String name) {
        String userId = UserInfo.getUserId();
        List<Contact> conList = [SELECT Name, Id From Contact where OwnerId =: userId And Name LIKE: ('%' + name + '%')];
        return conList;
    }
}