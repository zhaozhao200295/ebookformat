package com.dtedu.dcl
{	
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.dcl.interfaces.IDCLOverlay;
	import com.dtedu.dcl.interfaces.IDCLStyleSheet;
	import com.dtedu.trial.helpers.EC;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.miscs.Common;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class DCLFactory extends EventDispatcher implements IDCLFactory
	{				
		private static var __mapping:Object = {};
		private static var __mappingAlias:Object = {};				
		
		public static function getComponentTypeName(type:Object):String
		{
			var tag:String = cufGetClassName(type);
			var firstLetter:String = tag.charAt().toLowerCase();			
			return firstLetter + tag.substr(1);
		}
		
		/**
		 * 注册动态组件。
		 * 动态组件必须先注册才能被创建。
		 */ 
		public static function registerComponent(type:Class):void
		{
			var tag:String = getComponentTypeName(type);
							
			__mapping[tag] = type;
		}
		
		public static function registerComponentAlias(alias:String, typeName:String):void
		{
			__mappingAlias[alias] = typeName;
		}
		
		/**
		 * 撤销动态组件。
		 * 通常用于以插件方式加载的动态组件。
		 */ 
		public static function unregisterComponent(type:Class):void
		{			
			var tag:String = cufGetClassName(type); 
			tag = tag.toLowerCase();
			
			cufDeleteByValue(__mappingAlias, tag);
			
			delete __mapping[tag];
		}
		
		/**
		 * Hosting kernel.
		 */ 
		private var _kernel:IKernel;								
		
		/**
		 * Stylesheet loaded by this factory.
		 */
		private var _styleSheet:IDCLStyleSheet;			
		
		private var _pathResolver:Function;
		
		private var _variables:Dictionary;		
		
		private var _overlayTable:Dictionary;
		
		private var _overlayEnabled:Boolean;
		
		public function DCLFactory(kernel:IKernel, commonStyleSheet:IDCLStyleSheet = null, pathResolver:Function = null)
		{
			super(null);
			
			this._kernel = kernel;
			this._styleSheet = new DCLStyleSheet(commonStyleSheet);		
			this._pathResolver = pathResolver;
			this._variables = new Dictionary();
			this._overlayTable = new Dictionary(true);
			this._overlayEnabled = true;
		}
		
		public function get kernel():IKernel
		{
			return this._kernel;
		}
		
		public function get styleSheet():IDCLStyleSheet
		{
			return this._styleSheet;	
		}		
		
		public function get variables():Dictionary
		{
			return _variables;
		}
		
		public function get overlayEnabled():Boolean
		{
			return this._overlayEnabled;
		}
		
		public function set overlayEnabled(enabled:Boolean):void
		{
			this._overlayEnabled = enabled;
			
			if (!enabled)
			{
				this.hideAllOverlay();
			}
		}			
		
		public function resolvePath(originalPath:String):String
		{
			if (this._pathResolver != null)
			{
				return this._pathResolver(originalPath); 
			}
			
			return originalPath;
		}
		
		public function isComponentXML(xml:XML):Boolean
		{
			var name:String = xml.localName().toString();
			
			return __mapping[name] || (__mappingAlias[name] && __mapping[__mappingAlias[name]]);
		}
		
		public function getDCLLocalizedText(text:String, params:Object = null):String
		{
			return _kernel.getLocalizer("com.dtedu.dcl").getText(text, params);
		}
		
		public function createComponentByName(name:String, byLoading:Boolean = false):IDCLComponent
		{
			var comp:IDCLComponent;
			var clazzObject:* = __mapping[name] || (__mappingAlias[name] && __mapping[__mappingAlias[name]]);
			
			if (clazzObject) 
			{
				try 
				{													
					var clazz:Class = Class(clazzObject);					
					comp = _kernel.popIdleObject(clazz);
					comp ||= new clazz();
					comp.initialize(this, byLoading);
				} 
				catch (er:Error) 
				{
					_kernel.reportError(
						"Error creating DCL type '" + name + "': " + er.message, 
						Common.LOGCAT_DCL
					);												
				}
			}				
			else 
			{
				_kernel.reportError(
					"Unregistered DCL type given: '" + name + "'.", 
					Common.LOGCAT_DCL
				);				
			}
			
			return comp;
		}
		
		public function recycleComponent(component:IDCLComponent):void
		{			
			_kernel.cacheIdleObject(component);			
		}
		
		public function createComponentFromXML(xml:XML):IDCLComponent
		{
			var comp:IDCLComponent = null;
			
			if (!xml) 
			{
				_kernel.reportError(
					"Invalid (null) XML given.", 
					Common.LOGCAT_DCL
				);								
			} 
			else 
			{				
				var name:String = String(xml.localName());
				comp = createComponentByName(name, true);
				comp.loadFromXML(xml);
			}
			
			return comp;
		}				
		
		public function showOverlay(targetComponent:IDCLComponent, overlayName:String = null):IDCLOverlay
		{			
			hideOverlay(targetComponent, null, false);			
			
			try
			{								
				var overlay:IDCLOverlay;
				
				if (overlayName)
				{					
					overlay = IDCLOverlay(createComponentByName(overlayName));					
					this._overlayTable[targetComponent] = overlay;		
				}
				else
				{
					overlay = IDCLOverlay(this._overlayTable[targetComponent]);						
				}
				
				if (overlay)
				{					
					overlay.show(targetComponent);	
				}					
				
				return overlay;
			}
			catch (e:Error)
			{
				_kernel.reportError(
					"Show overlay error. Overlay: " + overlayName + ", Error: " + e.message, 
					Common.LOGCAT_DCL
				);								
			}							
			
			return null;
		}		
		
		public function hideOverlay(targetComponent:IDCLComponent, overlayName:String = null, remove:Boolean = true):void
		{						
			var overlay:IDCLOverlay = IDCLOverlay(this._overlayTable[targetComponent]);
			
			if (remove)
			{
				if (overlay && (overlayName == null || overlay.type == overlayName))
				{
					recycleComponent(overlay);
					delete this._overlayTable[targetComponent];
				}								
			}			
			else
			{
				if (overlay && (overlayName == null || overlay.type == overlayName))
				{
					overlay.hide();
				}
			}
		}
		
		public function hideAllOverlay(mode:String = null):void
		{
			for (var component:* in this._overlayTable)
			{
				if (!mode || mode == IDCLComponent(component).mode)
				{
					hideOverlay(component);
				}
			}
		}
		
		public function dispose():void
		{
			hideAllOverlay();
			
			_pathResolver = null;
			
			//!_styleSheet || _styleSheet.dispose();
			_styleSheet = null;
			
			_kernel = null;
		}
	}
}