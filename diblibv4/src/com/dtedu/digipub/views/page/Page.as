package com.dtedu.digipub.views.page
{
	import com.dtedu.dcl.components.Box;
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.digipub.interfaces.IBookView;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.IPageView;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	public class Page extends Box implements IPageView
	{
		private var _bookView:IBookView;
		
		private var _pageFile:IPageFile;
		
		public function Page()
		{
			super();
		}
		
		public function get pageScaleRatio():Number
		{
			return 0;
		}
		
		public function set pageScaleRatio(ratio:Number):void
		{
		}
		
		public function get bookView():IBookView
		{
			return this._bookView;
		}
		
		public function set bookView(view:IBookView):void
		{
			this._bookView = view;
		}
		
		public function get pageFile():IPageFile
		{
			return this._pageFile;
		}
		
		public function set pageFile(page:IPageFile):void
		{
			this._pageFile = page;
			
			invalidate();
		}
		
		public function get selectedComponents():Vector.<IDCLComponent>
		{
			return null;
		}
		
		public function set selectedComponents(dcls:Vector.<IDCLComponent>):void
		{
		}
		
		public function deselect():void
		{
		}
		
		public function getThumbnail(cover:Boolean=false):ByteArray
		{
			return null;
		}
	}
}