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
    
    import flash.display.DisplayObject;

    public class ParallelCommand extends CompositeCommand
    {
        private var _pendingCount:int;

        public function ParallelCommand(kernel:IKernel, commands:Array, abortOnFailure:Boolean = true, dataBag:IDataBag = null)
        {
            super(kernel, commands, abortOnFailure, dataBag);
        }

        override public function execute(data:Object = null):void
        {            
            this._pendingCount = this._commands.length;			

            for each (var command:ICommand in this._commands)
            {
				this._kernel.addCommandListener(command.name, onCommandCompleted);
				
                command.execute(data);
            }
        }

        /**
         * 如果某一命令执行成功的话，将结果存入结果列表；
         * 如果不成功，根据abortOnFailure的值选择继续等待未执行完的命令执行结果，
         * 或中断所有未完成命令的等待。
         */
        private function onCommandCompleted(message:CommandMessage):void
        {
			this._kernel.removeCommandListener(message.command.name, onCommandCompleted);
			
            if (!message.command)
            {
                this._allSucceeded = false;
            }

            this._pendingCount--;

            if (this._pendingCount == 0 || (!this._allSucceeded && this._abortOnFailure))
            {
                this.markComplete(this._allSucceeded, this._commands);
            }
        }
    }
}