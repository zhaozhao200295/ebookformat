/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.navigation
{
	import com.dtedu.trial.miscs.BrowserDefs;
	
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public function openNewWindow(url:String):void
	{							
		var browserName:String = getBrowserName();
		var window:String = BrowserDefs.WINDOW_BLANK; 
		
		if (browserName == BrowserDefs.BROWSER_FIREFOX)
		{
			ExternalInterface.call("window.open", url, window, ""); 
		}
			//If IE, 
		else if (browserName == BrowserDefs.BROWSER_IE)
		{
			ExternalInterface.call("function setWMWindow() {window.open('" + url + "');}");
		}
			//If Safari 
		else if (browserName == BrowserDefs.BROWSER_SAFARI)
		{              
			navigateToURL(new URLRequest(url), window); 
		}
			//If Opera 
		else if (browserName == BrowserDefs.BROWSER_OPERA)
		{    
			navigateToURL(new URLRequest(url), window); 
		}
			//Otherwise, use Flash's native 'navigateToURL()' function to pop-window. 
			//This is necessary because Safari 3 no longer works with the above ExternalInterface work-a-round.
		else
		{
			navigateToURL(new URLRequest(url), window);
		}
	}
}