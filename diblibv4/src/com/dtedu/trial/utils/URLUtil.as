package com.dtedu.trial.utils
{
	import com.dtedu.trial.miscs.Common;
	
	public class URLUtil
	{					
		public static const URL_PASS_SEPARATOR:String = ":";
		public static const URL_HOST_SEPARATOR:String = "@";
		public static const URL_PORT_SEPARATOR:String = ":";
		public static const URL_PATH_SEPARATOR:String = "/";
		public static const URL_QUERY_SEPARATOR:String = "?";
		public static const URL_PARAM_SEPARATOR:String = "&";
		public static const URL_FRAGMENT_SEPARATOR:String = "#";		
		
		/**
		 * file:// for windows local filesystem url.
		 * app:/ for ios filesystem url.
		 */ 
		public static const URL_PROTOCALS:Array = ["http://", "https://", "ftp://", "file:///", "app:/", "mailto:", "/", "rtmp://", "rtmpe://"];
		
		public static const URL_SCHEME:String = 'scheme';
		public static const URL_USER:String = 'user';
		public static const URL_PASS:String = 'pass';
		public static const URL_HOST:String = 'host';
		public static const URL_PORT:String = 'port';
		public static const URL_PATH:String = 'path';
		public static const URL_QUERY:String = 'query';
		public static const URL_FRAGMENT:String = 'fragment';
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function parseUrl(url:String, component:String = null):Object
		{
			url = translatePath(url);
			
			var result:Object = {}							
			
			if (!component || component == URL_FRAGMENT || component == URL_QUERY || component == URL_PATH)	
			{				
				var pos:int = url.lastIndexOf(URL_FRAGMENT_SEPARATOR);
				if (pos != Common.NON_EXIST)
				{								
					result[URL_FRAGMENT] = url.substr(pos+1);									
					url = url.substr(0, pos);
				}
				
				if (component == URL_FRAGMENT) return result[URL_FRAGMENT];			
							
				pos = url.lastIndexOf(URL_QUERY_SEPARATOR);
				if (pos != Common.NON_EXIST)
				{
					result[URL_QUERY] = url.substr(pos+1);								
					url = url.substr(0, pos);				
				}
				
				if (component == URL_QUERY) return result[URL_QUERY];
			}
			
			for each (var prot:String in URL_PROTOCALS) 
			{
				if (StringUtil.beginsWith(url, prot)) 
				{
					result[URL_SCHEME] = prot;										
					url = url.substr(prot.length);
					break;
				}
			}	
			
			if (component == URL_SCHEME) return result[URL_SCHEME];
			
			pos = url.indexOf(URL_PATH_SEPARATOR);
			if (pos != Common.NON_EXIST)
			{
				if (url.charAt(pos-1) == ":") // file:///C:/
				{
					pos = url.indexOf(URL_PATH_SEPARATOR, pos+1);	
				}
				
				result[URL_PATH] = url.substr(pos);								
				url = url.substr(0, pos);				
			}						
			
			if (component == URL_PATH) return result[URL_PATH];
			
			var hostAndPort:String = url;			
			
			pos = url.indexOf(URL_HOST_SEPARATOR);									
			if (pos != Common.NON_EXIST)
			{
				var userAndPass:String = url.substr(0, pos);
				url = url.substr(pos+1);	
							
				pos = userAndPass.indexOf(URL_PASS_SEPARATOR);
				if (pos != Common.NON_EXIST)
				{
					result[URL_USER] = userAndPass.substr(0, pos);										
					result[URL_PASS] = userAndPass.substr(pos+1);
				}
				else
				{
					result[URL_USER] = userAndPass;
				}														
			}
			
			if (component == URL_USER) return result[URL_USER];
			if (component == URL_PASS) return result[URL_PASS];
			
			pos = url.indexOf(URL_PORT_SEPARATOR);
			if (pos != Common.NON_EXIST)
			{
				result[URL_HOST] = url.substr(0, pos);
				result[URL_PORT] = url.substr(pos+1);
			}
			else
			{
				result[URL_HOST] = url;
			}
			
			if (component == URL_HOST) return result[URL_HOST];
			if (component == URL_PORT) return result[URL_PORT];
			
			return result;
		}	
		
		public static function buildUrl(url:String, queryParams:* = null, fragmentParams:* = null):String
		{
			if (!queryParams && !fragmentParams) return url;
			
			var parsedUrl:Object = parseUrl(url);
			
			// Add our params to the parsed uri
			if (queryParams)
			{
				if (!parsedUrl[URL_QUERY])
				{
					parsedUrl[URL_QUERY] = queryParams is String 
						? trimChars(queryParams, [0, URL_QUERY_SEPARATOR], true, false) 
						: cufJoinKeyValuePairs(queryParams, URL_PARAM_SEPARATOR);
				}
				else
				{
					var q1:Object = cufSplitKeyValuePairs(parsedUrl[URL_QUERY], URL_PARAM_SEPARATOR);										
					var q2:Object = queryParams is String ? cufSplitKeyValuePairs(queryParams, URL_PARAM_SEPARATOR) : queryParams;					
					parsedUrl[URL_QUERY] = cufJoinKeyValuePairs(cufMerge(q1, q2), URL_PARAM_SEPARATOR);
				}
			}
			
			if (fragmentParams)
			{
				if (!parsedUrl[URL_FRAGMENT])
				{
					parsedUrl[URL_FRAGMENT] = fragmentParams is String 
						? trimChars(fragmentParams, [0, URL_FRAGMENT_SEPARATOR], true, false) 
						: cufJoinKeyValuePairs(fragmentParams, URL_PARAM_SEPARATOR);
				}
				else
				{
					q1 = cufSplitKeyValuePairs(parsedUrl[URL_FRAGMENT], URL_PARAM_SEPARATOR);										
					q2 = fragmentParams is String ? cufSplitKeyValuePairs(fragmentParams, URL_PARAM_SEPARATOR) : fragmentParams;					
					parsedUrl[URL_FRAGMENT] = cufJoinKeyValuePairs(cufMerge(q1, q2), URL_PARAM_SEPARATOR);
				}
			}
			
			// Put humpty dumpty back together
			return ((parsedUrl[URL_SCHEME]) ? parsedUrl[URL_SCHEME] : "")
				+ ((parsedUrl[URL_USER]) ? parsedUrl[URL_USER] + (parsedUrl[URL_PASS] ? URL_PASS_SEPARATOR + parsedUrl[URL_PASS] : "") + URL_HOST_SEPARATOR : "")
				+ ((parsedUrl[URL_HOST]) ? parsedUrl[URL_HOST] : "")
				+ ((parsedUrl[URL_PORT]) ? URL_PORT_SEPARATOR + parsedUrl[URL_PORT] : "")
				+ ((parsedUrl[URL_PATH]) ? parsedUrl[URL_PATH] : "")
				+ ((parsedUrl[URL_QUERY]) ? URL_QUERY_SEPARATOR + parsedUrl[URL_QUERY] : "")
				+ ((parsedUrl[URL_FRAGMENT]) ? URL_FRAGMENT_SEPARATOR + parsedUrl[URL_FRAGMENT] : "");					
		}
		
		public static function translatePath(path:String):String
		{
			return path.replace("\\", URL_PATH_SEPARATOR);
		}
		
		public static function combine(url1:String, url2:String):String
		{                						
			url1 = trimChars(translatePath(url1), [0, URL_PATH_SEPARATOR], false);
			url2 = trimChars(translatePath(url2), [0, URL_PATH_SEPARATOR], true, false);			
			
			return url1 + URL_PATH_SEPARATOR + url2;
		}
		
		public static function isAbsURL(url:String):Boolean
		{
			for each (var prot:String in URL_PROTOCALS)   
			{
				if (StringUtil.beginsWith(url, prot)) 
				{					
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Get the base URI (i.e., the full URL without query and fragement)
		 * 
		 * <p>e.g.<br/>
		 * http://host:2289/l1/l2/l3.html?k1=v1&k2=v2#body <br/>
		 * Return: http://host:2289/l1/l2/l3.html		
		 * </p>
		 */ 
		public static function getBaseUri(url:String):String
		{			
			url = translatePath(url);
			
			var pos:int = url.lastIndexOf(URL_FRAGMENT_SEPARATOR);
			if (pos != Common.NON_EXIST)
			{																		
				url = url.substr(0, pos);
			}									
			
			pos = url.lastIndexOf(URL_QUERY_SEPARATOR);
			if (pos != Common.NON_EXIST)
			{											
				url = url.substr(0, pos);				
			}
			
			return url;
		}			
		
		/**
		 * Get the base path 
		 * 
		 * <p>e.g.<br/>
		 * http://host:2289/l1/l2/l3.html?k1=v1&k2=v2#body <br/>
		 * Return: http://host:2289/l1/l2		
		 * </p>
		 */ 
		public static function getBasePath(url:String):String
		{			
			url = getBaseUri(url);
			
			var pos:int = url.lastIndexOf(URL_PATH_SEPARATOR);
			if (pos != Common.NON_EXIST && url.lastIndexOf(".") > pos)
			{											
				url = url.substr(0, pos);					
			}
			
			return url;
		}		
		
		/**
		 * 
		 */ 
		public static function getRoot(url:String):String
		{			
			var parts:Object = parseUrl(url);
			var root:String = parts[URL_HOST];
			
			root += parts[URL_PORT] ? URL_PORT_SEPARATOR + parts[URL_PORT] : "";
			root = parts[URL_USER] ? 
				parts[URL_USER] + (parts[URL_PASS] ? URL_PASS_SEPARATOR + parts[URL_PASS] : "") + URL_HOST_SEPARATOR + root :
				root;
			
			return parts[URL_SCHEME] + root;
		}
	}
}