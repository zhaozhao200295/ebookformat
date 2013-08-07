package com.dtedu.speak.core
{
	import com.dtedu.bytearray.display.ScaleBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class ClassFactory
	{
		
		private static var _bitmapdataMap:Dictionary = new Dictionary();
		
		public function ClassFactory()
		{
			
		}
		public static function getBitmapData(cls:Class):BitmapData
		{
			if( !(cls in _bitmapdataMap) )
			{
				_bitmapdataMap[cls] = (new cls() as Bitmap).bitmapData;
			}
			return _bitmapdataMap[cls];
		}
		
		public static function getBitmap(cls:Class):Bitmap
		{
			var bmd:BitmapData = getBitmapData(cls);
			if(bmd != null)
			{
				return new Bitmap(bmd);
			}
			return null;
		}
		
		
		public static function getScaleBitmap( cls:Class ,scale9Grid:Rectangle=null):ScaleBitmap
		{
			var bmd:BitmapData = getBitmapData(cls);
			if(bmd != null)
			{
				var sb:ScaleBitmap = new ScaleBitmap(bmd.clone());
				sb.scale9Grid = scale9Grid;
				return sb;
			}
			return null;
		}
		
	}
}