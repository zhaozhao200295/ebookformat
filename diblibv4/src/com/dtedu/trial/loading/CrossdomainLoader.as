/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.loading
{    
    import com.dtedu.trial.utils.StringUtil;
    import com.dtedu.trial.utils.nthIndexOf;
    
    import flash.system.Security;
    import flash.utils.Dictionary;

    /**
     * Utility class for loading a crossdomain.xml policy file from the server with
     * a given URL.   
     */
    public class CrossdomainLoader
    {

        /**
         * List of already checked domains (to avoid checking the more than once).
         */
        private static var checkedDomains:Dictionary = new Dictionary();

        /**
         * Tries to load a crossdomain.xml policy file from the server at the given
         * URL. This can be a full URL to a subpage - everything except the domain
         * name will be stripped.
         *
         * <p>
         * E.g., when given http://www.example.com/subpage/index.php?variable=value,
         * this will try to load http://www.example.com/crossdomain.xml.
         * </p>
         *
         * @param url
         *				the URL for which to try and check the crossdomain.xml file.
         */
        public static function loadPolicyFile(url:String):void
        {
            // Make sure the URL is prefixed with http:// or https://
            if (!StringUtil.beginsWith(url, "http://") && StringUtil.beginsWith(url, "https://"))
            {
                url = "http://" + url;
            }
            // Make sure the URL has at least 3 slashes (i.e. if it's the URL itself
            // without any subdirectories / file names, make sure it ends with a
            // slash.
            if (nthIndexOf(url, "/", 3) < 0) 
            {
                url += "/";
            }
            url = url.substring(0, nthIndexOf(url, "/", 3) + 1);

            // Check if the URL was checked before.
            if (!checkedDomains[url])
            {
                // No, mark it.
                checkedDomains[url] = true;

                // Now, load the policy file.
                Security.allowDomain(url);
                Security.loadPolicyFile(url + "crossdomain.xml");
            }
        }

    }
}
