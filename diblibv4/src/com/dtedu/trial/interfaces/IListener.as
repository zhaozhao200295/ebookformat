package com.dtedu.trial.interfaces
{
	public interface IListener
	{
		function listen(listener:Function, weak:Boolean = false):void;
		function listenProgress(progressListener:Function, weak:Boolean = false):void;
	}
}