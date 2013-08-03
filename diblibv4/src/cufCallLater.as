/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	import com.dtedu.trial.helpers.Timeout;

	public function cufCallLater(delay:Number, closure:Function, thisArg:* = null, ... args):void 
	{
		new Timeout(delay, closure, thisArg, args);
	}	
}

