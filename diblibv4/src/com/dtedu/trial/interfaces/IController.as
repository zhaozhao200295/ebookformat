/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.interfaces
{	
	import flash.events.IEventDispatcher;		

    /**
     * The interface definition for a Trial Controller.
     */
    public interface IController extends IEventDispatcher 
    {				
		function get name():String;						
		function get view():Object;
		function get kernel():IKernel;
		
		
		function get locationLink():String;
		function get isSiteNode():Boolean;	
		
		function get childControllers():Array;
        			
        /**
         * Called by the View when the Controller is registered
         */
        function register():void;

        /**
         * Called by the View when the Controller is removed
         */
        function remove():void;				
		
		/**
		 * Called by the child Controller when the child Controller is registered
		 */
		function registerChildController(childController:IController):void;
		
		/**
		 * Called by the child Controller when the child Controller is removed
		 */
		function removeChildController(childController:IController):void;							
    }
}