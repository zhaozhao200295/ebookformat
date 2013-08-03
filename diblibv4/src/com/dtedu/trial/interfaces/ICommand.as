/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.interfaces
{
	import com.dtedu.trial.interfaces.IKernel;

    /**
     * The interface definition for a Trial Command.
     *
     * @see com.dtedu.trial.interfaces IMessage
     */
    public interface ICommand extends IDisposable 
    {									
		/**
		 * Get command name
		 */ 
		function get name():String;
		
		function get completed():Boolean;
		
		function get succeeded():Boolean;
		
		function get result():Object;				
		
		function get dataBag():IDataBag;
		
        /**
         * Execute the <code>ICommand</code>'s logic to handle a given <code>IMessage</code>.
         *
         * @param note an <code>IMessage</code> to handle.
         */
        function execute(data:Object = null):void;
		
		function addListener(listener:Function):ICommand;
		
		function removeListener(listener:Function):void;
		
		function removeAllListeners():void;
		
		function markComplete(succeeded:Boolean = true, data:Object = null):void;
    }
}