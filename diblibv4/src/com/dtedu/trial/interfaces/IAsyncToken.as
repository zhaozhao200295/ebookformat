package com.dtedu.trial.interfaces
{
	public interface IAsyncToken extends IDisposable
	{
		function get listener():IListener;
		function get notifier():INotifier;
	}
}