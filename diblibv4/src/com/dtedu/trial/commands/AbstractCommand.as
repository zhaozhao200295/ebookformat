/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.commands
{    
    import com.dtedu.trial.core.Kernel;
    import com.dtedu.trial.helpers.EC;
    import com.dtedu.trial.interfaces.ICommand;
    import com.dtedu.trial.interfaces.IDataBag;
    import com.dtedu.trial.interfaces.IKernel;
    import com.dtedu.trial.messages.CommandMessage;
    import com.dtedu.trial.storage.DataBag;
    
    import flash.display.DisplayObject;
    import flash.events.EventDispatcher;
    import flash.utils.getQualifiedClassName;
    
    import mx.utils.NameUtil;
    import mx.utils.ObjectUtil;

    /**
     * A base <code>ICommand</code> implementation.
     *
     * <P>
     * Your subclass should override the <code>execute</code>
     * method where your business logic will handle the <code>INotification</code>. </P>
     */
    public class AbstractCommand implements ICommand
    {				
		protected var _name:String;
		
		protected var _completed:Boolean;
		
		protected var _succeeded:Boolean;
		
        protected var _kernel:IKernel;  
		
		protected var _dataBag:IDataBag;
		
		protected var _result:Object;			
		
		public function AbstractCommand(kernel:IKernel, dataBag:IDataBag)
		{	
			this._kernel = kernel;
			this._dataBag = dataBag ? dataBag : new DataBag();			
			 
			this._name = this._kernel.getAutoIncreaseID(cufGetClassName(this));			
			this._succeeded = false;			
		}				
		
		public function get name():String
		{
			return this._name;
		}
		
		public function get kernel():IKernel
		{
			return this._kernel;
		}			
		
		public function get completed():Boolean
		{
			return this._completed;
		}
		
		public function get succeeded():Boolean
		{
			return this._succeeded;
		}
		
		public function get result():Object
		{
			return this._result;
		}
		
		public function get dataBag():IDataBag
		{
			return this._dataBag;
		}
       
        public function execute(data:Object = null):void
        {
        }
		
		public function addListener(listener:Function):ICommand
		{
			this._kernel.addCommandListener(
				this._name,
				listener
			);
			
			return this;
		}
		
		public function removeListener(listener:Function):void
		{
			this._kernel.removeCommandListener(
				this._name,
				listener
			);
		}
		
		public function removeAllListeners():void
		{
			this._kernel.removeAllCommandListeners(this._name);
		}
		
		public function markComplete(succeeded:Boolean = true, data:Object = null):void
		{	
			this._succeeded = succeeded;
			this._result = data;						
			
			var command:ICommand = this;
			
			cufCallLater(0, function ():void { _kernel.sendCommandMessage(command);});						
		}
		
		public function dispose():void
		{			
			removeAllListeners();		
			
			this._kernel = null;
			this._dataBag = null;
			this._result = null;
		}				
    }
}