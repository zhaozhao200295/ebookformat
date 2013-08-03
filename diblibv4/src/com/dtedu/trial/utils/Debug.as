/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{      
    import com.dtedu.trial.interfaces.IKernel;
    import com.dtedu.trial.miscs.Common;

    public class Debug
    {        				
		private static var kernel:IKernel		
		
        /**
         *
         * @param expression
         * @param message
         * @throws AssertError
         */
        public static function assert(expression:Boolean, message:String):void
        {   
            if (!expression)
            {
                if (message == null)
                {
                    message = "Unknown error.";
                }											
				
				kernel ||= Globals.tryGetKernel();				
				kernel && kernel.reportError(message, Common.LOGCAT_ASSERT, true);													                
            }         			
        }

        /**
         *
         * @param value
         * @param message
         */
        public static function assertNull(value:Object, message:String = null):void
        {
            Debug.assert(value == null, message != null ? message : "Object should be NULL!");
        }

        /**
         *
         * @param value
         * @param message
         */
        public static function assertNotNull(value:Object, message:String = null):void
        {
            Debug.assert(value != null, message != null ? message : "Object should *not* be NULL!");
        }

        /**
         *
         * @param actualValue
         * @param expectedValue
         * @param message
         */
        public static function assertEqual(actualValue:Object, expectedValue:Object, message:String = null):void
        {
            Debug.assert(actualValue == expectedValue, message != null ? message : "Actual value [" + actualValue.toString() + "] does not match expected value [" + expectedValue.toString() + "]!");
        }

        /**
         *
         * @param actualValue
         * @param unexpectedValue
         * @param message
         */
        public static function assertNotEqual(actualValue:Object, unexpectedValue:Object, message:String = null):void
        {
            Debug.assert(actualValue != unexpectedValue, message != null ? message : "Unexpected value [" + actualValue.toString() + "] occurs!");
        }

        /**
         *
         * @param message
         */
        public static function unexpectedPath(message:String = null):void
        {
            Debug.assert(false, message != null ? message : "Unexpected code path!");
        }

        /**
         *
         * @param message
         */
        public static function notImplemented(message:String = null):void
        {
            Debug.assert(false, message != null ? message : "This method has *not* been implemented!");
        }

        /**
         *
         * @param message
         */
        public static function mustOverride(message:String = null):void
        {
            Debug.assert(false, message != null ? message : "This method must be overrided!");
        }				

        /**
         *
         * @param level
         * @param message
         */
        public static function trace(message:Object, category:String = null):void
        {
			kernel ||= Globals.tryGetKernel();
			kernel && kernel.logger.debug(message, category);
        }				
    }
}
