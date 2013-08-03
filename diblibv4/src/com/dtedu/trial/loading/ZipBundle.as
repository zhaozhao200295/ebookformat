/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{    
    import com.dtedu.trial.events.ResourceErrorEvent;
    import com.dtedu.trial.interfaces.IResourceBundle;
    import com.dtedu.trial.interfaces.IResourceLoader;
    import com.dtedu.trial.miscs.Common;
    import com.dtedu.trial.utils.Debug;
	import com.dtedu.trial.core.Kernel;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    import nochump.util.zip.ZipFile;

    /**
     * This bundle provides data inside a ZIP file.
     *
     * <p>
     * IMPORTANT: does <em>not</em> support sounds, due to the Sound class lacking
     * a loadBytes() function. Might add later using a workaround.
     * </p>
     */
    public class ZipBundle implements IResourceBundle
    {

        /** Loader used to get the actual ZIP file */
        private var loader_:IResourceLoader;

        /** Array of load requests that came in while the ZIP file was loading */
        private var pending_:Array;

        /** The actual parsed ZIP file */
        private var zipFile_:ZipFile;

        /** Base path to strip away from absolute paths when getting zip entries */
        private var basePath_:String;

        /**
         * Creates a new, uninitialized ZIP bundle.
         *
         * <p>
         * IMPORTANT: you <em>must</em> call the init() or initBytes() function,
         * otherwise this bundle will eternally block all requests going through it!
         * Alternatively, the initializing information can be given directly via the
         * initializer variable.
         * </p>
         *
         * @param basePath the base bath to strip away from absolute URLs.
         * @param initialzier data to initialize the ZIP bundle with (i.e. a
         * 				URLRequest or ByteArray).
         */
        public function ZipBundle(basePath:String = "/", initializer:* = null)
        {
            this.basePath_ = stripdomain(basePath);
			
            if (basePath_.charAt(basePath_.length - 1) != "/")
            {
                basePath_ += "/";
            }
			
            if (basePath_.charAt(0) != "/")
            {
				Kernel.getInstance().reportWarning(
					"Basepath is relative, this could lead to unexpected results.", 
					Common.LOGCAT_TRIAL);				                
            }
			
            pending_ = [];
			
            if (initializer is URLRequest)
            {
                init(initializer);
            }
            else if (initializer is ByteArray)
            {
                initBytes(initializer);
            }
        }

        /**
         * Initializes this ZIP bundle by loading a ZIP file from the given url.
         *
         * @param url the url to the ZIP file to use in this bundle.
         * @return this instance, for convenience.
         * @throws Error if the bundle is already initialized.
         */
        public function init(url:URLRequest):ZipBundle
        {
            if (loader_ || zipFile_)
            {
                throw new Error("Already initialized.");
            }
            loader_ = ResourceProvider.getDefault().load(url, ResourceType.BINARY);
            loader_.addEventListener(Event.COMPLETE, handleLoadComplete);
            loader_.addEventListener(ResourceErrorEvent.RESOURCE_ERROR, handleLoadError);
            return this;
        }

        /**
         * Initializes this ZIP bundle by using the ZIP file represented by the
         * given bytearray.
         *
         * @param data the bytearray representing the ZIP file to use in this bundle.
         * @return this instance, for convenience.
         * @throws Error if the bundle is already initialized.
         */
        public function initBytes(data:ByteArray):ZipBundle
        {
            if (loader_ || zipFile_)
            {
                throw new Error("Already initialized.");
            }
            zipFile_ = new ZipFile(data);
            loadPending();
            return this;
        }

        /**
         * Load of ZIP succeeded, try to parse it.
         */
        private function handleLoadComplete(e:Event):void
        {
            loader_.removeEventListener(Event.COMPLETE, handleLoadComplete);
            loader_.removeEventListener(ErrorEvent.ERROR, handleLoadError);
            zipFile_ = new ZipFile(loader_.data);
            loadPending();
        }

        /**
         * Load failed, let all pending loads fail, too.
         */
        private function handleLoadError(e:ResourceErrorEvent):void
        {
            loader_.removeEventListener(Event.COMPLETE, handleLoadComplete);
            loader_.removeEventListener(ResourceErrorEvent.RESOURCE_ERROR, handleLoadError);
            failPending();
			
			Kernel.getInstance().reportWarning(
				"Could not load ZIP file.", 
				Common.LOGCAT_TRIAL);		
        }

        private function loadPending():void
        {
            for each (var loader:ZipLoader in pending_)
            {
                loader.zipFile = zipFile_;
            }
            pending_ = null;
        }

        private function failPending():void
        {
            for each (var loader:ZipLoader in pending_)
            {
                loader.dispatchEvent(new ResourceErrorEvent(ResourceErrorEvent.RESOURCE_ERROR, null, "ZIP for bundle invalid."));
            }
            pending_ = null;
        }

        /**
         * @inheritDoc
         */
        public function load(request:URLRequest, type:String, context:*):IResourceLoader
        {
            if (loader && relativize(loader.request.url) == relativize(request.url))
            {
                // Self loading is not ok ;)
                // TODO This check might be a little frail...
                throw new Error("Cannot load self.");
            }
            if (!zipFile_ && !pending_)
            {
                // Zip load failed.
                throw new Error("Invalid ZIP bundle.");
            }
            // Get rid of the query part if it's there.
            var path:String = relativize(request.url);
            var q:int = path.indexOf("?");
            if (q >= 0)
            {
                path = path.substring(0, q);
            }
            // OK, check as what to get it.
            var loader:IResourceLoader;
            switch (type)
            {
                case ResourceType.BINARY:
                    loader = new BinaryLoader(this, request, type, zipFile_, path);
                    break;
                case ResourceType.IMAGE:
                    loader = new ImageLoader(this, request, type, zipFile_, path, context);
                    break;
                case ResourceType.TEXT:
                    loader = new TextLoader(this, request, type, zipFile_, path);
                    break;
                default:
                    throw new ArgumentError("Invalid or unsupported resource type.");
            }
            if (pending_)
            {
                pending_.push(loader);
            }
            return loader;
        }

        /**
         * @inheritDoc
         */
        public function supportsType(datatype:String):Boolean
        {
            return (pending_ || zipFile_) && (datatype == ResourceType.BINARY || datatype == ResourceType.IMAGE || datatype == ResourceType.TEXT);
        }

        private function relativize(path:String):String
        {
            path = stripdomain(path);
            if (path.charAt(0) == "/" && path.search(basePath_) == 0)
            {
                return path.substring(basePath_.length);
            }
            else
            {
                return path;
            }
        }

        private function stripdomain(path:String):String
        {
            if (!path)
            {
                return "/"
            }
            var m:Array = path.match("^(?:(?:[a-zA-Z]+:/+(?:[^/]+/)?)(?:/[^/]+))?(.*)$");
            if (m && m.length > 1)
            {
                return m[1].charAt(0) == "/" ? m[1] : ("/" + m[1]);
            }
            else
            {
                return "/";
            }
        }
    }
}

