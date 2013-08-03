package com.dtedu.dcl.events
{
	import flash.events.Event;
	
	public class ModeChangeEvent extends Event
	{
		public static const MODE_CHANGE:String = "modeChange";		
		
		public var mode:String;
		
		public function ModeChangeEvent(mode:String)
		{
			super(MODE_CHANGE);			
			
			this.mode = mode;
		}
	}
}