package com.dtedu.trial.interfaces
{
	public interface ILogger 
	{						
		function getLevelLabel(level:int):String;
		function log(level:int, content:Object, category:Object = null):void;			
		function fatal(content:Object, category:Object = null):void;
		function crit(content:Object, category:Object = null):void;
		function error(content:Object, category:Object = null):void;
		function warn(content:Object, category:Object = null):void;
		function info(content:Object, category:Object = null):void;
		function debug(content:Object, category:Object = null):void;
	}
}