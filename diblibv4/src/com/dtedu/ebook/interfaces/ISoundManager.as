package com.dtedu.ebook.interfaces
{
	public interface ISoundManager extends IManager
	{
		/**
		 * 设置电子课本路径
		 * 
		 * value - 电子课本路径
		 */
		function set bookPath(value:String):void;
		
		
		/**
		 * 播放音频
		 * 
		 * info - 可以是音频路径，也可以是SoundInfo
		 */
		function play(info:Object):void;
		
		/**
		 * 停止播放音频
		 * 
		 * channel - 停止播放某一频道的音频，为空则停止所有音频
		 */
		function stop(channel:Object = null):void;
	}
}