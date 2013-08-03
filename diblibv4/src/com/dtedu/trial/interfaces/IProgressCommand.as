package com.dtedu.trial.interfaces
{
	public interface IProgressCommand extends ICommand
	{
		function get totalSteps():int;
		
		function increaseTotalSteps(moreSteps:int):void;
		
		function addProgressListener(listener:Function):ICommand;
		
		function removeProgressListener(listener:Function):void;
		
		function increaseStep():void;
	}
}