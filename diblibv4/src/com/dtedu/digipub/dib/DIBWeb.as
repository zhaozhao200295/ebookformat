package com.dtedu.digipub.dib
{	
	import com.dtedu.dcl.DCLFactory;
	import com.dtedu.dcl.components.Audio;
	import com.dtedu.dcl.components.Button;
	import com.dtedu.dcl.components.Flash;
	import com.dtedu.dcl.components.Img;
	import com.dtedu.dcl.components.Plugin;
	import com.dtedu.dcl.components.Video;
	import com.dtedu.digipub.commands.SaveDIBI_ECO;
	import com.dtedu.digipub.commands.SavePage_ECO;
	import com.dtedu.digipub.events.BookViewerEvent;
	import com.dtedu.digipub.interfaces.IBookController;
	import com.dtedu.digipub.interfaces.IBookFile;
	import com.dtedu.digipub.interfaces.IBookView;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.IPageView;
	import com.dtedu.digipub.miscs.BookData;
	import com.dtedu.digipub.views.page.Page;
	import com.dtedu.ebook.managers.LoadManager;
	import com.dtedu.ebook.managers.SoundManager;
	import com.dtedu.ebook.managers.ThemeManager;
	import com.dtedu.ebook.miscs.ManagerConst;
	import com.dtedu.trial.events.AsyncEvent;
	import com.dtedu.trial.events.ResourceErrorEvent;
	import com.dtedu.trial.interfaces.IAsyncToken;
	import com.dtedu.trial.interfaces.ICommand;
	import com.dtedu.trial.interfaces.IController;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.interfaces.IListener;
	import com.dtedu.trial.interfaces.INotifier;
	import com.dtedu.trial.interfaces.IResourceLoader;
	import com.dtedu.trial.loading.ResourceType;
	import com.dtedu.trial.messages.CommandMessage;
	import com.dtedu.trial.utils.Debug;
	import com.dtedu.trial.utils.URLUtil;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class DIBWeb extends DIBNotify implements IBookController
	{
		private var _bookViewer:IBookViewer;
		
		private var _bookFile:IBookFile;
		private var _bookFactory:DCLFactory;
		
		private var _pageDataCache:Vector.<IPageFile>;
		private var _pageViewCache:Dictionary;
		private var _isSaving:Boolean;
		private var _basePath:String;				
		
		public function DIBWeb(viewer:IBookViewer)
		{		
			_bookFile = new DIBIndex(this);
			
			DCLFactory.registerComponent(Page);
			DCLFactory.registerComponent(Img);
			//DCLFactory.registerComponent(Video);
			//DCLFactory.registerComponent(Audio);
			DCLFactory.registerComponent(Flash);
			DCLFactory.registerComponent(Button);
			DCLFactory.registerComponent(Plugin);
			
			DCLFactory.registerComponentAlias("body", "page");
			DCLFactory.registerComponentAlias("image", "img");
			
			_bookViewer = viewer;		
		}

		public function get bookViewer():IBookViewer
		{
			return _bookViewer;
		}
		
		public function get bookType():String
		{
			return DIBCommon.DIB_TYPE;
		}
		
		public function get bookFile():IBookFile
		{
			return _bookFile;
		}				
		
		override public function notifyChange(source:*=null):void
		{
			var first:Boolean = !this.hasPendingChanges;
			
			super.notifyChange(source);
			
			if (first && this.hasPendingChanges)
			{
				var event:BookViewerEvent = new BookViewerEvent(BookViewerEvent.BOOK_CONTENT_CHANGED);
				this._bookViewer.dispatchEvent(event);
			}
		}
		
		public function loadAsync(bookPath:String):IListener
		{		
			var token:IAsyncToken = _bookViewer.kernel.createAsyncToken();
			var controller:IBookController = this;
			
			_basePath = bookPath;
			
			// 获取索引文件路径
			bookPath = URLUtil.combine(_basePath, this._bookViewer.settings.getSetting("dibiFileName"));
            bookPath += "?no_cache=" + new Date().time;
			
			var manifestPath:String = URLUtil.combine( _basePath, this._bookViewer.settings.getSetting("manifestFileName") );
			
			// 读取索引文件
			var loader:IResourceLoader = this._bookViewer.kernel.resourceProvider.load(
				new URLRequest(bookPath), 
				ResourceType.TEXT
			);
			
			loader.addEventListener(ProgressEvent.PROGRESS, function (e:ProgressEvent):void
			{
				token.notifier.notifyProgress(e.bytesLoaded, e.bytesTotal);
			});
			
			loader.addEventListener(Event.COMPLETE, function (e:Event):void
			{								
				_pageDataCache = new Vector.<IPageFile>();
				_pageViewCache = new Dictionary(true);
				_isSaving = false;			
				_bookFile.load( XML(loader.data) );
				
				// preserve page spaces
				for (var index:int = 0; index < _bookFile.pageCount; index++)
				{
					_pageDataCache.push(null);
				}
				
				_bookFactory = new DCLFactory(_bookViewer.kernel);
				_bookFile.style && _bookFactory.styleSheet.addStyleDefinitions(_bookFile.style);
				//_bookFactory.styleSheet.applyDisplayObjectStyles(_bookViewer.bookView, "body", ["width","height"]);
				//_bookFile.width = _bookViewer.bookView.width;
				//_bookFile.height = _bookViewer.bookView.height;
				
				//初始化管理器
				_bookViewer.kernel.localData.setData(ManagerConst.SoundManager, SoundManager.instance);
				_bookViewer.kernel.localData.setData(ManagerConst.ThemeManager, ThemeManager.instance);
				_bookViewer.kernel.localData.setData(ManagerConst.LoadManager, LoadManager.instance);
				SoundManager.instance.bookPath = URLUtil.combine(_basePath, "audios/");
				
				if(_bookFile.librarys.length == 0)
				{
					_enableChangeTracking = true;
					token.notifier.notify(true, controller);
				}
				else
				{
					_loadResLib(_bookFile.librarys, token);
				}
				
				_enableChangeTracking = false;
				
				//token.notifier.notify(true, controller);
				
				loader.detachAndClean();
			});
			
			loader.addEventListener(ResourceErrorEvent.RESOURCE_ERROR, function (e:ResourceErrorEvent):void
			{
				token.notifier.notify(false);						
				
				loader.detachAndClean();	
			});
			
			return token.listener;
		}
		
		private function _loadResLib(data:Array, token:IAsyncToken):void
		{
			var controller:IBookController = this;
			var currentLibrary:Object = data.shift();
			var lc:LoaderContext = new LoaderContext();
			lc.allowCodeImport = true;
			var loader:IResourceLoader = _bookViewer.kernel.resourceProvider.load(
				new URLRequest(URLUtil.combine(_basePath, "libs/" + currentLibrary.url) + "?no_cache=" + new Date().time),
				ResourceType.IMAGE, lc);
			
			loader.addEventListener(
				Event.COMPLETE,						
				function (e:Event):void
				{
					ThemeManager.instance.addStyle(currentLibrary.key, loader.data);
					
					if(data.length == 0)
					{
						_enableChangeTracking = true;
						token.notifier.notify(true, controller);
					}
					else
					{
						_loadResLib(data, token);
					}
					
					loader.detachAndClean();
				}
			);
		}
		
		public function saveAsync():IListener
		{						
			if (_isSaving) return null;
			
			_isSaving = true;
			
			var token:IAsyncToken = _bookViewer.kernel.createAsyncToken();
			
			var total:int = _pageDataCache.length;			
			
			if (_bookFile.hasPendingChanges)
			{								
				var data:String = XML(_bookFile.save()).toXMLString();				
				
				// 保存索引文件				
				var cmd:ICommand = new SaveDIBI_ECO(this._bookViewer.kernel);
				cmd.execute({coursewareID: _bookFile.uuid, dibi: data, pageCount: total});
				
				cmd.addListener(function (e:CommandMessage):void
				{										
					if (e.command.succeeded)
					{					
						_bookFile.resetChanges();
						
						token.notifier.notifyProgress(1, total+1);						
						_saveBookPages(token.notifier);
					}
					else
					{
						_isSaving = false;
						token.notifier.notify(false, e.command.result);												
					}
					
					e.command.dispose();
				});								
			}					
			else
			{							
				_saveBookPages(token.notifier);
			}
			
			return token.listener;
		}
		
		public function loadPageAsync(index:int):IListener
		{
			var token:IAsyncToken = _bookViewer.kernel.createAsyncToken();
			
			if (index < 0 || index >= this._bookFile.pageCount)
			{
				token.notifier.notify(false, "Invalid page index!");
			}			
			else 
			{	
				var page:IPageFile = this._pageDataCache[index];
				
				if (page)
				{
					var view:IPageView = this._pageViewCache[page];			
					
					// 检查视图是否有改变
					if (view && view.hasPendingChanges)
					{								
						var body:XML = view.saveToXML();
						body.setLocalName("body");
						page.body = body;		
						
						view.resetChanges();																					
					}					
					
					token.notifier.notify(true, page);																				
				}			
				else
				{
					var url:String = this._bookFile.getPageEntryByIndex(index).url;
					url = this.resolvePath(url);
					
					var loader:IResourceLoader = this._bookViewer.kernel.resourceProvider.load(
						new URLRequest(url), 
						ResourceType.TEXT
					);
					
					loader.addEventListener(Event.COMPLETE, function (e:Event):void
					{
						var page:DIBPage = new DIBPage(_bookFile, _bookFile.getPageEntryByIndex(index).id);
						page.load(XML(loader.data));
						
						_pageDataCache[index] = page;										
						
						token.notifier.notify(true, page);											
						
						loader.detachAndClean();
					});
					
					loader.addEventListener(ResourceErrorEvent.RESOURCE_ERROR, function (e:ResourceErrorEvent):void
					{
						token.notifier.notify(false, e.text);								
						
						loader.detachAndClean();	
					});   				
				}
			}
			
			return token.listener;
		}
		
		public function resolvePath(path:String):String
		{			
			var serverPath:String = _bookViewer.kernel.configuration.params.ebook.@host;
            path = URLUtil.isAbsURL(path) ? URLUtil.combine(serverPath, path) : URLUtil.combine(_basePath, path);
            return path + '?no_cache=' + new Date().time;        
		}
		
		public function createPageView(ownerView:IBookView, bookPage:IPageFile):IPageView
		{
			var view:IPageView = IPageView(
				this._pageViewCache[bookPage] ||= 
				new DCLFactory(
					this._bookViewer.kernel, 
					this._bookFactory.styleSheet,
					this.resolvePath
				).createComponentFromXML(bookPage.body)
			);					
			
			view.bookView = ownerView;
			view.pageFile = bookPage;
			
			if (bookPage.hasPendingChanges) view.notifyChange();
			
			return view;
		}
		
		public function addNewPageAt(index:int, pageData:* = null, pid:String = null):String
		{			
			if(_bookFile.pageCount < 1)
			{
				index = 0;
			}
			var id:String = _bookFile.insertPage(index, pid);
			
			var bookPage:DIBPage = new DIBPage(_bookFile, id, true);
			bookPage.load(pageData || DIBCommon.DIBPTemplate);						
			
			_pageDataCache.splice(_bookFile.getPageIndexByID(id), 0, bookPage);	
			if(index<0)
				index = _bookFile.pageCount-1;
			dispathBookViewerEvent("add",[index],id);
			return id;
		}				
		
		public function removePageAt(index:int):IPageView
		{
			var id:String = bookFile.getPageEntryByIndex(index).id;
		
			var actualIndex:int = bookFile.deletePage(id);		
			_pageDataCache.splice(actualIndex, 1);
			dispathBookViewerEvent("delete",[index],id);
			
			if (actualIndex == 0 && _pageDataCache.length > 0)
			{
				var pageView:IPageView = _pageViewCache[_pageDataCache[0]];
				pageView &&	pageView.notifyChange(this);
				return pageView;
			}
			
			return null;
		}
		
		public function removePageCacheAt(index:int):void
		{
			var page:IPageFile = this._pageDataCache[index];
			delete this._pageViewCache[page];
			this._pageDataCache[index] = null;
		}
		
		/**
		 * 
		 * @param eventType default Event Type BookViewerEvent.PAGES_CHANGE_EVENT
		 * @param relatedActionType delete,swap,add
		 * @param carryData carryData[0] = upPageIndex;carryData[1]=downPageIndex
		 * 
		 */		
		private function dispathBookViewerEvent(relatedActionType:String,carryData:Array,pageID:String=null,eventType:String=BookViewerEvent.PAGES_CHANGE_EVENT):void
		{
			var bookViewerEvent:BookViewerEvent = new BookViewerEvent(eventType);
			bookViewerEvent.actionType = relatedActionType;
			bookViewerEvent.relatedPages = carryData;
			bookViewerEvent.relatedPageID = pageID;
			_bookViewer.dispatchEvent(bookViewerEvent);
		}
		
		public function swapPage(page1Index:int, page2Index:int):void
		{
			if (page1Index == page2Index) return;
			
			if (page2Index < page1Index)
			{
				var tmp:int = page1Index;
				page1Index = page2Index;
				page2Index = tmp;
			}								
			
			if (page1Index < 0 || page2Index >= this._pageDataCache.length) return;
			
			var page1:IPageFile = this._pageDataCache[page1Index];
			var page2:IPageFile = this._pageDataCache[page2Index];
			
			var id1:String = bookFile.getPageEntryByIndex(page1Index).id;
			var id2:String = bookFile.getPageEntryByIndex(page2Index).id;
			
			// Delete
			var actualIndex:int = bookFile.deletePage(id1);		
			Debug.assertEqual(actualIndex, page1Index);
			_pageDataCache.splice(actualIndex, 1);			
			
			actualIndex = bookFile.deletePage(id2);		
			Debug.assertEqual(actualIndex, page2Index-1);
			_pageDataCache.splice(actualIndex, 1);					
			
			// Insert
			var id:String = _bookFile.insertPage(page1Index, id2);
			Debug.assertEqual(id, id2);
			_pageDataCache.splice(_bookFile.getPageIndexByID(id2), 0, page2);	
			
			id = _bookFile.insertPage(page2Index, id1);
			Debug.assertEqual(id, id1);						
			_pageDataCache.splice(_bookFile.getPageIndexByID(id1), 0, page1);
			dispathBookViewerEvent("swap",[page1Index,page2Index]);
			
			if (page1Index == 0 && _pageDataCache.length > 0)
			{
				var pageView:IPageView = _pageViewCache[_pageDataCache[0]];
				pageView &&	pageView.notifyChange(this);
			}
		}
		
		public function savePageAsync(index:int):IListener
		{								
			var token:IAsyncToken = _bookViewer.kernel.createAsyncToken();	
			var page:IPageFile = this._pageDataCache[index];
			
			if (!page)
			{			
				token.notifier.notify(true);
				
				return token.listener; 
			}			
			
			var view:IPageView = this._pageViewCache[page];	
			var bytes:ByteArray = null;
			
			// 检查视图是否有改变
			if (view && view.hasPendingChanges)
			{								
				var body:XML = view.saveToXML();
				body.setLocalName("body");
				page.body = body;								
				
				view.resetChanges();											
				
				// 更新截图							
				bytes = view.getThumbnail(index == 0);	
				
				var thumbUpdatedEvent:BookViewerEvent = new BookViewerEvent(BookViewerEvent.PAGE_THUMBNAIL_UPDATED);
				thumbUpdatedEvent.relatedPageIndex = index;		
				thumbUpdatedEvent.pageThumb = bytes;
				thumbUpdatedEvent.relatedPageID = page.id;
				_bookViewer.dispatchEvent(thumbUpdatedEvent);
				
				if (!view.isEditting)
				{
					view.dispose();
					delete this._pageViewCache[page];
				}
			}			
			
			// 没有改变，转到页面数据保存											
			_saveBookPage(index, page, bytes, token.notifier);			
			
			return token.listener;
		}				
		
		public function tryGetPageViewFromCache(index:int):IPageView
		{
			if(!_pageDataCache) return null;
			var page:IPageFile = this._pageDataCache[index];
			if(!page) return null;
			
			return this._pageViewCache[page];
		}
		
		public function dispose():void
		{
			_disposeBook();
			
			_bookViewer = null;	
		}
		
		private function _disposeBook():void
		{						
			if (this._pageViewCache)
			{
				for each (var view:IPageView in this._pageViewCache)
				{
					view.dispose();
				}				
			}
			_pageViewCache = null;			
			
			if (_pageDataCache)
			{
				for each (var page:DIBPage in this._pageDataCache)
				{
					if(page == null) continue;
					page.dispose();
				}				
			}
			_pageDataCache = null;			
			
			!_bookFactory || _bookFactory.dispose();						
			_bookFactory = null;
			
			!_bookFile || _bookFile.dispose();
			_bookFile = null;				
			
			_enableChangeTracking = false;
		}	
		
		private function _saveBookPages(notifier:INotifier):void
		{								
			if (_pageDataCache.length > 0)
			{			
				var finished:int = 1;
				var total:int = _pageDataCache.length + 1;	
				
				for (var index:int = 0; index < _pageDataCache.length; index++)
				{								
					var listener:IListener = savePageAsync(index);				
					
					listener.listen(
						function (e:AsyncEvent):void
						{
							var succeeded:Boolean = e.endAsync();												
							
							if (succeeded)
							{
								++finished;
								
								notifier.notifyProgress(finished, total);
								
								if (finished == total)
								{
									resetChanges();
									_isSaving = false;
									notifier.notify(true);								
								}
							}
							else
							{
								_isSaving = false;
								notifier.notify(false, e.data);							
							}																	
						}
					);
				}	
			}
			else
			{
				resetChanges();
				_isSaving = false;
				notifier.notify(true);
			}
		}
		
		private function _saveBookPage(pageIndex:int, page:IPageFile, thumbnailData:ByteArray, notifier:INotifier):void
		{
			if (page.hasPendingChanges)
			{																					
				//保存页面数据							
				var pageData:BookData = new BookData();
				pageData.name = page.id;
				pageData.content = XML(page.save()).toXMLString();
				pageData.thumb = thumbnailData;
				pageData.cover = pageIndex == 0;
				
				var cmd:ICommand = new SavePage_ECO(this._bookViewer.kernel);	
				cmd.addListener(function (e:CommandMessage):void
				{
					if (e.command.succeeded)
					{																		
						page.resetChanges();																			
						notifier.notify(true);							
					}
					else
					{
						notifier.notify(false, e.command.result);
					}
					e.command.dispose();
				});		
				cmd.execute({coursewareID:_bookFile.uuid, pages:pageData});																										
			}
			else
			{																									
				notifier.notify(true);				
			}
		}
		
		public function addPage(page:IPageFile):IPageView
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function addPageAt(index:int, page:IPageFile):IPageView
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function removePage(page:IPageFile):IPageView
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get childControllers():Array
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get isSiteNode():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function get kernel():IKernel
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get locationLink():String
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function register():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function registerChildController(childController:IController):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function remove():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function removeChildController(childController:IController):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get view():Object
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get name():String
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function willTrigger(type:String):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
	}
}