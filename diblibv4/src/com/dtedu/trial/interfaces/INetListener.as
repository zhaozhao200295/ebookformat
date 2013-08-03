package com.dtedu.trial.interfaces
{
	import flash.net.NetConnection;

	public interface INetListener
	{		
		function get connectionId():String;		
		function onConnected(netConnection:NetConnection):void;
		function onConnectError(error:Error):void;
	}
}