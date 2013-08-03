package com.dtedu.trial.messages
{
	import flash.events.Event;
	
	public class ContextChangedEvent extends Event
	{
		public static const NAME:String = "[N]contextChanged";
		
		private var _contextChangingEvent:ContextChangingEvent;
		
		public function ContextChangedEvent(e:ContextChangingEvent)
		{			
			super(NAME);
			
			this._contextChangingEvent = e.clone() as ContextChangingEvent;
		}
	}
}