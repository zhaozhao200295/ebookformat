/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.errors
{

    public class AssertError extends Error
    {
        public function AssertError(message:String)
        {            
			super(message);
        }
    }
}