global class getEventsSchedulable implements Schedulable {
	global void execute(SchedulableContext SC) {
   		For(user u : [SELECT Id from User where Name = 'Louis Fox' OR Name = 'Siggy Vik']){
            ID jobID = System.enqueueJob(new EventHelperQueueable(u.Id));
        }
	}
}