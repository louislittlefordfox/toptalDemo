public class appointmentController {
	
    @AuraEnabled
    public static List<DayCalendar> findAllAppointments(Date appointmentDate, String specialization) {
       
        List<String> timeSlots = getTimes();
        List<DayCalendar> timeTable = new List<DayCalendar>();
        Map<String, Appointment__c> appointmentMap = new Map<String, Appointment__c>();
        Appointment_Cost__mdt ac = [SELECT Label, Price__c FROM Appointment_Cost__mdt WHERE Label =: specialization LIMIT 1][0];
        
        For(Appointment__c a : [SELECT Id, Specialization__c, Name, Date__c, Time_Slot__c, Patient__r.Name, Owner.Name, OwnerId, fromGoogleCalendar__c FROM Appointment__c where Date__c =: appointmentDate AND (Specialization__c =: specialization OR fromGoogleCalendar__c = TRUE)]) {
            appointmentMap.put(a.Time_Slot__c + a.Owner.Name, a);
        }
        
        List<User> specialists = [SELECT Id, Name FROM User WHERE UserRole.Name =: specialization]; //AND IsActive = TRUE
        
        For(User u : specialists) {
            DayCalendar dc = new DayCalendar();
            dc.specialist = u.Name;
            dc.isVisible = true;
            List<AppointmentSlot> appointmentSlotList = new List<AppointmentSlot>();
            For(String timeSlot: timeSlots) {
                Appointment__c a = appointmentMap.get(timeSlot + u.Name);
                if(a<>null) {
                   System.debug(a.Owner.Name);
                	System.debug(u.Name); 
                }
                if(a <> null && a.Owner.Name == u.Name) {
                    AppointmentSlot slot = new AppointmentSlot(a);
                    slot.timeSlot = timeSlot;
                    slot.cost = ac.Price__c;
                    slot.fromGoogleCalendar = a.fromGoogleCalendar__c;
                    appointmentSlotList.add(slot);
                }else {
                    AppointmentSlot slot = new AppointmentSlot();
                    slot.timeSlot = timeSlot;
                    slot.specialist = u.Name;
                    slot.specialism = specialization;
                    slot.specialistId = u.Id;
                    slot.cost = ac.Price__c;
                    slot.appointmentDate = appointmentDate;
                    appointmentSlotList.add(slot); 
                }
            }
            dc.appointments = appointmentSlotList;
            
            timeTable.add(dc);
            
        }
        return timeTable;
    }
    
    @AuraEnabled
    public static List<Specialist> getUsers(String specialization) {
        List<Specialist> specList = new List<Specialist>();
        for(User u : [SELECT Name FROM User WHERE IsActive = TRUE AND UserRole.Name =: specialization]) {
            Specialist s = new Specialist();
            s.name = u.Name;
            s.isVisible = true;
            specList.add(s);
        }
        return specList;
    }
    
    @AuraEnabled
    public static String createAppointment(Decimal cost, String specialism, String specialistId, String patientId, String timeSlot, Date appointmentDate) {
        Appointment__c a = new Appointment__c();
        a.Patient__c = patientId;
        a.Price__c = cost;
        a.Date__c = appointmentDate;
        a.Time_Slot__c = timeSlot;
        a.Specialization__c = specialism;
        a.OwnerId = specialistId;
        try {
            insert a;
            return 'SUCCESS';
        } catch(DMLException e) {
            return e.getDmlMessage(0);
        }
    }
    
    @AuraEnabled
    public static String updateAppointment(Id appointmentId, String specialism, String specialistId, String patientId, String timeSlot, Date appointmentDate) {
        Appointment__c a = new Appointment__c();
		a.Id = appointmentId;
        a.Patient__c = patientId;
        a.Date__c = appointmentDate;
        a.Time_Slot__c = timeSlot;
        a.Specialization__c = specialism;
        a.OwnerId = specialistId;
        try {
            update a;
            return 'SUCCESS';
        } catch(DMLException e) {
            return e.getDmlMessage(0);
        }
    }
    
    @AuraEnabled
    public static String deleteAppointment(Id appointmentId) {
        Appointment__c a = [SELECT Id FROM Appointment__c WHERE Id =: appointmentId LIMIT 1][0];
        try {
            delete a;
            return 'SUCCESS';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    public static List<String> getTimes(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Appointment__c.Time_Slot__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    
    public class DayCalendar {
        @AuraEnabled
        public String specialist {get; set;}
        @AuraEnabled
        public Boolean isVisible {get; set;}
        @AuraEnabled
        public List<AppointmentSlot> appointments {get; set;}
    }
    
    public class AppointmentSlot {
        @AuraEnabled
        public String timeSlot {get; set;}
        @AuraEnabled
        public Boolean fromGoogleCalendar {get; set;}
        @AuraEnabled
        public Decimal cost {get; set;}
        @AuraEnabled
        public Date appointmentDate {get; set;}
        @AuraEnabled
        public String patient {get; set;}
        @AuraEnabled
        public String patientId {get; set;}
        @AuraEnabled
        public String specialism {get; set;}
        @AuraEnabled
        public String specialist {get; set;}
        @AuraEnabled
        public String specialistId {get; set;}
        @AuraEnabled
        public String appointmentId {get; set;}
        
        public AppointmentSlot(Appointment__c a) {
            this.timeSlot = a.Time_Slot__c;
            this.appointmentDate = a.Date__c;
            this.patient = a.Patient__r.Name;
            this.patientId = a.Patient__c;
            this.specialist = a.Owner.Name;
            this.specialism = a.Specialization__c;
            this.specialistId = a.OwnerId;
            this.appointmentId = a.Id;
        }
        
        public AppointmentSlot() {
        }
    }
    
    public class Specialist {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Boolean isVisible {get; set;}
    }
}