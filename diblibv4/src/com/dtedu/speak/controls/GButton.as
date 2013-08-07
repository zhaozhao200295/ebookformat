package com.dtedu.speak.controls
{
	import com.dtedu.speak.interfaces.ISkin;
	import com.dtedu.speak.interfaces.IUIComponent;
	
	import flash.display.SimpleButton;
	
	public class GButton extends SimpleButton implements IUIComponent
	{
		private var _skinClass:ISkin;
		
		public function GButton()
		{
			super();
		}
		
		public function get skinClass():ISkin
		{
			return this._skinClass;
		}

		public function set skinClass(value:ISkin):void
		{
			this._skinClass = value;
			
			this.upState = value.upStyle;
			this.overState = value.overStyle;
			this.downState = value.downStyle;
			
			this.hitTestState = this.overState;
		}
	}
}