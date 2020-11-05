public class EventHelper {
    
    public static void addEvents(Id userId, String res) {
        //String userEmail = [SELECT Email FROM User WHERE Id =: userId LIMIT 1][0].Email;
        //Get list of existing events from google calendar. 
        //TODO: if the user has not granted share access then we should ask them for it.
        GoogleEventList gel = (GoogleEventList)JSON.deserialize(res, GoogleEventList.class);
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        For(GoogleEvent ge : gel.items) {
            if(ge.start <> null && ge.endDate <> null){
                DateTime start = ge.start.dTime;
                DateTime endt = ge.endDate.dTime;
                System.debug(start + ' : ' + endt);
                Integer i = 1;
                while(start < ge.endDate.dTime) {
                    Appointment__c a = new Appointment__c();
                    a.Time_Slot__c = floorTimeSlot(start); 
                    a.eventId__c = ge.id + ':part' + i;
                    a.Date__c =  Date.newinstance(start.year(), start.month(), start.day());
                    a.OwnerId = userId;
                    a.fromGoogleCalendar__c = true;
                    appointmentList.add(a);
                    start = start.addMinutes(30);
                    i++;
                }
            }   
        }
        
        //check if there are already existing events in place and remove items if there are
        Map<Appointment__c, Date> dateMap = new Map<Appointment__c, Date>();
        Map<Appointment__c, String> timeSlotMap = new Map<Appointment__c, String>();
        For(Appointment__c a : appointmentList) {
            dateMap.put(a, a.Date__c);
            timeSlotMap.put(a, a.Time_Slot__c);
        }
        List<Appointment__c> existingAppointments = [SELECT Id, Date__c, Time_Slot__c FROM Appointment__c WHERE Date__c IN: dateMap.values() AND Time_Slot__c IN: timeSlotMap.values() AND OwnerId =: userId];
        
        Map<String, Appointment__c> existingAppointmentMap = new Map<String, Appointment__c>();
            For(Appointment__c ea : [SELECT Id, Date__c, Time_Slot__c FROM Appointment__c WHERE Date__c IN: dateMap.values() AND Time_Slot__c IN: timeSlotMap.values() AND OwnerId =: userId]) {
                existingAppointmentMap.put(String.valueOf(ea.Date__c) + ea.Time_Slot__c, ea);
            }
        
        Integer appointmentListIndex = appointmentList.size() -1;
        List<Integer> appointmentsToRemove = new List<Integer>();
        For(Appointment__c newAppointment : appointmentList) {
            if(existingAppointmentMap.get(String.valueOf(newAppointment.Date__c) + newAppointment.Time_Slot__c) <> null) {
                appointmentsToRemove.add(appointmentListIndex);
                appointmentListIndex -= 1;
            }
        }
        For(Integer index : appointmentsToRemove) {
            appointmentList.remove(index);
        }
        
        //upsert remaining appointments. Logic here is that google calendar can show when someone is busy but their plans outside of work should not be counted if they had not given access before booking was made.
        upsert appointmentList eventId__c;
    }
    
    private static String floorTimeSlot(DateTime start) {
        System.debug('start: ' + start);
        String timeSlot = String.valueOf(start.hour()-1) + ':';
        if(start.minute() >= 30) timeSlot += '30';
        else timeSlot += '00';
        System.debug(timeSlot);
        return timeSlot;
    }
    
    public class GoogleEvent {
        String id {get; set;}
        DateForm start {get; set;}
        DateForm endDate {get; set;}
    }
    
    public class DateForm {
        DateTime dTime {get; set;}
    }
    
    public class GoogleEventList {
        List<GoogleEvent> items {get; set;}
    }
    
    public class gException extends Exception {}
}