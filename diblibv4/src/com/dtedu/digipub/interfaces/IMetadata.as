package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IDisposable;

	public interface IMetadata
	{
		function bind(key:String, functor:Function):void;
		
		function getItem(key:String):String;
		function setItem(key:String, value:String):void;
	}
}