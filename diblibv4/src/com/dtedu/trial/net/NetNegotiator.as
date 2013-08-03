package com.dtedu.trial.net
{		
	import com.dtedu.trial.events.NetConnectionEvent;
	import com.dtedu.trial.interfaces.INetListener;
	import com.dtedu.trial.utils.Debug;
	
	import flash.errors.IOError;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.utils.Timer;
	
	/**
	 * The NetNegotiator class attempts to negotiate its way through firewalls and proxy
	 * servers, by trying multiple parallel connection attempts on differing port and protocol combinations.
	 * The first connection to succeed is kept and those still pending are shut down.	 
	 */
	internal class NetNegotiator 
	{		
		private var _listener:INetListener;
		private var _netConnectionURLs:Vector.<String>;
		private var _netConnection:NetConnection;
				
		private var _failedConnectionCount:int;
		//private var _timeOutTimer:Timer;
		//private var _connectionTimer:Timer;
		private var _attemptIndex:int;		
		private var _connectionTimeout:Number;
			
		/**
		 * Constructor.
		 * 
		 * @param connectionAttemptInterval Interval in milliseconds between consecutive connection
		 * attempts.
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetNegotiator(connectionTimeout:Number):void
		{
			super();
			
			this._connectionTimeout = connectionTimeout;			
		}				
		
		/**
		 * @private
		 */
		public function createNetConnection(listener:INetListener, netConnectionURLs:Vector.<String>):void
		{
			this._listener = listener;
			this._netConnectionURLs = netConnectionURLs;			
		
			//initializeConnectionAttempts();
			
			// Initialize counters
			_failedConnectionCount = 0;
			_attemptIndex = 0;
			
			tryToConnect(null);					
		}
		
		/** 
		 * Initializes properties and timers used during rtmp connection attempts.
		 * @private
		 */
		/*
		private function initializeConnectionAttempts():void
		{
			// Master timeout
			if (_connectionTimeout > 0)
			{
				_timeOutTimer = new Timer(_connectionTimeout * _netConnectionURLs.length, 1);
				_timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout);
				_timeOutTimer.start();
				
				// Individual attempt sequencer
				_connectionTimer = new Timer(_connectionTimeout);
				_connectionTimer.addEventListener(TimerEvent.TIMER, tryToConnect);
				_connectionTimer.start();
			}		
		}
		*/
		
		/** 
		 * Attempts to connect to FMS using a particular connection string
		 * @private
		 */
		private function tryToConnect(evt:TimerEvent):void 
		{				
			shutdownConnection();
			
			this._netConnection = new NetConnection();	
			
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError, false, 0, true);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);			
			
			try 
			{				
				var host:String = _netConnectionURLs[_attemptIndex];						
				
				/*PRAGMA::DEBUG				
				{
					Debug.traceDebug("Attempting connection to " + host, "trial.net");
				}	*/			
				
				_netConnection.objectEncoding = ObjectEncoding.AMF3;
				_netConnection.connect(host);			
				_listener.onConnected(_netConnection);

				_attemptIndex++;
				/*
				if (_attemptIndex >= _netConnectionURLs.length) 
				{
					_connectionTimer.removeEventListener(TimerEvent.TIMER, tryToConnect);
					_connectionTimer.stop();
				}
				*/
			}
			catch (e:Error) 
			{
				handleFailedConnection(e, _netConnectionURLs[_attemptIndex]);				
			}						
		}
		
		/** 
		 * Monitors status events from the NetConnections
		 * @private
		 */
		private function onNetStatus(event:NetStatusEvent):void 
		{
			switch (event.info.code) 
			{			
				case "NetConnection.Connect.Rejected":
       			case "NetConnection.Connect.Failed":
    				_failedConnectionCount++;
    				
					/*PRAGMA::DEBUG
					{
						if (_failedConnectionCount < _netConnectionURLs.length)
						{
							Debug.traceDebug("NetConnection attempt failed: " + NetConnection(event.target).uri, "trial.net");
						}
					}*/

    				if (_failedConnectionCount >= _netConnectionURLs.length) 
    				{
    					handleFailedConnection(new Error(event.info.description), NetConnection(event.target).uri);
    				}
					else
					{
						//_connectionTimer.reset();
						tryToConnect(null);
					}
    				break;							
			}
		}
		
  		/** 
		 * Closes down all parallel connections in the netConnections vector which are not connected.
		 * Also shuts down the master timeout and attempt timers. 
		 * @private
		 */
		private function shutdownConnection():void
		{						
			if (_netConnection)
			{
				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError);
				_netConnection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				_netConnection.close();
				_netConnection = null;
			}
		}

		/** 
		 * Handles a failed connection session and dispatches a CONNECTION_FAILED event
		 * @private
		 */
		private function handleFailedConnection(e:Error, url:String):void
		{
/*			PRAGMA::DEBUG				
			{
				Debug.traceDebug("NetConnection attempt failed: " + url + " (" + e.errorID + "): " + e.message, "trial.net");
			}*/
			
			/*
			_timeOutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout);
			_timeOutTimer.stop();
			
			_connectionTimer.removeEventListener(TimerEvent.TIMER, tryToConnect);
			_connectionTimer.stop();
			*/
			
			shutdownConnection();		
			
			_listener && _listener.onConnectError(e);
		}
		
		/** 
		 * Catches any netconnection net security errors
		 * @private
		 */
		private function onNetSecurityError(event:SecurityErrorEvent):void
		{
			handleFailedConnection(new SecurityError(event.text, event.errorID), NetConnection(event.target).uri);
		}

    	/** 
    	 * Catches any async errors
    	 * @private
    	 */
		private function onAsyncError(event:AsyncErrorEvent):void 
		{
			handleFailedConnection(event.error, NetConnection(event.target).uri);
		}

		/** 
		 * Catches the master timeout when no connections have succeeded within _timeout.
		 * @private
		 */
		/*
		private function masterTimeout(event:TimerEvent):void 
		{
			handleFailedConnection(new Error("Connection timeout"), null);
		}					
		*/
	}
}

