package com.dtedu.speak.containers
{
	import com.dtedu.speak.core.UIComponent;
	import com.dtedu.speak.interfaces.ILayer;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.DisplayObject;
	
	public class GContainer extends UIComponent implements ILayer
	{
		public function GContainer()
		{
			super();
			tabChildren = false;
		}
		
		///////////////////////////////////实现ILayer接口
		
		public function addPopup(displayObject:DisplayObject, modal:Boolean=false):void
		{
			if( displayObject && this.contains(displayObject) == false )
			{			
				this.addChild(displayObject);
			}
		}
		
		public function centerPopup(displayObject:DisplayObject):void
		{
			displayObject.x = (Globals.stage.stageWidth - displayObject.width)/2;
			displayObject.y = (Globals.stage.stageHeight - displayObject.height)/2;
		}
		
		public function setPosition(displayObject:DisplayObject, x:int, y:int):void
		{
			displayObject.x = x;
			displayObject.y = y;
		}
		
		public function isTop(displayObject:DisplayObject):Boolean
		{
			if( this.contains(displayObject) )
			{
				return this.getChildIndex( displayObject ) == this.numChildren-1;
			}
			return false;
		}
		
		public function removePopup(displayObject:DisplayObject):void
		{
			if( this.contains(displayObject) )
			{
				this.removeChild(displayObject);
			}
		}
		
		public function hasPopup(displayObject:DisplayObject):Boolean
		{
			return this.contains(displayObject);
		}
		
		public function setTop(displayObject:DisplayObject):void
		{
			if( this.contains(displayObject) )
			{
				if( this.getChildIndex(displayObject) != this.numChildren -1 )
				{
					this.setChildIndex(displayObject,this.numChildren - 1);
				}
			}
		}
		
	}
}