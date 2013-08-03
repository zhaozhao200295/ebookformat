package com.dtedu.trial.events
{
	import com.dtedu.trial.interfaces.IAsyncToken;
	import com.dtedu.trial.interfaces.IKernel;
	
	import flash.events.Event;
	
	public class AsyncEvent extends Event
	{
		public var kernel:IKernel;
		
		private var _succeeded:Boolean;
		
		public var data:*;
		
		public function AsyncEvent(type:String, kernel:IKernel, succeeded:Boolean, data:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.kernel = kernel;
			this.data = data;
			
			this._succeeded = succeeded;			
		}
		
		public function endAsync():Boolean
		{
			this.target.dispose(); 
			
			return this._succeeded;
		}				
	}
}