/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.helpers
{    
    import com.dtedu.trial.miscs.Common;
    import com.dtedu.trial.utils.Debug;
    
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;

    /**
     * Event listening helper class.
     * <pre>
	 * <b>Example:</b>
     * import com.dtedu.trial.helpers.EC;
     *
     * var ec:EC = new EC();
     * ec.add(obj, type, listener);
     * ec.remove(obj);
     * </pre>
     */
    public class EC
    {        
        private static var __global:EC;

        public static function get global():EC
        {            
            if (!__global)
                __global = new EC();
            return __global;
        }

		/**
		 * A weak referenced objects map.
		 */ 
        private var _objectMap:Dictionary;	

        public function EC()
        {
            this._objectMap = new Dictionary(true);			
        }				 
		
		public function addWeak(obj:IEventDispatcher,
							eventType:String,
							listener:Function):Boolean
		{
			return this.add(obj, eventType, listener, false, 0, true);
		}

        /**
         * 添加事件监听处理方法。
         *
         * @param obj 需要添加监听的对象。
         * @param eventType 事件类型。
         * @param listener 监听器。
         * @param useCapture 是否在捕捉阶段处理。
         * @param priority 优先级。
         * @param useWeakReference 是否使用弱引用。
         * @return 如果该事件相同的监听器已存在，则返回false，否则返回true。
         */
        public function add(obj:IEventDispatcher,
                            eventType:String,
                            listener:Function,  
							useCapture:Boolean = false,
                            priority:int = 0,
                            useWeakReference:Boolean = false):Boolean
        {
            Debug.assertNotNull(obj);
            Debug.assertNotNull(eventType); 
            Debug.assertNotNull(listener);						

			var objEvents:Object = this._objectMap[obj];
            if (!objEvents)
            {
                // create an entry for a new object
				objEvents = {};
                this._objectMap[obj] = objEvents;
            }
                        
			var objEventCaptureOrNot:Dictionary = objEvents[eventType];			
            if (!objEventCaptureOrNot)
            {
                // create an entry for new event
				objEventCaptureOrNot = new Dictionary();
                objEvents[eventType] = objEventCaptureOrNot;
            }
			
			var objEventListeners:Dictionary = objEventCaptureOrNot[useCapture];			
			if (!objEventListeners)
			{
				// create an entry for new event
				objEventListeners = new Dictionary(true);
				objEventCaptureOrNot[useCapture] = objEventListeners;
			}     

            if (!objEventListeners[listener])
            {
                objEventListeners[listener] = { p: priority, w: useWeakReference };
				
                obj.addEventListener(eventType, listener, useCapture, priority, useWeakReference);

				/*PRAGMA::DEBUG
				{												
	                Debug.trace("Added event listener. Object: " + cufGetDisplayName(obj) +
	                                   "; Event: " + eventType +
									   "; Capture: " + (useCapture ? 'true' : 'false') +
									   "; Weak: " + (useWeakReference ? 'true' : 'false'),
						Common.LOGCAT_TRIAL);
				}*/

                return true; // event added
            }

			/*PRAGMA::DEBUG
			{
            	Debug.trace("Operation ignored! A listener of the event [" +
                               eventType + "] with [" + (useCapture ? 'capture' : 'non-capture') 
							   + "] has already been added to the object [" +
							   cufGetDisplayName(obj) + "].",
							   Common.LOGCAT_TRIAL);
			}*/

            return false; // it's already in  
        }

        /**
         * 移除事件监听处理方法。
         *
         * @param obj 需要移除监听的对象。
         * @param eventType 事件类型，null表示所有事件。
         * @param listener 监听器，null表示所有监听器。
         * @param useCapture 是否在捕捉阶段处理。
         */
        public function remove(obj:IEventDispatcher = null,
                               eventType:String = null,
                               listener:Function = null,
							   useCapture:* = null):void
        {									
            if (!obj)
            {
                for (var objToRemove:* in this._objectMap)
                {
					this.remove(objToRemove, eventType, listener, useCapture);					
                }
				
                return;
            }

            var objEvents:Object = this._objectMap[obj];

            // no entry for this object
            if (!objEvents)
            {
                return;
            }                        

            if (!eventType)
            {            								
                for (eventType in objEvents)
                {
					this.remove(obj, eventType, listener, useCapture);
                }
				
                return;
            }
			
			var objEventCaptureOrNot:Dictionary = objEvents[eventType];
			
			// no entry for this event            
			if (!objEventCaptureOrNot)
			{
				return;
			}
			
			if (useCapture === null)
			{								
				for (useCapture in objEventCaptureOrNot)
				{
					this.remove(obj, eventType, listener, useCapture);
				}
				
				return;
			}						
			
			var objEventListeners:Dictionary = objEventCaptureOrNot[useCapture];

            // no entry for this event            
            if (!objEventListeners)
            {
                return;
            }

            if (listener === null)
            {
                // remove all listeners for this event                
				for (var listenerToRemove:* in objEventListeners)
				{
					this.remove(obj, eventType, listenerToRemove, useCapture);
				}								
				
				return;
            }           		
			
			var listenerInfo:Object = objEventListeners[listener];
			
			if (!listenerInfo)
			{
/*				PRAGMA::DEBUG
				{	
					Debug.trace("Event listener already removed. Object: " + cufGetDisplayName(obj) +
						"; Event: " + eventType +
						"; Capture: " + useCapture,
						Common.LOGCAT_TRIAL);
				}*/
				
				return;
			}
			
			// remove the specified listeners
			obj.removeEventListener(eventType, listener, cufGetBoolean(useCapture));	
			
			delete objEventListeners[listener];		
			  
/*			PRAGMA::DEBUG
			{	
				Debug.trace("Removed event listener. Object: " + cufGetDisplayName(obj) +
					"; Event: " + eventType +
					"; Capture: " + useCapture +
					"; Weak: " + (listenerInfo.w ? 'true' : 'false'),
					Common.LOGCAT_TRIAL);
			}		*/				
        }      		
    }
}