global class AccountOrderReminder implements Schedulable,Database.Batchable<sObject>, Database.Stateful {
    public Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Task Handler: Batch execution started');
        List<Id> accountIds =  new List<Id>();
        List<Task> tasks = [Select AccountID From TASK];
        for(Task t:tasks){
            accountIds.add(t.AccountId);
        } 
        return Database.getQueryLocator([select Id,Name from Account where Id not in (select AccountId from Order) and Id not in:accountIds
                                        ]);
        
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        List<Task> tasks =  new List<Task>();
        for (Account account : scope) {
            Task newTask = new Task(Priority = 'Normale',
                                    Status = 'Nouvelle ',
                                    Subject = 'Call',
                                    IsReminderSet = true,
                                    ReminderDateTime =system.now()+4,
                                    whatId=account.Id
                                   );
            tasks.add(newTask);
            recordsProcessed = recordsProcessed + 1;
        }
        insert tasks;
        System.debug('Task Handler: Batch executed');
        
    }
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Name
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('##Job###'+job);
        System.debug('Task handler: Batch execution finished');
        
    }
    
    global void execute(SchedulableContext ctx) {
        AccountOrderReminder aor = new AccountOrderReminder();
        Database.executeBatch(aor);
        System.debug('Task handler: Schedulable Batch Done');
    }
    
    global static void startBackLogScheduler() {
        AccountOrderReminder aor = new AccountOrderReminder();
        String FirstMondayofEveryMonth = '0 0 10 ? * 2#1';
        if(!Test.isRunningTest()){
            system.schedule('Task Handler job First Monday Of every Month',FirstMondayofEveryMonth,aor);
        }
        
    }
    
}