/**
 * Common Utility Functions
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package 
{		
	import com.dtedu.trial.utils.SerializationUtil;

	public function cufDeepCopy(o:Object):Object
	{
		return SerializationUtil.deserialize(SerializationUtil.serialize(o));		
	}	
}