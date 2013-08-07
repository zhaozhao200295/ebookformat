package com.dtedu.speak.containers
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.ebook.utils.ObjectCreate;
	import com.dtedu.speak.interfaces.ISkin;
	import com.dtedu.speak.interfaces.IUIComponent;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class GLayer extends Sprite
	{
		private var _bg:DisplayObject;
		private var _bgSprite:DisplayObject;
		private var _resizePopuplist:Dictionary;
		
		public function GLayer()
		{
			super();
			_resizePopuplist = new Dictionary();
			visible = false;
		}
		
		public function get bg():DisplayObject
		{
			if (!_bg)
			{
				_bg = new Sprite();
				_bgSprite = ObjectCreate.createRect(0, Globals.stage.stageWidth, Globals.stage.stageHeight, 1, DisplayObjectContainer(_bg));
				_bg.alpha = 0.9;
				addChild(_bg);
				stage.addEventListener(Event.RESIZE, resizeHandler);
			}
			return _bg;
		}
		
		protected function popupUpdateSizeHandler(e:Event):void
		{
			e.stopImmediatePropagation();
		}
		
		protected function resizeHandler(e:Event):void
		{
			if(!visible) return;
			
			updateBgSize(Globals.stage.stageWidth, Globals.stage.stageHeight);
		}
		
		protected function updateBgSize(w:Number, h:Number):void
		{
			width = bg.width = w;
			height = bg.height = h;
			_bgSprite.width = w;
			_bgSprite.height = h;
		}
	}
}