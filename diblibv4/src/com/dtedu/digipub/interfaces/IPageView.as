package com.dtedu.digipub.interfaces
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLContainer;
	import com.dtedu.trial.interfaces.IChangeTarget;
	import com.dtedu.trial.interfaces.ICommand;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public interface IPageView extends IDCLContainer
	{
		/**
		 * 获取或设置缩放比例
		 */
		function get pageScaleRatio():Number;
		function set pageScaleRatio(ratio:Number):void;
		
		/**
		 * 获取或设置BookView
		 * 可用于运行期更换课本渲染器
		 */
		function get bookView():IBookView;	
		function set bookView(view:IBookView):void;
		
		/**
		 * 获取或设置页面数据
		 * 可用于运行期更换页面数据
		 */
		function get pageFile():IPageFile;
		function set pageFile(page:IPageFile):void;
		
		/**
		 * 获取或设置被选择的页面元素
		 */
		function get selectedComponents():Vector.<IDCLComponent>;
		function set selectedComponents(dcls:Vector.<IDCLComponent>):void;
		
		/**
		 * 取消所有选择的页面元素
		 */
		function deselect():void;
		
		/**
		 * 获取当前页面的接图数据
		 */
		function getThumbnail(cover:Boolean = false):ByteArray;
	}
}