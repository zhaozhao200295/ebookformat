package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IChangeTarget;

	public interface IPageFile extends IChangeTarget, IPageEditor
	{			
		function get id():String;		
		
		function get version():String;
		function set version(version:String):void;
		
		function get metadata():IMetadata;
		
		/**
		 * style元素的内容。
		 */ 
		function get style():String;
		function set style(style:String):void;
		
		/**
		 * body元素的内容。
		 */ 
		function get body():XML;
		function set body(body:XML):void;		
		
		function get lecture():XMLList;
		function set lecture(value:XMLList):void;			
	}
}