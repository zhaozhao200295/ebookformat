package com.dtedu.speak.containers
{
	import com.dtedu.bytearray.display.ScaleBitmap;
	import com.dtedu.speak.controls.GButton;
	import com.dtedu.speak.interfaces.ILayer;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	
	public class GWindow extends GContainer
	{
		protected var _scaleBg:ScaleBitmap;
		protected var _windowBg:Bitmap;
		protected var _closeBtn:GButton;
		private var _canDrag:Boolean = false;
		
		public function GWindow(_container:ILayer = null)
		{
			super();
			//container = (_container == null) ? LayerManager.activeLayer : _container;
		}
		
		public function get windowBg():Bitmap
		{
			return _windowBg;
		}

		public function set windowBg(value:Bitmap):void
		{
			_windowBg = value;
			width = value.width;
			height = value.height;
			this.addChildAt(_windowBg,0);
		}

		public function get scaleBg():ScaleBitmap
		{
			return _scaleBg;
		}

		public function set scaleBg(value:ScaleBitmap):void
		{
			_scaleBg = value;
			width = _scaleBg.width;
			height = _scaleBg.height;
			this.addChildAt(_scaleBg,0);
		}		

		public function get canDrag():Boolean
		{
			return _canDrag;
		}

		public function set canDrag(value:Boolean):void
		{
			if(_canDrag == value)
			{
				return;
			}
			_canDrag = value;
			if(_canDrag)
			{
				addEventListener(MouseEvent.MOUSE_DOWN,onDrag);
			}else if(hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				removeEventListener(MouseEvent.MOUSE_DOWN,onDrag);
			}
		}
		
		private function onDrag(e:MouseEvent):void
		{
			//container.setTop(this);
			if(e.target!=this)
			{
				return;
			}
			this.startDrag(false);
			Globals.stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
		}
		
		private function onDrop(e:MouseEvent):void
		{
			this.stopDrag();
			Globals.stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
		}

	}
}