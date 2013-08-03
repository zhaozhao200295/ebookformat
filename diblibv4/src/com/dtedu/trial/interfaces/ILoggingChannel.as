package com.dtedu.trial.interfaces
{
	public interface ILoggingChannel extends IDisposable
	{
		function init(kernel:IKernel, params:Object):void;
		function log(category:Object, level:int, object:Object):void;		
	}
}