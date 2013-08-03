package com.dtedu.digipub.commands.page
{ 
	import com.dtedu.trial.core.Kernel;
	import com.dtedu.trial.interfaces.ICommand;
	import com.dtedu.trial.interfaces.IDataBag;
	
	import flash.errors.IllegalOperationError;
	
	public class UndoCommand implements ICommand
	{
		public function UndoCommand()
		{
		
		}
		
		public function addListener(listener:Function):ICommand
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get completed():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function get dataBag():IDataBag
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function execute(data:Object=null):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function markComplete(succeeded:Boolean=true, data:Object=null):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get name():String
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function removeAllListeners():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function removeListener(listener:Function):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get result():Object
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function get succeeded():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function dispose():void
		{
			// TODO Auto Generated method stub
			
		}
		
	}
}