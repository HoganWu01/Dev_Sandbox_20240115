/*
    @Author:Scott
    @Function:
    The trigger template,all trigger handler class should implements Triggers.Handler interface
    in trigger,just write like this:
    new Triggers().bind(***,***).execute(); 
*/  
public class Triggers {
    /*
        SObject 增删改查 动作
        原文:
        Enum representing each of before/after CRUD events on Sobjects
    */
    public enum Evt
    {
        AfterDelete, 
        AfterInsert, 
        AfterUndelete,
        AfterUpdate, 
        BeforeDelete, 
        BeforeInsert, 
        BeforeUpdate    
    }
    
    /*
        Simplistic handler to implement on any of the event. It doesn't requires or enforces any patter except the
        method name to be "handle()", a developer is free to use any Trigger context variable or reuse any other
        apex class here.
    */
    public interface Handler 
    {
        void handle();          
    } 
    
    // Store binding handlers
    Map<String, List<Handler>> eventHandlerMapping = new Map<String, List<Handler>>();
    
    /*
        原文:
        Core API to bind handlers with events
    */
    public Triggers bind(Evt event, Handler eh) 
    {
        List<Handler> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) 
        {
            handlers = new List<Handler>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }
    
    /*
        原文:
        Invokes correct handlers as per the context of trigger and available registered handlers
    */
    public void execute() 
    {
        Evt ev = null;
        if(Trigger.isInsert && Trigger.isBefore)
        {
            ev = Evt.beforeinsert;
        } 
        else if(Trigger.isInsert && Trigger.isAfter)
        {
            ev = Evt.afterinsert;
        } 
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
            ev = Evt.beforeupdate;
        } 
        else if(Trigger.isUpdate && Trigger.isAfter)
        {
            ev = Evt.afterupdate;
        } 
        else if(Trigger.isDelete && Trigger.isBefore)
        {
            ev = Evt.beforedelete;
        } 
        else if(Trigger.isDelete && Trigger.isAfter)
        {
            ev = Evt.afterdelete;
        } 
        else if(Trigger.isundelete)
        {
            ev = Evt.afterundelete;             
        }
        List<Handler> handlers = eventHandlerMapping.get(ev.name());
        if (handlers != null && !handlers.isEmpty()) 
        {
            for (Handler h : handlers) 
            {
                h.handle();
            }
        }
    }
}