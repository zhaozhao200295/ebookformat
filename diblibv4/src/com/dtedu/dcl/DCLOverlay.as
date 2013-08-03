package com.dtedu.dcl
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.dcl.interfaces.IDCLOverlay;
	import com.dtedu.trial.utils.Debug;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class DCLOverlay extends DCLComponent implements IDCLOverlay
	{				
		protected var _owner:IDCLComponent;
		protected var _overlayContainer:DisplayObjectContainer;
		
		public function DCLOverlay(displayObject:DisplayObject)
		{
			super(displayObject);						
		}				
		
		override public function initialize(factory:IDCLFactory, byLoading:Boolean=false):void
		{
			super.initialize(factory, byLoading);
			
			_overlayContainer = DisplayObjectContainer(_factory.kernel.localData.getData("overlayLayer"));
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
		
		public function set owner(component:IDCLComponent):void
		{
			_owner = component;
		}
		
		public function show(owner:IDCLComponent):void
		{						
			hide();						
			
			this.owner = owner;
			
			if (_factory.overlayEnabled && _owner)
			{			
				try 
				{											
					_addChildToOverlayHolder(_displayObject);
				} 
				catch(e:Error) 
				{				
				}
			}
		}
		
		public function hide():void
		{		
			_owner = null;	
			
			_removeChildFromOverlayHolder(this._displayObject);					
		}	
		
		protected function _addChildToOverlayHolder(child:DisplayObject):void
		{
			if (!_overlayContainer) return;
			
			var abs:Point = _overlayContainer.localToGlobal(new Point());
			child.x -= abs.x;
			child.y -= abs.y;
			
			_overlayContainer.addChild(child);	
		}
		
		protected function _removeChildFromOverlayHolder(child:DisplayObject):void
		{
			child.parent && child.parent.removeChild(child);	
		}
	}
}