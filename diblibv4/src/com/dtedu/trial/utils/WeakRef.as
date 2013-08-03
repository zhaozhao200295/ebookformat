/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{
    import flash.utils.Dictionary;

    /**
     * Utility class for using weak references.
     *
     * @author fnuecke
     */
    public class WeakRef
    {
        /**
         * Dictionary used to implement the weak referencing.
         */
        private var dict:Dictionary;

        /**
         * Creates a new weak reference to the given object.
         *
         * @param object
         *				the object for which to create a weak reference.
         */
        public function WeakRef(object:Object)
        {
            dict = new Dictionary(true);
            dict[object] = true;
        }

        /**
         * The element referenced to by this weak reference, or <code>null</code>
         * if the referenced object has been garbage collected.
         */
        public function get value():Object
        {
            for (var obj:Object in dict)
            {
                return obj;
            }
            return null;
        }
    }
}
