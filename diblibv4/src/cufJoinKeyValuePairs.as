/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{
	public function cufJoinKeyValuePairs(object:Object, separator:String, kvDelimiter:String = "=", encode:Boolean = true, sorted:Boolean = true):String
	{
		var result:Array = [];
		for (var k:String in object)
		{
			var v:String = object[k].toString();
			result.push((encode ? encodeURIComponent(k) : k) + kvDelimiter + (encode ? encodeURIComponent(v) : v));				
		}
		result.sort();
		return result.join(separator);
	}
}