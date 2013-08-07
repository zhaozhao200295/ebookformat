package com.dtedu.speak.miscs
{
	import com.dtedu.bytearray.display.ScaleBitmap;
	import com.dtedu.speak.core.ClassFactory;
	
	import flash.geom.Rectangle;

	/**
	 * 静态资源 
	 * @author Jeff
	 * 
	 */	
	public class ResouceConst
	{
		
		public static var _scaleMap:Object = {
			board_bg:new Rectangle(20,20,810,273),
			panelToolbar_bg:new Rectangle(10,3,70,17),
			window_bg:new Rectangle(20,20,164,98),
			annotation_bubble_bg:new Rectangle(133,72,3,3),
			secondary_bg:new Rectangle(15,15,89,36),
			button_downSkin:new Rectangle(10,10,39,17),
			button_upSkin:new Rectangle(10,10,39,17),
			button_overSkin:new Rectangle(10,10,39,17)
		};
		
		public function ResouceConst()
		{
			
		}
		
		public static function getScaleBitmap( cls:Class,scale9Grid:Rectangle = null ):ScaleBitmap
		{
			if(scale9Grid)
			{
				return ClassFactory.getScaleBitmap(cls,scale9Grid);
			}
			else
			{
				return ClassFactory.getScaleBitmap(cls,getRectangle(cls));
			}
		}
		
		private static function getRectangle(cls:Class):Rectangle
		{
			return _scaleMap[cufGetClassName(cls)] as Rectangle;
		}
	}
}