/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.navigation
{    
    import com.swfaddress.SWFAddress;
    import com.swfaddress.SWFAddressEvent;
    import com.dtedu.trial.core.Kernel;
    import com.dtedu.trial.interfaces.IBrowserNavigator;
    import com.dtedu.trial.interfaces.IController;
    import com.dtedu.trial.interfaces.IKernel;
    import com.dtedu.trial.miscs.BrowserDefs;
    import com.dtedu.trial.utils.Debug;
    import com.dtedu.trial.utils.PathUtil;
    import com.dtedu.trial.utils.URLUtil;
    
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
	
    public class BrowserNavigator implements IBrowserNavigator 
    {            						
		public static function set browserTitle(title:String):void
		{
			SWFAddress.setTitle(title);
		}             				
		
		private var _kernel:IKernel;
		private var _useSWFAddress:Boolean;
		private var _fullURL:String;
		
        private var _previousURL:String;
		private var _currentURL:String;
		private var _redirectURL:String;
		
		private var _targetDL:DeepLinkURL;			
		private var _queryParameters:Object;      												
		
        public function BrowserNavigator(kernel:IKernel)
        {           
			_kernel = kernel;
			
			if (_kernel.configuration && _kernel.configuration.hasOwnProperty("navigation"))
			{
				_useSWFAddress = _kernel.configuration.navigation.@useSWFAddress == "true";
			}
			else
			{
				_useSWFAddress = false;
			}
			
			if (_useSWFAddress)
			{
	            SWFAddress.setStrict(false);
	            SWFAddress.init();
				
				_fullURL = SWFAddress.getBaseURL() + "#" + SWFAddress.getValue();
				_queryParameters = SWFAddress.getParameters();
				if (!this._queryParameters) this._queryParameters = {};		
			}
			else
			{			
				_fullURL = _kernel.swfRoot.loaderInfo.url;
				_queryParameters = cufSplitKeyValuePairs(String(URLUtil.parseUrl(_fullURL, URLUtil.URL_QUERY)), URLUtil.URL_PARAM_SEPARATOR);
			}		 			
			
			/*
			var debuggingCfg:XML = Kernel.getInstance().configuration.debugging[0];
			var changed:Boolean = false;
								
			if ('debug' in this._queryParameters && debuggingCfg.@enabled != "true")
			{
				debuggingCfg.@enabled = "true";	
				changed = true;
			}
			
			if ('logger' in this._queryParameters && debuggingCfg.@remoteLogger != "true")
			{
				debuggingCfg.@remoteLogger = true;	
				changed = true;
			}
			
			if ('debugger' in this._queryParameters && debuggingCfg.@debugger != "true")
			{
				debuggingCfg.@debugger = true;	
				changed = true;
			}
			
			if (changed)
			{
				Debug.reset(Kernel.getInstance(), debuggingCfg);									
			}						
			
			parseURL();
			
			SWFAddress.addEventListener(SWFAddressEvent.EXTERNAL_CHANGE, parseURL);	
			*/
        }              
		
		/**		  
		 * Gets the URL except of the anchor part. 
		 * 
		 * fullURL: http://domain.com/folder/page.html?query#anchor
		 * baseURL: http://domain.com/folder/page.html?query
		 * webRoot: http://domain.com/
		 * appRoot: http://domain.com/folder
		 */ 
		public function get fullURL():String
		{
			return _fullURL;
		}
		
		/**		  
		 * Gets the domain root. 
		 * 
		 * fullURL: http://domain.com/folder/page.html?query#anchor
		 * baseURL: http://domain.com/folder/page.html?query
		 * domainRoot: http://domain.com/
		 * appRoot: http://domain.com/folder
		 */ 
		public function get domainRoot():String
		{
			return URLUtil.getRoot(_fullURL); 
		}			
		
		public function get queryParams():Object
		{
			return this._queryParameters;
		}
		
		/**
		 * 改变系统的状态。
		 */ 
		public function goto(link:String, context:Object = null, redirect:Boolean = false):void
		{									
			if (redirect)
			{
				if (this._redirectURL == null)
				{
					this._redirectURL = this._targetDL.url;
				}
				//Debug.traceVerbose("Redirect to link: \"" + link + "\"");
			}
			else
			{
				this._redirectURL = null;
				//Debug.traceVerbose("Goto link: \"" + link + "\"");
			}
			
			this._previousURL = this._currentURL;
			this._targetDL = new DeepLinkURL(link, context);																									  			
			
//			Kernel.getInstance().rootController.dispatchEvent( 
//				new Message(Message.CONTEXT_CHANGING, this._targetDL)
//			);
		}
		
		public function href(url:String, useSWFAddress:Boolean = true, targetWindow:String = null):void
		{
			if (targetWindow == null) targetWindow = BrowserDefs.WINDOW_SELF;
			
			if (useSWFAddress)
			{
				SWFAddress.href(url, targetWindow);
			}
			else
			{
				flash.net.navigateToURL(new URLRequest(url), targetWindow);
			}
		} 					
        
        public function fallback(useSWFAddress:Boolean = true):void
        {
        	if (useSWFAddress)
        	{
        		SWFAddress.back();
        	}
        	else
        	{        			        	
        		flash.net.navigateToURL(new URLRequest("#" + this._previousURL), BrowserDefs.WINDOW_SELF);
        	}
        }	
		
		public function dispose():void
		{
			this._kernel = null;
		}

        private function parseURL(event:SWFAddressEvent = null):void
        {
            var url:String = event ? event.value : SWFAddress.getValue();			
            //Debug.traceCritical("URL loaded: " + url);				
			
			var dl:DeepLinkURL = DeepLinkURL.fromURL(url);					                                 
            goto(dl.link, dl.context);
        }         				
    }
}