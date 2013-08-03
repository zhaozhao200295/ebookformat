/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{

    import com.dtedu.trial.interfaces.IResourceBundle;
    import com.dtedu.trial.interfaces.IResourceLoader;
    import com.dtedu.trial.utils.DictionaryUtil;
    import com.dtedu.trial.utils.StringUtil;
    import com.dtedu.trial.utils.URLUtil;
    
    import flash.display.LoaderInfo;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    /**
     * Instances of this resource bundle implementation may be used to make embedded
     * data available in a transparent fashion.    
     */
    public class EmbeddedBundle implements IResourceBundle
    {

        /**
         * A mapping of names (paths) to the embedded resource associated with it.
         */
        private var resources_:Dictionary;

        /**
         * Base path to resolve relative paths to when adding resources.
         */
        private var _basePath:String;

        /**
         * Initializes a new resource bundle using embedded data using the given
         * loader info to determine a base path. This base path is used to convert
         * relative paths to absolute ones.
         *
         * @param loaderInfo the loaderinfo from which to extract the base path.
         */
        public function EmbeddedBundle(loaderInfo:LoaderInfo)
        {
            resources_ = new Dictionary();

            // Get absolute path. Replace backslashes with slashes for IE in
            // Windows, which uses those for local files.
            this._basePath = URLUtil.getBasePath(loaderInfo.url);            
        }

        /**
         * The base path used by this resource bundle (used to complete relative
         * paths).
         */
        public function get basePath():String
        {
            return _basePath;
        }

        /**
         * All resource entries known by this bundle.
         *
         * <p>
         * IMPORTANT: this generates a new array on each call, so store it where
         * appropriate.
         * </p>
         */
        public function get resources():Array
        {
            return DictionaryUtil.getKeys(resources_);
        }

        /**
         * Register a resource with this bundle.
         *
         * <p>
         * Add an embedded resource or class using this function. For example to
         * add an embedded image, use:<br/>
         * <pre>[Embed(source="image.jpg")]
         * var image:Class;
         * ...
         * bundle.addResource("image.jpg", image, ResourceType.IMAGE);</pre>
         * </p>
         *
         * <p>
         * Note that normal classes extending Sprite can be added as SWFs, too.
         * </p>
         *
         * @param path the absolute or relative path to the resource.
         * @param resource the resource to associate with the given path.
         */
        public function addResource(path:String, resource:Class):void
        {
            resources_[getAbsPath(path)] = resource;
        }

        /**
         * Removes a previously added resource.
         *
         * @param path the absolute or relative path to the resource.
         */
        public function removeResource(path:String):void
        {
            delete resources_[getAbsPath(path)];
        }

        /**
         * @inheritDoc
         */
        public function load(request:URLRequest, type:String, context:*):IResourceLoader
        {
            // Get rid of the query part if it's there.
            var url:String = getAbsPath(request.url);
            var q:int = url.indexOf("?");
            if (q >= 0)
            {
                url = url.substring(0, q);
            }
            // Check if we have that resource.
            var raw:Class = resources_[url];
            if (raw)
            {
                // OK, check as what to get it.
                switch (type)
                {
                    case ResourceType.BINARY:
                        return new BinaryLoader(this, request, type, raw);
                    case ResourceType.IMAGE:
                        return new ImageLoader(this, request, type, raw);
                    case ResourceType.SOUND:
                        return new SoundLoader(this, request, type, raw);
                    case ResourceType.TEXT:
                        return new TextLoader(this, request, type, raw);
                    default:
                        throw new ArgumentError("Invalid or unsupported resource type.");
                }
            }
            // Unknown, error.
            return new NotFoundLoader(this, request);
        }

        /**
         * @inheritDoc
         */
        public function supportsType(datatype:String):Boolean
        {
            return datatype == ResourceType.BINARY || datatype == ResourceType.TEXT || datatype == ResourceType.IMAGE || datatype == ResourceType.SOUND;
        }

        /**
         * Resolves relative paths to absolute ones.
         *
         * @path url the path to resolve to an absolute one.
         */
        private function getAbsPath(url:String):String
        {
			return URLUtil.isAbsURL(url) ? url : URLUtil.combine(this._basePath, url);
        }

    }
}

import com.dtedu.trial.core.Kernel;
import com.dtedu.trial.events.ResourceErrorEvent;
import com.dtedu.trial.helpers.Timeout;
import com.dtedu.trial.interfaces.IResourceBundle;
import com.dtedu.trial.loading.ResourceLoader;
import com.dtedu.trial.miscs.Common;
import com.dtedu.trial.utils.Debug;
import com.dtedu.trial.utils.Globals;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.ByteArray;

