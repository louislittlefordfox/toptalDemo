({
	openForm : function(component, event, helper) {
		var e = component.get("v.appointment");
        var compEvent = $A.get("e.c:openForm");
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        compEvent.setParams({
            "specialist" : e.specialist,
            "specialism": e.specialism,
            "specialistId" : e.specialistId,
            "appointmentDate": e.appointmentDate,
            "timeSlot": e.timeSlot,
            "patientId": e.patientId,
            "appointmentId": e.appointmentId,
            "cost": e.cost
        });
        compEvent.fire();
	}
})