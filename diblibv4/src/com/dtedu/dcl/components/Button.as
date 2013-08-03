package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLComponent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class Button extends DCLComponent 
	{
		protected var _loader:Loader = new Loader();
		
		public function Button()
		{
			super(_loader);
			
			_properties.register("src", null, cufGetTrimmedString);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
		}				
		
		override protected function _setAttribute(name:String, value:*):Boolean  
		{
			if (super._setAttribute(name, value)) return true;							
			if(!value) return false;
			
			switch (name)
			{
				case "src":
					value &&= this._factory.resolvePath(value);	
					_loader.load( new URLRequest(value));
					return true;
					
				default:
					return false;
			}		
		}
		
		private function loadCompleteHandler(evn:Event):void
		{
			trace("加载成功。");
		}
		
		private function loadErrorHandler(evn:IOErrorEvent):void
		{
			trace(evn.text);
		}
	}
}