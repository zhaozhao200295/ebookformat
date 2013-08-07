package com.dtedu.speak.interfaces
{
	import flash.display.DisplayObject;
	
	public interface ILayer
	{
		function addPopup(displayObject:DisplayObject, modal:Boolean = false):void
		
		function centerPopup(displayObject:DisplayObject):void;
		
		function setPosition(displayObject:DisplayObject,x:int,y:int):void;
		
		function isTop( displayObject:DisplayObject):Boolean;
		
		function removePopup(displayObject:DisplayObject):void;
		
		function hasPopup(displayObject:DisplayObject):Boolean;
		
		function setTop(displayObject:DisplayObject):void;
		
		function get width():Number;
		function get height():Number;
	}
}