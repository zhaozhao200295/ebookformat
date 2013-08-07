package com.dtedu.speak.core
{
	import com.dtedu.speak.interfaces.ISkin;
	import com.dtedu.speak.interfaces.IUIComponent;
	
	import flash.display.Sprite;
	
	public class UIComponent extends Sprite implements IUIComponent
	{
		public function UIComponent()
		{
			super();
		}
		
		private var _skinClass:ISkin;
		
		public function get skinClass():ISkin
		{
			return this._skinClass;
		}
		
		public function set skinClass(value:ISkin):void
		{
			this._skinClass = value;
		}
	}
}