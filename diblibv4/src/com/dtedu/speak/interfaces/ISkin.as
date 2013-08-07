package com.dtedu.speak.interfaces
{
	import flash.display.DisplayObject;

	public interface ISkin
	{
		function get upStyle():DisplayObject;
		
		function get overStyle():DisplayObject;
		
		function get downStyle():DisplayObject;
	}
}