package
{
	import com.dtedu.dcl.DCLComponent;
	import com.dtedu.dcl.DCLFactory;
	import com.dtedu.ebook.interfaces.IPlugin;
	import com.dtedu.trial.interfaces.IKernel;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class demo extends DCLComponent implements IPlugin
	{
		public function demo()
		{
			super(_loader);
			
			DCLFactory.registerComponent(demo);
			
			_properties.register("src", null, cufGetTrimmedString);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
		}
		
		protected var _loader:Loader = new Loader();			
		
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
		
		public function get instance():DisplayObject
		{
			return this.displayObject;
		}
		
		public function get dependencies():Array
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function initPlugin(kernel:IKernel):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function invalidatePlugin(value:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get pluginVersion():String
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get graphics():Graphics
		{
			// TODO Auto Generated method stub
			return null;
		}
		
	}
}