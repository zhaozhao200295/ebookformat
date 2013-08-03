package com.dtedu.trial.interfaces
{
	public interface IDataBag
	{
		function getData(key:String):Object;
		function setData(key:String, data:*):void;
		function eraseKey(key:String):void;		
	}
}