import com.dtedu.trial.events.ResourceErrorEvent;
import com.dtedu.trial.helpers.Timeout;
import com.dtedu.trial.interfaces.IResourceBundle;
import com.dtedu.trial.loading.ResourceLoader;

import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipFile;

internal class ZipLoader extends ResourceLoader
{

    /** Zip file from which to get the resource. */
    protected var zipFile_:ZipFile;

    /** The path inside the ZIP file to the resource to load. */
    private var path_:String;

    /** Timeout used to delay the actual load */
    private var timeout_:Timeout;

    public function ZipLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, zipFile:ZipFile, path:String)
    {
        super(bundle, request, datatype, null);
        this.zipFile = zipFile;
        this.path_ = path;				
    }

    /**
     * Sets the zipfile to use with this loader. If it's not null, the actual
     * load will be triggered in the next frame.
     */
    public function set zipFile(value:ZipFile):void
    {
        this.zipFile_ = value;
        if (this.zipFile_)
        { 
            timeout_ = new Timeout(1, handleTimeout);
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
            var entry:ZipEntry = zipFile_.getEntry(path_);
            if (entry)
            {
                load(zipFile_.getInput(entry));
            }
            else
            {
                throw new Error("Not found in ZIP.");
            }
            if (data_)
            {
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }
        catch (er:Error)
        {
            dispatchEvent(new ResourceErrorEvent(ResourceErrorEvent.RESOURCE_ERROR, null, "Resource could not be loaded as the requested type: " + er.message));
        }
    }

    /**
     * Actual loading, after this the data_ of the loader should be set.
     * Otherwise an error should be thrown.
     */
    protected function load(data:ByteArray):void
    {
        throw new Error("Not implemented");
    }

    override public function unload():void
    {
        if (timeout_)
        {
            timeout_.cancel();
            timeout_ = null;
        }
        zipFile = null;
    }

}

/**
 * Loader for binary data (equivalent to URLLoader with data type BINARY).
 */
internal class BinaryLoader extends ZipLoader
{
    public function BinaryLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, zipFile:ZipFile, path:String)
    {
        super(bundle, request, datatype, zipFile, path);
    }

    override protected function load(data:ByteArray):void
    {
        data_ = data;
    }
}

/**
 * Loader for image data (equivalent to Loader for normal images).
 */
internal class ImageLoader extends ZipLoader
{
    /** Actual loader used to parse the binary data */
    private var loader:Loader;

    /** LoaderContext to use when parsing the data */
    private var context:LoaderContext;

    public function ImageLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, zipFile:ZipFile, path:String, context:LoaderContext)
    {
        super(bundle, request, datatype, zipFile, path);
    }

    override protected function load(data:ByteArray):void
    {
        loader = new Loader();
        addAsListenerTo(loader.contentLoaderInfo);
        loader.loadBytes(data, context);
        context = null;
        display_ = loader;
    }

    /**
     * Done loading binary data
     */
    protected override function handleComplete(e:Event):void
    {
        if (loader)
        {
            data_ = loader.content;
        }
		
        super.handleComplete(e);
    }

    override public function unload():void
    {
        if (loader)
        {
            try
            {
                loader.close();
            }
            catch (er:Error)
            {
            }
            try
            {
                loader.unload();
            }
            catch (er:Error)
            {
            }
            loader = null;
        }
        super.unload();
    }
}

/**
 * Loader for text data (equivalent to URLLoader with data type TEXT).
 */
internal class TextLoader extends ZipLoader
{
    public function TextLoader(bundle:IResourceBundle, request:URLRequest, datatype:String, zipFile:ZipFile, path:String)
    {
        super(bundle, request, datatype, zipFile, path);
    }

    override protected function load(data:ByteArray):void
    {
        data_ = data.readUTFBytes(data.length)
    }
}
