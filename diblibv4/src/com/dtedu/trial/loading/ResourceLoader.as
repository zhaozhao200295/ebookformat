/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{
    import com.dtedu.trial.events.ResourceErrorEvent;
    import com.dtedu.trial.interfaces.IResourceBundle;
    import com.dtedu.trial.interfaces.IResourceLoader;

    import flash.display.DisplayObject;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;

    /**
     * Convenience base class for resource loaders.
     *
     * <p>
     * This class implements most of the common functionality required of resource
     * loader implementations. All functions can be overridden (or ignored) as
     * required by subclasses.
     * </p>     
     */
    public class ResourceLoader extends EventDispatcher implements IResourceLoader
    {

        /** Resource bundle that created this instance. */
        protected var bundle_:IResourceBundle;

        /** Optional context information for the loader. */
        protected var context_:*;

        /** Data representing the actual loaded resource. */
        protected var data_:*;

        /** Type of the loaded data. */
        protected var datatype_:String;

        /** Wrapper display object container for loaders of visual content. */
        protected var display_:DisplayObject;

        /** URLRequest that triggered this load. */
        protected var request_:URLRequest;

        /**
         * Initializes the loader for the given bundle and with the given type.
         *
         * @param bundle the resource bundle the loader was spawned by.
         * @param request the request describing where to find the resource.
         * @param datatype the datatype of the resource being loaded.
         * @param context optional loader context.
         */
        public function ResourceLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, context:*)
        {
            bundle_ = bundle;
            context_ = context;
            datatype_ = datatype;
            request_ = request;
        }

        /**
         * @inheritDoc
         */
        public function get bundle():IResourceBundle
        {
            return bundle_;
        }

        /**
         * @inheritDoc
         */
        public function get loaderContext():*
        {
            return context_;
        }

        /**
         * @inheritDoc
         */
        public function get data():*
        {
            return data_;
        }

        /**
         * @inheritDoc
         */
        public function get datatype():String
        {
            return datatype_;
        }
		
		public function get stateContext():*
		{
			return null;
		}

        /**
         * @inheritDoc
         */
        public function get display():DisplayObject
        {
            return display_;
        }

        /**
         * @inheritDoc
         */
        public function get request():URLRequest
        {
            return request_;
        }

        /**
         * @inheritDoc
         *
         * To be overridden by subclasses where appropriate. This should serve as a
         * combination of "close", i.e. aborting a load, and "unload", i.e.
         * disposing a loaded resource.
         */
        public function unload():void
        {
        }
		
		public function detachAndClean():void
		{
			this.bundle_ = null;			
			this.context_ = null;			
			this.data_ = null;			
			this.display_ = null;							
			this.request_ = null;
		}

        /**
         * Adds this instance as a listener for the following events to the given
         * dispatcher:<br/>
         * Event.COMPLETE, IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR
         * and ProgressEvent.PROGRESS<br/>
         * The events are handled by these overridable functions:<br/>
         * handleComplete, handleError, handleSecurityError and handleProgress<br/>
         * By default, they just forward the event by redispatching it via this
         * instance.
         *
         * @param dispatcher the event dispatcher to register self with.
         */
        protected function addAsListenerTo(dispatcher:IEventDispatcher):void
        {
            dispatcher.addEventListener(Event.COMPLETE, handleComplete);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, handleError);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, handleProgress);
        }

        /**
         * This function is called by the default handlers for the completion and
         * error events and removes this loader as a listener from the dispatcher.
         * Used as cleanup when added via <code>addAsListenerTo</code>.
         *
         * @param e the event to use to fetch the dispatcher.
         */
        protected function removeAsListener(dispatcher:IEventDispatcher):void
        {
            dispatcher.removeEventListener(Event.COMPLETE, handleComplete);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
            dispatcher.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
        }

        /**
         * Default handler for completion events.
         *
         * <p>
         * In case a finished load requires special actions override this function.
         * </p>
         */
        protected function handleComplete(e:Event):void
        {
            removeAsListener(IEventDispatcher(e.currentTarget));
            dispatchEvent(e.clone());
        }

        /**
         * Default handler for error events.
         *
         * <p>
         * In case a load error requires special actions override this function.
         * </p>
         */
        protected function handleError(e:ErrorEvent):void
        {
            removeAsListener(IEventDispatcher(e.currentTarget));
            dispatchEvent(new ResourceErrorEvent(ResourceErrorEvent.RESOURCE_ERROR, e, e.text));
        }

        /**
         * Default handler for progress events.
         *
         * <p>
         * In case a progress event requires special actions override this function.
         * </p>
         */
        protected function handleProgress(e:ProgressEvent):void
        {
            dispatchEvent(e.clone());
        }				
    }
}
