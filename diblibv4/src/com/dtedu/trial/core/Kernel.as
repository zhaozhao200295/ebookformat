/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.core
{
	import com.dtedu.trial.utils.StringUtil;
	import com.dtedu.trial.errors.AssertError;
	import com.dtedu.trial.helpers.EC;
	import com.dtedu.trial.helpers.Logger;
	import com.dtedu.trial.i18n.Localizer;
	import com.dtedu.trial.interfaces.IAsyncToken;
	import com.dtedu.trial.interfaces.IBrowserNavigator;
	import com.dtedu.trial.interfaces.ICommand;
	import com.dtedu.trial.interfaces.IDataBag;
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.interfaces.IKernelProvider;
	import com.dtedu.trial.interfaces.ILocalizer;
	import com.dtedu.trial.interfaces.ILogger;
	import com.dtedu.trial.interfaces.IResourceProvider;
	import com.dtedu.trial.interfaces.IServiceFactory;
	import com.dtedu.trial.interfaces.ISettings;
	import com.dtedu.trial.loading.ResourceProvider;
	import com.dtedu.trial.messages.CommandMessage;
	import com.dtedu.trial.miscs.Common;
	import com.dtedu.trial.navigation.BrowserNavigator;
	import com.dtedu.trial.net.ServiceFactory;
	import com.dtedu.trial.storage.DataBag;
	import com.dtedu.trial.storage.Pool;
	import com.dtedu.trial.storage.Settings;
	import com.dtedu.trial.utils.Debug;
	import com.dtedu.trial.utils.Globals;
	import com.dtedu.trial.utils.URLUtil;
	import com.dtedu.trial.utils.WeakRef;
	
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	//import mx.controls.Alert;

	public class Kernel implements IKernel, IKernelProvider
	{					
		private static var __kernel:IKernel;	
		private static var __instanceMap:Dictionary;											
		
		public static function getInstance(root:DisplayObject = null):IKernel
		{		
			if (!root)
			{
				if (!__kernel)
				{
					throw new IllegalOperationError("Root kernel not initialized!");
				}
				
				return __kernel;
			}
			
			__instanceMap ||= new Dictionary(true);
			
			while (!root.loaderInfo && root.parent) root = root.parent;			
			root.loaderInfo && (root = root.loaderInfo.content);			
					
			return (__instanceMap[root] || new Kernel(root, new SingletonEnforcer()));						
		}    				
		
		private var _objectPool:Pool;
		
		private var _eventDispatcher:EventDispatcher;			
		
		private var _config:XML;  
		
		private var _ec:EC;				
		
		private var _browserNavigator:IBrowserNavigator;
		
		private var _serviceFactory:ServiceFactory;
		
		private var _swfRoot:WeakRef;		
		
		private var _logger:Logger;
		
		private var _counter:int = 0;		
		
		private var _localizers:Object;
		
		private var _localData:IDataBag;
		
		public function Kernel(root:DisplayObject, singleton:SingletonEnforcer)
		{   						
			this._objectPool = new Pool();
			this._logger = new Logger();
			this._swfRoot = new WeakRef(root);
			this._eventDispatcher = new EventDispatcher();			
			this._ec = new EC();
			this._localizers = {};
			this._localData = new DataBag();
			
			__instanceMap[root] = this;
			
			this._logger.crit(
				"A trial kernel for " + String(root) + " is created.", 
				Common.LOGCAT_TRIAL
			);			
			
			if (!__kernel)
			{			
				var className:String = getQualifiedClassName(root);
				
				try
				{
					var cls:Class = Class(ApplicationDomain.currentDomain.getDefinition(className));
					if (root is cls)
					{
						__kernel = this;						
					}
				}
				catch(e:Error)
				{
					throw new IllegalOperationError("Root kernel not initialized!");
				}								
			}	
			
			if (!Globals.stage)
			{
				if (root.stage)
				{
					Globals.stage = root.stage;
				}
				else
				{
					root.addEventListener(Event.ADDED_TO_STAGE, 
						function (e:Event):void
						{
							Globals.stage = root.stage;
						}
					);
				}
			}			
		}						
		
		public function get configuration():XML
		{
			return this._config;			
		}          
		
		public function set configuration(config:XML):void
		{							
			this._config = config;			
			
			if (this._config && this._config.hasOwnProperty("logging"))
			{
				this._logger.reset(this, this._config.logging[0]);			
			}				
			else
			{
				this._logger.reset(this);	
			}						
			
			if (this._config && this._config.hasOwnProperty("services"))
			{
				this._serviceFactory || (this._serviceFactory = new ServiceFactory());
				this._serviceFactory.reset(this._config.services[0]);				
			}					
		}				
		
		public function get swfRoot():DisplayObject
		{
			return DisplayObject(this._swfRoot.value);
		}				
		
		public function get serviceFactory():IServiceFactory
		{
			return (this._serviceFactory ||= new ServiceFactory());
		}
		
		public function get resourceProvider():IResourceProvider
		{
			return ResourceProvider.getDefault();
		}
		
		public function get browserNavigator():IBrowserNavigator
		{
			return (_browserNavigator ||= new BrowserNavigator(this));
		}
		
		public function get logger():ILogger
		{
			return this._logger;
		}
		
		public function get localData():IDataBag
		{
			return this._localData;
		}
		
		public function popIdleObject(type:Class):*
		{
			return _objectPool.popOne(type);
		}
		
		public function cacheIdleObject(obj:*):void
		{			
			if (obj is IDisposable) obj.dispose();
			
			_objectPool.pushOne(obj.constructor, obj);
		}
		
		public function getLocalizer(name:String):ILocalizer
		{
			return _localizers[name];
		}
		
		public function createLocalizer(name:String, path:String, defaultLanguage:String = null):ILocalizer
		{
			Debug.assertNull(_localizers[name]);
			
			StringUtil.endsWith(path, URLUtil.URL_PATH_SEPARATOR) || (path += URLUtil.URL_PATH_SEPARATOR);
			return (_localizers[name] = new Localizer(path + name, defaultLanguage));
		}
		
		public function createKernel(any:DisplayObject):IKernel
		{
			Debug.assertNotNull(any);
			
			var root:DisplayObject = any;
			while (!root.loaderInfo && root.parent) root = root.parent;			
			root.loaderInfo && (root = root.loaderInfo.content);	
			
			Debug.assertNull(__instanceMap[root], "One swf can only have one kernel object!");							
			
			return new Kernel(root, new SingletonEnforcer());
		}
		
		public function getAutoIncreaseID(prefix:String = null, radix:int = 10):String
		{
			var id:String = _counter++.toString(radix);
			
			// If the class name ends with a digit (which some autogenerated
			// classes do), then append an underscore before appending
			// the counter.
			if (prefix)
			{
				var charCode:int = prefix.charCodeAt(prefix.length - 1);
				if (charCode >= 48 && charCode <= 57)
				{
					prefix += "_";
				}
				
				return prefix + id;
			}									
			
			return id;
		}
		
		public function createSettings():ISettings
		{
			return new Settings();
		}
		
		public function createAsyncToken():IAsyncToken
		{
			return new AsyncToken(this);			
		}
		
		public function reportWarning(errorMessage:String, category:String = null):void
		{
			this._logger.warn(errorMessage, category);
		}
		
		public function reportError(errorMessage:String, category:String = null, stopRunning:Boolean = false):void
		{			
			//TODO: refine this
			if (stopRunning)
			{
				this._logger.fatal(errorMessage, category);
				
				if (!Capabilities.isDebugger)
				{
					trace(errorMessage);
					//Alert.show(errorMessage);
				}
				
				throw new AssertError(errorMessage);				
			}
			else
			{
				this._logger.error(errorMessage, category);
				trace(errorMessage);
				//Alert.show(errorMessage);
			}					
		}					
		
		public function addCommandListener(commandName:String, listener:Function):void
		{
			this._ec.add(this._eventDispatcher, commandName, listener);
		}
		
		public function removeCommandListener(commandName:String, listener:Function):void
		{						
			if (listener != null)
			{			
				this._ec.remove(this._eventDispatcher, commandName, listener);
			}
			else
			{
				Debug.unexpectedPath("Null listener");
			}
		}
		
		public function removeAllCommandListeners(commandName:String):void
		{
			this._ec.remove(this._eventDispatcher, commandName);
		}
		
		public function sendCommandMessage(command:ICommand):void
		{
			this._eventDispatcher.dispatchEvent(new CommandMessage(command)); 
		}
		
		public function dispose():void
		{
			this._ec.remove();
			this._ec = null;
			
			!this._serviceFactory || this._serviceFactory.dispose();
			this._serviceFactory = null;
			
			this._logger.dispose();
			this._logger = null;		
			
			for each (var l:ILocalizer in this._localizers)
			{
				l.dispose();
			}
			
			this._localizers = null;	
			
			this._objectPool.clearAll();
		}
	}
}

class SingletonEnforcer
{
}