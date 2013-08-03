package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLComponent;
	
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	public class Flash extends DCLComponent 
	{				
		protected var _flash:Loader = new Loader();
		
		public function Flash()
		{
			super(_flash);
			
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
					_flash.load( new URLRequest(value));
					return true;
					
				default:
					return false;
			}		
		}
	}
}