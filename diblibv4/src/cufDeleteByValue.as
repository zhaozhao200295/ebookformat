/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	public function cufDeleteByValue(object:*, value:*):void 
	{
		for (var key:* in object)
		{
			if (value === object[key])
			{
				delete object[key];
			}
		}
		
		return;
	}
	
}