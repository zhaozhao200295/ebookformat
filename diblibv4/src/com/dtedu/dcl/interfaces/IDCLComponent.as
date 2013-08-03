/**
 * Dynamic Component Library (DCL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.dcl.interfaces
{
	import flash.display.DisplayObject;
	
	/**
	 * 动态组件库的所有组件的共有接口。
	 * 包括非可视组件、可视组件和可视组件容器。
	 */ 
	public interface IDCLComponent extends IDCLDisplayObject
	{				
		/**
		 * 组件的类型。
		 */ 
		function get type():String;
		
		/**
		 * 创建该组件的工厂。
		 */ 
		function get factory():IDCLFactory;			
		
		/**
		 * 组件的ID，一般是全局唯一（非强制要求）。
		 */
		function set id(value:String):void
			
		function get id():String;	
		
		/**
		 * 组件的所属内容组,默认为0;
		 * @return 
		 * 
		 */		
		function get contentGroupID():uint;
		
		function set contentGroupID(value:uint):void;
		
		/**
		 * 组件的容器。		 
		 */ 
		function get parent():IDCLContainer;				
		
		/**
		 * 组件是否为容器。
		 */ 
		function get isContainer():Boolean;
		
		/**
		 * 组件是否为插件
		 */
		function get isPlugin():Boolean;
		
		/**
		 * 组件的样式类。
		 */ 
		function get styleClasses():Array;
		
		/**
		 * 组件的样式属性。
		 */ 
		function get inlineStyle():String;						
		
		/**
		 * 是否可编辑。
		 */ 
		function get editable():Boolean;	
		
		/**
		 * 是否可被选中操作。
		 * 默认可以。
		 */ 
		function get selectable():Boolean;
		
		/**
		 * 是否可被移动。
		 * 默认可以。
		 */ 
		function get movable():Boolean;
		
		/**
		 * 是否可被改变大小。
		 * 默认可以。
		 */ 
		function get resizable():Boolean;
		
		/**
		 * 是否可被旋转。
		 * 默认不可以。
		 */ 
		function get rotatable():Boolean;		
		
		function get x():Number;				
		
		function set x(value:Number):void;		
		
		function get y():Number;
		
		function set y(value:Number):void;			
		
		function get width():Number;		
		
		function set width(value:Number):void;			
		
		function get height():Number;		
		
		function set height(value:Number):void;	
		
		/**
		 * 组件别名
		 */
		function set label(value:String):void;
		
		function get label():String;
		
		/**
		 * 组件真实名
		 */
		function set title(value:String):void;
		
		function get title():String;
		
		function get rotation():Number;		
		
		function set rotation(value:Number):void;			
		
		function get isLocked():Boolean;		
		
		function set isLocked(value:Boolean):void;
		
		function get selected():Boolean;
		
		function set selected(value:Boolean):void;	
		
		function get standbyOverlay():String;
		
		function set standbyOverlay(overlay:String):void;
		
		/**
		 * 组件模式。
		 */ 
		function get mode():String;
		
		/**
		 * 获取当前是否处于备用模式。
		 * 在备用模式下，组件可被选中，并可进行移动、改变大小或进去编辑模式等操作。
		 */ 
		function get isStandby():Boolean;				
		
		/**
		 * 获取当前是否处于编辑模式。
		 */ 
		function get isEditting():Boolean;				
		
		/**
		 * 获取当前是否处于播放模式。
		 * 当组件处于播放模式，该组件不可被选中用于编辑，但可监听播放模式的交互事件。
		 */ 
		function get isPlaying():Boolean;
		
		/**
		 * 获取当前是否处于冻结模式。
		 * 当组件处于冻结模式，该组件不可被选中用于编辑，也不可播放任何动画，不可监听任何交互事件。
		 */ 
		function get isFrozen():Boolean;				
		
		function initialize(factory:IDCLFactory, byLoading:Boolean = false):void;
		
		/**
		 * 进入备用模式。
		 */ 
		function standby():void;
		
		/**
		 * 进入编辑模式。
		 */ 
		function edit():void;
		
		/**
		 * 进入播放模式。
		 */ 
		function play():void;	
		
		/**
		 * 进入冻结模式。
		 */ 
		function freeze():void;						
		
		/**
		 * 通过XML重置组件。
		 */ 
		function loadFromXML(xml:XML):void;
		
		/**
		 * 将组件保存为XML。
		 */ 
		function saveToXML():XML;		
		
		/**
		 * 获取组件是否设置某动态属性。
		 */ 
		function hasDynamicProperty(name:String):Boolean;
		
		/**
		 * 获取组件的动态属性。
		 */ 
		function getDynamicProperty(name:String):*;
		
		/**
		 * 设置组件的动态属性。
		 */ 
		function setDynamicProperty(name:String, value:*, byOuterStyle:Boolean = false):void;			
		
		/**
		 * 状态刷新。
		 */ 
		function invalidate():void;
	}
}