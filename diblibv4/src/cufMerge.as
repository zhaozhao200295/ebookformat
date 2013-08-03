/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{	
	public function cufMerge(obj1:Object, obj2:Object):Object
	{
		var result:Object = {};
		var key:String;
		
		for (key in obj1)
		{
			result[key] = obj1[key];
		}
		
		for (key in obj2)
		{
			result[key] = obj2[key];
		}
		
		return result;
	}
}