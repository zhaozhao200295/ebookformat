package com.dtedu.digipub
{
	import com.dtedu.digipub.events.BookViewerEvent;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.interfaces.INavigator;
	
	public class Navigator implements INavigator
	{
		private var _bookViewer:IBookViewer;
		
		private var _currentPageIndex:int;

		private var _currentPageID:String;				
		
		private var _hoveredPageIndex:int;
		
		public function Navigator(bookViewer:IBookViewer)
		{
			this._bookViewer = bookViewer;
		}
		
		public function set currentPageIndex(index:int):void
		{
/*			(bookViewer.bookView as IFlipBook).currentPageIndex = index;
			
			_currentPageID = this._bookViewer.controller.bookFile.getPageIDByIndex(_currentPageIndex);*/
		}
		
		[Bindable]
		public function get currentPageIndex():int
		{
			return this._currentPageIndex;
		}
		
		public function set hoveredPageIndex(value:int):void
		{
			this._hoveredPageIndex = value;
		}
		
		public function get hoveredPageIndex():int
		{
			return this._hoveredPageIndex;
		}
		
		public function set focusePageIndex(index:int):void
		{
			_currentPageIndex = index;
		}
		
		public function gotoPreviousPage():void
		{
			if (_currentPageIndex > 0)
			{
				currentPageIndex--;                
			}	
		}
		
		public function gotoNextPage():void
		{
			var pageCount:int = this._bookViewer.controller.bookFile.pageCount;
			if (_currentPageIndex < pageCount-1)
			{
				currentPageIndex++;                
			}	
			else 
			{
				currentPageIndex = pageCount - 1;
			}
		}
		
		public function gotoFirstPage(force:Boolean=false):void
		{
			if (force)
			{
				currentPageIndex = -1;
			}
			
			currentPageIndex = 0;   
		}
		
		public function gotoLastPage(force:Boolean=false):void
		{
			if (force)
			{
				currentPageIndex = -1;
			}
			
			currentPageIndex = this._bookViewer.controller.bookFile.pageCount - 1; 
		}
		
		public function gotoTocPage():void
		{
			if(!this._bookViewer.controller.bookFile.bookTocPage) return;
			
			//currentPageIndex = this._bookViewer.controller.bookFile.bookTocPage;
		}
		
		public function gotoPageByIndex(value:int, force:Boolean=false):void
		{
			if (force)
			{
				currentPageIndex = -1;
				return;
			}
			
			if(value == -1)
			{
				currentPageIndex = 0;
				return;
			}
			
			currentPageIndex = value; 
		}
		
		public function gotoPageByPageID(value:String, force:Boolean = false):void
		{
			if(!value) return;
			
			var pageIndex:int = this._bookViewer.controller.bookFile.getPageIndexByID(value);
			gotoPageByIndex(pageIndex, force);
		}
		
		public function reload():void
		{
			var old:int = this._currentPageIndex;
			var pageCount:int = this._bookViewer.controller.bookFile.pageCount;
			
			if( pageCount == 0)
			{
				currentPageIndex = -1;				
			}
			else
			{
				var newIndex:int = this._bookViewer.controller.bookFile.getPageIndexByID(_currentPageID);
				if (newIndex == -1)
				{
					//该页已被删除
					newIndex = old;
				}
				
				if (newIndex == old)
				{
					currentPageIndex = -1;					
				}
				
				currentPageIndex = newIndex;							
			}
		}
		
		public function get bookViewer():IBookViewer
		{
			return this._bookViewer;
		}
		
		public function dispose():void
		{
			this._bookViewer = null;
		}
		
		public function get autoPlay():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function set autoPlay(newValue:Boolean):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get currentPageID():String
		{
			// TODO Auto Generated method stub
			return null;
		}
	}
}