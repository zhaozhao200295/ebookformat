/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{
    import com.dtedu.trial.interfaces.IResourceBundle;
    import com.dtedu.trial.interfaces.IResourceLoader;
    
    import flash.events.Event;
    import flash.media.Sound;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;

    /**
     * A resource bundle using the actual file system to load resources.
     *
     * <p>
     * This basically falls back to the default loaders of Flash.
     * </p>
     *
     * <p>
     * As there is no practical sense in multiple instances of this class, it
     * implements the singleton pattern. Get the sole instance via the static
     * <code>getInstance()</code> function.
     * </p>     
     */
    public class FileSystemBundle implements IResourceBundle
    {

        /** Single and sole instance of this class. */
        private static var instance_:FileSystemBundle;

        /**
         * Use <code>getInstance()</code> to get an instance of this singleton.
         */
        public function FileSystemBundle(singleton:SingletonEnforcer)
        {
        }

        /**
         * Gets an instance of this class, which can then be used as a normal
         * resource bundle to fetch data from the file system.
         */
        public static function getInstance():IResourceBundle
        {
            return instance_ ||= new FileSystemBundle(new SingletonEnforcer());
        }

        /**
         * @inheritDoc
         */
        public function load(request:URLRequest, type:String, context:*):IResourceLoader
        {
            switch (type)
            {
                case ResourceType.BINARY:
                    return new BinaryLoader(request, this, type);
                case ResourceType.IMAGE:
                    return new ImageLoader(request, this, type, context);
                case ResourceType.SOUND:
                    return new SoundLoader(request, this, type, context);
                case ResourceType.TEXT:
                    return new TextLoader(request, this, type);
                default:
                    throw new ArgumentError("Invalid or unsupported resource type.");
            }
        }

        /**
         * @inheritDoc
         */
        public function supportsType(datatype:String):Boolean
        {
            return datatype == ResourceType.BINARY || datatype == ResourceType.TEXT || datatype == ResourceType.IMAGE || datatype == ResourceType.SOUND;
        }
    }
}

import com.dtedu.trial.interfaces.IResourceBundle;
import com.dtedu.trial.loading.CachingLoader;
import com.dtedu.trial.loading.LoaderExt;
import com.dtedu.trial.loading.ResourceLoader;

import flash.display.Loader;
import flash.events.Event;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;

/** Used to make sure this class stays a singleton. */
internal class SingletonEnforcer
{
}

/**
 * Loader for binary data, using an URLLoader.
 */
internal class BinaryLoader extends ResourceLoader
{

    /** Actual loader used. */
    protected var loader_:URLLoader;

    public function BinaryLoader(request:URLRequest, bundle:IResourceBundle, datatype:String)
    {
        super(bundle, request, datatype, null);
        loader_ = new URLLoader();
        loader_.dataFormat = URLLoaderDataFormat.BINARY;
        addAsListenerTo(loader_);
        loader_.load(request);
    }

    /**
     * @inheritDoc
     */
    override public function unload():void
    {
        if (loader_)
        {
            try
            {
                loader_.close();
            }
            catch (er:Error)
            {
            }
            loader_ = null;
        }
    }

    /**
     * @inheritDoc
     */
    override protected function handleComplete(e:Event):void
    {
        data_ = loader_.data;
        super.handleComplete(e);
    }
}

/**
 * Loader for SWFs and images, using the CachingLoader.
 */
internal class ImageLoader extends ResourceLoader
{

    /** Actual loader used. */
    protected var loader_:Loader;

    public function ImageLoader(request:URLRequest, bundle:IResourceBundle, datatype:String, context:*)
    {
        super(bundle, request, datatype, context);
        loader_ = CachingLoader.load(request, LoaderContext(context));
        display_ = loader_;
        addAsListenerTo(loader_);
        addAsListenerTo(loader_.contentLoaderInfo);
    }

    /**
     * @inheritDoc
     */
    override public function unload():void
    {
        if (loader_)
        {
            CachingLoader.cancel(loader_);
            loader_.unload();
            removeAsListener(loader_);
            loader_ = null;
        }
    }

    /**
     * @inheritDoc
     */
    override protected function handleComplete(e:Event):void
    {
        if (loader_)
        {
            data_ = loader_.content;
        }
        super.handleComplete(e);
    }
}

/**
 * Loader for sounds.
 */
internal class SoundLoader extends ResourceLoader
{

    /** Actual loader used. */
    protected var loader_:Sound;

    public function SoundLoader(request:URLRequest, bundle:IResourceBundle, datatype:String, context:*)
    {
        super(bundle, request, datatype, context);
        loader_ = new Sound();
        addAsListenerTo(loader_);
        loader_.load(request, context);
    }

    /**
     * @inheritDoc
     */
    override public function unload():void
    {
        if (loader_)
        {
            try
            {
                loader_.close();
            }
            catch (er:Error)
            {
            }
            loader_ = null;
        }
    }

    /**
     * @inheritDoc
     */
    override protected function handleComplete(e:Event):void
    {
        data_ = loader_;
        super.handleComplete(e);
    }
}

/**
 * Loader for text data.
 */
internal class TextLoader extends ResourceLoader
{

    /** Actual loader used. */
    protected var loader_:URLLoader;

    public function TextLoader(request:URLRequest, bundle:IResourceBundle, datatype:String)
    {
        super(bundle, request, datatype, null);
        loader_ = new URLLoader();
        loader_.dataFormat = URLLoaderDataFormat.TEXT;
        addAsListenerTo(loader_);
        loader_.load(request);
    }

    /**
     * @inheritDoc
     */
    override public function unload():void
    {
        if (loader_)
        {
            try
            {
                loader_.close();
            }
            catch (er:Error)
            {
            }
            loader_ = null;
        }
    }

    /**
     * @inheritDoc
     */
    override protected function handleComplete(e:Event):void
    {
        data_ = loader_.data;
        super.handleComplete(e);
    }
}
