/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.events
{

    import flash.events.ErrorEvent;

    /**
     * Error event used when a <code>ResourceLoader</code> fails.
     */
    public class ResourceErrorEvent extends ErrorEvent
    {

        /**
         * Dispatched by <code>ResourceLoader</code>s if the load fails.
         *
         * @eventType resource_error
         */
        public static const RESOURCE_ERROR:String = "resource_error";

        /** The original error event. May be null. */
        private var inner_:ErrorEvent;

        public function ResourceErrorEvent(type:String, inner:ErrorEvent, text:String = "")
        {
            super(type, false, false, text);
            this.inner_ = inner;
        }

        /**
         * The inner error event, i.e. the original cause for this one.
         *
         * <p>
         * May be <code>null</code>
         * </p>
         */
        public function get inner():ErrorEvent
        {
            return inner_;
        }
    }
}
