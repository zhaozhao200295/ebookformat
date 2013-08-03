package com.dtedu.digipub.dib
{
	import com.dtedu.dcl.interfaces.IDCLStyleSheet;
	import com.dtedu.digipub.interfaces.IBookController;
	import com.dtedu.digipub.interfaces.IBookFile;
	import com.dtedu.digipub.interfaces.IManifest;
	import com.dtedu.digipub.interfaces.IMetadata;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.IPageView;
	import com.dtedu.digipub.interfaces.ITOCNode;
	import com.dtedu.digipub.miscs.PageEntry;
	import com.dtedu.trial.utils.Debug;
	
	import flash.utils.Dictionary;
	
	public class DIBIndex extends DIBNotify implements IBookFile
	{
		XML.ignoreWhitespace = true;
		XML.ignoreComments = true;
		XML.ignoreProcessingInstructions = false;
		
		default xml namespace = DIBCommon.dibNamespace;
		
		public function DIBIndex(controller:IBookController)
		{
			_controller = controller;
		}
		
		private var _controller:IBookController;				
		
		private var _version:String;
		
		private var _uuid:String;
		
		private var _code:String;
		
		private var _plugins:Array;
		
		private var _metadata:IMetadata;        
		
		private var _style:String;
		
		private var _bookStyle:IDCLStyleSheet;
		
		private var _width:Number;
		
		private var _height:Number;
		
		private var _title:String;
		
		private var _librarys:Array;
		
		private var _authors:String;
		
		private var _creationDate:Date;
		
		private var _modificationDate:Date;				
		
		private var _manifest:IManifest;
		
		private var _tocTree:XMLList;
		
		private var _tocTopNodes:Vector.<ITOCNode>;
		
		private var _pages:Vector.<PageEntry>;
		
		private var _pageIdToIndexTable:Dictionary;
		
		public function get version():String
		{
			return this._version;
		}
		
		public function set version(version:String):void
		{
			this._version = version;
		}
		
		public function get code():String
		{
			return this._code;
		}
		
		public function set code(value:String):void
		{
			this._code = value;
		}
		
		public function get uuid():String
		{
			return this._uuid;
		}
		
		public function get authors():String
		{
			return this._authors;
		}
		
		public function get creationDate():Date
		{
			return this._creationDate;
		}
		
		public function get modificationDate():Date
		{
			return this._modificationDate;
		}
		
		public function get metadata():IMetadata
		{
			return this._metadata;
		}
		
		public function set style(style:String):void
		{
			//TODO: 使用StyleSheet类进行处理
			this._style = style;
		}
		
		public function get style():String
		{
			return this._style;
		}
		
		
		public function get bookStyle():IDCLStyleSheet
		{
			return this._bookStyle;
		}
		
		public function get width():Number
		{
			return this._width;
		}
		
		public function get height():Number
		{
			return this._height;
		}
		
		public function set height(value:Number):void
		{
			this._height = value;
		}
		
		public function set width(value:Number):void
		{
			this._width = value;
		}
		
		
		public function get title():String
		{
			return this._title;
		}
		
		public function set librarys(libs:Array):void
		{
			this._librarys = libs;
			//TODO: 加载类库
		}
		
		public function get librarys():Array
		{
			return this._librarys;
		}
		
		
		public function get pageCount():int
		{
			return this._pages.length;
		}
		
		public function get bookTocPage():String
		{
			return this._tocTree.@tocPage;
		}
		
		public function get tocTree():XMLList
		{
			return this._tocTree;
		}
		
		public function get manifest():IManifest
		{
			return this._manifest;
		}
		
		public function get toolbar():XML
		{
			return null;
		}
		
		public function appendPage(page:IPageFile):IPageView
		{
			return null;
		}
		
		public function removePage(page:IPageFile):IPageView
		{
			return null;
		}
		
		public function load(value:XML):void
		{
			var content:XML = XML(value[0]);	
			
			this._version = content.@version;
			
			_createMetadata(content.head.meta);
			
			this._style = content.head.style.toString(); 
			
			_createLibrarys(content.librarys.library);
			
			_createPages(content.spine.item);
			
			//_createToolbarGroups();
			
			
			_createTOCTree(content.toc);
		}
		
		/**
		 * 创建页面组与页面跟索引的对应关系
		 */
		private function _createPages(spines:XMLList):void
		{
			this._pages = new Vector.<PageEntry>;	
			this._pageIdToIndexTable = new Dictionary();
			
			var page:PageEntry;
			var index:int  = 0;
			
			for each (var node:XML in spines)
			{
				page = new PageEntry(node.@id);
				this._pages.push(page);
				
				this._pageIdToIndexTable[page.id] = index++;
			}
		}
		
		/**
		 * 构建页面也索引的对应关系
		 */
		private function _buildPageIndex():void
		{
			this._pageIdToIndexTable = new Dictionary();
			
			var index:int  = 0;
			
			for each (var item:PageEntry in this._pages)
			{			
				if (item.id in this._pageIdToIndexTable)
				{
					_controller.bookViewer.kernel.reportWarning(
						"Duplicate page id: " + item.id,
						DIBCommon.DIBX_TYPE
					);
				}									
				
				this._pageIdToIndexTable[item.id] = index++;			
			}				
		}
		
		/**
		 * 解析课本索引页面Metadata
		 */
		private function _createMetadata(metadata:XMLList):void
		{
			this._metadata = new Metadata(this);
			
			this._metadata.bind("title", function (value:String):void { _title = value });
			this._metadata.bind("authors", function (value:String):void { _authors = value });
			this._metadata.bind("code", function (value:String):void { _code = value });
			this._metadata.bind("uuid", function (value:String):void { _uuid = value });
			this._metadata.bind("creation-date", function (value:String):void { _creationDate = cufGetDateTime(value) });
			this._metadata.bind("modification-date", function (value:String):void { _modificationDate = cufGetDateTime(value) });
			
			for each (var meta:XML in metadata)
			{
				this._metadata.setItem(meta.@name, meta.@content);
			}
		}
		
		/**
		 * 创建目录树
		 */
		private function _createTOCTree(toc:XMLList):void
		{
			this._tocTree = toc;
			
			this._tocTopNodes = new Vector.<ITOCNode>();		
			
			var tocTop:ITOCNode;
			
			for each (var node:XML in toc..node)
			{
				tocTop = new TOCNode(null);
				tocTop.load(node);
				_tocTopNodes.push(tocTop);
			}
		}
		
		/**
		 * 创建电子课本外部库数组
		 */
		private function _createLibrarys(library:XMLList):void
		{
			this._librarys = [];
			for each (var node:XML in library)
			{
				var item:Object = {sort:Number(node.@sort), key:String(node.@key), url:String(node.@url)};
				this._librarys.push(item);
			}
		}
		
		/**
		 * 自动生成页面编号
		 */
		private function _autoPageID():String
		{				
			var date:Date = new Date();	
			var num:Number = date.getTime();
			var newId:String = "p" + num.toString(16); 
			
			while (this._pageIdToIndexTable[newId])
			{				
				newId = "p" + (++num).toString(16); 
			}
			
			return newId;
		}
		
		public function insertPage(index:int, id:String):String
		{
			
			Debug.assert(index <= this._pages.length, "Invalid page index to insert!");
			
			if (index < 0)
			{
				index += this._pages.length + 1;
			}					
			
			Debug.assert(index >= 0, "Invalid page index to insert!");
			
			id ||= _autoPageID();
			var item:PageEntry = new PageEntry(id);
			
			this._pages.splice(index, 0, item);
			
			_buildPageIndex();	
			
			notifyChange(this);
			
			return id;
		}
		
		public function deletePage(id:String):int
		{
			var index:int = changePageIDToIndex(id);								
			
			this._pages.splice(index, 1);
			
			_buildPageIndex();	
			
			notifyChange(this);
			
			return index;
		}
		
		public function changePageIndexToID(index:int):String
		{
			if(index > this._pages.length || index < 0) return null;
				
			return this._pages[index].id;
		}
		
		public function changePageIDToIndex(ID:String):int
		{
			if (!(ID in this._pageIdToIndexTable)) return -1;
			
			return this._pageIdToIndexTable[ID];
		}
		
		public function save():XML
		{
			var bookXML:XML = DIBCommon.DIBITemplate.copy();
			bookXML.@id = this.uuid;
			
			var metas:XMLList = bookXML.head.meta;
			var spine:XMLList = bookXML.spine;
			var librarys:XMLList = bookXML.librarys;
			var toc:XML = bookXML.toc[0];
			var style:XML = bookXML.head.style[0];
			style.appendChild("body {width: "+ this.width +"; height: "+ this.height +";}");
			
			metas.(@name == "title").@content = this.title;
			metas.(@name == "authors").@content = this.authors;
			metas.(@name == "code").@content = this.code;
			metas.(@name == "uuid").@content = bookXML.@id.toString().replace(/-/gi, "").toLowerCase();
			metas.(@name == "creation-date").@content = this.creationDate;
			metas.(@name == "modification-date").@content = this.modificationDate;
			
			var itemTemp:XML;
			var itemObj:Object;
			
			//生成页面
			for each(itemObj in _pages)
			{
				itemTemp = DIBCommon.pageItemTemplate.copy();
				itemTemp.@id = itemObj.id;
				spine.appendChild(itemTemp);
			}
			
			//生成外部库
			for each(itemObj in this._librarys)
			{
				itemTemp = DIBCommon.libraryTemplate.copy();
				itemTemp.@sort = itemObj.sort;
				itemTemp.@key = itemObj.key;
				itemTemp.@src = itemObj.src;
				librarys.appendChild(itemTemp);
			}
			
			//生成章节目录
			for each(var tocNode:ITOCNode in this._tocTopNodes)
			{
				toc.appendChild(tocNode.save());
			}
			
			return bookXML;
		}
		
		public function dispose():void
		{
		}
		
		public function getPageEntryByIndex(index:int):PageEntry
		{
			return this._pages[index];
		}
		
		public function getPageIndexByID(id:String):int
		{
			if (!(id in this._pageIdToIndexTable)) return -1;
			
			return this._pageIdToIndexTable[id];
		}
		
		public function getPageEntryByID(id:String):PageEntry
		{
			var index:int = getPageIndexByID(id);
			if(index == -1) return null;
			
			return getPageEntryByIndex(index);
		}
		
	}
}