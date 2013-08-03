/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.navigation
{
    import com.dtedu.trial.miscs.BrowserDefs;
    
    import flash.external.ExternalInterface;

    public function getBrowserName():String
    {
        //Uses external interface to reach out to browser and grab browser useragent info.
        var browserAgent:String = ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");

        //Determines brand of browser using a find index. If not found indexOf returns (-1).
        if (browserAgent != null && browserAgent.indexOf("Firefox") >= 0)
        {
            return BrowserDefs.BROWSER_FIREFOX; 
        }
        else if (browserAgent != null && browserAgent.indexOf("Safari") >= 0)
        {
            return BrowserDefs.BROWSER_SAFARI;
        }
        else if (browserAgent != null && browserAgent.indexOf("MSIE") >= 0)
        {
            return BrowserDefs.BROWSER_IE;
        }
        else if (browserAgent != null && browserAgent.indexOf("Opera") >= 0)
        {
            return BrowserDefs.BROWSER_OPERA;
        }

        return BrowserDefs.BROWSER_UNDEFINED;
    }
}