public class AppointmentTriggerHandler implements triggerHandlerInterface {
    
    public static Boolean TriggerDisabled = false;
 
    public Boolean IsDisabled(){
    	return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {
        List<Appointment__c> appointmentList = (List<Appointment__c>)newItems;
        checkForClashes(appointmentList);
        sendInvites(appointmentList);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Appointment__c> appointmentList = (Map<Id, Appointment__c>)newItems;
        checkForClashes(appointmentList.values());
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id, Appointment__c> appointmentMap = (Map<Id, Appointment__c>)newItems;
       	getMessagesToCustomers(appointmentMap.values());
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {
    }
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    private static void checkForClashes(List<Appointment__c> appointmentList) {
        Map<String, Appointment__c> doctorAppointmentMap = new Map<String, Appointment__c>();
        Map<String, Appointment__c> patientAppointmentMap = new Map<String, Appointment__c>();
        List<String> timeSlots = new List<String>();
        List<String> specialists = new List<String>();
        List<Date> days = new List<Date>();
        List<String> patients = new List<String>();
        For(Appointment__c a : appointmentList) {
            timeSlots.add(a.Time_Slot__c);
            specialists.add(a.OwnerId);
            days.add(a.Date__c);
            patients.add(a.Patient__c);
        }
        For(Appointment__c a : [SELECT Id, Date__c, OwnerId, Time_Slot__c, Patient__c FROM Appointment__c WHERE Time_Slot__c IN: timeSlots AND Date__c IN: days AND (OwnerId IN: specialists OR Patient__c IN: patients)]){
            doctorAppointmentMap.put(a.Date__c + a.Time_Slot__c + a.OwnerId, a);
            patientAppointmentMap.put(a.Date__c + a.Time_Slot__c + a.Patient__c, a);
        }
        
        For(Appointment__c a : appointmentList) {
            if(doctorAppointmentMap.get(a.Date__c + a.Time_Slot__c + a.OwnerId) <> null || patientAppointmentMap.get(a.Date__c + a.Time_Slot__c + a.Patient__c) <> null) {
                //if this is from google api just dont add it, otherwise add error.
                if(!a.fromGoogleCalendar__c) a.addError('Sorry, there appears to be a schedule conflict');
            }
        }    
	}
    
    private static void sendInvites(List<Appointment__c> appointmentList) { 
       
        List<Id> contactIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        For(Appointment__c a : appointmentList) {
            if(!a.fromGoogleCalendar__c) {
                contactIds.add(a.Patient__c);
            	userIds.add(a.OwnerId);
            }
        }
        Map<Id, Contact> cMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN: contactIds]);
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN: userIds]);
        
       	if(userMap.size() > 0) getMessagesToSpecialists(appointmentList, userMap, cMap);
    }
    
    private static void getMessagesToSpecialists(List<Appointment__c> appointmentList, Map<Id, User> userMap, Map<Id, Contact> cMap) {
        List<Messaging.SingleEmailMessage> messageListToSpecialists = new List<Messaging.SingleEmailMessage>();
        For(Appointment__c a : appointmentList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(new List<String>{userMap.get(a.OwnerId).Email});
            mail.setSubject('Meeting Invitation: ' + cMap.get(a.Patient__c).Name);      
            mail.setPlainTextBody('');     
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
            attach.setFileName('invite.ics');         
            attach.body = invite(a, cMap.get(a.Patient__c));
            attach.setContentType('text/calendar');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
            messageListToSpecialists.add(mail);
        }
        Messaging.SendEmailResult[] er = Messaging.sendEmail(messageListToSpecialists); 
        
    }
    
    private static void getMessagesToCustomers(List<Appointment__c> appointmentList) {
        List<Id> contactIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        For(Appointment__c a : appointmentList) {
                contactIds.add(a.Patient__c);
            	userIds.add(a.OwnerId);
        }
        Map<Id, Contact> cMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN: contactIds]);
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN: userIds]);
       
        List<Messaging.SingleEmailMessage> messageListToCustomers = new List<Messaging.SingleEmailMessage>();
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Appointment_Confirmation' LIMIT 1][0].Id;
        For(Appointment__c a : appointmentList) {
            if(!a.fromGoogleCalendar__c) {
            Messaging.SingleEmailMessage m = Messaging.renderStoredEmailTemplate(templateId, a.Id, a.Patient__c);
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setPlainTextBody(m.getPlainTextBody());
            msg.setSubject('Appointment Confirmation');
            msg.setToAddresses(new List<String>{cMap.get(a.Patient__c).Email});
            messageListToCustomers.add(msg);
            }
        }
        if(messageListToCustomers.size() > 0) Messaging.SendEmailResult[] er = Messaging.sendEmail(messageListToCustomers);
    }
    
    private static Blob invite(Appointment__c a, Contact c) {
        Date dt= a.Date__c;
        String month = dt.month() < 10 ? '0' + dt.month() : String.valueOf(dt.month());
        String day = dt.day() < 10 ? '0' + dt.day() : String.valueOf(dt.day());
        String appointmentStartTime = a.Time_Slot__c.replace(':', '');
        String appointmentEndTime = getEndTime(appointmentStartTime);
        System.debug(appointmentStartTime + ' ' + appointmentEndTime);
        String startdatetime=String.valueof(dt.year()+month+''+day+'T'+appointmentStartTime+'00Z');
        String enddatetime=String.valueof(dt.year()+month+''+day+'T'+appointmentEndTime+'00Z');
        
        String inv = '';
        inv += 'BEGIN:VCALENDAR\n';
		inv += 'PRODID:-//Google Inc//Google Calendar 70.9054//EN\n';
        inv += 'VERSION:2.0\n';
		inv += 'CALSCALE:GREGORIAN\n';
		inv += 'METHOD:REQUEST\n';
		inv += 'BEGIN:VEVENT\n';
		inv += 'DTSTART:' + startdatetime+'\n';
		inv += 'DTEND:' + enddatetime + '\n';
		inv += 'DTSTAMP:20201102T144626Z\n';
		inv += 'ORGANIZER;CN=louislittlefordfox@gmail.com:mailto:louislittlefordfox@gmail.com\n';
		inv += 'UID:hallloysodzxcdf0oo@google.com\n';
		inv += 'ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE;CN=louis.a.fox12@gmail.com;X-NUM-GUESTS=0:mailto:louis.a.fox12@gmail.com\n';
		inv += 'ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE;CN=louislittlefordfox@gmail.com;X-NUM-GUESTS=0:mailto:louislittlefordfox@gmail.com\n';
		inv += 'X-MICROSOFT-CDO-OWNERAPPTID:-1872871622\n';
		inv += 'CREATED:20201102T144623Z\n';
		inv += 'DESCRIPTION;';
		inv += 'LAST-MODIFIED:20201102T144624Z\n';
		inv += 'LOCATION:Oslo\n';
		inv += 'SEQUENCE:0\n';
		inv += 'STATUS:CONFIRMED\n';
		inv += 'SUMMARY;';
        inv += 'LANGUAGE=en-us:' + a.Specialization__c + ' Appointment: ' + c.Name + '\n';
        inv += 'TRANSP:OPAQUE\n';
        inv += 'END:VEVENT\n';
        inv += 'END:VCALENDAR\n';
        return Blob.valueOf(inv);
    }
    
    private static string getEndTime(String startTime) {
        String minutes = startTime.substring(2);
        String hours = startTime.substring(0,2);
        if(minutes == '30') {
            minutes = '00';
            hours = String.valueOf(Integer.valueOf(hours) + 1);
        } else {
            minutes = '30';
        }
        return hours + minutes;
    }
}