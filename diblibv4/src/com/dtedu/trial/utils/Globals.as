/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{
	import com.dtedu.trial.interfaces.IKernel;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	public class Globals
	{
		public static var stage:Stage;				
		
		public static function tryGetKernel(obj:DisplayObject = null):IKernel
		{												
			var clazz:Class = Class(ApplicationDomain.currentDomain.getDefinition("com.dtedu.trial.core::Kernel"));
			return Object(clazz).getInstance(obj);										
		}
	}
}