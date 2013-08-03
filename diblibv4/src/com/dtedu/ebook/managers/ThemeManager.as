package com.dtedu.ebook.managers
{
	import com.dtedu.bytearray.display.ScaleBitmap;
	import com.dtedu.ebook.interfaces.IThemeManager;
	import com.dtedu.ebook.miscs.ScaleBitmapConst;
	import com.dtedu.trial.utils.Debug;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class ThemeManager implements IThemeManager
	{
		private static var _instance:IThemeManager;
		private var _bitmapdataMap:Dictionary = new Dictionary();
		private var _libraryDict:Dictionary;
		
		public static function get instance():IThemeManager
		{
			if (_instance == null)
			{
				_instance = new ThemeManager();
			}
			
			return _instance;
		}
		
		public function ThemeManager()
		{
			if(_instance != null )
			{
				throw new Error("ThemeManager 单例");
			}
			_libraryDict = new Dictionary();
		}
		
		public function addStyle(key:String, value:Object):void
		{
			_libraryDict[key] = value;
			
			Debug.trace("Add style [" + key + "]", "EVM");
		}
		
		public function getBitmap(className:String):Bitmap
		{
			var bmd:BitmapData = getBitmapData(className);
			if(bmd != null)
			{
				var bmp:Bitmap = new Bitmap(bmd); 
				bmp.smoothing = true;
				return bmp;
			}
			return null;
		}
		
		public function getScaleBitmap( className:String,rect:Rectangle = null ):ScaleBitmap
		{
			var bmd:BitmapData = getBitmapData(className);
			if(bmd != null)
			{
				var sb:ScaleBitmap = new ScaleBitmap(bmd.clone());
				sb.scale9Grid = rect;
				if(rect)
				{
					sb.scale9Grid = rect;
				}
				else
				{
					sb.scale9Grid = ScaleBitmapConst[className] as Rectangle;
				}
				return sb;
			}
			return null;
		}
		
		public function getMovieClip(className:String):MovieClip
		{
			var assetClass:Class = getClass(className);
			if(assetClass != null)
			{
				return new assetClass() as MovieClip;
			}
			return null;
		}
		
		
		
		public function getBitmapData(fullClassName:String):BitmapData
		{
			if( !(fullClassName in _bitmapdataMap) )
			{
				_bitmapdataMap[fullClassName] = getBitmapdataImpl(fullClassName);
			}
			return _bitmapdataMap[fullClassName];
		}
		
		public function getClass(className:String):Class
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
		
		
		
		private function getBitmapdataImpl( fullClassName:String ):BitmapData
		{
			var assetClass:Class = getClass(fullClassName);
			if(assetClass != null)
			{
				return new assetClass(0,0) as BitmapData;
			}
			return null;
		}
		// 实现接口
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