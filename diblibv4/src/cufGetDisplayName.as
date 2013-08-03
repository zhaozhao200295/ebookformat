/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	import com.dtedu.trial.utils.SerializationUtil;
	
	public function cufGetDisplayName(o:Object):String
	{
		var objName:String = String(o);			
		
		var pos:int = objName.lastIndexOf(".");
		var n:int = 0;
		
		while (pos > 0 && n < 4)
		{
			pos = objName.lastIndexOf(".", pos - 1);
			n++;
		}
		
		if (pos != -1)
		{
			objName = objName.substr(pos+1);
		}
		
		return objName;		
	}	
}