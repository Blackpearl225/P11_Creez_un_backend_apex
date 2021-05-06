public with sharing class OrderHandler{
	//check if order has product and return true if so
	public static boolean OrderHasNoProduct(Id orderId){
		boolean bool;
		List<OrderItem> ordItem = [SELECT OrderId
		                           FROM OrderItem
		                           WHERE OrderId = :orderId];
		if (ordItem.isEmpty())
			bool = true;
		else
			bool = false;
            return bool;
	}
	// check if account has one order and return true if so
	public static boolean AccountHasOneOrder(Id accountId){
		boolean bool;
		AggregateResult[] ord = [SELECT count(id)total, AccountId, Account.Name Name
		                         FROM Order
		                         WHERE AccountId = :accountId
		                         GROUP BY AccountId, Account.Name];
        if(ord.size()==1)
            bool=true;
        else 
            bool=false;
      
		return bool;
	}
	//Check if Account has no order and if so, uncheck the  Account_active_checkbox__c checkbox  to false
	public static void accountHasNoOrderActive(List<Order> ords){
		List<Account> accts = new List<Account>();
		for (order od : ords){
			boolean check = OrderHandler.AccountHasOneOrder(od.AccountId);
			if (check){
				Account acct = [select Id, Name, Account_active_checkbox__c
				                from Account
				                where Id = :od.AccountId];
				acct.Account_active_checkbox__c = false;
				accts.add(acct);
			}
		}
		update accts;
	}
	// Check if all account has order and if so check the Account_active_checkbox__c checkbox  to true
	public static void accountHasOrderActive(List<Order> ords){
		List<Account> acctss = new List<Account>();
		for (order o : ords){
			Account acct = [select Id, Name, Account_active_checkbox__c
			                from Account
			                where Id = :o.AccountId];
			acct.Account_active_checkbox__c = true;
			acctss.add(acct);
			system.debug('acct ==>' + acct);
		}
		update acctss;
	}
	// check if order has no product and throw an alert when trying to actived it 
	public static void orderWithNoProductError(List<Order> ords){
		for (Order ord : ords){
			boolean ok = OrderHandler.OrderHasNoProduct(ord.Id);
			if (ord.Status == 'Activated'){
				if (ok){
					trigger.newMap.get(ord.Id).addError('Vous ne pouvez pas activer un order qui ne possède pas de produits!');
				}

			}
		}
	}
}
