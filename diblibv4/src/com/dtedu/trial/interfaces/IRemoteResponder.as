package com.dtedu.trial.interfaces
{	
	public interface IRemoteResponder
	{
		function get kernel():IKernel;		
		function handleResult(data:Object):void;
		function handleFault(fault:Object):void;
	}
}