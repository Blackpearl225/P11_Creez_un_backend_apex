public with sharing class OrderHandler{
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
