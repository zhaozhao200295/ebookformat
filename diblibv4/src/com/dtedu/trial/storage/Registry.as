/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.storage
{
    import flash.utils.Dictionary;

    /**
     * The Registry is a global store for system-wide values and objects.
     * Because Registry represents a static class it provides a single point of
     * access everywhere.
     */
    public class Registry
    {
        // where system-wide values are stored by scope and index
        private static var scopeIndex:Dictionary = new Dictionary();        

        /**
         * Register data with some global identifier for system-wide lookup.
         *
         * @param	index			String or object identifier with which to
         * 							register and lookup data.
         * @param	value			Data to be registered.
         * @param	scope			Optionally register data to a specific scope
         * 							identifier, creating a localized scope
         * 							within the global space.
         *
         * @see		#lookup
         */
        public static function register(index:Object, value:Object, scope:Object = null):void
        {
            if (scopeIndex[scope] == null)
            {
                scopeIndex[scope] = new Dictionary();
            }

            scopeIndex[scope][index] = value;
        }

        /**
         * Remove any data registered at the specified index and scope.
         *
         * @param	index			String or object identifier with which to
         * 							locate and remove data.
         * @param	scope			Optionally remove data by a specific scope
         * 							identifier, a localized scope within the
         * 							global space.
         *
         * @see		#register
         */
        public static function unregister(index:Object, scope:Object = null):void
        {
            if (scopeIndex[scope] != null)
            {
                delete scopeIndex[scope][index];
            }
        }

        /**
         * Retrieve data registered at the specified index and scope.
         *
         * @param	index			String or object identifier with which to
         * 							lookup registered data.
         * @param	scope			Optionally lookup data by a specific scope
         * 							identifier, a localized scope within the
         * 							global space.
         *
         * @return					Registered data.
         *
         * @see		#register
         */
        public static function lookup(index:Object, scope:Object = null, unregisterAfterLookup:Boolean = false):*
        {
            var dict:Dictionary = scopeIndex[scope] as Dictionary;
            if (dict == null) return null;
            if (unregisterAfterLookup)
            {
                var cache:* = dict[index];
                delete dict[index];
                return cache;
            }
            else
            {
                return dict[index];
            }              
        }
    }
}
