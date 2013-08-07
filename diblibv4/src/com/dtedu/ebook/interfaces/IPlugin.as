package com.dtedu.ebook.interfaces
{
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.IKernel;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.IEventDispatcher;
	
	public interface IPlugin extends IEventDispatcher, IDisposable
	{
		function get instance():DisplayObject;
		
		function get graphics():Graphics;
		
		/**
		 * 返回插件的依赖列表
		 */
		function get dependencies():Array;
		
		/**
		 * 返回插件的版本
		 */
		function get pluginVersion():String;
		
		/**
		 * 初始化插件
		 */
		function initPlugin(kernel:IKernel):void;
		
		/**
		 * 根据XML刷新插件中的内容
		 */
		function invalidatePlugin(value:String):void;
	}
}