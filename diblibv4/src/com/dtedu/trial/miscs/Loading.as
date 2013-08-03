package com.dtedu.trial.miscs
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;

	public class Loading
	{
		[Embed(source = "assets/swfs/loading.swf")]
		private static var __loading:Class;
		
		public static function get loadingAnimation():DisplayObject
		{
			return new __loading();
		}
	}
}