({
	fireAppointmentSubmittedEvent : function(component, event) {
		var compEvent = $A.get("e.c:appointmentSubmitted");
        compEvent.fire();
	}
})