package com.dtedu.trial.interfaces
{
	public interface IChangeTarget
	{
		function get hasPendingChanges():Boolean;
		function resetChanges():void;
	}
}