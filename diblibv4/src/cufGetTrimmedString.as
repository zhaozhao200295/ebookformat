/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	import com.dtedu.trial.utils.StringUtil;

	public function cufGetTrimmedString(raw:*, def:String = null):String
	{
		if (raw == null)
		{
			return def;
		}
		
		return StringUtil.trim(String(raw)); 
	}
	
}