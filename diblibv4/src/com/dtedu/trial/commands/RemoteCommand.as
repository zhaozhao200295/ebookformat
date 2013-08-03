/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.commands
{
	import com.dtedu.trial.core.Kernel;
	import com.dtedu.trial.interfaces.IDataBag;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.interfaces.IRemoteResponder;
	import com.dtedu.trial.net.RemoteProxy;
	
	import flash.display.DisplayObject;
	
	public class RemoteCommand extends AbstractCommand implements IRemoteResponder
	{
		public function RemoteCommand(kernel:IKernel = null, dataBag:IDataBag = null)
		{			
			kernel ||= Kernel.getInstance();
			
			super(kernel, dataBag);
		}
		
		public function getService(serviceName:String, connectionId:String = null):RemoteProxy
		{
			return new RemoteProxy(serviceName, this, connectionId);
		}					
		
		public function handleResult(data:Object):void
		{
			this.markComplete(true, data);
		}
		
		public function handleFault(fault:Object):void
		{
			this.markComplete(false, fault);
		}
	}
}