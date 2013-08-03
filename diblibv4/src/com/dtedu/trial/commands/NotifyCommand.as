package com.dtedu.trial.commands
{
	import com.dtedu.trial.interfaces.IDataBag;
	import com.dtedu.trial.interfaces.IKernel;
	
	public class NotifyCommand extends AbstractCommand
	{
		public function NotifyCommand(kernel:IKernel)
		{
			super(kernel, null);
		}
	}
}