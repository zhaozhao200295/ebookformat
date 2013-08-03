package com.dtedu.trial.messages
{
	import com.dtedu.trial.navigation.DeepLinkURL;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class ContextChangingEvent extends Event
	{
		public static const NAME:String = "[N]contextChanging";
		
		private var _deepLinkURL:DeepLinkURL;
		
		private var _tokenId:int;
		
		public function ContextChangingEvent(deepLinkURL:DeepLinkURL)
		{			
			super(NAME);
			
			this._deepLinkURL = deepLinkURL;
			this._tokenId = flash.utils.getTimer();
		}
		
		public function get deepLinkURL():DeepLinkURL
		{
			return this._deepLinkURL;
		}
		
		public function get tokenId():int
		{
			return this._tokenId;
		}
	}
}