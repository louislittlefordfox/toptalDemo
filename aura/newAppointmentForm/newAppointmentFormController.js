({
	openForm : function(component, event, helper) {
		component.set("v.isVisible", true);
        component.set("v.timeSlot", event.getParam("timeSlot"));
        component.set("v.specialist", event.getParam("specialist"));
        component.set("v.specialistId", event.getParam("specialistId"));
        component.set("v.specialism", event.getParam("specialism"));
        component.set("v.patientId", event.getParam("patientId"));
        component.set("v.date", event.getParam("appointmentDate"));
        component.set("v.cost", event.getParam("cost"));
        component.set("v.appointmentId", event.getParam("appointmentId"));
	},
    
    newAppointment : function(component, event, helper) {
        event.preventDefault();
        var action = component.get("c.createAppointment");
        action.setParams({
            appointmentDate : component.get("v.date"),
            timeSlot : component.get("v.timeSlot"),
            specialism : component.get("v.specialism"),
            specialistId : component.get("v.specialistId"),
            patientId : component.get("v.patientId"),
            cost: component.get("v.cost")
        });
        console.log(component.get("v.cost"));
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() == "SUCCESS") {
                    component.set("v.isVisible", false);
                    
                    helper.fireAppointmentSubmittedEvent(component, event);
                } else {
                    console.log('error');
                    component.set("v.errorMessage", response.getReturnValue());
                }
            }else{
                component.set("v.errorMessage", "There was an error. Please contact your System Administrator");
            }
        });
        $A.enqueueAction(action);
    },
    
    editAppointment : function(component, event, helper) {
        event.preventDefault(); 
        var action = component.get("c.updateAppointment");
        action.setParams({
            date : component.get("v.date"),
            timeSlot : component.get("v.timeSlot"),
            specialism : component.get("v.specialism"),
            specialist : component.get("v.specialist"),
            specialistId : component.get("v.specialistId"),
            patientId : component.get("v.patientId"),
            appointmentId : component.get("v.appointmentId")
        })
        action.setCallback(this, function(response){
            console.log(response.getState());
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() == "SUCCESS") {
                    component.set("v.isVisible", false);
                } else {
                    console.log('error');
                    component.set("v.errorMessage", response.getReturnValue());
                }
            }else{
                component.set("v.errorMessage", "There was an error. Please contact your System Administrator");
            }
        });
        $A.enqueueAction(action); 
    },
    
    removeAppointment : function(component, event, helper) {
        event.preventDefault(); 
        var action = component.get("c.deleteAppointment");
        action.setParams({
            appointmentId : component.get("v.appointmentId")
        })
       	action.setCallback(this, function(response){
            console.log(response.getState());
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() == "SUCCESS") {
                    component.set("v.isVisible", false);
                } else {
                    console.log('error');
                    component.set("v.errorMessage", response.getReturnValue());
                }
            }else{
                component.set("v.errorMessage", "There was an error. Please contact your System Administrator");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    closeWindow : function(component, event, helper) {
        component.set("v.isVisible", false);
    }
})