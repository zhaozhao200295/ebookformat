package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLComponent;
	import com.dtedu.ebook.interfaces.IPlugin;
	import com.dtedu.ebook.managers.LoadManager;
	import com.dtedu.trial.utils.URLUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Plugin extends DCLComponent 
	{
		private var _config:String;
		
		protected var _plugin:IPlugin;
		
		private var _ebookPath:Object;
		
		protected var _container:Sprite = new Sprite();
		
		public function Plugin()
		{
			super(_container);
			
			_properties.register("src", null, cufGetTrimmedString);
			_properties.register("config", null, cufGetTrimmedString);
		}
		
		private function resolvePath(path:String):String
		{
			var serverPath:String = _factory.kernel.configuration.params.ebook.@host;
			path = URLUtil.isAbsURL(path) ? URLUtil.combine(serverPath, path) : URLUtil.combine("ebooks/" +_ebookPath as String, path);
			return path + '?no_cache=' + new Date().time;
		}
		
		override protected function _setAttribute(name:String, value:*):Boolean  
		{
			if (super._setAttribute(name, value)) return true;					
			if(!value) return false;
			
			switch (name)
			{
				case "src":
					_ebookPath = _factory.kernel.localData.getData("ebookPath");
					
					if(_ebookPath)
					{
						value &&= this.resolvePath(value);	
					}
					else
					{
						value &&= this._factory.resolvePath(value);	
					}
					LoadManager.instance.load(value,pluginLoadedHandler);
					return true;
				case "config":
					value &&= this._factory.resolvePath(value);
					this._config = value;
					return true;
				default:
					return false;
			}		
		}
		
		private function pluginLoadedHandler(value:DisplayObject):void
		{
			_container.addChild(value);
			_plugin = IPlugin(value);
			_plugin.initPlugin(_factory.kernel);
			_plugin.invalidatePlugin(_config);
		}
		
		private function pluginUpdateSizeHandler(e:Event):void
		{
			_container.width =  e.target.width;
			_container.height = e.target.height;
		}

		
		override public function dispose():void
		{
			super.dispose();
			
			_plugin.dispose();
		}
		
		override public function get isPlugin():Boolean
		{
			return true;
		}
	}
}