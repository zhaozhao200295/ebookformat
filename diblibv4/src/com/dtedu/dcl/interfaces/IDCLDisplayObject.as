package com.dtedu.dcl.interfaces
{
	import com.dtedu.trial.interfaces.IDisposable;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

	public interface IDCLDisplayObject extends IEventDispatcher, IDisposable
	{
		/**
		 * 获取displayObject对象。
		 */ 
		function get displayObject():DisplayObject;
	}
}