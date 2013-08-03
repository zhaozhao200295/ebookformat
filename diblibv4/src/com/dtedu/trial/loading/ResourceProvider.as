/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{
    import com.dtedu.trial.events.ResourceErrorEvent;
    import com.dtedu.trial.interfaces.IResourceBundle;
    import com.dtedu.trial.interfaces.IResourceLoader;
    import com.dtedu.trial.interfaces.IResourceProvider;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.utils.Dictionary;

    /**
     * This class can be used for centralized asset management, loading data from
     * whatever resource bundles are given.
     *
     * <p>
     * IMPORTANT: a current limitation is, that no resource bundles must be added
     * or removed while a load is in progress!
     * </p>
     *
     * <p>
     * To add a custom data source, either use one of the existing resource bundle
     * implementations, or write your own. See the specifications in the
     * <code>IResourceBundle</code> interface.
     * </p>
     *
     * <p>
     * A basic request lifecylce works like this:<br/>
     * <ol>
     * <li>START. Call <code>ResourceProvider.load(request, datatype)</code>.</li>
     * <li>Pick resource bundle with the highest priority supporting the requested
     * datatype.</li>
     * <li>Call <code>IResourceBundle.load(request, datatype)</code>.</li>
     * <li>Store returned loader and add listeners.</li>
     * <li>Return a different dummy loader wrapper and wait for events.</li>
     * <li>On error event of actual internal loader:
     * <ul>
     * <li>pick next highest bundle supporting requested datatype
     * and continue with step 3 (with step 4 updating the internal loader reference,
     * and skipping step 5).</li>
     * <li>if no more bundles are available, have the wrapper returned in step 5
     * dispatch an error event. END.
     * </ul>
     * <li>On success event of actual internal loader, push data to the wrapper
     * returned in step 5 and make this wrapper loader in turn dispatch a completion
     * event. END.</li>
     * </ol>
     * </p>
     */
    public class ResourceProvider implements IResourceProvider
    {

        /** Default instance. */
        private static const __defaultProvider:ResourceProvider = new ResourceProvider();

        /**
         * The global default resource provider.
         */
        public static function getDefault():ResourceProvider
        {
            return __defaultProvider;
        }

        /**
         * List of available resource bundles, where the last entry has highest
         * priority.
         *
         * <p>
         * Entries are arrays of length two, with the priority as the first element
         * and the resource bundle as the second.
         * </p>
         */
        private var _bundles:Array;

        /**
         * Maps loaders of underlying resource bundles to the loader we returned
         * when a load was requested.
         *
         * <p>
         * Entries are keys of type IResourceLoader and values of IResourceLoader,
         * where the key is the internal loader, and the value is the external one.
         * </p>
         */
        private var _loaderMapping:Dictionary;
		
		private var _resourceMapping:Object;

        /**
         * Creates a new resource provider, which is initialized to only have a
         * file system resource bundle, i.e. will always patch through loader
         * requests to the file system / web server, until additional bundles are
         * added.
         *
         * <p>
         * Creating explicit instances of this class is likely only necessary in
         * very specific scenarios. In general, consider using the default instance
         * available via <code>getDefault()</code>
         * </p>
         */
        public function ResourceProvider()
        {
            _bundles = [[ 0, FileSystemBundle.getInstance()]];
            _loaderMapping = new Dictionary();
			_resourceMapping = {
				'swf': ResourceType.IMAGE,
				'png': ResourceType.IMAGE,
				'gif': ResourceType.IMAGE,
				'jpg': ResourceType.IMAGE,
				'jpeg': ResourceType.IMAGE,
				
				'mp3': ResourceType.SOUND,
				'wav': ResourceType.SOUND,
				
				'txt': ResourceType.TEXT,
				'html': ResourceType.TEXT,
				'xml': ResourceType.TEXT,
				'xhtml': ResourceType.TEXT,
				'css': ResourceType.TEXT				
			};										
        }

        /**
         * @inheritDoc
         */
        public function load(request:URLRequest, datatype:String, loaderContext:* = null, stateContext:* = null):IResourceLoader
        {
            // Try to resolve the type if it was not explicitly set.
            if (datatype == ResourceType.AUTO)
            {
                datatype = getResourceType(request);
            }

            // Get first bundle to check.
            var bundle:IResourceBundle = nextBundle(null, datatype);
            if (!bundle)
            {
                // No bundle known that is capable of fulfilling a request of this
                // data type.
                throw new ArgumentError("Unsupported data type requested.");
            }

            // Create wrapper loader.
            var outer:LoaderProxy = new LoaderProxy(request, datatype, loaderContext, stateContext);
            outer.addEventListener("canceled", handleLoadCanceled);

            // Start loading internally.
            loadViaBundle(bundle, outer);

            // Return the wrapper.
            return outer;
        }

        /**
         * @inheritDoc
         */
        public function registerBundle(resource:IResourceBundle, priority:uint):void
        {
            // Remove first, to avoid duplicates.
            removeBundle(resource);

            // Try to find an element with a higher priority and insert before it.
            // This basically provides sorted insertion, so we can then work the
            // resources list from back to front when a request comes in.
            // We start at index 1 because the first one will always be the file
            // system.
            for (var i:int = 1; i < _bundles.length; ++i)
            {
                if (_bundles[i][0] > priority)
                {
                    // Found one, insert before.
                    _bundles.splice(Math.max(0, i), 0, [ priority, resource ]);
                    return;
                }
            }

            // None with higher priority found, push to end.
            _bundles.push([ priority, resource ]);
        }

        /**
         * @inheritDoc
         */
        public function get bundles():Array
        {
            var result:Array = new Array(_bundles.length);
            for (var i:int = _bundles.length - 1; i >= 0; --i)
            {
                result[i] = _bundles[i][1];
            }
            return result;
        }

        /**
         * @inheritDoc
         */
        public function removeBundle(resource:IResourceBundle):void
        {
            // Try to find it...
            for (var i:int = 0; i < _bundles.length; ++i)
            {
                if (_bundles[i][1] == resource)
                {
                    // Found it, remove and return.
                    _bundles.splice(i, 1);
                    return;
                }
            }
        }

        /**
         * Try to automatically determine the resource type based on the given
         * request.
         *
         * @param request the request for loading the resource.
         * @return the adjusted url.
         * @throws ArgumentError if the type cannot be determined.
         */
        public function getResourceType(request:URLRequest):String
        {
            // Strip query string if it's there.
            var url:String = request.url;
            var q:int = url.lastIndexOf("?");
            if (q >= 0)
            {
                url = url.substring(0, q);
            }
            // Extract file extension.
            var xt:String = url.substring(url.lastIndexOf(".") + 1);            
			var t:String = _resourceMapping[xt];
			
			if (t) return t;
			
            throw new ArgumentError("Cannot determine resource type.");
        }

        /**
         * Utility function to get the next bundle to try.
         *
         * <p>
         * Searches for the given bundle in the list and starting from there starts
         * further to the beginning of the list (lower priorities).
         * </p>
         *
         * <p>
         * Note that the <code>bundle</code> parameter may be <code>null</code>, in
         * which case the first bundle supporting the given datatype is returned.
         * </p>
         *
         * @param bundle the bundle to start from (last queried one).
         * @param type the datatype that was requested (to check support).
         */
        private function nextBundle(bundle:IResourceBundle, type:String):IResourceBundle
        {
            // Initialize to true if there was no loader given, in which case all
            // bundles are valid for selection.
            var found:Boolean = !bundle;
            // Starting with the last entry...
            for (var i:int = _bundles.length - 1; i >= 0; --i)
            {
                var curr:IResourceBundle = _bundles[i][1];
                // If we may start picking bundles and the current one supports the
                // requested datatype we're successful and return it.
                if (found && curr.supportsType(type))
                {
                    return curr;
                }
                // Flip to true once the old loader was found.
                found ||= curr == bundle;
            }
            // Was the last bundle or not found.
            return null;
        }

        /**
         * Try loading a resource via the given bundle, with the given outer
         * representation.
         *
         * @param bundle the bundle to use.
         * @param outer the loader proxy used for the outside storing the
         * 				parameters necessary for the load.
         */
        private function loadViaBundle(bundle:IResourceBundle, outer:LoaderProxy):void
        {
            // Begin the actual load and store.
            var inner:IResourceLoader = bundle.load(outer.request, outer.datatype, outer.loaderContext);
            _loaderMapping[inner] = outer;
            outer.inner = inner;

            // Wait for events by the internal loader.
            inner.addEventListener(Event.COMPLETE, handleResourceComplete);
            inner.addEventListener(ResourceErrorEvent.RESOURCE_ERROR, handleResourceError);
        }

        /**
         * Clean up an internal loader no longer being used.
         *
         * @param loader the loader to clean up.
         */
        private function cleanup(loader:IResourceLoader):void
        {
            delete _loaderMapping[loader];
            loader.removeEventListener(Event.COMPLETE, handleResourceComplete);
            loader.removeEventListener(ResourceErrorEvent.RESOURCE_ERROR, handleResourceError);
        }

        /**
         * Resource loaded successfully.
         */
        private function handleResourceComplete(e:Event):void
        {
            // Get the data and copy it to the outer loader, having it fire its
            // completion event in turn.
            var inner:IResourceLoader = IResourceLoader(e.currentTarget);
            var outer:LoaderProxy = _loaderMapping[inner];
            cleanup(inner);

            outer.removeEventListener("canceled", handleLoadCanceled);
            outer.success(inner);
        }

        /**
         * Resource loading failed.
         */
        private function handleResourceError(e:ResourceErrorEvent):void
        {
            // Get data and based on it the next bundle to try.
            var inner:IResourceLoader = IResourceLoader(e.currentTarget);
            var outer:LoaderProxy = _loaderMapping[inner];
            cleanup(inner);

            // Check if we have a next bundle to query.
            var bundle:IResourceBundle = nextBundle(inner.bundle, outer.datatype);
            if (!bundle)
            {
                // Last bundle...
                outer.removeEventListener("canceled", handleLoadCanceled);
                outer.error(e);
            }
            else
            {
                // OK, try next.
                loadViaBundle(bundle, outer);
            }
        }

        /**
         * Load was canceled from the outside.
         */
        private function handleLoadCanceled(e:ErrorEvent):void
        {
            // Get data and based on it the next bundle to try.
            var inner:IResourceLoader = IResourceLoader(e.currentTarget);
            var outer:LoaderProxy = _loaderMapping[inner];
            cleanup(inner);
            outer && outer.removeEventListener("canceled", handleLoadCanceled);
        }
    }
}

