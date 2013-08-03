/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.core
{
	import com.dtedu.trial.events.AsyncEvent;
	import com.dtedu.trial.interfaces.IAsyncToken;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.interfaces.IListener;
	import com.dtedu.trial.interfaces.INotifier;
	
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import com.dtedu.trial.helpers.EC;
	
	public class AsyncToken extends EventDispatcher implements IAsyncToken, INotifier, IListener
	{					
		private static const NOTIFY:String = "notify";		
		
		private var _ec:EC = new EC();
		
		private var _disposed:Boolean;
		
		private var _kernel:IKernel;
		
		public function AsyncToken(kernel:IKernel)
		{
			super();
			
			_kernel = kernel;
		}				
		
		public function get listener():IListener
		{			
			return this;
		}
		
		public function get notifier():INotifier
		{			
			return this;
		}				
		
		public function notify(succeeded:Boolean, data:* = null):void
		{
			if (_disposed) return;			
			
			cufCallLater(
				0, 
				function ():void { dispatchEvent(new AsyncEvent(NOTIFY, _kernel, succeeded, data)) }													
			);			
		}
		
		public function notifyProgress(progress:Number, total:Number):void
		{
			if (_disposed) return;
			
			cufCallLater(
				0, 
				function ():void { dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, progress, total)) }													
			);						
		}
		
		public function listen(listener:Function, weak:Boolean = false):void
		{
			_ec.add(this, NOTIFY, listener, false, 0, weak);
		}
		
		public function listenProgress(progressListener:Function, weak:Boolean = false):void
		{
			_ec.add(this, ProgressEvent.PROGRESS, progressListener, false, 0, weak);
		}
		
		public function dispose():void
		{
			_ec.remove(this);	
			_disposed = true;
		}
	}
}