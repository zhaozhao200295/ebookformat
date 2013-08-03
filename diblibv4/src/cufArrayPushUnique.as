/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	public function cufArrayPushUnique(array:Array, value:*):int 
	{
		if (array.indexOf(value) != -1)
		{
			return -1;
		}
		
		return array.push(value);
	}
	
}