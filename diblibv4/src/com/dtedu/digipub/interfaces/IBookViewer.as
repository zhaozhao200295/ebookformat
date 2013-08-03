package com.dtedu.digipub.interfaces 
{	
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.interfaces.ISettings;
	
	import flash.events.IEventDispatcher;
	
	/**
	 * DIB浏览器接口
	 */
	[Bindable]
	public interface IBookViewer extends IEventDispatcher, IDisposable
	{
		/**
		 * 获取TRIAL内核接口。
		 */ 
		function get kernel():IKernel;				
		
		/**
		 * 获取全局设置。
		 */ 
		function get settings():ISettings;	
		
		function getLocalizedText(keyText:String, params:Object = null):String;
		
		/**
		 * 获取导航控制器。
		 */
		function get navigator():INavigator;
		
		/**
		 * 获取图书编辑器对象。
		 */
		function get bookEditor():IBookEditor;
		
		/**
		 * 获取图书控制器对象。
		 */
		function get controller():IBookController;
		
		/**
		 * 获取View对象。
		 */ 
		function get bookView():IBookView;		
		
		/**
		 * 获取当前是否处于编辑状态。
		 */ 
		function get editMode():Boolean;
		
		/**
		 * 切换编辑状态。
		 */ 
		function set editMode(newValue:Boolean):void;
		
		/**
		 * 加载电子书。
		 */ 
		function loadBook(bookPath:String, type:String = null):void;	
		
		/**
		 * 保存电子书。
		 */ 
		function saveBook():void;
		
		/**
		 * 当Viewer内部状态发生变化后，刷新Viewer以反应新的状态。
		 */ 
		function invalidate():void;
		
	}
}
