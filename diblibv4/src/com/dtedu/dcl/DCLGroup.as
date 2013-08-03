package com.dtedu.dcl
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.dcl.interfaces.IDCLGroup;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	public class DCLGroup extends DCLComponent implements IDCLGroup
	{
		protected var _container:DisplayObjectContainer;		
		
		protected var _nonVisualChildren:Array;
		protected var _visualChildren:Array;
		protected var _visualChildrenData:Array;
		
		protected var _componentMapping:Dictionary;
		protected var _hasPendingChanges:Boolean;
		
		public function DCLGroup(container:DisplayObjectContainer, 
									 displayObject:DisplayObject = null)
		{
			displayObject ||= container;
			
			super(displayObject);
			
			_container = container;								
		}
		
		override public function get isContainer():Boolean
		{
			return true;
		}
		
		public function get numVisualChildren():int
		{
			return this._visualChildrenData.length;
		}
		
		public function get visualChildren():Array
		{
			return this._visualChildren;
		}
		
		public function get visualChildrenData():Array
		{
			return this._visualChildrenData;
		}
		
		public function get hasPendingChanges():Boolean
		{
			return _hasPendingChanges;
		}
		
		public function resetChanges():void
		{
			_hasPendingChanges = false;
		}
		
		public function notifyChange(source:* = null):void
		{
			_hasPendingChanges = true;
		}
		
		override public function initialize(factory:IDCLFactory, byLoading:Boolean = false):void
		{						
			super.initialize(factory, byLoading);
			
			_nonVisualChildren = [];
			_visualChildren = [];
			_visualChildrenData = [];
			
			_componentMapping = new Dictionary(true);
			
			_hasPendingChanges = false;
		}
		
		override public function dispose():void
		{						
			_nonVisualChildren = null;		
			
			for each (var child:IDCLComponent in _componentMapping)
			{
				child.dispose();
			}
			
			_componentMapping = null;
			
			
			_visualChildren = null;		
			
			_visualChildrenData = null;
			
			this.resetChanges();
			
			super.dispose();
		}				
		
		override public function loadFromXML(xml:XML):void
		{
			super.loadFromXML(xml);
			
			for each (var childNode:XML in xml.children()) 
			{
				if (_factory.isComponentXML(childNode))
				{										
					_visualChildrenData.push(childNode);
					
				}
				else
				{
					_nonVisualChildren.push(childNode);
				}
			}
		}
		
		override public function saveToXML():XML
		{
			var xml:XML = super.saveToXML();
			
			for each (var nvChild:XML in _nonVisualChildren)
			{
				xml.appendChild(nvChild);
			}							
			
			for each (var child:XML in _visualChildrenData)
			{
				xml.appendChild(child);
			}						
			
			return xml;
		}
		
		override public function invalidate():void
		{
			super.invalidate();
			
			for each (var child:IDCLComponent in _componentMapping)
			{
				child.invalidate();
			}
		}
		
		public function getComponentIndex(component:IDCLComponent):int
		{			
			var i:int;
			var len:uint = _visualChildrenData.length;
			for (i=0;i<len;i++)
			{
				if((_visualChildrenData[i] as XML).@id==component.id)
				{
					return i;
				}
			}	
			return -1;
		}
		
		public function getComponentByDisplayObject(object:DisplayObject):IDCLComponent
		{
			for each (var comp:IDCLComponent in _componentMapping)
			{
				if(comp.displayObject===object)
				{
					return comp;
				}
			}	
			return null;
		}	
		
		public function getComponentByIndex(index:int):IDCLComponent
		{
			if(index>=_visualChildrenData.length) return null;
			for each (var comp:IDCLComponent in _componentMapping)
			{
				if(comp.id==(_visualChildrenData[index] as XML).@id)
				{
					return comp;
				}
			}
			//当不存在comp时,生成comp
			comp = _factory.createComponentFromXML(_visualChildrenData[index] as XML);
			_componentMapping[comp.id] = comp;
			return comp;
		}
		
		public function getComponentByID(id:String):IDCLComponent
		{
			var comp:IDCLComponent = _componentMapping[id];
			if(comp) return comp;
			//当不存在comp时,生成comp
			for each (var child:XML in _visualChildrenData)
			{
				if(child.@id==id)
				{
					comp = _factory.createComponentFromXML(child);
					_componentMapping[comp.id] = comp;
					return comp;
				}
			}
			return null;
		}
		
		public function addComponent(child:IDCLComponent):void
		{
			_visualChildrenData.push(child.saveToXML());
			_componentMapping[child.id] = child; 
			
		}
		
		public function removeComponentByIndex(index:int):void
		{
			var dclc:IDCLComponent = getComponentByIndex(index);
			
			delete _componentMapping[dclc.id];
			dclc.dispose();
			
			_visualChildrenData.splice(index, 1);
			
			this.resetChanges();
		}
	}
}