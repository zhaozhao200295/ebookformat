/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{

/**
 * If the application runs in a browser, this function can be used to add a
 * random part to the url (to the query string).
 * 
 * <p>
 * The function will properly attach the random value if the url already
 * has a query part (e.g. url?a=b).
 * </p>
 * 
 * <p>
 * The variable added will be of the format <code>r\d{1-10}=\d{1-10}</code>.
 * </p>
 * 
 * @param url
 *				the url to modify to work around caching.
 * @return the adjusted url.
 */
public function antiCache(url:String):String {
	// Browser based? If yes, avoid cache.
	if (playerIsInBrowser()) {
		url += (url.indexOf("?") >= 0 ? "&" : "?")
				+ "r" + Math.round(Math.random() * 99999999)
				+ "="
				+ Math.round(Math.random() * 99999999);
	}
	return url;
}

}