import com.dtedu.trial.events.ResourceErrorEvent;
import com.dtedu.trial.interfaces.IResourceLoader;
import com.dtedu.trial.loading.ResourceLoader;
import com.dtedu.trial.loading.ResourceType;

import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.URLRequest;

/**
 * This loader does not actually do anything, but is used as a way to propagate
 * actual loads to the original source of the loading process. It will be
 * populated with the results of an internal load on success, and fire the
 * completion event, or error event if no resource bundle could be queried
 * successfully.
 */
internal class LoaderProxy extends ResourceLoader
{

    /** The original loader used to load the resource. */
    private var _innerLoader:IResourceLoader;

    /** Was the load canceled? */
    private var _canceled:Boolean;
	
	private var _stateContext:*;

    /**
     * Initialize a new proxy with the given parameters.
     */
    public function LoaderProxy(request:URLRequest, type:String, loaderContext:*, stateContext:*)
    {
        super(null, request, type, loaderContext);
        if (type == ResourceType.IMAGE)
        {
            display_ = new Sprite();
        }
		
		this._stateContext = stateContext;
    }
	
	/**
	 * @inheritDoc
	 */
	override public function get stateContext():*
	{
		return this._stateContext;
	}

    /**
     * @inheritDoc
     */
    override public function unload():void
    {
        if (_innerLoader)
        {
            _innerLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
            _innerLoader.unload();
            if (!data_)
            {
                dispatchEvent(new ErrorEvent("canceled"));
            }
        }
        _innerLoader = null;
        data_ = null;
        bundle_ = null;
    }
	
