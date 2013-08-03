package com.dtedu.ebook.interfaces
{
	import flash.display.DisplayObjectContainer;
	import flash.system.LoaderContext;
	
	/**
	 * @date 2013-6-9 上午9:48:49
	 * @author Jeff
	 *
	 */
	
	public interface ILoadManager extends IManager
	{
		/**
		 * 添加加载到加载队列 
		 * @param _url 加载路径
		 * @param _completeFunction 加载完成调用方法
		 * @param _container 父容器
		 * @param _context LoaderContext
		 * 
		 */	
		function load(_url:String,_completeFunction:Function=null,_container:DisplayObjectContainer=null,_context:LoaderContext=null):void;
		
		/**
		 * 停止当前所有加载,清空加载队列 
		 * 
		 */	
		function stopAll():void;
		
		/**
		 * 取消加载队列中指定加载路径;
		 * @param value 指定加载路径
		 * 
		 */	
		function cancelLoad(value:String):void;
		
		/**
		 * 返回是否加载中 
		 * @return 
		 * 
		 */	
		function get isLoading():Boolean;
	}
}