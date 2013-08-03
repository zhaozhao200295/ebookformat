/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.interfaces
{
    import flash.net.URLRequest;

    /**
     * Interface to the <code>ResourceProvider</code> class. See class itself for
     * more information.
     */
    public interface IResourceProvider
    {
        /**
         * Starts loading a resource from the given location and returns an object
         * allowing to track the progress.
         *
         * <p>
         * The function must not throw for any other reason, instead an error
         * event should be thrown.
         * </p>
         *
         * @param request the url from which to load the resource (identifier).
         * @param type the resource type.
         * @param loaderContext loader context to use for some loaders. Note that some
         * 				resource bundles may choose to ignore this parameter.
         * @param stateContext used for passing some data to the place where the
         * 				complete event is handled.
         * @return a loader object which can be used to track the progress.
         * @throws ArgumentError if the given datatype is not supported by any of
         * 				the resource bundles registered with the provider, or if the
         * 				data type is set to 'automatic' but cannot be resolved.
         */
        function load(request:URLRequest, datatype:String, loaderContext:* = null, stateContext:* = null):IResourceLoader;

        /**
         * Adds a new bundle with the given priority.
         *
         * <p>
         * Resource bundles with higher priority will be queried first. The order of
         * two bundles with the same priority is undefined (can be random).
         * </p>
         *
         * <p>
         * If this bundle had been added before, it'll be removed before the insert,
         * to avoid duplicate entries.
         * </p>
         *
         * @param resource the resource bundle to add.
         * @param priority the priority with which the bundle should be queried.
         */
        function registerBundle(resource:IResourceBundle, priority:uint):void;

        /**
         * All resource bundles known by this provider.
         *
         * <p>
         * IMPORTANT: this generates a new array on each call, so store it where
         * appropriate.
         * </p>
         */
        function get bundles():Array;

        /**
         * Removes the given bundle from the list of known resource bundles, if it
         * is known.
         *
         * @param resource the resource bundle to remove.
         */
        function removeBundle(resource:IResourceBundle):void;
    }
}
