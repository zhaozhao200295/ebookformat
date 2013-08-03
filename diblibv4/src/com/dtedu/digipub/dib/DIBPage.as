package com.dtedu.digipub.dib
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.digipub.interfaces.IBookFile;
	import com.dtedu.digipub.interfaces.IMetadata;
	import com.dtedu.digipub.interfaces.IPageEditor;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.trial.interfaces.IChangeObserver;
	import com.dtedu.trial.interfaces.IChangeTarget;
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.utils.Debug;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class DIBPage extends DIBNotify implements IPageFile, IChangeObserver, IDisposable
	{				
		XML.ignoreWhitespace = true;
		XML.ignoreComments = true;
		XML.ignoreProcessingInstructions = false;
		
		default xml namespace = DIBCommon.dibNamespace;
		
		private var _bookFile:IBookFile;
		private var _id:String;
		private var _version:String;
		private var _style:String;
		
		public function addElement(element:IDCLComponent):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function set backgroundColor(color:uint):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function set backgroundImage(image:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function removeElement(element:IDCLComponent):void
		{
			// TODO Auto Generated method stub
			
		}
		
		private var _body:XML;		
		private var _lecture:XMLList;
		
		private var _metadata:Metadata;				
		
		public function DIBPage(bookFile:IBookFile, id:String, newPage:Boolean = false)
		{			
			_bookFile = bookFile;
			_id = id;
			
			_isNew = newPage;
		}				
		
		public function get id():String
		{
			return _id;	
		}
		
		public function get lecture():XMLList
		{
			return this._lecture;
		}
		
		public function set lecture(value:XMLList):void
		{
			this._lecture = value;
		}
		
		public function get version():String
		{
			return this._version;
		}
		
		public function set version(version:String):void
		{
			this._version = version;
			
			notifyChange(this);
		}
		
		public function get metadata():IMetadata
		{
			return this._metadata;
		}
		
		public function get style():String
		{
			return this._style;
		}
		
		public function set style(style:String):void
		{
			this._style = style;
			
			notifyChange(this);
		}
		
		public function get body():XML
		{
			return this._body;
		}
		
		public function set body(body:XML):void
		{
			Debug.assertEqual(body.localName().toString(), "body");
			
			this._body = body;
			
			notifyChange(this);
		}		
		
		override public function notifyChange(source:* = null):void
		{
			super.notifyChange(source);
			
			//_bookFile.controller.notifyChange(this);
		}
		
		public function load(data:XML):void
		{	
			this._version   = data.@version;
			
			_createMetadata(data.head.meta);
			
			this._style = data.head.style.toString();			
			
			this._body  = data.body[0];
			
			this._lecture = data.lecture.item;
			
			this._enableChangeTracking = true;
			
			if (_isNew) this.notifyChange(this);
		}
		
		public function save():XML
		{
			var pageXML:XML = DIBCommon.DIBPTemplate.copy();
			
			var headXML:XML = null;//_metadata.headXML;
			var style:XML = null;//DIBCommon.styleTemplate.copy();
			style.appendChild(_style);
			headXML.appendChild(style);
			
			var lectureXML:XML = DIBCommon.lectureTemplate.copy();
			for each(var item:XML in lecture)
			{
				lectureXML.appendChild(item);
			}
			
			pageXML.appendChild(headXML);
			pageXML.appendChild(body);
			pageXML.appendChild(lectureXML);
			
			return pageXML;
		}							
		
		public function dispose():void
		{			
			_disposePage();
			
			_bookFile = null;
		}
		
		private function _disposePage():void
		{
			!_metadata || _metadata.dispose();
			_metadata = null;
			
			_body = null;
			
			resetChanges();
			
			_enableChangeTracking = false;
			_isNew = false;
		}
		
		private function _createMetadata(meta:XMLList):void
		{
			this._metadata = new Metadata(this);								
			
			for each (var node:XML in meta)
			{
				this._metadata.setItem(node.@name, node.@content);
			}							
		}
	}
}