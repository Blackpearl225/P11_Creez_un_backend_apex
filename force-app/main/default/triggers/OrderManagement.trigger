trigger OrderManagement on Order (before update, before insert, before delete){
	if (trigger.isUpdate){
        OrderHandler.orderWithNoProductError(trigger.new); //Throw an error if trying to update an order that has no product
	}
	if (trigger.isDelete){
	
        OrderHandler.accountHasNoOrderActive(trigger.old); // Check if account has one order and if one uncheck the active chechbox
	}
	if (trigger.isInsert){
		OrderHandler.accountHasOrderActive(trigger.new); // Check the account active chekbox if an order is added to it  
    }
}
