package com.dtedu.digipub.editors
{
	import com.dtedu.digipub.dib.DIBCommon;
	import com.dtedu.digipub.events.BookViewerEvent;
	import com.dtedu.digipub.interfaces.IBookController;
	import com.dtedu.digipub.interfaces.IBookEditor;
	import com.dtedu.digipub.interfaces.IBookFile;
	import com.dtedu.digipub.interfaces.IBookView;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.interfaces.INavigator;
	import com.dtedu.digipub.interfaces.IPageEditor;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.IPageView;
	import com.dtedu.trial.events.AsyncEvent;
	import com.dtedu.trial.interfaces.IListener;
	
	import flash.utils.setInterval;
	
	public class BookEditor implements IBookEditor
	{
		default xml namespace = DIBCommon.dibNamespace; 
		
		private var _viewer:IBookViewer;
		private var _pageEditor:PageEditor;
		private var _defaultPageSettings:Object;				
		
		public function BookEditor(viewer:IBookViewer)
		{
			_viewer = viewer;
			_defaultPageSettings = {};
		}				
		
		public function setDefaultPageSetting(name:String, value:*):void
		{
			this._defaultPageSettings[name] = value;
		}
		
		public function getDefaultPageSetting(name:String):*
		{
			return this._defaultPageSettings[name];	
		}		
		
		public function get currentPageEditor():IPageEditor
		{
			return (_pageEditor ||= new PageEditor(_viewer.bookView));					 
		}

		public function appendNewPageAfterPagination(value:int):void
		{			
			var newPage:XML = DIBCommon.pageItemTemplate;
			
			var backgroundImage:String = this.getDefaultPageSetting("backgroundImage");
			if (backgroundImage && backgroundImage != '')
			{
				newPage.body.@backgroundImage = backgroundImage;
			}
			else
			{
				newPage.body.@backgroundImage = "";
			}
			
			//_executePageCommand(value+1, new AddPageCommand(),null, newPage);
		}
		
		public function appendNewPage():void
		{
			//appendNewPageAfterPagination(_viewer.bookController.bookFile.pageCount-1);
		}			
		
		public function removePage(page:IPageFile):IPageView
		{	
			return null;
		}
		
		public function dispose():void
		{
			_viewer = null;
			_pageEditor && _pageEditor.dispose();
			_pageEditor = null;
		}
		
		public function appendPage(page:IPageFile):IPageView
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function load(value:XML):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function save():XML
		{
			// TODO Auto Generated method stub
			return null;
		}
		
	}
}