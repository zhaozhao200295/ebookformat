package com.dtedu.digipub
{
	import com.dtedu.digipub.dib.DIBCommon;
	import com.dtedu.digipub.dib.DIBWeb;
	import com.dtedu.digipub.editors.BookEditor;
	import com.dtedu.digipub.events.BookViewerEvent;
	import com.dtedu.digipub.interfaces.IBookController;
	import com.dtedu.digipub.interfaces.IBookEditor;
	import com.dtedu.digipub.interfaces.IBookView;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.interfaces.INavigator;
	import com.dtedu.digipub.views.book.SlidesView;
	import com.dtedu.trial.events.AsyncEvent;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.interfaces.IListener;
	import com.dtedu.trial.interfaces.ISettings;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	/**
	 * 当图书加载完后，触发。
	 */ 
	[Event(name = 'complete', type = 'flash.events.Event')]
	
	/**
	 * 当图书加载失败后，触发。
	 */ 
	[Event(name = 'ioError', type = 'flash.events.IOErrorEvent')]
	
	/**
	 * 当图书的缩略图更新后，触发。
	 */ 
	[Event(name = 'pageThumbnailUpdated', type = 'com.dtedu.digipub.events.BookViewerEvent')]
	
	/**
	 * 当图书的当前页面更新后，触发。
	 */ 
	[Event(name = 'currentPageChanged', type = 'com.dtedu.digipub.events.BookViewerEvent')]
	
	/**
	 * 当图书的正在保存时，触发。
	 */ 
	[Event(name = 'bookSaving', type = 'com.dtedu.digipub.events.BookViewerProgressEvent')]		
	
	/**
	 * 当图书的保存完毕后，触发。
	 */ 
	[Event(name = 'bookSaved', type = 'com.dtedu.digipub.events.BookViewerEvent')]		
	
	/**
	 * 当图书的内容有变化时，触发。
	 */ 
	[Event(name = 'bookContentChanged', type = 'com.dtedu.digipub.events.BookViewerEvent')]				
	
	public class BookViewer extends Sprite implements IBookViewer
	{
		private var _kernel:IKernel;
		private var _settings:ISettings;		
		
		private var _navigator:INavigator;
		private var _bookEditor:IBookEditor;
		
		private var _bookController:IBookController;		
		private var _bookView:IBookView;
		
		private var _viewLayer:Sprite;				
		private var _overlayLayer:Sprite;
		
		private var _editMode:Boolean;
		
		private var _detectBookChange:Boolean; 
		
		public function BookViewer()
		{
			super();				

			_navigator = new Navigator(this);
			_bookEditor = new BookEditor(this);
			_bookController = new DIBWeb(this);
			_bookView = new SlidesView(this);
			
			_viewLayer = new Sprite();
			_viewLayer.mouseEnabled = false;
			
			_overlayLayer = new Sprite();
			_overlayLayer.mouseEnabled = false;
			
			this.addChild(_bookView.viewport);
			this.addChild(_viewLayer);
			
			this.initialize();
		}				
		
		public function get kernel():IKernel
		{
			return _kernel;
		}
		
		public function get settings():ISettings
		{
			return _settings;
		}
		
		public function getLocalizedText(keyText:String, params:Object = null):String
		{
			return _kernel.getLocalizer("com.dtedu.digipub").getText(keyText, params);
		}
		
		public function get navigator():INavigator
		{
			return _navigator;
		}
		
		public function get bookEditor():IBookEditor
		{
			return _bookEditor;
		}
		
		public function get controller():IBookController
		{
			return _bookController;
		}
		
		public function get bookView():IBookView
		{
			return _bookView;
		}				
		
		public function get editMode():Boolean
		{
			return _editMode;
		}
		
		public function set editMode(value:Boolean):void
		{
			_editMode = value;
			
			//刷新状态
			invalidate();
		}	
		
		public function invalidate():void
		{
			if(_detectBookChange)
			{
				_bookView.invalidate();
			}
		}
		
		public function initialize():void
		{
			_kernel = Globals.tryGetKernel();
			_kernel.localData.setData("overlayLayer", _overlayLayer);
			_kernel.localData.setData("bookViewer", this);
			
			EmbeddedAsset.init(_kernel, _kernel.swfRoot.loaderInfo);
			
			_kernel.createLocalizer("com.dtedu.dcl", "assets/i18n").language = "zh_CN";
			_kernel.createLocalizer("com.dtedu.digipub", "assets/i18n").language = "zh_CN";	
			
			this._settings = _kernel.createSettings();
			this._settings.setup();				
			
			this._registerSettings();
		}
		
		public function loadBook(bookPath:String, type:String=null):void
		{
			type ||= DIBCommon.DIB_TYPE;		
			
			var viewer:IBookViewer = this;					
			
			var listener:IListener = _bookController.loadAsync(bookPath);
			listener.listen(function (e:AsyncEvent):void
			{
				if (e.endAsync())
				{	
					//_navigator.currentPageIndex = 0;
					_bookView.invalidate();
					
					dispatchEvent(new Event(Event.COMPLETE));		
					
					_detectBookChange = true;
				}
				else
				{
					dispatchEvent(new IOErrorEvent(
						IOErrorEvent.IO_ERROR, 
						false, false, 
						getLocalizedText(
							"Failed to load %type% book: %book_path%",
							{"%type%": type, "%book_path%": bookPath}
						)
					));										
				}
			});
		}		
		
		public function saveBook():void
		{						
			var listener:IListener = this._bookController.saveAsync();
			if (!listener) return;
			
			var viewer:IBookViewer = this;
			
			listener.listenProgress(function (e:ProgressEvent):void
			{
				//var event:BookViewerProgressEvent = new BookViewerProgressEvent(BookViewerProgressEvent.BOOK_SAVING, e);
				//viewer.dispatchEvent(event);
			});
			
			listener.listen(function (e:AsyncEvent):void
			{
				if (e.endAsync())
				{
					var event:BookViewerEvent = new BookViewerEvent(BookViewerEvent.BOOK_SAVED);
					viewer.dispatchEvent(event);	
				}		
				else
				{
					_kernel.reportWarning(
						getLocalizedText(
							"Failed to save the book."
						), 
						DIBCommon.DIBX_TYPE
					);
				}
			});			
		}
		
		public function dispose():void
		{
			!this._bookController || this._bookController.dispose()
			this._bookController = null;		
			
			!this._bookView || this._bookView.dispose();	
			this._bookView = null;	
			
			//!this._navigator || this._navigator.dispose();
			this._navigator = null;
			
			!this._bookEditor || this._bookEditor.dispose();
			this._bookEditor = null;
			
			!this._settings || this._settings.dispose()
			this._settings = null;
			
			_kernel.localData.eraseKey("bookViewer");	
			_kernel.localData.eraseKey("overlayLayer");
			_kernel = null;
		}	
		
		private function _registerSettings():void
		{
			this._settings.register("dibiFileName", DIBCommon.DINDEX, false, true);			
			this._settings.register("framesAutoSave", 30, false);
			this._settings.register("thumbnailWidth", 160, false);
			this._settings.register("thumbnailHeight", 120, false);
			this._settings.register("coverWidth", 400, false);
			this._settings.register("coverHeight", 300, false);
			this._settings.register( "manifestFileName", "manifest.xml", false, false );
		}		
	}
}