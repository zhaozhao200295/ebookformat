package com.dtedu.dcl.interfaces
{
	import com.dtedu.trial.interfaces.IChangeObserver;
	import com.dtedu.trial.interfaces.IChangeTarget;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public interface IDCLContainer extends IDCLComponent, IChangeObserver, IChangeTarget
	{
		function get numVisualChildren():int;								
		
		/**
		 * 往页面中添加或移除组件
		 */
		function addComponent(component:IDCLComponent):IDCLComponent;
		function removeComponent(component:IDCLComponent):IDCLComponent;
		
		/**
		 * 往页面中添加多个组件
		 */
		function addComponents(components:Vector.<IDCLComponent>):int;
		
		/**
		 * 移除页面中所有的组件
		 */
		function removeElements():void;
		
		function getComponentIndex(component:IDCLComponent):int;
		
		function setComponentIndex(component:IDCLComponent, index:int):void;
		
		function getComponentByDisplayObject(object:DisplayObject):IDCLComponent;
		
		function getComponentByID(id:String):IDCLComponent;	
	}
}