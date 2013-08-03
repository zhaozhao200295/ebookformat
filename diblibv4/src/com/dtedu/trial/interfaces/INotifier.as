package com.dtedu.trial.interfaces
{
	public interface INotifier
	{
		/**
		 * 异步操作结果通知。
		 */ 
		function notify(succeeded:Boolean, data:* = null):void;
		
		/**
		 * 异步操作进度通知。
		 */ 
		function notifyProgress(progress:Number, total:Number):void;
	}
}