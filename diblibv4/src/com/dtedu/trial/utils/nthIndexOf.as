/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{

/**
 * Finds the index of the nth occurrence of a given substring in a string,
 * optionally starting at a given position.
 */
public function nthIndexOf(string:String, substring:String, n:uint,
		start:int = 0):int
{
	var index:int = start - 1;
	while (n-- > 0) 
	{
		index = string.indexOf(substring, index + 1);
		if (index < 0) 
		{
			return index;
		}
	}
	return index;
}

}