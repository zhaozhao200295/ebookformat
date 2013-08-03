package com.dtedu.digipub.interfaces
{
	public interface ITOCNode
	{
		function get name():String;
		function get pageID():String;
		function get parent():ITOCNode;		
		function get hasChildren():Boolean;
		function get childNodes():Vector.<ITOCNode>;	
		
		function load(data:*):void;		
		function save():XML;
	}
}