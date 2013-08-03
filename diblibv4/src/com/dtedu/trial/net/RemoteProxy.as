/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.net
{    
    import com.dtedu.trial.interfaces.INetListener;
    import com.dtedu.trial.interfaces.IRemoteResponder;
    import com.dtedu.trial.miscs.Common;
    import com.dtedu.trial.utils.Debug;
    
    import flash.events.Event;
    import flash.events.NetStatusEvent;
    import flash.net.NetConnection;
    import flash.net.Responder;
    import flash.utils.Dictionary;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
    
    import mx.rpc.CallResponder;

    use namespace flash_proxy;

    /**
     * A proxy class of RemoteObject.
     *
     * @example <code>
     *     var proxy:RemoteProxy = new RemoteProxy("serviceName", responder, "conntectionId");
     *     proxy.serviceOperation(argument1, argument2, ...);
     * </code>
     */
    public dynamic class RemoteProxy extends Proxy  
    {             				
        public static function getOne(serviceName:String, responder:IRemoteResponder = null, connectionId:String = null):RemoteProxy
        {
            return new RemoteProxy(serviceName, responder, connectionId);
        }       
		
        private var _serviceName:String;
		private var _connectionId:String;		
		private var _resultResponder:IRemoteResponder;
		private var _callResponder:CallResponder;

        public function RemoteProxy(serviceName:String, responder:IRemoteResponder = null, connectionId:String = null)
        {
			this._serviceName = serviceName;
			this._connectionId = connectionId;
			this._resultResponder = responder;			
        }	
		
		public function get serviceName():String
		{
			return this._serviceName;
		}	
		
		public function get connectionId():String
		{
			return this._connectionId;
		}								
		
		override flash_proxy function callProperty(name:*, ... args:Array):*
		{		
			this._callResponder && this._callResponder.cancel();			
			
			var pendingCall:String = this._serviceName + "." + name;			
			var netConnection:NetConnection = this._resultResponder.kernel.serviceFactory.createConnection(this._connectionId);
			
			this._callResponder = new CallResponder(this._connectionId, netConnection, pendingCall, _resultResponder);
			
			var applyArgs:Array = [ pendingCall, this._callResponder ].concat(args);					
			
/*			PRAGMA::DEBUG
			{
				Debug.trace("Remote call to [" + pendingCall + "] was just sent out.", Common.LOGCAT_TRIAL);
			}*/
			
			return netConnection.call.apply(netConnection, applyArgs);			
		}					        
    }
}

import com.dtedu.trial.interfaces.IRemoteResponder;
import com.dtedu.trial.miscs.Common;
import com.dtedu.trial.utils.Debug;

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.Responder;

class CallResponder extends Responder
{
	private var _remoteCall:String;
	private var _channelId:String;
	private var _netConnection:NetConnection;
	private var _responder:IRemoteResponder;	
	
	public function CallResponder(channelId:String, netConnection:NetConnection, remoteCall:String, responder:IRemoteResponder)
	{
		super(this.result, this.fault);
		
		this._channelId = channelId;
		this._netConnection = netConnection;
		this._remoteCall = remoteCall;
		this._responder = responder;
		
		netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true); 
	}
	
	public function cancel():void
	{
		this._responder = null;
		this._responder.kernel.serviceFactory.closeConnection(this._channelId, this._netConnection);			
		_netConnection = null;						
	}			
	
	private function onNetStatus(event:NetStatusEvent):void
	{
		switch (event.info.code) 
		{	
			case "NetConnection.Connect.Rejected":
			case "NetConnection.Connect.Failed":
			case "NetConnection.Call.BadVersion":
			case "NetConnection.Call.Failed":
			case "NetConnection.Call.Prohibited":
				this.fault(new Error(event.info.description));					 
				break;
		}
	}
	
	private function handleResponse():void
	{	
		try
		{			
			this._responder.kernel.serviceFactory.closeConnection(this._channelId, this._netConnection);
		} 
		catch(error:Error) 
		{
			/*PRAGMA::DEBUG
			{
				Debug.trace(error.getStackTrace());
			}*/	
		}			
		_netConnection = null;						
	}
	
	private function result(result:Object):void
	{
		/*PRAGMA::DEBUG
		{
			Debug.trace("Remote call to [" + this._remoteCall + "] came back successfully.", Common.LOGCAT_TRIAL);
		}*/	
		
		this.handleResponse();
		
		if (this._responder)
		{							            
			try
			{										
				this._responder.handleResult(result);
			}
			catch (e:Error)
			{
				this._responder.kernel.reportError(					
					"Error occurrid on handling remoting result: " + e.message, 
					Common.LOGCAT_TRIAL
				);
			}	     
			
			this._responder = null;
		}						
	}
	
	private function fault(fault:Object):void
	{    
/*		PRAGMA::DEBUG
		{
			Debug.trace("Remote call to [" + this._remoteCall + "] failed.", Common.LOGCAT_TRIAL);
		}	*/		
		
		this.handleResponse();			
		
		if (this._responder)
		{			
			//process header					            
			try
			{					
				this._responder.handleFault(fault);
			}
			catch (e:Error)
			{
				this._responder.kernel.reportError(					
					"Error occurrid on handling remoting failure: " + e.message, 
					Common.LOGCAT_TRIAL
				);
			}	            
			
			this._responder = null;
		}
	}       
}