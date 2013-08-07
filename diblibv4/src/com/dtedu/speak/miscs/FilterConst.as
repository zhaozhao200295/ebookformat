package com.dtedu.speak.miscs
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	public class FilterConst
	{
		public static const glowFilter:GlowFilter = new GlowFilter(0x000000,0.3,6,6,2);
		public static const textFilter:GlowFilter = new GlowFilter(0x000000,0.3,2,2,2);
		public static const windowShadowFilter:DropShadowFilter = new DropShadowFilter(8,90,0,0.8,20,20,1,2);
		public function FilterConst(){}
		
		public static const colorFilter:ColorMatrixFilter = new ColorMatrixFilter([ //黑白滤镜
			1,0,0,0,0,   
			1,0,0,0,0,   
			1,0,0,0,0,   
			0,0,0,1,0  
		]);  
		
		public static const colorFilter2:ColorMatrixFilter = new ColorMatrixFilter([ //灰色滤镜
			0.5086,0.2094,0.082,0,0,
			0.5086,0.2094,0.082,0,0,
			0.5086,0.2094,0.082,0,0,
			0,0,0,1,0
		]);
		
		public static const colorFilterRed:ColorMatrixFilter = new ColorMatrixFilter([//红色滤镜
			0.5,0.5,1,0,0,   
			0.2,0.2,0.2,0,0,   
			0.2,0.2,0.2,0,0,   
			0,0,0,1,0  
		]);
		/**
		 * 描边 
		 * @param color
		 * @return 
		 * 
		 */
		public static function textStrokeFilter(color:uint=0x000000):GlowFilter
		{
			return new GlowFilter(color,1,2,2,50,1,false,false);
		}
	}
}