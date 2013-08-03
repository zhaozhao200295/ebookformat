package com.dtedu.trial.interfaces
{
	import flash.events.IEventDispatcher;
	
	/**
	 * Interface for the <code>Localizer</code> class.	 
	 */
	public interface ILocalizer extends IEventDispatcher, IDisposable 
	{		
		/**
		 * The default language.
		 */
		function get defaultLanguage():String;
		
		/**
		 * @private
		 */
		function set defaultLanguage(defaultLang:String):void;				
		
		/**
		 * The currently used language. If set updates all registered objects to the
		 * given language.
		 */
		function get language():String;
		
		/**
		 * @private
		 */
		function set language(lang:String):void;
		
		/**
		 * Returns an array with ids of the available languages, e.g. ["en", "de"].
		 * 
		 * @return an array with known languages.
		 */
		function get availableLanguages():Array;				
		
		/**
		 * Get one specific string from a language.
		 * 
		 * @param lang
		 *				the language from which to get the string.
		 * @param id
		 *				the id of the string.
		 * @return the content of the string with the given id in the given
		 *				language.
		 */
		function getText(keyText:String, params:Object = null):String;							
	}
}