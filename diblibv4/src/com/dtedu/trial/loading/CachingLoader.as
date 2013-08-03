/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{   
    import com.dtedu.trial.utils.DictionaryUtil;
    import com.dtedu.trial.core.Kernel;
    import com.dtedu.trial.events.ResourceErrorEvent;
    import com.dtedu.trial.helpers.EC;
    import com.dtedu.trial.interfaces.IResourceLoader;
    import com.dtedu.trial.miscs.Common;
    import com.dtedu.trial.utils.Debug;
    import com.dtedu.trial.utils.Globals;
    
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    /**
     * Used by the <code>FileSystemBundle</code> to load images and SWFs.
     *
     * <p>
     * Once a load for a certain url has been requested, the loaded data will be
     * cached and the cached data used for further loads.
     * </p>
     *
     * <p>
     * The number of "real" loads is limited, to keep performance acceptable. Also,
     * cached data will be cleared after a certain time if it was not requested
     * again.
     * </p>     
     */
    public class CachingLoader
    {

        /**
         * Number of maximum loading operations allowed at a time.
         *
         * <p>
         * This number only affects the number of parallel real loads (i.e. loads
         * running through ResourceLoaders), not the internal ones (where the data
         * is fetched from the cache).
         * </p>
         */
        private static var maxloading_:uint = 2;

        /**
         * Time in milliseconds after which to dispose cache entries if they have
         * not been requested.
         */
        private static var disposeAfter_:uint = 30000;

        /**
         * Time interval in milliseconds in which, if the same url is requested
         * more than once, to actually cache an element.
         */
        private static var cacheInterval_:uint = 5000;

        /**
         * List of cached data.
         *
         * <p>
         * This can either contain loaded binary data, or an IOErrorEvent in case
         * the original load failed.
         * </p>
         */
        private static var cache_:Dictionary = new Dictionary();

        /**
         * Stores when which element of the cache was last accessed.
         *
         * <p>
         * Used when the clean up timer ticks. Elements that haven't been used for
         * a certain time will be disposed.
         * </p>
         */
        private static var accessTimes_:Dictionary = new Dictionary();

        /**
         * Check every 10 seconds. Unused variable, but allows static initialization
         * this way (yeah, nasty trick, I know).
         */
        private static var cleanupTimer_:Timer = function():Timer
        {
            cleanupTimer_ = new Timer(10000);
            cleanupTimer_.addEventListener(TimerEvent.TIMER, handleTimerTick);
            cleanupTimer_.start(); 
            return cleanupTimer_;
        }();

        /**
         * List of currently loading elements.
         *
         * <p>
         * This maps urls of loading elements (for checking if they are already
         * loading) and ResourceLoader objects (for getting back to the data when
         * done) to an object containing all data related to the loading operation,
         * i.e. the url, the ResourceLoader and the Loader.
         * </p>
         */
        private static var loading_:Dictionary = new Dictionary();

        /**
         * Number of entries in the loading dictionary.
         */
        private static var loadingCount_:uint = 0;

        /**
         * Current loading queue.
         */
        private static var queue_:Array = new Array();

        /**
         * Timer for delayed calling of 'tryLoad', to skip some calls.
         */
        private static var tryLoadTimer_:Timer = function():Timer
        {
            var t:Timer = new Timer(50, 1);
            t.addEventListener(TimerEvent.TIMER_COMPLETE, tryLoad);
            return t;
        }();

        /**
         * Starts loading an element from the given path.
         *
         * <p>
         * First, the element is added to the loading queue. After a short delay
         * (so as not to block, and to allow the caller to add listeners to the
         * loader) it is checked if the element can be loaded from cache, or if it
         * has to be loaded from the server for the first time.
         * </p>
         *
         * <p>
         * <em>Important</em>: unlike when normally working with the Loader class,
         * the IOErrorEvents are dispatched through the loader itself (not through
         * its contentLoaderInfo). The completion event is still dispatched through
         * the contentLoaderInfo.
         * </p>
         *
         * @param url
         *				the url of the file to load.
         * @return a loader which will be used to display the object.
         */
        public static function load(request:URLRequest, context:LoaderContext = null):Loader
        {
            // Create a loader finally used to load the graphics into it.
            var loader:LoaderExt = new LoaderExt();
            // Handle errors.
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError, false, 0, true);
            loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError, false, 0, true);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError, false, 0, true);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError, false, 0, true);
            // Add to loading queue.
            queue_.push(new LoadingQueueNode(request, loader, null, context));
            // Schedule first update, to check if new loading operations can begin.
            if (!tryLoadTimer_.running)
            {
                tryLoadTimer_.reset();
                tryLoadTimer_.start();
            }
            // Return the loader object.
            return loader;
        }

        /**
         * Cancel the loading process for this loader.
         */
        public static function cancel(loader:Loader):void
        {
            for (var i:int = 0; i < queue_.length; ++i)
            {
                if (LoadingQueueNode(queue_[i]).loader == loader)
                {
                    queue_.splice(i, 1);
                    return;
                }
            }
        }

        private static function tryLoad(e:TimerEvent):void
        {
            // Find an element that doesn't have to wait for another element
            // being loaded from the same path to complete.
            // At max, try all elements.
            var ql:int = queue_.length; //Math.min(50, queue_.length);
            for (var i:int = 0; i < ql; ++i)
            {
                var nextLoadCandidate:LoadingQueueNode = queue_.shift();
                var request:URLRequest = nextLoadCandidate.request;
                // Check if the element is available cached.
                var entry:* = getCacheEntry(request.url);
                if (entry)
                {
                    if (entry is ErrorEvent)
                    {
                        // 'twas an invalid load. Throw error.
                        var ee:ErrorEvent = entry;
                        nextLoadCandidate.loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, ee.bubbles, ee.cancelable, ee.text));
                    }
                    else if (entry is Error)
                    {
                        // And throw an error.
                        nextLoadCandidate.loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, (Error(entry).getStackTrace() || String(Error(entry)))));
                    }
                    else if (entry == "direct")
                    {
                        // Load directly.
                        nextLoadCandidate.loader.load(nextLoadCandidate.request, nextLoadCandidate.context);
                    }
                    else
                    {
                        // Cached data available.
                        try
                        {
                            nextLoadCandidate.loader.loadBytes(entry, nextLoadCandidate.context);
                        }
                        catch (er:Error)
                        {
                            // Pass the error on...
                            nextLoadCandidate.loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, (er.getStackTrace() || String(er))));
                            // Remember this failed to avoid running into the same
                            // error again and again...
                            setCacheEntry(request.url, er);
                        }
                    }
                }
                else if (!loading_[request.url] && loadingCount_ < maxloading_)
                {
                    // Not already loading.
                    try
                    {
                        ++loadingCount_;
                        loading_[request.url] = nextLoadCandidate;
                        var rawloader:IResourceLoader = ResourceProvider.getDefault().load(request, ResourceType.BINARY);
                        nextLoadCandidate.rawloader = rawloader;
                        loading_[rawloader] = nextLoadCandidate; 
                        EC.global.add(rawloader, Event.COMPLETE, handleRawLoadComplete);
                        EC.global.add(rawloader, ResourceErrorEvent.RESOURCE_ERROR, handleRawLoadError);
                        EC.global.add(rawloader, ProgressEvent.PROGRESS, nextLoadCandidate.loader.dispatchEvent);
                            // Store as loading.
                    }
                    catch (er:Error)
                    {
                        // Log loading error.						
						Kernel.getInstance().reportWarning("Failed loading real data: " + er.message, Common.LOGCAT_TRIAL);
                        
                        // Set cache to the error event, for later reuse (cloning).
                        setCacheEntry(request.url, er);
                        // Delete from loading list, trigger next load.
                        delete loading_[request.url];
                        delete loading_[rawloader];
                        --loadingCount_;
                    }
                }
                else
                {
                    // One of the same url is already loading, wait for it, try
                    // the next.
                    queue_.push(nextLoadCandidate);
                }
            }
            // In case all loads failed or something...
            if (queue_.length > 0 && !tryLoadTimer_.running)
            {
                tryLoadTimer_.reset();
                tryLoadTimer_.start();
            }
        }

        /**
         * Utility function for getting a cache entry, updating the access time.
         *
         * @param key
         *				key of the entry to get.
         * @return the value of the cache.
         */
        private static function getCacheEntry(key:*):*
        {
            var value:* = cache_[key];
            if (value)
            {
                accessTimes_[key] = new Date().time;
            }
            return value;
        }

        /**
         * Utility function for setting a cache entry, updating the access time.
         *
         * @param key
         *				key of the entry to set.
         * @param value
         *				value of the entry to set.
         */
        private static function setCacheEntry(key:*, value:*):void
        {
            // Only cache if the last request has been during the last 5 seconds.
            if (timeSinceLastAccess(key) < cacheInterval_)
            {
                cache_[key] = value;
            }
            accessTimes_[key] = new Date().time;
        }

        private static function timeSinceLastAccess(key:*):Number
        {
            if (accessTimes_[key])
            {
                return new Date().time - accessTimes_[key];
            }
            else
            {
                return Number.POSITIVE_INFINITY;
            }
        }

        /**
         * ResourceLoader finished loading of real data, store it in the cache
         * dictionary and tell the loader associated with this load to load the
         * bytes.
         *
         * @param e
         *				unused.
         */
        private static function handleRawLoadComplete(e:Event):void
        {
            EC.global.remove(IEventDispatcher(e.target));
            // Get the data...
            var data:LoadingQueueNode = loading_[e.target];
            // Store the loading results in the cache.
            setCacheEntry(data.request.url, data.rawloader.data);
            // Try to load it via the loader.
            try
            {
                data.loader.loadBytes(data.rawloader.data, data.context);
            }
            catch (er:Error)
            {
                // Pass the error on...
                data.loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, (er.getStackTrace() || String(er))));
                // Remember this failed to avoid running into the same
                // error again and again...
                setCacheEntry(data.request.url, er);
            }
            // Delete from loading list, trigger next load.
            delete loading_[data.request.url];
            delete loading_[data.rawloader];
            --loadingCount_;
            tryLoad(null);
        }

        /**
         * Error loading the actual data the first time.
         *
         * @param e
         *				used for cloning when dispatching error events for loaders
         *				trying to load the invalid element from cache.
         */
        private static function handleRawLoadError(e:ResourceErrorEvent):void
        {
            EC.global.remove(IEventDispatcher(e.target));
            // Error loading. Mark as invalid.
            var data:LoadingQueueNode = loading_[e.target];
            // Delete from loading list, trigger next load.
            delete loading_[data.request.url];
            delete loading_[data.rawloader];
            // Try loading directly if it was a security error. This is necessary
            // for loading external content from different domains, such as youtube
            // videos -- which don't like being loaded via URLLoaders.
            if (e.inner is SecurityErrorEvent)
            {
                setCacheEntry(data.request.url, "direct");
                data.loader.load(data.request, data.context);
            }
            else
            {
                // Set cache to the error event, for later reuse (cloning).
                setCacheEntry(data.request.url, e);
                // Dispatch an event (through the loader itself, sadly it's not possible
                // to do this through the LoaderInfo).
                data.loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, e.bubbles, e.cancelable, e.text));
            }
            --loadingCount_;
            tryLoad(null);
        }

        /**
         * Error loading from cache (either corrupt data or invalid initial load).
         *
         * @param e
         *			  used for printing the error message.
         */
        private static function handleLoadError(e:IOErrorEvent):void
        {
            IEventDispatcher(e.target).removeEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            IEventDispatcher(e.target).removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            tryLoad(null);
        }

        /**
         * Clean up entries that have not been used for a while.
         *
         * @param e
         *				unused.
         */
        private static function handleTimerTick(e:TimerEvent):void
        {
            // Dispose of old entries.
            for each (var key:* in DictionaryUtil.getKeys(cache_))
            {
                if (timeSinceLastAccess(key) > disposeAfter_)
                {
                    delete accessTimes_[key];
                    delete cache_[key];
                }
            }
        }
    }
}

import com.dtedu.trial.interfaces.IResourceLoader;
import com.dtedu.trial.loading.LoaderExt;

import flash.net.URLRequest;
import flash.system.LoaderContext;

internal class LoadingQueueNode
{
    public var request:URLRequest;

    public var loader:LoaderExt;

    public var rawloader:IResourceLoader;

    public var context:LoaderContext;

    public function LoadingQueueNode(request:URLRequest, loader:LoaderExt, rawloader:IResourceLoader, context:LoaderContext)
    {
        this.request = request;
        this.loader = loader;
        this.rawloader = rawloader;
        this.context = context;
    }
}
