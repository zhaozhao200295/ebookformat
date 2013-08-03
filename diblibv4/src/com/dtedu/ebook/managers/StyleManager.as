package com.dtedu.ebook.managers
{
	import com.dtedu.ebook.interfaces.IStyleManager;
	import com.dtedu.trial.miscs.Common;
	import com.dtedu.trial.utils.Debug;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class StyleManager implements IStyleManager
	{
		private static var _instance:IStyleManager;
		
		public static function get instance():IStyleManager
		{
			if (_instance == null)
			{
				_instance = new StyleManager();
			}
			
			return _instance;
		}
		
		public function StyleManager()
		{
			_instance = this;
			_libraryDict = new Dictionary();
		}
		
		
		
		private var _libraryDict:Dictionary;
		
		public function getImageByName(className:String):Class
		{
			for each(var content:MovieClip in _libraryDict )
			{
				if(content && content.loaderInfo.applicationDomain.hasDefinition( className ) )
				{
					return content.loaderInfo.applicationDomain.getDefinition( className ) as Class;
				}
			}
			
			return null;
		}
		
		public function addStyle(key:String, value:Object):void
		{
			_libraryDict[key] = value;
			
			Debug.trace("Add style [" + key + "]", "EVM");
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			return false;
		}
		
		public function dispose():void
		{
		}
	}
}