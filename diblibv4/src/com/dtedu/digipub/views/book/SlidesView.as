package com.dtedu.digipub.views.book
{
	import com.dtedu.digipub.dib.DIBCommon;
	import com.dtedu.digipub.interfaces.IBookView;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.IPageView;
	import com.dtedu.trial.events.AsyncEvent;
	import com.dtedu.trial.interfaces.IListener;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	public class SlidesView implements IBookView
	{
		private var _viewport:DisplayObjectContainer;
		private var _activePage:IPageView;
		private var _viewer:IBookViewer;
		private var _grow:GlowFilter;
		
		public function SlidesView(viewer:IBookViewer)
		{
			this._viewer = viewer;
			this._viewport = new Sprite();
			this._grow = new GlowFilter(0, 0.6, 24, 24, 2, 2);
		}
		
		public function get focusPage():IPageView
		{
			return null;
		}
		
		public function get pageScaleRatio():Number
		{
			return 0;
		}
		
		public function set pageScaleRatio(ratio:Number):void
		{
		}
		
		public function loadPage(page:IPageFile):void
		{
			var newPageView:IPageView = this._viewer.controller.createPageView(this, page);				
			
			if (newPageView !== this._activePage)
			{
				this._removePage();								
				
				this._activePage = newPageView;		
				
				if (this._viewer.editMode)
				{				
					this._activePage.displayObject.filters = [this._grow];
				}
				
				this._viewport.addChild(this._activePage.displayObject);
			}
		}
		
		public function loadPages(pages:Vector.<IPageFile>):void
		{
		}
		
		public function get viewport():DisplayObjectContainer
		{
			return this._viewport;
		}
		
		public function invalidate():void
		{
			var index:int = _viewer.navigator.currentPageIndex;	
			var pageCount:int = _viewer.controller.bookFile.pageCount;						
			
			if (pageCount == 0)
			{
				this._removePage();			
				
				//_viewport.addChild(  );
			}
			else
			{
				var listener:IListener = _viewer.controller.loadPageAsync(index);
				
				listener.listen(function (e:AsyncEvent):void
				{
					if (e.endAsync())
					{
						loadPage(IPageFile(e.data));						
					}
					else
					{
						_viewer.kernel.reportError(
							"Failed to load page " + index + ": " + e.data,
							DIBCommon.DIB_TYPE
						);
					}									
				});						
			}
		}
		
		private function _removePage():void
		{
			if (this._activePage)
			{				
				this._activePage.standby();			
				
				this._viewport.removeChild(this._activePage.displayObject);
				this._activePage.displayObject.filters = null;				
				this._activePage = null;	
			}						
		}
		
		public function get height():Number
		{
			return this._viewport.height;
		}
		
		public function set height(value:Number):void
		{
			//this._viewport.height = value;
		}
		
		public function get width():Number
		{
			return this._viewport.width;
		}
		
		public function set width(value:Number):void
		{
			//this._viewport.width = value;
		}
		
		public function dispose():void
		{
		}
	}
}