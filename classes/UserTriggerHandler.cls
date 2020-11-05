public class UserTriggerHandler implements TriggerHandlerInterface {

        public static Boolean TriggerDisabled = false;
 
    public Boolean IsDisabled(){
    	return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id, User> userMap = (Map<Id, User>)newItems;
        List<String> userEmailAddresses = new List<String>();
        for(User u : userMap.values()) userEmailAddresses.add(u.Email);
        requestCalendarAccess(userEmailAddresses);
        
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {
    }
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    @Future
    private static void requestCalendarAccess(List<String> userEmailAddresses) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        For(String userEmailAddress : userEmailAddresses) {
            Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
            m.setToAddresses(new List<String>{userEmailAddress});
            m.setPlainTextBody('Please share your calendar with louislittlefordfox@gmail.com');
            m.setSubject('Google Calendar Share');
            messages.add(m);
            Messaging.SendEmailResult[] er = Messaging.sendEmail(messages);
        }
    }
}