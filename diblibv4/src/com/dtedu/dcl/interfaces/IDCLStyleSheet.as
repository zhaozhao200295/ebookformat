/**
 * Dynamic Component Library (DCL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.dcl.interfaces 
{
	import com.dtedu.digipub.interfaces.IView;

	/**
	 * 动态组件库样式表接口。
	 * 此样式为广义的样式，也可作用于非可视化组件。
	 */
	public interface IDCLStyleSheet 
	{
		/**
		 * Add style element block into the style sheet and override the existing items if any.
		 * 
		 * @param styleBlock
		 *				the content of style element.
		 */ 
		function addStyleDefinitions(definitions:String):void;
		
		/**
		 * Applies all known styles to a DCL component.
		 * 
		 * @param object
		 *				the object to which to apply known styles.
		 * @param xml
		 *				the object's own, set styles. This is just used to check 
		 *				which attributes may not be overwritten.
		 */
		function applyStyles(object:IDCLComponent):void;	
		
		function applyDisplayObjectStyles(object:IView, styleName:String, item:Array):void;
	}
}