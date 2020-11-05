({
	doInit : function(component, event, helper) {
        helper.setDate(component, event);
		helper.getAppointments(component,event);
        helper.getListOfSpecialists(component, event);

	},
    
    refresh : function(component, event, helper) {
        helper.getAppointments(component, event);
    },
    
    updateLists : function(component, event, helper) {
        
        var selected = component.get("v.specialists");
        var timeTable = component.get("v.timeTable");
        for(var i = 0; i < selected.length; i++) {
            for(var j = 0; j < timeTable.length; j++) {
                if(selected[i].name == timeTable[j].specialist) {
                    timeTable[j].isVisible = selected[i].isVisible ;
                }
            }
        }
        component.set("v.timeTable", timeTable);
    },
    
    updateAll : function(component, event, helper) {
        var selectAll = component.get("v.selectAll");
        var selected = component.get("v.specialists");
        var timeTable = component.get("v.timeTable");
        for(var j = 0; j < timeTable.length; j++) {
        	timeTable[j].isVisible = selectAll;
        }
        for(var i = 0; i < selected.length; i ++) {
                selected[i].isVisible = selectAll;
            	
        }
        component.set("v.specialists", selected);
        component.set("v.timeTable", timeTable); 
    }
})