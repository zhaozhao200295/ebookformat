package com.dtedu.dcl.interfaces
{
	import flash.display.DisplayObjectContainer;

	public interface IDCLOverlay extends IDCLComponent
	{				
		function get owner():IDCLComponent;		
		
		function show(onwer:IDCLComponent):void;
		function hide():void;
	}
}