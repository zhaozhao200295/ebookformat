package com.dtedu.trial.interfaces
{
	public interface IBrowserNavigator extends IDisposable
	{
		function get fullURL():String;
		
		function get domainRoot():String;
		
		function get queryParams():Object;
	}
}