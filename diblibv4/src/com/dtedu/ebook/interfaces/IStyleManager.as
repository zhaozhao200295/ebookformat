package com.dtedu.ebook.interfaces
{
	public interface IStyleManager extends IManager
	{
		/**
		 * 根据名称获取相应的图片
		 * 
		 * name - 图片名称
		 */
		function getImageByName(className:String):Class;
		
		/**
		 * 加载一个皮肤库
		 * 
		 * key - 皮肤库键名
		 * value - 皮肤库键值
		 */
		function addStyle(key:String, value:Object):void;
	}
}