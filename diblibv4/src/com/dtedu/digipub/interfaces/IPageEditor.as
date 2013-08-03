package com.dtedu.digipub.interfaces
{	
	import com.dtedu.dcl.interfaces.IDCLComponent;
	
	import flash.geom.Point;

	public interface IPageEditor extends IEditor
	{	
		function addElement(element:IDCLComponent):void;
		
		function removeElement(element:IDCLComponent):void;
		
		function set backgroundImage(image:String):void;
		
		function set backgroundColor(color:uint):void;
	}
}