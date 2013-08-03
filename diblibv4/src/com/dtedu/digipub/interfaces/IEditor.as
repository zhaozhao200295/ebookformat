package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IDisposable;
	
	public interface IEditor extends IDisposable
	{
		function load(value:XML):void;
		
		function save():XML;
	}
}