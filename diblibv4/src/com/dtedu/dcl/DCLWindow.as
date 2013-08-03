package com.dtedu.dcl
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.dcl.interfaces.IDCLOverlay;
	import com.dtedu.trial.utils.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class DCLWindow extends DCLComponent implements IDCLOverlay
	{
		protected var _owner:IDCLComponent;
		protected var _overlayContainer:DisplayObjectContainer;
		
		[Embed(source="assets/icons/close_on.png")]
		[Bindable]
		public var ppt_closeBtn_on:Class;
		
		[Embed(source="assets/icons/close_over.png")]
		[Bindable]
		public var ppt_closeBtn_over:Class;
		
		protected var _sprite:Sprite = new Sprite();
		
		protected var _closeButton:SimpleButton;
		
		public function DCLWindow()
		{
			super(_sprite);
		}

		override public function initialize(factory:IDCLFactory, byLoading:Boolean=false):void
		{
			super.initialize(factory, byLoading);
		}
		
		override public function dispose():void
		{
			hide();			
			
			_overlayContainer = null;
			
			super.dispose();
		}
		
		public function get owner():IDCLComponent
		{
			return _owner;
		}
		
		public function hide():void
		{	
			if(!_owner) return;
			
			var container:DisplayObjectContainer = _overlayContainer;
			container.removeChild(_owner.displayObject);
			
			if(_owner.type == "flash")
			{
				DisplayObjectUtil.stopMovie(Loader(_owner.displayObject).content as DisplayObjectContainer);
			}
			
			if(!_owner.isPlugin && _closeButton)
			{
				container.removeChild(_closeButton);
			}
			_owner = null;
		}
		
		private function changeOverlay(type:String):void
		{
			switch(type)
			{
				case "audio":
					_overlayContainer = DisplayObjectContainer(_factory.kernel.localData.getData("overlayLayer"));
					break;
				default:
					_overlayContainer = DisplayObjectContainer(_factory.kernel.localData.getData("popUpLayer"));
					break;
			}
			_overlayContainer.addEventListener("close", _onCloseDialogHandler);
		}
		
		public function show(owner:IDCLComponent):void
		{
			_owner = owner;
			changeOverlay(_owner.type);
			
			if (_factory.overlayEnabled && owner)
			{
				var container:DisplayObjectContainer = _overlayContainer;
				var element:DisplayObject = owner.displayObject;
				
				container.addChild(element);
				if(_owner.type != "audio")
				{
					addCloseButton(container, owner.isPlugin);
				}
			}
		}
		
		protected function _onCloseDialogHandler(evn:Event):void
		{
			evn.stopPropagation();
			_overlayContainer.removeEventListener("close", _onCloseDialogHandler);
			
			hide();
		}
		
		protected function addCloseButton(container:DisplayObjectContainer, isPlugin:Boolean):void
		{
			if(!isPlugin)
			{
				_closeButton = new SimpleButton();
				//_closeButton.upState = ppt_closeBtn_on;
				//_closeButton.overState = ppt_closeBtn_over;
				
				_closeButton.addEventListener(MouseEvent.CLICK, function(evn:MouseEvent):void{
					_closeButton.removeEventListener(MouseEvent.CLICK, arguments.callee);
					
					_overlayContainer.dispatchEvent(new Event("close"));
				});
				
				container.addChild(_closeButton);
			}
		}
	}
}