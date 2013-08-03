/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.events
{
	import flash.events.Event;
	import flash.net.NetConnection;		
	
	/**
	 * A NetConnectionFactory dispatches a NetConnectionFactoryEvent when it has either
	 * succeeded or failed at establishing a NetConnection.	   	 
	 */	
	public class NetConnectionEvent extends Event 
	{
		private var _netConnection:NetConnection;
		private var _id:String;
		private var _url:String;
		private var _error:Error
		
		public static const CONNECTING:String = "connecting";
		
		/**
		 * The NetConnectionFactoryEvent.CREATION_COMPLETE constant defines the value of the
		 * type property of the event object for a NetConnectionFactoryEvent when the 
		 * the class has succeeded in establishing a connected NetConnection.
		 * 
		 * @eventType CREATION_COMPLETE 
		 */	
		public static const CONNECTED:String = "connected";
		
		/**
		 * The NetConnectionFactoryEvent.CREATION_ERROR constant defines the value of the
		 * type property of the event object for a NetConnectionFactoryEvent when the 
		 * the class has failed at establishing a connected NetConnection.
		 * 
		 * @eventType CREATION_ERROR
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CONNECT_ERROR:String = "connectError";

		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param netConnection NetConnection to which this event refers.
 		 * @param resource URLResource to which this event refers.
 		 * @param mediaError Error associated with the creation attempt.  Should only be non-null
		 * when type is CREATION_ERROR.
		 */
		public function NetConnectionEvent
			( type:String
			, bubbles:Boolean=false
			, cancelable:Boolean=false
			, id:String = null  
			, netConnection:NetConnection=null
			, url:String=null
			, error:Error=null  
			)
		{
			super(type, bubbles, cancelable);

			_id = id;
			_netConnection = netConnection;
			_url = url;
			_error = error;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		/**
		 * NetConnection to which this event refers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get netConnection():NetConnection
		{
			return _netConnection;
		}

		/**
		 * URLResource to which this event refers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * Error associated with the creation attempt.  Should only be non-null
		 * when type is CREATION_ERROR.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get error():Error
		{
			return _error;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new NetConnectionEvent(type, bubbles, cancelable, _id, _netConnection, _url, _error);
		}				
	}
}