public class GoogleCallouts {
    public static Http http = new Http();
    public static HTTPResponse response;
    public static HttpRequest request;
    
    @Future(callout=true)
    public static void getCalendar(String userId) {
         
        String calendarId = [SELECT Email FROM User WHERE Id =: userId LIMIT 1][0].Email;
        request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setEndpoint('callout:GoogleAPI/calendar/v3/calendars/' + calendarId + '/events?timeMin=2020-11-06T00:00:00Z');
        response = http.send(request); 
        EventHelper.addEvents(userId, response.getBody().replace('end', 'endDate').replace('dateTime', 'dTime'));
    }


}