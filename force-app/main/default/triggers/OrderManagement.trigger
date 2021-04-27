trigger OrderManagement on Order (before update, before insert, before delete){
	if (trigger.isUpdate){
        OrderHandler.orderWithNoProductError(trigger.new);
	}
	if (trigger.isDelete){
	
        OrderHandler.accountHasNoOrderActive(trigger.old);
	}
	if (trigger.isInsert){
		OrderHandler.accountHasOrderActive(trigger.new);	
    }
}