package com.dtedu.dcl.components
{
	import com.dtedu.dcl.DCLComponent;
	import com.dtedu.dcl.interfaces.IDCLFactory;
	
	import flash.display.DisplayObject;
	
	import spark.components.VideoPlayer;
	import spark.components.mediaClasses.DynamicStreamingVideoItem;
	import spark.components.mediaClasses.DynamicStreamingVideoSource;
	
	public class Audio extends DCLComponent
	{
		private var _audioPlayer:VideoPlayer = new VideoPlayer();
		protected var _audioSource:DynamicStreamingVideoSource;
		
		public function Audio()
		{
			super(_audioPlayer);
			
			_properties.register("src",null,cufGetTrimmedString);
			_properties.register("autoPlay", true, cufGetBoolean);
			
			_audioPlayer.styleName = "audioPlayer";
		}
		
		override protected function _setAttribute(name:String, value:*):Boolean
		{
		    if(super._setAttribute(name, value)) return true;
			
			switch(name)
			{
			   case "src":
				   if (value)
				   {	   
					   var rtmpIndex:int = value.indexOf("rtmp");
					   if(rtmpIndex != -1)
					   {
						   if(!_audioSource) _audioSource = new DynamicStreamingVideoSource();
						   var sourceItem:DynamicStreamingVideoItem = new DynamicStreamingVideoItem();
						  
						   var index:int = value.lastIndexOf("mp3:");
						   _audioSource.host = value.substring(0, index);
						   sourceItem.streamName = value.substring(index);
						   
						   _audioSource.streamItems = new Vector.<DynamicStreamingVideoItem>();
						   _audioSource.streamItems.push(sourceItem);
						   this._audioPlayer.source = _audioSource;
					   }
					   else
					   {
						   this._audioPlayer.source = this._factory.resolvePath(value);
					   }
				   }
				   else
				   {
					   this._audioPlayer.source = null;
				   }
				   return true;
				   
			   case "autoPlay":
				   this._audioPlayer.autoDisplayFirstFrame = value;
				   this._audioPlayer.autoPlay = value;
				   return true;
				   
			   default:
				   return false;
			}
		}
		
		override public function set height(value:Number):void
		{
			setDynamicProperty("height", 25);
		}
	}
}