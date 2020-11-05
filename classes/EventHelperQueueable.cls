public class EventHelperQueueable implements Queueable {
    public final Id userId;
    public EventHelperQueueable(Id input)
    {
        userId = input;
    }
    public void execute(QueueableContext context)
    {         
        GoogleCallouts.getCalendar(userId);
    }
}