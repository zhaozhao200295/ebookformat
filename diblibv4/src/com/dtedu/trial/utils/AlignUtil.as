package com.dtedu.trial.utils
{
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    
    public class AlignUtil
    {        
		public static function alignLeft(current:Object, left:Number, snapToPixel:Boolean = true):void
		{            
			current.x = snapToPixel ? Math.round(left) : left;
		}
		
		public static function alignRight(current:Object, targetWidth:Number, right:Number, snapToPixel:Boolean = true):void
		{
			if (targetWidth == 0) return;
			var x:Number = right - targetWidth;
			current.x = snapToPixel ? Math.round(x) : x;
		}
		
		public static function alignTop(current:Object, top:Number, snapToPixel:Boolean = true):void
		{            
			current.y = snapToPixel ? Math.round(top) : top;
		}
		
		public static function alignBottom(current:Object, targetHeight:Number, bottom:Number, snapToPixel:Boolean = true):void
		{
			if (targetHeight == 0) return;
			var y:Number = bottom - targetHeight;
			current.y = snapToPixel ? Math.round(y) : y;
		}
		
        public static function alignHCenter(current:Object, left:Number, width:Number, snapToPixel:Boolean = true):void
        {			
            var centerX:Number = width * 0.5 - current.width * 0.5 + left;
			current.x = snapToPixel ? Math.round(centerX) : centerX;
        }
        
        public static function alignVCenter(current:Object, top:Number, height:Number, snapToPixel:Boolean = true):void
        {			
            var centerY:Number = height * 0.5 - current.height * 0.5 + top;
			current.y = snapToPixel ? Math.round(centerY) : centerY;
        }        
		
		public static function alignCenter(current:Object, bound:Rectangle, snapToPixel:Boolean = true):void
		{
			alignHCenter(current, bound.left, bound.width, snapToPixel);
			alignVCenter(current, bound.top, bound.height, snapToPixel);
		}
    }
}