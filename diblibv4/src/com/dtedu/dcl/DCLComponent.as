package com.dtedu.dcl
{
	import com.dtedu.dcl.events.ModeChangeEvent;
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.dcl.interfaces.IDCLContainer;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	import com.dtedu.trial.helpers.EC;
	import com.dtedu.trial.miscs.Common;
	import com.dtedu.trial.utils.Debug;
	import com.dtedu.trial.utils.StringUtil;
	import com.dtedu.trial.utils.UIDUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 *  Name of the skin class to use for this component. The skin must be a class 
	 *  that extends UIComponent. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="openSkinClass", type="Class")]
	
	public class DCLComponent extends EventDispatcher implements IDCLComponent
	{			
		protected var _displayObject:DisplayObject;			
		
		protected var _mode:String;
		protected var _normalEC:EC = new EC();
		protected var _edittingEC:EC = new EC();
		protected var _playingEC:EC = new EC();			
		
		protected var _properties:Properties;		
		
		protected var _factory:IDCLFactory;			
		protected var _parent:IDCLContainer;			
		
		protected var _id:String;
		protected var _styleClasses:Array;
		protected var _inlineStyle:String;			
		
		protected var _editable:Boolean;
		protected var _selectable:Boolean;
		protected var _movable:Boolean;
		protected var _resizable:Boolean;
		protected var _rotatable:Boolean;		
		protected var _locked:Boolean;
		protected var _label:String;
		protected var _title:String;
		protected var _contentGroupID:uint;
		
		protected var _selected:Boolean;
		
		protected var _standbyOverlay:String;
		
		public function DCLComponent(displayObject:DisplayObject)
		{
			super(null);			
				
			_displayObject = displayObject;							
			
			_mode = ComponentMode.UNINIT;
			
			_properties = new Properties(_setAttribute);	
				
			_properties.register("id", UIDUtil.createUID().replace(/-/gi, "").toLowerCase(), cufGetTrimmedString);
			_properties.register("class", null, cufGetTrimmedString);
			_properties.register("style", null, cufGetTrimmedString);	
			_properties.register("x", 0.0, cufGetNumber);
			_properties.register("y", 0.0, cufGetNumber);
			//_properties.register("width", _displayObject.width ? _displayObject.width : NaN, cufGetNumber);
			//_properties.register("height", _displayObject.height ? _displayObject.height : NaN, cufGetNumber);
			_properties.register("label", null, cufGetTrimmedString);
			_properties.register("title", null, cufGetTrimmedString);
			_properties.register("rotation", 0.0, cufGetNumber);
			_properties.register("locked", false, cufGetBoolean);	
			_properties.register("contentGroupID", 0, cufGetNumber);
		}
		
		public function get type():String
		{
			return DCLFactory.getComponentTypeName(this);			
		}
		
		public function get factory():IDCLFactory
		{
			return _factory;
		}				
		
		public function get id():String
		{
			return getDynamicProperty("id");
		}
		
		public function set id(value:String):void
		{
			setDynamicProperty("id", value.toLowerCase());
		}
		
		public function get contentGroupID():uint
		{
			return _contentGroupID;
		}
		
		public function set contentGroupID(value:uint):void
		{
			_contentGroupID = value;
		}
		
		public function get parent():IDCLContainer
		{
			return _parent;
		}
		
		public function set parent(value:IDCLContainer):void
		{
			_parent = value;		
		}		
		
		public function get isContainer():Boolean
		{
			return false;
		}
		
		public function get isPlugin():Boolean
		{
			return false;
		}
		
		public function get styleClasses():Array
		{						
			return _styleClasses;
		}
		
		public function get displayObject():DisplayObject
		{			
			return _displayObject;
		}				
		
		public function get inlineStyle():String
		{
			return _inlineStyle;
		}
		
		public function get editable():Boolean
		{
			return _editable;
		}				
		
		public function get selectable():Boolean
		{
			return _selectable;	
		}			
		 
		public function get movable():Boolean
		{
			return _movable;
		}
		 
		public function get resizable():Boolean
		{
			return _resizable;
		}
 
		public function get rotatable():Boolean
		{
			return _rotatable;
		}		
		
		[Bindable]
		public function get x():Number
		{
			return _displayObject.x;
		}		
		
		public function set x(value:Number):void
		{
			setDynamicProperty("x", value);
		}
		
		[Bindable]
		public function get y():Number
		{
			return _displayObject.y;
		}
		
		public function set y(value:Number):void
		{
			setDynamicProperty("y", value);
		}
		
		[Bindable]
		public function get width():Number
		{
			return _displayObject.width;
		}
		
		public function set width(value:Number):void
		{
			setDynamicProperty("width", value);
		}
		
		[Bindable]
		public function get height():Number
		{
			return _displayObject.height;
		}
		
		public function set height(value:Number):void
		{
			setDynamicProperty("height", value);
		}
		
		[Bindable]
		public function get label():String
		{
			return this._label;
		}
		
		public function set label(value:String):void
		{
			setDynamicProperty("label", value);
		}
		
		[Bindable]
		public function get title():String
		{
			return this._title;
		}
		
		public function set title(value:String):void
		{
			setDynamicProperty("title", value);
		}
		
		[Bindable]
		public function get rotation():Number
		{
			return _displayObject.rotation;
		}
		
		public function set rotation(value:Number):void
		{
			setDynamicProperty("rotation", value);
		}
		
		[Bindable]
		public function get isLocked():Boolean
		{
			return _locked;
		}
		
		public function set isLocked(value:Boolean):void
		{
			setDynamicProperty("locked", value);
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
		}
		
		public function get standbyOverlay():String
		{
			return _standbyOverlay;
		}
		
		public function set standbyOverlay(overlay:String):void
		{
			if (_standbyOverlay != overlay)
			{
				if (overlay == null)
				{
					_factory.hideOverlay(this, this._standbyOverlay);	
				}
				
				_standbyOverlay = overlay;
			}
		}
		 
		public function get mode():String
		{
			return _mode;
		}
		
		public function set mode(newMode:String):void
		{
			if (this._mode != newMode)
			{
				var oldMode:String = this._mode;
				
				switch (oldMode)
				{
					case ComponentMode.STANDBY:
						this._exitStandbyMode(newMode);								
						break;
					
					case ComponentMode.EDITTING:
						this._exitEdittingMode(newMode);			
						break;
					
					case ComponentMode.PLAYING:
						this._exitPlayingMode(newMode);			
						break;
				}
				
				this._mode = newMode;				
				this._factory.hideOverlay(this);
				
				switch (newMode)
				{
					case ComponentMode.STANDBY:
						this._enterStandbyMode(oldMode);								
						break;
					
					case ComponentMode.EDITTING:
						this._enterEdittingMode(oldMode);			
						break;
					
					case ComponentMode.PLAYING:
						this._enterPlayingMode(oldMode);			
						break;
					
					case ComponentMode.FROZEN:
						this._enterFrozenMode(oldMode);
						break;
				}
			}							
		}
		
		public function get isStandby():Boolean
		{
			return _mode == ComponentMode.STANDBY;
		}				
		
		public function get isEditting():Boolean
		{
			return _mode == ComponentMode.EDITTING;
		}		
		
		public function get isPlaying():Boolean
		{
			return _mode == ComponentMode.PLAYING;
		}				
		
		public function get isFrozen():Boolean
		{
			return _mode == ComponentMode.FROZEN;
		}		
		
		public function initialize(factory:IDCLFactory, byLoading:Boolean = false):void
		{
			
			Debug.assertEqual(_mode, ComponentMode.UNINIT);
			
			_factory = factory;						
			
			_editable = false;			
			_selectable = true;
			_movable = true;
			_resizable = true;
			_rotatable = false;	
			
			_selected = false;			
			
			if (!byLoading)
			{
				var names:Array = _properties.getAllPropertyNames();
				
				for each (var prop:String in names)
				{			
					_properties.applyDefault(prop);					
				}		
			}
			
			this._displayObject.addEventListener(MouseEvent.ROLL_OVER, _onRollOver, false, 0, true);
			this._displayObject.addEventListener(MouseEvent.ROLL_OUT, _onRollOut, false, 0, true);
			
			// 内容组别处理
			//contentGroupChangeHandler(null);
			/*var bookViewer:DisplayObject = _factory.kernel.localData.getData("bookViewer") as DisplayObject;
			bookViewer.addEventListener(DCLEvent.CONTENT_GROUP_CHANGE,contentGroupChangeHandler);*/
			addEventListener(Event.ADDED_TO_STAGE,addedHandler);
			
		}
		
		/**
		 * 组件被添加到舞台处理 
		 * @param e
		 * 
		 */		
		protected function addedHandler(e:Event):void
		{
			//contentGroupChangeHandler(null);
		}
		
		/**
		 * 内容组别选择变化处理 
		 * @param e
		 * 
		 */		
		/*protected function contentGroupChangeHandler(e:DCLEvent):void
		{
			if(_contentGroupID&&this.parent)
			{
				var _id:uint = uint(_factory.kernel.localData.getData("contentGroupID"));
				var id:String = String(_factory.kernel.localData.getData("contentGroupID"));
				if(_id==0||_id==_contentGroupID)
				{
					this._displayObject.visible = true;
				}else
				{
					this._displayObject.visible = false;
				}
			}
		}*/
		
		public function dispose():void
		{				
			mode = ComponentMode.UNINIT;
			
			this._displayObject.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
			this._displayObject.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
			
			_normalEC.remove();
			_edittingEC.remove();
			_playingEC.remove();			
			
			_factory.hideOverlay(this);						
			
			_id = null;
			_styleClasses = null;
			_inlineStyle = null;			

			_displayObject.parent && _displayObject.parent.removeChild(_displayObject);
			_parent = null;
			_factory = null;		
			
			_standbyOverlay = null;						
			
			_properties.restoreDefault();			
		}			
		
		public function standby():void
		{						
			if (!this._parent || this._parent.isEditting)
			{
				this.mode = ComponentMode.STANDBY;										
			}			
			else
			{
				Debug.unexpectedPath("Changging the component into normal mode failed. The container is not in normal mode.");				
			}
		}
		
		public function play():void
		{
			if (!this._parent || this._parent.isPlaying || this._parent.isEditting)
			{
				this.mode = ComponentMode.PLAYING;		
			}
			else
			{
				Debug.unexpectedPath("Changging the component into playing mode failed. The container is not in playing mode or editting mode.");				
			}
		}
		
		public function edit():void
		{						
			if (!this.editable) 
			{
				_factory.kernel.reportError(
					"This component is uneditable.",
				    Common.LOGCAT_DCL
					);
			}
			
			if (!this._parent || this._parent.isEditting)
			{			
				this.mode = ComponentMode.EDITTING;			
			}			
			else
			{
				Debug.unexpectedPath("Changging the component into editting mode failed. The container is not in editting mode.");				
			}		
		}			
		
		public function freeze():void
		{
			if (!this._parent || this._parent.isFrozen)
			{				
				this.mode = ComponentMode.FROZEN;			
			}			
			else
			{
				Debug.unexpectedPath("Changging the component into frozen mode failed. The container is not in frozen mode.");				
			}		
		}				
		
		public function loadFromXML(xml:XML):void
		{		
			var names:Array = _properties.getAllPropertyNames();
			
			for each (var prop:String in names)
			{			
				if (xml.hasOwnProperty("@" + prop)) 
				{
					_properties[prop] = xml.attribute(prop).toString();					
				}		
				else
				{
					_properties.applyDefault(prop);
				}
			}	
		}
		
		public function saveToXML():XML
		{
			var xml:String = "<" + this.type + " ";
			
			var props:Object = _properties.getAllValidValues();
			var value:String;
			
			for (var prop:String in props)
			{
				xml += prop + '="' + props[prop].toString() + '" ';
			}	
			
			xml += "/>";						
			
			return XML(xml);
		}		
		
		public function hasDynamicProperty(name:String):Boolean
		{
			return _properties.hasOwnProperty(name);
		}
		
		public function getDynamicProperty(name:String):*
		{
			return _properties[name];
		}
		
		public function setDynamicProperty(name:String, value:*, byOuterStyle:Boolean = false):void
		{		
			if (byOuterStyle)
			{
				_setAttribute(name, _properties.validate(name, value));		
			}
			else
			{				
				_properties[name] = value;
				
				if (name != "id")
				{
					_parent && _parent.notifyChange(this);
				}							
			}						
		}	
		
		public function invalidate():void
		{
			//根据父容器调整自己的模式			
			if (this._parent)
			{					
				if (this._parent.isPlaying)
				{
					this.play();
				}
				else if (this._parent.isStandby)
				{
					this.standby();
				}
				else if (this._parent.isFrozen)
				{
					this.freeze();
				}
				else if (this._parent.isEditting)
				{
					if (!this.isEditting && !this.isStandby)
					{
						this.standby();
					}					
				}
			}
		}					
		
		protected function _enterStandbyMode(previousMode:String):void
		{												
			this.dispatchEvent(new ModeChangeEvent(ComponentMode.STANDBY));
		}
		
		protected function _exitStandbyMode(newMode:String):void
		{
			this._normalEC.remove();
			
			_factory.hideOverlay(this);
		}
		
		protected function _enterEdittingMode(previousMode:String):void
		{											
			this.dispatchEvent(new ModeChangeEvent(ComponentMode.EDITTING));
		}
		
		protected function _exitEdittingMode(newMode:String):void
		{
			this._edittingEC.remove();
		}
		
		protected function _enterPlayingMode(previousMode:String):void
		{				
			this.dispatchEvent(new ModeChangeEvent(ComponentMode.PLAYING));
		}						
		
		protected function _exitPlayingMode(newMode:String):void
		{
			this._playingEC.remove();	
		}	
		
		protected function _enterFrozenMode(previousMode:String):void
		{				
			this.dispatchEvent(new ModeChangeEvent(ComponentMode.FROZEN));
		}	

		protected function _setAttribute(name:String, value:*):Boolean
		{
			switch (name)				
			{											
				case "class":
					this._styleClasses && (this._styleClasses.length = 0);								
					
					if (value)
					{
						this._styleClasses || (this._styleClasses = []);
						
						for each (var style:String in value.split(" ")) 
						{
							style = StringUtil.trim(style); 
							if (!style) 
							{
								continue;
							}
							
							this._styleClasses.push(style);
						}
					}
					return true;													
				
				case "id":
					this._id = value.toLowerCase();
					return true;																												
				
				case "style":
					this._inlineStyle = value;
					return true;	
					
				case "x":
					if (value != null) _displayObject.x = value;
					return true;
					
				case "y":
					if (value != null) _displayObject.y = value;
					return true;
					
				case "width":
					(value != null) && (_displayObject.width = value);
					return true;
					
				case "height":
					(value != null) && (_displayObject.height = value);
					return true;
					
				case "label":
					(value != null) && (_label = value);
					return true;
					
				case "title":
					(value != null) && (_title = value);
					return true;
					
				case "rotation":
					value ||= 0.0;
					_displayObject.rotation = value;
					return true;
					
				case "locked":
					_locked = value;
					return true;			
				
				case "contentGroupID":
					_contentGroupID = uint(value);
					return true;
					
				default:					
					return false;
			}			
		}
		
		/**
		 * 鼠标移动到组件上时绘制边框
		 **/
		protected function _onRollOver(e:MouseEvent):void
		{												
			if (this.mode == ComponentMode.STANDBY)
			{
				this._standbyOverlay && _factory.showOverlay(this, this._standbyOverlay);								
			}
		}		
		
		protected function _onRollOut(e:MouseEvent):void
		{												
			if (this.mode == ComponentMode.STANDBY)
			{
				this._standbyOverlay && _factory.hideOverlay(this, this._standbyOverlay);								
			}
		}
	}
}