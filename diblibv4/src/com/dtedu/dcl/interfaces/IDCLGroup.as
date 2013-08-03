package com.dtedu.dcl.interfaces
{
	import com.dtedu.trial.interfaces.IChangeObserver;
	import com.dtedu.trial.interfaces.IChangeTarget;
	
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElementContainer;

	public interface IDCLGroup extends IDCLComponent, IChangeObserver, IChangeTarget
	{
		function get numVisualChildren():int;	
		
		function get visualChildren():Array;
		
		function get visualChildrenData():Array;
		
		function getComponentIndex(component:IDCLComponent):int;
		
		function getComponentByDisplayObject(object:DisplayObject):IDCLComponent;
		
		function getComponentByIndex(index:int):IDCLComponent;
		
		function addComponent(child:IDCLComponent):void;
		
		function removeComponentByIndex(index:int):void;
		
		function getComponentByID(id:String):IDCLComponent;	
	}
}