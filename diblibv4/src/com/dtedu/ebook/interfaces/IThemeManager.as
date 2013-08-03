package com.dtedu.ebook.interfaces
{
	
	import com.dtedu.bytearray.display.ScaleBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	public interface IThemeManager extends IManager
	{
		/**
		 * 根据名称获取相应的图片
		 * 
		 * className - 图片在库中的名称
		 */
		function getBitmap(className:String):Bitmap;
		
		/**
		 * 根据名称获取相应可缩放图片 
		 * @param className - 图片在库中的名称
		 * @param rect - 图片可缩放矩形
		 * @return 
		 * 
		 */		
		function getScaleBitmap( className:String,rect:Rectangle = null ):ScaleBitmap;
		
		/**
		 * 根据名称获取相应的图片 
		 * @param className - 图片在库中的名称
		 * @return 
		 * 
		 */		
		function getBitmapData(className:String):BitmapData;
		
		/**
		 * 根据名称获取相应的影片剪辑 
		 * @param className - 影片剪辑在库中的名称
		 * @return 
		 * 
		 */		
		function getMovieClip(className:String):MovieClip;
		
		/**
		 * 根据名称获取库中资源的类 
		 * @param className - 资源在库中的名称
		 * @return 
		 * 
		 */		
		function getClass(className:String):Class;
		
		/**
		 * 加载一个皮肤库
		 * 
		 * key - 皮肤库键名
		 * value - 皮肤库键值
		 */
		function addStyle(key:String, value:Object):void;
	}
}