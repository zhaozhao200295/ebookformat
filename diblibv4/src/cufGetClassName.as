/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	import flash.utils.getQualifiedClassName;

	public function cufGetClassName(any:*):String 
	{
		return flash.utils.getQualifiedClassName(any).split("::").pop();
	}	
}