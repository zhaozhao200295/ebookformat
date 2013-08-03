package com.dtedu.trial.net
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * The NetClient class provides support for handling
	 * HTTP header callbacks.	 
	 */	
	dynamic public class NetClient extends Proxy
	{
		// Internals
		//
		
		/**
		 * @private
		 * 
		 * Holds an array of handlers per callback name. 
		 */		
		private var handlers:Dictionary = new Dictionary();
		
		/**
		 * Adds a handler for the specified callback name.	
		 * 
		 * var client:NetClient = new NetClient();
		 * client.addHandler("onMetaData", onMetaData); //add the handler		 
		 * 
		 * @param name Name of callback to handle.
		 * @param handler Handler to add.		 
		 */		
		public function addHandler(name:String, handler:Function, priority:int=0):void
		{
			var handlersForName:Array 
				= handlers.hasOwnProperty(name)
					? handlers[name]
					: (handlers[name] = []);
			
			if (handlersForName.indexOf(handler) == -1)
			{
				var inserted:Boolean = false;
				
				priority = Math.max(0, priority);
				
				// Higher priority handlers are at the front of the list.
				if (priority > 0)
				{
					for (var i:int = 0; i < handlersForName.length; i++)
					{
						var handlerWithPriority:Object = handlersForName[i];
						
						// Stop iterating when we're passed all handlers of
						// this priority.
						if (handlerWithPriority.priority < priority)
						{
							handlersForName.splice(i, 0, {handler:handler, priority:priority});
							inserted = true;
							break;
						}
					}
				}
				if (!inserted)
				{
					handlersForName.push({handler:handler, priority:priority});
				}
			}
		}
		
		/**
		 * Removes a handler method for the specified callback name.
		 * 
		 * @param name Name of callback for whose handler is being removed.
		 * @param handler Handler to remove.	
		 */		
		public function removeHandler(name:String,handler:Function):void
		{
			if (handlers.hasOwnProperty(name))
			{
				var handlersForName:Array = handlers[name];
				for (var i:int = 0; i < handlersForName.length; i++)
				{
					var handlerWithPriority:Object = handlersForName[i];
					if (handlerWithPriority.handler == handler)
					{
						handlersForName.splice(i, 1);
						
						break;
					}
				}
			}
		}
		
		// Proxy Overrides
		//
		
		/**
		 * @private
		 */		
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			return invokeHandlers(methodName, args);
        }
        
        /**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):* 
		{
			var result:*;			
			if (handlers.hasOwnProperty(name))
			{
				result 
					=  function():*
						{
							return invokeHandlers(arguments.callee.name, arguments);
						}
				
				result.name = name;
			}
			
			return result;
		}
		
        /**
		 * @private
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return handlers.hasOwnProperty(name);
		}		
		
		/**
		 * @private
		 * 
		 * Utility method that invokes the handlers for the specified
		 * callback name.
		 *  
		 * @param name The callback name to invoke the handlers for.
		 * @param args The arguments to pass to the individual handlers on
		 * invoking them.
		 * @return <code>null</code> if no handlers have been added for the
		 * specified callback, or otherwise an array holding the result of
		 * each individual handler invokation. 
		 * 
		 */				
		private function invokeHandlers(name:String, args:Array):*
		{
			var result:Array;
			
        	if (handlers.hasOwnProperty(name))
			{
				result = [];
				var handlersForName:Array = handlers[name];
				for each (var handler:Object in handlersForName)
				{
					result.push(handler.handler.apply(null,args));
				}
			}
			
			return result;
		}
	}
}