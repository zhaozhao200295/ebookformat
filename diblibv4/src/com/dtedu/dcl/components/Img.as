package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLComponent;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	
	public class Img extends DCLComponent 
	{				
		protected var _img:MovieClip = new MovieClip();
		protected var _loader:Loader = new Loader();
		
		public function Img()
		{
			super(_img);
			
			_img.addChild(_loader);
			
			_properties.register("src", null, cufGetTrimmedString);
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
	}
}