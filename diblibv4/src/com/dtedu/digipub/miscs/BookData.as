package com.dtedu.digipub.miscs
{
	import flash.utils.ByteArray;
	
	public class BookData
	{	
		public var name:String;
		
		public var content:String;
		
		public var thumb:ByteArray;
		
		public var cover:Boolean;
		
		public function BookData(_name:String = null, _content:String = null, _thumb:ByteArray = null, _cover:Boolean = false):void
		{
			if(_name) name = _name;
			if(_content) content = _content;
			if(_thumb) thumb = _thumb;
			
			cover = _cover;
		}
	}
}