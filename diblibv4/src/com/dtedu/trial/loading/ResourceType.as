/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{

    /**
     * A list of possible resource types that be me queried from the
     * <code>ResourceProvider</code> class.     
     */
    public class ResourceType
    {
        /** Try to automatically determine type by file extension. */
        public static const AUTO:String = "auto";

        /** Image file */
        public static const IMAGE:String = "image";

        /** Sound file */
        public static const SOUND:String = "sound";

        /** Test data */
        public static const TEXT:String = "text";

        /** Binary data */
        public static const BINARY:String = "binary";
    }
}