/**
 * Base class for "loaders" of this bundle.
 *
 * <p>
 * Basically all this class does is wait one frame before firing the finalizing
 * event (completion per default). Subclasses should create the actual instances
 * of the "loaded" objects.
 * </p>
 */
internal class TimeoutLoader extends ResourceLoader
{

    /** The resource class to create a new instance of */
    protected var clazz_:Class;

    /** Timeout object (to allow canceling). */
    private var timeout_:Timeout;

    /**
     * Creates a new timeout based loader with the given properties.
     */
    public function TimeoutLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, clazz:Class)
    {
        super(bundle, request, datatype, null);
        this.clazz_ = clazz;
        timeout_ = new Timeout(1, handleTimeout);
    }

    override public function unload():void
    {
        if (timeout_)
        {
            timeout_.cancel();
            timeout_ = null;
        }
    }

    /**
     * Handle the timeout, i.e. fire the finalizing event.
     */
    private function handleTimeout():void
    {
        timeout_ = null;
        try
        {
            load();
            dispatchEvent(new Event(Event.COMPLETE));
        }
        catch (er:Error)
        {
            dispatchEvent(
				new ResourceErrorEvent(ResourceErrorEvent.RESOURCE_ERROR, null, 
					"Resource could not be loaded as the requested type: " + er.message)
			);
        }
    }

    /**
     * Actual loading, after this the data_ of the loader should be set.
     * Otherwise an error should be thrown.
     */
    protected function load():void
    {
        throw new Error("Not implemented");
    }
}

/**
 * Loader for binary data (equivalent to URLLoader with data type BINARY).
 */
internal class BinaryLoader extends TimeoutLoader
{
    public function BinaryLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, clazz:Class)
    {
        super(bundle, request, datatype, clazz);
    }

    override protected function load():void
    {
        data_ = ByteArray(new clazz_());
    }
}

/**
 * Loader for image data (equivalent to Loader for normal images).
 */
internal class ImageLoader extends TimeoutLoader
{
    public function ImageLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, clazz:Class)
    {
        super(bundle, request, datatype, clazz);
    }

    override protected function load():void
    {
        data_ = new clazz_();
		
        if (!data)
        {
            // Invalid data... probably won't happen ever (will probably throw
            // an error on new).			
			Kernel.getInstance().reportWarning("Invalid embedded image resource.", Common.LOGCAT_TRIAL);			
            
            data_ = new Bitmap(new BitmapData(1, 1, false, 0xFF0000));
        }
		
        if (data is Bitmap && !Bitmap(data).bitmapData)
        {
            // BitmapData brokzorn...
			Kernel.getInstance().reportWarning("Invalid embedded image bitmap data.", Common.LOGCAT_TRIAL);			
            
            Bitmap(data).bitmapData = new BitmapData(1, 1, false, 0xFF0000);
        }
		
        display_ = data;
    }

    override public function unload():void
    {
        if (data is Bitmap)
        {
            Bitmap(data).bitmapData.dispose();
            data_ = null;
        }
        super.unload();
    }
}

/**
 * Loader for sounds (equivalent to Sound.load)
 */
internal class SoundLoader extends TimeoutLoader
{
    public function SoundLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, clazz:Class)
    {
        super(bundle, request, datatype, clazz);
    }

    override protected function load():void
    {
        data_ = Sound(new clazz_());
    }

    override public function unload():void
    {
        if (data_)
        {
            try
            {
                Sound(data_).close();
            }
            catch (er:Error)
            {
            }
            data_ = null;
        }
    }
}

/**
 * Loader for text data (equivalent to URLLoader with data type TEXT).
 */
internal class TextLoader extends TimeoutLoader
{
    public function TextLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, clazz:Class)
    {
        super(bundle, request, datatype, clazz);
    }

    override protected function load():void
    {
        var data:ByteArray = new clazz_();
        data_ = data.readUTFBytes(data.length)
    }
}

/**
 * Loader to signal the load failed (resource not embedded or invalid type).
 */
internal class NotFoundLoader extends TimeoutLoader
{
    public function NotFoundLoader(bundle:IResourceBundle, request:URLRequest)
    {
        super(bundle, request, null, null);
    }

    override protected function load():void
    {
        throw new Error("Resource not found.");
    }
}
