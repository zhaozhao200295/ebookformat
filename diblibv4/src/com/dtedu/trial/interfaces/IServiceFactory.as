package com.dtedu.trial.interfaces
{
	import flash.net.NetConnection;

	public interface IServiceFactory extends IDisposable
	{
		function createConnection(serviceGroupId:String = null):NetConnection;
		function closeConnection(serviceGroupId:String, netConnection:NetConnection):void;
	}
}