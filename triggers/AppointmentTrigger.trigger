trigger AppointmentTrigger on Appointment__c (before insert, before update, before delete, after insert, after update, after delete) {
	triggerDispatcher.Run(new AppointmentTriggerHandler());
}