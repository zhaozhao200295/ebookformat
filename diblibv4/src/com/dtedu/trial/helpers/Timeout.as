/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.helpers
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    /**
     * This is basically a <code>setTimeout</code> implementation, using an object
     * orientated approach and a <code>Timer</code> object.
     *
     * @author fnuecke
     */
    public class Timeout
    {

        private var timer:Timer;

        private var closure:Function;

        private var thisArg:*;

        private var args:*;

        /**
         * Creates a new timeout.
         *
         * @param delay
         *				the delay in milliseconds after which to run 'closure'.
         * @param closure
         *				the function to call after the timeout.
         * @param thisArg
         *				the variable to use as "this" object when calling the
         *				function given.
         * @param args
         *				arguments to pass to the function to be called.
         */
        public function Timeout(delay:Number, closure:Function, thisArg:* = undefined, ... args)
        {
            this.closure = closure;
            this.thisArg = thisArg;
            this.args = args;
            timer = new Timer(delay, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
            timer.start();
        }

        /**
         * Cancel the timeout, preventing it to fire, and cleaning up all variables.s
         */
        public function cancel():void
        {
            cleanup();
        }

        /**
         * Timer completed, perform action (if not cleaned up before... which should
         * not be possible to happen, but sometimes seems to be the case, perhaps if
         * when the call of the cancel and the timer completion event run in the
         * same frame. But that's just a guess).
         */
        private function handleTimerComplete(e:TimerEvent):void
        {
            closure.apply(thisArg, args);
            cleanup();
        }

        /**
         * Clean up variables.
         */
        private function cleanup():void
        {
            if (timer)
            {
                timer.stop();
                timer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
            }
            timer = null;
            closure = null;
            thisArg = null;
            args = null;
        }
    }
}