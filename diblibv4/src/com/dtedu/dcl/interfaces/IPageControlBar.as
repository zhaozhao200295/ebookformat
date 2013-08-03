package com.dtedu.dcl.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IPageControlBar extends IEventDispatcher
	{
		function set selectedIndex(value:int):void;
		function get selectedIndex():int;
		
		function get selectedPage():int;
		
		function set length(value:int):void;
		function get length():int;
		
		function set pageCount(value:Number):void;
		function get pageCount():Number;
		
		function get perPage():int;
		function set perPage( num:int ):void;
		
		function set visible(value:Boolean):void;
	}
}