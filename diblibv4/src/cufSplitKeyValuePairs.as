/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{	
	public function cufSplitKeyValuePairs(kvs:String, separator:String, kvDelimiter:String = "=", decode:Boolean = true):Object
	{
		var result:Object = {};
		var a:Array = kvs.split(separator);
		for each (var s:String in a)
		{
			if (s == "") continue;
			
			var kv:Array = s.split(kvDelimiter, 2);
			decode && (kv[0] = decodeURIComponent(kv[0])); 
			result[kv[0]] = kv.length > 1 ? (decode ? decodeURIComponent(kv[1]) : kv[1]) : null;
		}
		return result;
	}
}