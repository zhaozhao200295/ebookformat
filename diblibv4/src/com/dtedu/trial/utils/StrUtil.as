package com.dtedu.trial.utils
{

	
	/**
	 * @date 2013-1-30 下午3:27:47
	 * @author Jeff
	 *
	 */
	
	public class StrUtil
	{
		public function StrUtil()
		{
		}
		
		public static function isContainStr(value:String,...args):Boolean
		{
			var i:int;
			for(i=0; i<args.length; i++)
			{
				if(value.indexOf(args[i])>-1)
				{
					return true;
				}
			}
			return false;
		}
	}
}