/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.events 
{
	import flash.events.Event;
	
	/**
	 * Event fired by the Localizer class when the language is changed or a new
	 * language is added.
	 */
	public class LocalizerEvent extends Event 
	{
	
		// ---------------------------------------------------------------------- //
		// Constants
		// ---------------------------------------------------------------------- //				
		
		/**
		 * Fired when the current language was changed, i.e. the language property
		 * already contains the new value.
		 * 
		 * @eventType lang_changed
		 */
		public static const LANGUAGE_CHANGING:String = "lang_changing";
	
		/**
		 * Fired when the current language was changed, i.e. the language property
		 * already contains the new value.
		 * 
		 * @eventType lang_changed
		 */
		public static const LANGUAGE_CHANGED:String = "lang_changed";			
		
		// ---------------------------------------------------------------------- //
		// Variables
		// ---------------------------------------------------------------------- //
		
		/**
		 * For language change events, the previous language.
		 */
		private var _oldLanguage:String = null;
		
		/**
		 * The affected language on update and adding events, the language to which
		 * was changed for change events.
		 */
		private var _language:String;
		
		// ---------------------------------------------------------------------- //
		// Constructor
		// ---------------------------------------------------------------------- //
		
		/**
		 * Creates a new localizer event.
		 * 
		 * @param type
		 *				the type of this event, see constants.
		 * @param language
		 *				the language that either caused the adding or updating event, or
		 *				the language to which was switched in case of a change event.
		 * @param oldLanguage
		 *				only used for change events, the language that was used before.
		 * @param bubbles
		 *				determines whether the Event object participates in the bubbling
		 *				stage of the event flow. The default value is false.
		 * @param cancelable
		 *				determines whether the Event object can be canceled. The default
		 *				values is false.
		 */
		public function LocalizerEvent(type:String, language:String,
				oldLanguage:String = null, bubbles:Boolean = false,
				cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
			this._language = language;
			this._oldLanguage = oldLanguage;
		}
		
		// ---------------------------------------------------------------------- //
		// Accessors
		// ---------------------------------------------------------------------- //
		
		/**
		 * The affected language on update and adding events, the language to which
		 * was changed for change events.
		 */
		public function get language():String 
		{
			return _language;
		}
		
		/**
		 * For language change events, the previous language. Otherwise this will
		 * always be <code>null</code>.
		 */
		public function get oldLanguage():String 
		{
			return _oldLanguage;
		}		
	}
}
