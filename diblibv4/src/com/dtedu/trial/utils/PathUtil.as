/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{    
	import com.dtedu.trial.miscs.Common;
	
	import flash.display.Sprite;

    public class PathUtil
    {							
        public static function getFileNameParts(path:String):Array
        {            
			var pos:int = path.lastIndexOf(".");
			if (pos != Common.NON_EXIST) 
			{																		
				return [ path.substr(0, pos), path.substr(pos+1) ];
			}		
			
            return [ path, "" ];
        }

        public static function getBaseName(path:String):String
        {
            return PathUtil.getFileNameParts(path)[0];
        }

        public static function getExtName(path:String):String
        {
            return PathUtil.getFileNameParts(path)[1];
        }    								
    }
}