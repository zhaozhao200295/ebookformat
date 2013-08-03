package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IDisposable;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	
	public interface IBookView extends IDisposable, IView
	{
		function get viewport():DisplayObjectContainer;
		
		function get focusPage():IPageView;		
		
		function get pageScaleRatio():Number;
		
		function set pageScaleRatio(ratio:Number):void;
		
		function loadPage(page:IPageFile):void;
		
		function loadPages(pages:Vector.<IPageFile>):void;
		
		function invalidate():void;
	}
}