package com.dtedu.digipub.interfaces
{
	public interface INavigator extends IViewerController
	{
		/**
		 * 获取当前页面缩影
		 */
		function get currentPageIndex():int;
		
		/**
		 * 获取当前页面编号
		 */
		function get currentPageID():String;
		
		/**
		 * 跳转到上一页。 
		 */	
		function gotoPreviousPage():void;
		/**
		 * 跳转到下一页。 
		 */
		function gotoNextPage():void;
		
		/**
		 * 跳转到首页。 
		 */
		function gotoFirstPage(force:Boolean = false):void;
		/**
		 * 跳转到末页。 
		 */
		function gotoLastPage(force:Boolean = false):void;	
		/**
		 * 跳转到目录页
		 */
		function gotoTocPage():void;
		
		/**
		 * 跳转到指定下标页（封面为0，依次排序）。 
		 */
		function gotoPageByIndex(value:int, force:Boolean = false):void;
		
		/**
		 * 跳转到指定页面 
		 */
		function gotoPageByPageID(value:String, force:Boolean = false):void;
		
		/**
		 * 刷新导航程序
		 * 删除页面时调用该方法 
		 */	
		function reload():void;	
		
		/**
		 * 获取自动播放状态。
		 */
		function get autoPlay():Boolean;
		
		/**
		 * 设置自动播放。
		 */
		function set autoPlay(newValue:Boolean):void;
	}
}