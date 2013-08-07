package com.dtedu.speak.skins
{
	import com.dtedu.speak.interfaces.ISkin;
	
	import flash.display.DisplayObject;
	
	public class Skin implements ISkin
	{
		public function Skin(up:DisplayObject = null, over:DisplayObject = null, down:DisplayObject = null)
		{
			if(up) this._upStyle = up;
			if(over) this._overStyle = over;
			if(down) this._downStyle = down;
		}
	
		private var _upStyle:DisplayObject;
		private var _overStyle:DisplayObject;
		private var _downStyle:DisplayObject;
		
		public function get upStyle():DisplayObject
		{
			return this._upStyle;
		}
		
		public function get overStyle():DisplayObject
		{
			return this._overStyle;;
		}
		
		public function get downStyle():DisplayObject
		{
			return this._downStyle;
		}
	}
}