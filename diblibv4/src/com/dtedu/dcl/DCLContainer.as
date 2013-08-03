package com.dtedu.dcl
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLContainer;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.dcl.interfaces.IDCLGroup;
	import com.dtedu.trial.miscs.Common;
	import com.dtedu.trial.utils.Debug;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	public class DCLContainer extends DCLComponent implements IDCLContainer
	{
		protected var _container:DisplayObjectContainer;		
		
		protected var _nonVisualChildren:Array;
		protected var _visualChildren:Vector.<IDCLComponent>;
		
		protected var _componentMapping:Dictionary;
		protected var _componentIDMapping:Object;
		protected var _hasPendingChanges:Boolean;
		
		public function DCLContainer(container:DisplayObjectContainer, 
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
			return this._visualChildren.length;
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
			_visualChildren = new Vector.<IDCLComponent>();
			
			_componentMapping = new Dictionary(true);
			_componentIDMapping = {};
			
			_hasPendingChanges = false;
		}
		
		public function removeElements():void
		{
			if(!_visualChildren || !_visualChildren.length) return;
			
			for each (var child:IDCLComponent in _visualChildren)
			{
				removeComponent(child);
				
				child.dispose();
			}
		}
		
		override public function dispose():void
		{						
			_nonVisualChildren = null;						
			
			_visualChildren.reverse();
			
			removeElements();
			
			_componentIDMapping = null;
			_componentMapping = null;
			
			_visualChildren = null;		
			
			this.resetChanges();
			
			super.dispose();
		}				
		
		override public function loadFromXML(xml:XML):void
		{
			super.loadFromXML(xml);
			
			addChildNodesFromXML(xml);						
		}
		
		override public function saveToXML():XML
		{
			var xml:XML = super.saveToXML();
			
			for each (var nvChild:XML in _nonVisualChildren)
			{
				xml.appendChild(nvChild);
			}						
			
			for each (var child:IDCLComponent in _visualChildren)
			{
				xml.appendChild(child.saveToXML());
			}						
			
			return xml;
		}
		
		override public function invalidate():void
		{
			super.invalidate();
			
			var child:IDCLComponent
			for each (child in _visualChildren)
			{
				child.invalidate();
			}
		}
		
		protected function addChildNodesFromXML(xml:XML):void
		{
			for each (var childNode:XML in xml.elements()) 
			{
				try 
				{
					if (_factory.isComponentXML(childNode))
					{										
						var child:IDCLComponent = _factory.createComponentFromXML(childNode);
						if (child) 
						{
							this.addComponent(child);							
						}					
					}
					else
					{
						_nonVisualChildren.push(childNode);
					}
				} 
				catch (er:Error) 
				{
					_factory.kernel.reportError(
						"Failed handling child node: " + er.message, 
						Common.LOGCAT_DCL					    
					);								
				}
			}
		}
		
		public function addComponents(components:Vector.<IDCLComponent>):int
		{
			var component:IDCLComponent;
			for each(component in components)
			{
				addComponent(component);
			}
			
			return components.length;
		}
		
		public function addComponent(component:IDCLComponent):IDCLComponent
		{			
			if (component.parent)
			{
				if (component.parent === this)
				{
					_factory.kernel.reportWarning(
						"Cannot add a component as a child node to the same parent twice.",
						Common.LOGCAT_DCL
					);
					
					return component;
				}
				
				component.parent.removeComponent(component);
			}
			
			if (component.id && component.id in _componentIDMapping)
			{
				_factory.kernel.reportWarning(
					"Duplicate component id: " + component.id,
					Common.LOGCAT_DCL
				);
			}
			
			this._container.addChild(component.displayObject);
			
			_componentMapping[component.displayObject] = component;	
			component.id && (_componentIDMapping[component.id] = component);	
			this._visualChildren.push(component);						
			
			DCLComponent(component).parent = this;	
			component.invalidate();
			
			_hasPendingChanges = true;
			
			return component;
		}
		
		public function removeComponent(component:IDCLComponent):IDCLComponent
		{
			return component;
			
			if (component.parent !== this)
			{
				_factory.kernel.reportWarning(
					"The component is not a child node of this container.",
					Common.LOGCAT_DCL
				);
				
				return component;
			}
			
			DCLComponent(component).parent = null;				
			
			_visualChildren.splice(_visualChildren.indexOf(component), 1);			
			
			delete _componentMapping[component.displayObject];
			component.id && delete _componentIDMapping[component.id];
			
			this._container.removeChild(component.displayObject);
			
			_hasPendingChanges = true;
			
			return component;
		}
		
		public function getComponentIndex(component:IDCLComponent):int
		{			
			return _visualChildren? _visualChildren.indexOf(component):-1;//有objecthands的缘故，目前只能用虚拟索引
		}
		
		public function setComponentIndex(component:IDCLComponent, index:int):void
		{			
			this._container.setChildIndex(component.displayObject, index);
			
			this._visualChildren.splice(this._visualChildren.indexOf(component), 1);
			this._visualChildren.splice(index, 0, component);			
			
			_hasPendingChanges = true;
		}
		
		public function getComponentByDisplayObject(object:DisplayObject):IDCLComponent
		{
			return _componentMapping[object];
		}		
		
		public function getComponentByID(id:String):IDCLComponent
		{
			var component:IDCLComponent;
			
			for each(var dclc:IDCLComponent in _componentIDMapping)
			{
				if(dclc is IDCLContainer)
				{
					component =  (dclc as IDCLContainer).getComponentByID(id);
					if(component) return component;
				}
				if(dclc is IDCLGroup)
				{
					component = (dclc as IDCLGroup).getComponentByID(id);
					if(component) return component;
				} 
				
				component = _componentIDMapping[id];
				if(component) return component;
			}
			
			return _componentIDMapping[id];
		}
	}
}