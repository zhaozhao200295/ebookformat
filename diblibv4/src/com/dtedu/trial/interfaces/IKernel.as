package com.dtedu.trial.interfaces
{
	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;

	public interface IKernel extends IKernelProvider, IDisposable
	{					
		function get swfRoot():DisplayObject;							
		
		function get configuration():XML;				
		
		function set configuration(config:XML):void;
		
		function get serviceFactory():IServiceFactory;		
		
		function get resourceProvider():IResourceProvider;
		
		function get browserNavigator():IBrowserNavigator;
		
		function get logger():ILogger;
		
		function get localData():IDataBag;
		
		function popIdleObject(type:Class):*;
		
		function cacheIdleObject(obj:*):void;
		
		function getLocalizer(name:String):ILocalizer;		
		
		function createLocalizer(name:String, path:String, defaultLanguage:String = null):ILocalizer;
		
		function getAutoIncreaseID(prefix:String = null, radix:int = 10):String;
		
		function createSettings():ISettings;
		
		function createAsyncToken():IAsyncToken;
		
		function reportWarning(errorMessage:String, category:String = null):void;
		
		function reportError(errorMessage:String, category:String = null, stopRunning:Boolean = false):void;						
		
		function addCommandListener(commandName:String, listener:Function):void;				
		
		function removeCommandListener(commandName:String, listener:Function):void;
		
		function removeAllCommandListeners(commandName:String):void;
		
		function sendCommandMessage(command:ICommand):void;				
	}
}