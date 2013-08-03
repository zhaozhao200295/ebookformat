package com.dtedu.trial.net
{
	import com.dtedu.trial.events.NetConnectionEvent;
	import com.dtedu.trial.helpers.EC;
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.INetListener;
	import com.dtedu.trial.interfaces.IServiceFactory;
	import com.dtedu.trial.miscs.Common;
	import com.dtedu.trial.storage.Pool;
	import com.dtedu.trial.utils.Debug;
	
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.utils.Dictionary;
	
	import mx.messaging.Channel;
	import mx.messaging.channels.NetConnectionChannel;
	
	public class ServiceFactory implements IServiceFactory
	{
		private static const CHANNEL_AMF:String = "AMF";
		
		private static const DEFAULT_SERVICE_ID:String = "default";
		
		private static const DEFAULT_CONNECTION_TIMEOUT:int = 10000;
		
		private static const DEFAULT_REQUEST_TIMEOUT:int = 30000;
		
		private var _connectionsCfg:XML;																	
		
		private var _pool:Pool;
		
		public function ServiceFactory()
		{										
		}
		
		public function reset(connectionsCfg:XML):void
		{				
			dispose();			
			
			this._connectionsCfg = connectionsCfg;			
			Debug.assertNotNull(this._connectionsCfg);
			Debug.assertNotEqual(this._connectionsCfg.serviceGroup.length(), 0);																													
			
			this._pool = new Pool();			
		}		
		
		public function createConnection(serviceGroupId:String = null):NetConnection
		{            
			serviceGroupId || (serviceGroupId = DEFAULT_SERVICE_ID);
			
			var connectionsCfg:XML = this._connectionsCfg.serviceGroup.(@id == serviceGroupId)[0];
			Debug.assertNotNull(connectionsCfg, "Service group [" + serviceGroupId + "] not found!");									
			
			var requestTimeout:int = connectionsCfg.@requestTimeout.length() > 0 ?				
				int(connectionsCfg.@requestTimeout) :
				DEFAULT_REQUEST_TIMEOUT;	
								
			var netConnection:NetConnection = this._pool.popOne(serviceGroupId);						
			
			// Check to see if we already have this connection ready to be shared.
			if (netConnection)
			{
/*				PRAGMA::DEBUG				
				{
					Debug.trace(
						"Reusing cached NetConnection. Service group Id: " + serviceGroupId + ", uri: " + netConnection.uri, 
						Common.LOGCAT_TRIAL
					);					
				}	*/							
				
				return netConnection;
			}																																						
			
			var connectTimeout:int = connectionsCfg.@connectionTimeout.length() > 0 ?				
				int(connectionsCfg.@connectionTimeout) :
				DEFAULT_CONNECTION_TIMEOUT;									
			
			// Set up our URLs and NetConnections
			/*
			var netConnectionURLs:Vector.<String> = new Vector.<String>();
			
			for each (var endpoint:XML in connectionsCfg.endpoint)
			{
				netConnectionURLs.push(endpoint.@uri);	
			}
			*/
			var netConnectionURL:String = connectionsCfg.endpoint[0].@uri;
			
			netConnection = new NetConnection();														
			netConnection.objectEncoding = ObjectEncoding.AMF3; 
			netConnection.connect(netConnectionURL);	
			
			/*PRAGMA::DEBUG				
			{
				Debug.trace(
					"Created new NetConnection. Service group Id: " + serviceGroupId + ", uri: " + netConnectionURL, 
					Common.LOGCAT_TRIAL
				);					
			}	*/
			
			return netConnection;
		}	
		
		public function closeConnection(serviceGroupId:String, netConnection:NetConnection):void
		{							
			serviceGroupId || (serviceGroupId = DEFAULT_SERVICE_ID);
			var connectionsCfg:XML = this._connectionsCfg.serviceGroup.(@id == serviceGroupId)[0];
					
			if (connectionsCfg.@maxIdleConnections.length() > 0 && this._pool.count(serviceGroupId) >= int(connectionsCfg.@maxIdleConnections))
			{			
				netConnection.close();	
				
				/*PRAGMA::DEBUG				
				{
					Debug.trace(
						"NetConnection is closed. Service group Id: " + serviceGroupId + ", uri: " + netConnection.uri, 
						Common.LOGCAT_TRIAL
					);					
				}*/
			}			
			else
			{	
				this._pool.pushOne(serviceGroupId, netConnection);
				
				/*PRAGMA::DEBUG				
				{
					Debug.trace(
						"NetConnection is cached in connection pool. Service Group Id: " + serviceGroupId + ", uri: " + netConnection.uri, 
						Common.LOGCAT_TRIAL
					);					
				}*/
			}
		}
		
		public function dispose():void
		{
			this._connectionsCfg = null;
			
			if (this._pool)
			{
				var conns:Array = this._pool.clearAll(true);
				for each (var conn:NetConnection in conns)
				{
					conn.close();
				}
			}
			
			this._pool = null;
		}
	}
}
