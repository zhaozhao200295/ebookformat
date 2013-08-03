/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.navigation
{
	import mx.utils.URLUtil;		

	public class DeepLinkURL
	{
		public static const CONTEXT_DELIMIER:String = ";";
		
		public static const URL_PARAM_LINK:String = "_l";
		
		public static const LINK_SEPARATOR:String = '/';
		
		public static var defaultURL:String = "";				
		
		public static function fromURL(url:String):DeepLinkURL
		{						
			if (url == "")
			{
				url = defaultURL;
			}
			
			var context:Object = URLUtil.stringToObject(url, CONTEXT_DELIMIER); 
			
			var link:String = context[URL_PARAM_LINK];
			if (link != null)
			{
				delete context[URL_PARAM_LINK];
			}
			else
			{
				link = "";
			}
			
			return new DeepLinkURL(link, context);	
		}			
		
		public static function combineLink(prefix:String, appendix0:String, ... rest):String
		{
			var link:String = prefix + LINK_SEPARATOR + appendix0;
			for each (var appendix:String in rest)
			{
				link += LINK_SEPARATOR + appendix;
			}
			return link;
		}
			
		private var _link:String;				
		
		private var _context:Object;
		
		private var _url:String;
		
		public function DeepLinkURL(link:String, context:Object = null)			
		{
			reset(link, context);
		}	
		
		public function reset(link:String, context:Object = null):void
		{
			this._link = link;
			this._context = context;
			this._url = null;
		}
		
		public function clone():DeepLinkURL
		{
			return new DeepLinkURL(this._link, this._context);
		}
		
		public function get link():String
		{
			return this._link;
		}
		
		public function get context():Object
		{
			return this._context;
		}
		
		public function get url():String
		{
			if (this._url == null) 
			{			
				var box:Object = {};
				box[URL_PARAM_LINK] = this.link;
				
				for (var key:String in this.context)
				{
					var value:* = this.context[key];
					if (value == null || (key == "" && value == "null"))
						continue;
					
					box[key] = value;
				}
				
				this._url = sortURLParams(URLUtil.objectToString(box, CONTEXT_DELIMIER, false));
			}
			
			return this._url;
		}
		
		private static function sortURLParams(urlFragment:String):String
		{
			var parts:Array = urlFragment.split(CONTEXT_DELIMIER);
			parts.sort();
			return parts.join(CONTEXT_DELIMIER);
		}
	}
}