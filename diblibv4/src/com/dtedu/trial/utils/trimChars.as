/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{		
	import com.dtedu.trial.miscs.Common;
	
	public function trimChars(str:String, chars:Array = null, left:Boolean = true, right:Boolean = true):String 
	{
		if (!str) return "";
		
		if (!left && !right) return str;				
		
		chars || (chars = [0]);
		
		var trimWS:Boolean = (chars.indexOf(0) != Common.NON_EXIST);
				
		var startIndex:int = 0;
		if (left)
		{			
			while (chars.indexOf(str.charAt(startIndex)) != Common.NON_EXIST || (trimWS && str.charCodeAt(startIndex) <= 32)) ++startIndex;
		}
		
		var endIndex:int = str.length - 1;
		if (right)
		{
			while (chars.indexOf(str.charAt(endIndex)) != Common.NON_EXIST || (trimWS && str.charCodeAt(endIndex) <= 32)) --endIndex;
		}
		
		if (endIndex >= startIndex)
			return str.slice(startIndex, endIndex + 1);
		else
			return "";
	}
	
}