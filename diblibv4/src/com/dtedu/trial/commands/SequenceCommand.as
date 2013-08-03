/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.commands
{
    import com.dtedu.trial.interfaces.ICommand;
    import com.dtedu.trial.interfaces.IDataBag;
    import com.dtedu.trial.interfaces.IKernel;
    import com.dtedu.trial.messages.CommandMessage;
    import com.dtedu.trial.utils.Debug;
    
    import flash.display.DisplayObject;

    public class SequenceCommand extends CompositeCommand
    {
        private var _currentCommand:ICommand;

        private var _currentPos:int;
		
		private var _inputData:Object;

        public function SequenceCommand(kernel:IKernel, commands:Array, abortOnFailure:Boolean = true, dataBag:IDataBag = null)
        {
            super(kernel, commands, abortOnFailure, dataBag);
        }

        override public function execute(data:Object = null):void
        {            
            this._currentPos = 0;
			this._inputData = data;

            executeNextCommand();
        }    	
		
		override public function markComplete(succeeded:Boolean = true, data:Object = null):void
		{
			super.markComplete(succeeded, data);
			
			this._currentCommand = null;
			this._inputData = null;
		}

        private function executeNextCommand():void
        {
            this._currentCommand = this._commands[this._currentPos];            
			
			this._kernel.addCommandListener(this._currentCommand.name, onCommandCompleted);

            this._currentCommand.execute(this._inputData);
        }

        private function onCommandCompleted(message:CommandMessage):void
        {
			this._kernel.removeCommandListener(message.command.name, onCommandCompleted);			
			
            if (!message.command.succeeded)
            {
                this._allSucceeded = false;
            }

            this._currentPos++;

            if (this._currentPos == this._commands.length || (!this._allSucceeded && this._abortOnFailure))
            {
				this.markComplete(this._allSucceeded, this._commands);
            }
            else
            {
                executeNextCommand();
            }
        }
    }
}