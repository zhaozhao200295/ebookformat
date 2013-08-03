/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{
import flash.system.Capabilities;

/**
 * Determines if the current player hosting this application is browser
 * based or standalone.
 * 
 * @return <code>true</code> if the player runs in a browser, else
 *				<code>false</code>.
 */
public function playerIsInBrowser():Boolean {
	switch (Capabilities.playerType.toLowerCase()) {
		case "plugin":
		case "activex":
			return true;
	}
	return false;
}

}