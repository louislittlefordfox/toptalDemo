trigger UserTrigger on User (before insert, after insert) {
	triggerDispatcher.Run(new UserTriggerHandler());
}