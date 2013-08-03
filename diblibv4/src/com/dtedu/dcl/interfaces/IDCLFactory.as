/**
 * Dynamic Component Library (DCL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.dcl.interfaces
{
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.IKernel;
	
	import flash.utils.Dictionary;

	/**
	 * 动态组件库工厂。
	 * 用于动态创建组件，如通过XML、JSON等。
	 */ 
	public interface IDCLFactory extends IDisposable
	{
		function get kernel():IKernel;	
		
		/**
		 * 获取工厂中的样式表。
		 */ 
		function get styleSheet():IDCLStyleSheet;
		
		function get variables():Dictionary;
		
		function get overlayEnabled():Boolean;
		
		function set overlayEnabled(enabled:Boolean):void;		
		
		function resolvePath(originalPath:String):String;
		
		function isComponentXML(xml:XML):Boolean;
		
		function getDCLLocalizedText(text:String, params:Object = null):String;
		
		/**
		 * 通过组件名创建组件，并应用样式表。
		 * 组件名如Box, Img等。
		 */ 
		function createComponentByName(name:String, byLoading:Boolean = false):IDCLComponent;
		
		function recycleComponent(component:IDCLComponent):void;
		
		/**
		 * 通过XML创建组件，并应用样式表。
		 */ 
		function createComponentFromXML(xml:XML):IDCLComponent;					
		
		function showOverlay(targetComponent:IDCLComponent, overlayName:String = null):IDCLOverlay;
		
		function hideOverlay(targetComponent:IDCLComponent, overlayName:String = null, remove:Boolean = true):void;
		
		function hideAllOverlay(mode:String = null):void;
	}
}