	override public function detachAndClean():void
	{
		super.detachAndClean();
		
		if (this._innerLoader)
		{
			this._innerLoader.detachAndClean();			
		}
		
		this._innerLoader = null;
		this._stateContext = null;
	}

    /**
     * Update the current inner loader in use.
     */
    internal function set inner(loader:IResourceLoader):void
    {
        if (_innerLoader)
        {
            _innerLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
        }
        _innerLoader = loader;
        _innerLoader.addEventListener(ProgressEvent.PROGRESS, handleProgress);
    }

    /**
     * Whether the load was canceled.
     */
    internal function get canceled():Boolean
    {
        return _canceled;
    }

    /**
     * Finalizes this loader by copying the data from the given loader and
     * firing a completion event.
     *
     * @param loader the loader from which to copy the data.
     */
    internal function success(loader:IResourceLoader):void
    {
        // Copy data.
        bundle_ = loader.bundle;
        data_ = loader.data;

        // Add to display sprite if it is a display object.
        if (display)
        {
            Sprite(display).addChild(loader.display);
        }

        if (_innerLoader)
        {
            _innerLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
        }

        // Propagate as complete.
        dispatchEvent(new Event(Event.COMPLETE));
    }

    /**
     * Finalizes this loader by letting it fire an io error event.
     */
    internal function error(e:ResourceErrorEvent):void
    {
        if (_innerLoader)
        {
            _innerLoader.removeEventListener(ProgressEvent.PROGRESS, handleProgress);
        }
        _innerLoader = null;
        dispatchEvent(new ResourceErrorEvent(ResourceErrorEvent.RESOURCE_ERROR, e.inner, e.text));
    }
}
