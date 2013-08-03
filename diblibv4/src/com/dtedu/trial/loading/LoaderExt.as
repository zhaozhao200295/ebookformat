/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{
    import com.dtedu.trial.core.Kernel;
    import com.dtedu.trial.helpers.Timeout;
    import com.dtedu.trial.miscs.Common;
    import com.dtedu.trial.utils.Debug;
    import com.dtedu.trial.utils.Globals;
    
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    /**
     * This class extends the normal <code>Loader</code> class, adding some more
     * functionality.
     *
     * <p>
     * For one, it adds an internal queue, making sure that only a certain number
     * of loading processes take place at a time, resulting in better performance.
     * The exact number can be set using the <code>maxLoading</code> attribute.
     * </p>
     *
     * <p>
     * When cancelling a loading process using <code>close()</code> or
     * <code>unload()</code>, this sets a flag to make sure the content gets
     * unloaded after the load completed. When testing, I found that the calling
     * either during a load on the normal <code>Loader</code> class would not
     * reliably cancel the load.
     * </p> 
     */
    public class LoaderExt extends Loader
    {

        // ---------------------------------------------------------------------- //
        //{ region Queue Variables

        private static var queue_:Array = [[]];

        private static var maxLoading_:uint = 4;

        private static var numLoading_:uint = 0;

        private static var timeout_:Timeout;

        //} endregion
        // ---------------------------------------------------------------------- //

        // ---------------------------------------------------------------------- //
        //{ region State Constants

        private static const INIT:uint = 0;

        private static const QUEUED:uint = 1;

        private static const LOADING:uint = 2;

        private static const LOADED:uint = 3;

        private static const UNLOADED:uint = 4;

        private static const ERROR:uint = 5;

        //} endregion
        // ---------------------------------------------------------------------- //

        // ---------------------------------------------------------------------- //
        //{ region Variables

        private var state_:uint = INIT;

        //} endregion
        // ---------------------------------------------------------------------- //

        // ---------------------------------------------------------------------- //
        //{ region Getter / Setter

        /**
         * The number of loading processes that may run in parallel.
         */
        public static function get maxLoading():uint
        {
            return maxLoading_;
        }

        /**
         * @private
         */
        public static function set maxLoading(newValue:uint):void
        {
            maxLoading_ = newValue;
        }

        /**
         * Whether this loader is currently loading data or not.
         */
        public function get loading():Boolean
        {
            return state_ > INIT && state_ < LOADED;
        }

        /**
         * Whether this loader has completed loading (successfully).
         */
        public function get loaded():Boolean
        {
            return state_ > LOADING && state_ < ERROR;
        }

        //} endregion
        // ---------------------------------------------------------------------- //

        // ---------------------------------------------------------------------- //
        //{ region Overrides

        /**
         * @inheritDoc
         */
        override public function close():void
        {
            if (state_ == QUEUED)
            {
                unqueue();
                state_ = INIT;
            }
            else if (state_ == LOADING)
            {
                try
                {
                    super.close();
                }
                catch (er:Error)
                {
					Kernel.getInstance().reportWarning("Failed closing loader. " + er.message, Common.LOGCAT_TRIAL);                    
                }
                state_ = UNLOADED;
                handleDone();
            }
        }

        /**
         * @inheritDoc
         */
        override public function unload():void
        {
            if (loading)
            {
                close();
            }
            else
            {
                try
                {
                    super["unloadAndStop"]();
                }
                catch (er:Error)
                {
                    super.unload();
                }
                state_ = UNLOADED;
            }
        }

        /**
         * @inheritDoc
         *
         * <b>Important</b>: unlike the Loader.load() function, this one never
         * throws a SecurityError. Add a listener to this instance to listen to
         * SecurityError events for that error (loading is queued and performed
         * when a slot clears, meaning loading via this class is completely
         * asynchronous - even the SecurityError).
         */
        override public function load(request:URLRequest, context:LoaderContext = null):void
        {
            loadPrioritized(request, context);
        }

        /**
         * Like load() this triggers a new load, but with a definable priority.
         * Simply calling load() will add the loader with priority 0, which is the
         * highest priority. Higher values mean the load will be handled later.
         */
        public function loadPrioritized(request:URLRequest, context:LoaderContext = null, priority:int = 0):void
        {
            close();
            // Make sure there's a slot for the requested priority.
            if (queue_.length <= priority)
            {
                queue_.length = priority + 1;
            }
            // Make sure there's a list for the requested priority.
            queue_[priority] ||= [];
            // Push the entry to the queue.
            (queue_[priority] as Array).push(new QueueEntry(this, request, context));
            state_ = QUEUED;
            timeout_ && timeout_.cancel();
            timeout_ = new Timeout(10, loadQueue);
        }

        //} endregion
        // ---------------------------------------------------------------------- //

        // ---------------------------------------------------------------------- //
        //{ region Queueing

        /**
         * Try loading an element from the queue.
         */
        private static function loadQueue():void
        {
            timeout_ && timeout_.cancel();
            timeout_ = null;
            var prio:int = 0;
            while (numLoading_ < maxLoading_ && prio < queue_.length)
            {
                var qp:Array = queue_[prio];
                if (qp && qp.length > 0)
                {
                    var entry:QueueEntry = QueueEntry(qp.shift());
                    entry.loader.loadInternal(entry.request, entry.context);
                }
                else
                {
                    ++prio;
                }
            }
        }

        /**
         * Remove a loader from the queue.
         */
        private function unqueue():void
        {
            var ql:int = queue_.length;
            for (var i:int = 0; i < ql; ++i)
            {
                var qp:Array = queue_[i];
                var qpl:int = qp.length;
                for (var j:int = 0; i < qpl; ++j)
                {
                    if (QueueEntry(qp[j]).loader == this)
                    {
                        var entry:QueueEntry = QueueEntry(qp.splice(j, 1)[0]);
                        entry.loader = null;
                        entry.request = null;
                        entry.context = null;
                        return;
                    }
                }
            }
        }

        //} endregion
        // ---------------------------------------------------------------------- //

        // ---------------------------------------------------------------------- //
        //{ region Actual Loading

        /**
         * Start the actual load by calling super.load().
         *
         * @param request
         *				see Loader.load()
         * @param context
         *				see Loader.load()
         */
        private function loadInternal(request:URLRequest, context:LoaderContext):void
        {
            state_ = LOADING;
            ++numLoading_;
            contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoadDone, false, int.MAX_VALUE);
            contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError, false, int.MAX_VALUE);
            contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError, false, int.MAX_VALUE);
            try
            {
                super.load(request, context);
            }
            catch (er:SecurityError)
            {
                if (hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
                {
                    dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, er.getStackTrace() || er.message));
                }
                state_ = ERROR;
                handleDone();
            }
        }

        /**
         * Loading succeeded, start next loader. If set so, unload again.
         *
         * @param e
         *				unused.
         */
        private function handleLoadDone(e:Event):void
        {
            state_ = LOADED;
            handleDone();
        }

        /**
         * Loading failed, start next loader.
         *
         * @param e
         *				unused.
         */
        private function handleLoadError(e:Event):void
        {
            state_ = ERROR;
            handleDone();
        }

        private function handleDone():void
        {
            --numLoading_;
            contentLoaderInfo.removeEventListener(Event.COMPLETE, handleLoadDone);
            contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            loadQueue();
        }

        //} endregion
        // ---------------------------------------------------------------------- //
    }
}

import com.dtedu.trial.loading.LoaderExt;

import flash.net.URLRequest;
import flash.system.LoaderContext;

/**
 * Class representing a queue entry.
 */
internal class QueueEntry
{

    public var loader:LoaderExt;

    public var request:URLRequest;

    public var context:LoaderContext;

    public function QueueEntry(loader:LoaderExt, request:URLRequest, context:LoaderContext)
    {
        this.loader = loader;
        this.request = request;
        this.context = context;
    }
}
