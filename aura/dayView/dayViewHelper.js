({
    getAppointments : function(component, event) {
        var action = component.get("c.findAllAppointments");
        action.setParams({
            specialization: component.get("v.specialization"),
            appointmentDate: component.get("v.dateValue")
        })
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS") {
                component.set("v.timeTable", response.getReturnValue());
                component.set("v.timeSlotList", response.getReturnValue()[0].appointments);
            }else{
                component.set("v.errorMessage", "There was an error. Please contact your System Administrator");
            }
        });
        $A.enqueueAction(action);
    },
    
	getTimeSlots : function(component, event) {
		var action = component.get("c.getTimes");
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS") {
                component.set("v.timeSlots", response.getReturnValue());
            }else{
                component.set("v.errorMessage", "There was an error. Please contact your System Administrator");
            }
        });
        $A.enqueueAction(action);
	}, 
    
    getListOfSpecialists: function(component, event) {
        var action = component.get("c.getUsers");
        action.setParams({
            specialization: component.get("v.specialization")
        })
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS") {
                component.set("v.specialists", response.getReturnValue());
            }else{
                component.set("v.errorMessage", "There was an error. Please contact your System Administrator");
            }
        });
        $A.enqueueAction(action);
    },
    
    setDate : function(component, event) {
        if(component.get("v.dateValue") == null) {
            var today = new Date();
        	var dd = String(today.getDate()).padStart(2, '0');
        	var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!	
        	var yyyy = today.getFullYear();
    		component.set("v.dateValue", yyyy + '-' + mm + '-' + dd);
            
        }
	}
})