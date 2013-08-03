/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.commands
{
    import com.dtedu.trial.interfaces.ICommand;
    import com.dtedu.trial.interfaces.IDataBag;
    import com.dtedu.trial.interfaces.IKernel;
    import com.dtedu.trial.storage.DataBag;
    import com.dtedu.trial.utils.Debug;
    
    import flash.display.DisplayObject;

    public class CompositeCommand extends AbstractCommand 
    {
        protected var _commands:Array;

        protected var _abortOnFailure:Boolean;

        protected var _allSucceeded:Boolean;

        public function CompositeCommand(kernel:IKernel, commands:Array, abortOnFailure:Boolean, dataBag:IDataBag)
        {       												
            Debug.assertNotEqual(commands.length, 0, "Empty commands!");
			
			super(kernel, dataBag);

            this._commands = commands;
            this._abortOnFailure = abortOnFailure;
            this._allSucceeded = true;
        }
		
		public function get commands():Array
		{
			return this._commands;
		}
		
		override public function dispose():void
		{			
			for each (var command:ICommand in _commands)
			{
				command.dispose();
			}
			
			_commands = null;
			
			super.dispose();			
		}				
    }
}