package com.dtedu.trial.messages
{	
	import com.dtedu.trial.interfaces.ICommand;
	
	import flash.events.Event;

	public class CommandMessage extends Event
	{
		public static const MESSAGE_PREFIX:String = '[C]';	
		
		private var _command:ICommand;
		
		public function CommandMessage(command:ICommand)
		{
			super(command.name);
			
			this._command = command;
		}
		
		public function get command():ICommand
		{
			return this._command;
		}
	}
}