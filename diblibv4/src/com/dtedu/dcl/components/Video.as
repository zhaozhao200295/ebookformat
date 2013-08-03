package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	
	import flash.display.DisplayObject;
	
	import spark.components.VideoPlayer;
	import spark.components.mediaClasses.DynamicStreamingVideoItem;
	import spark.components.mediaClasses.DynamicStreamingVideoSource;
	
	public class Video extends DCLComponent
	{
		protected var _videoPlayer:VideoPlayer = new VideoPlayer();
		protected var _videoSource:DynamicStreamingVideoSource;
		
		public function Video()
		{
			super(_videoPlayer);
			
		    _properties.register("src",null,cufGetTrimmedString);
			_properties.register("autoPlay", false, cufGetBoolean);
		}
		
		override protected function _setAttribute(name:String, value:*):Boolean
		{
		    if(super._setAttribute(name, value)) return true;
			
			switch(name)
			{
			   case  "src":
				   if (value)
				   {
					   var rtmpIndex:int = value.indexOf("rtmp");
					   if(rtmpIndex != -1)
					   {
						   if(!_videoSource) _videoSource = new DynamicStreamingVideoSource();
						   var sourceItem:DynamicStreamingVideoItem = new DynamicStreamingVideoItem();
						   
						   var suffixIndex:int = value.lastIndexOf(".");
						   var suffix:String = value.substr(suffixIndex + 1);
						   if(suffix == "mp4" || suffix == "f4v")
						   {
							   var index:int = value.lastIndexOf("mp4:");
							   _videoSource.host = value.substring(0, index);
							   sourceItem.streamName = value.substring(index);
							   
							   _videoSource.streamItems = new Vector.<DynamicStreamingVideoItem>();
							   _videoSource.streamItems.push(sourceItem);
							   this._videoPlayer.source = _videoSource;
						   }
						   else if(suffix == "flv")
						   {
							   this._videoPlayer.source = value.replace(".flv", "");
						   }
						   else
						   {
							   this._videoPlayer.source = null;
						   }
					   }
					   else
					   {
						   this._videoPlayer.source = this._factory.resolvePath(value);
					   }
				   }
				   else
				   {
					   this._videoPlayer.source = null;
				   }
                   return true;
				   
			   case  "autoPlay":
				   this._videoPlayer.autoDisplayFirstFrame = value;
				   this._videoPlayer.autoPlay = value;
				   return true;
				   
			   default:
				   return false;
			}
		}
	}
}