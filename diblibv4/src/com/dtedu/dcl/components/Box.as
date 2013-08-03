package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLContainer;
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.trial.interfaces.IResourceLoader;
	import com.dtedu.trial.loading.ResourceType;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	
	[Style(name="skinClass", type="Class")]
	
	public class Box extends DCLContainer 
	{				
		protected var _box:Sprite  = new Sprite();
		
		public function Box()
		{
			super(_box);
			
			_properties.register("backgroundAlpha", 1.0, cufGetNumber);
			_properties.register("backgroundColor", null, cufGetTrimmedString);					
			_properties.register("backgroundImage", null, cufGetTrimmedString);					
			_properties.register("borderAlpha", null, cufGetNumber);			
			_properties.register("borderColor", null, cufGetTrimmedString);
			_properties.register("borderStyle", null, cufGetTrimmedString);			
			_properties.register("borderVisible", false, cufGetBoolean);
			_properties.register("borderWeight", 0.0, cufGetNumber);			
			_properties.register("cornerRadius", null, cufGetNumber);
			_properties.register("dashedGap", 5.0, cufGetNumber);
			_properties.register("dashedLength", 5.0, cufGetNumber);			
		}									
		
		override protected function _setAttribute(name:String, value:*):Boolean  
		{
			if (super._setAttribute(name, value)) return true;					
			
			switch (name)
			{
				case "backgroundAlpha":
				case "backgroundColor":							
				case "borderAlpha":
				case "borderColor":
				case "borderStyle":
				case "borderVisible":
				case "borderWeight":
				case "cornerRadius":
				case "dashedGap":
				case "dashedLength":				
					return true;				
										
				case "backgroundImage":
					if (value)
					{
						value = _factory.resolvePath(value);						
					}
					var loader:Loader = new Loader();
					loader.cacheAsBitmap = true;
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(evn:Event):void{
						_box.graphics.clear();
						_box.graphics.beginBitmapFill(Bitmap(loader.content).bitmapData, null, false, true);
						_box.graphics.drawRect(0, 0, 1024, 768);
						_box.graphics.endFill();
					});
					loader.load(new URLRequest(value));
					
					//_box.setStyle("backgroundImage", value);										
					return true;
					
				default:
					return false;
			}
		}
	}
}