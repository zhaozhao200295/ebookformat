/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.i18n 
{	
	import com.dtedu.trial.utils.DictionaryUtil;
	import com.dtedu.trial.utils.StringUtil;
	import com.dtedu.trial.core.Kernel;
	import com.dtedu.trial.events.LocalizerEvent;
	import com.dtedu.trial.events.ResourceErrorEvent;
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.ILocalizer;
	import com.dtedu.trial.interfaces.IResourceLoader;
	import com.dtedu.trial.loading.ResourceProvider;
	import com.dtedu.trial.loading.ResourceType;
	import com.dtedu.trial.miscs.Common;
	import com.dtedu.trial.utils.Debug;
	import com.dtedu.trial.utils.URLUtil;
	import com.dtedu.trial.utils.trimChars;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * Used for localization purposes.
	 * 
	 * <p>
	 * Used to register elements (or rather: an elements property) for a given
	 * language string using some id. For a language string of any id it is possible
	 * to define any number of languages by a language shortcut (e.g. en). When
	 * switching between languages this class then updates all registered element
	 * properties accordingly.
	 * </p>
	 * 
	 * <p>
	 * A default language can be set, so if a string is registered for any other
	 * language and no string with that id exists in the default one it is copied to
	 * the default dictionary as well.
	 * </p>	
	 */
	public class Localizer extends EventDispatcher implements ILocalizer
	{		
		public static const DEFAULT_LANG_ID:String = "zh_CN";
		
		private static const LANG_FILE_EXT:String = '.xml';
		
		// ---------------------------------------------------------------------- //
		// Variables
		// ---------------------------------------------------------------------- //
		
		/**
		 * The current language.
		 */
		private var _currentLang:String;
		
		/**
		 * The target language.
		 */ 
		private var _targetLang:String;
		
		/**
		 * The default language.
		 */
		private var _defaultLang:String;
		
		private var _langFileBasePath:String;
		
		/**
		 * A dictionary containing dictionaries for all known languages, mapping
		 * domain ids to a key-value dictionary.	
		 */
		private var _languages:Dictionary;								
		
		// ---------------------------------------------------------------------- //
		// Constructor
		// ---------------------------------------------------------------------- //
		
		/**
		 * Creates a new, empty localizer.
		 * 
		 * @param def
		 *				the default language.		 
		 */
		public function Localizer(langFileBasePath:String, def:String = null)
		{						
			this._langFileBasePath = langFileBasePath;			
			
			this._currentLang = this._defaultLang = def;			
			_languages = new Dictionary();			
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void 
		{				
			_languages = null;			
		}
		
		// ---------------------------------------------------------------------- //
		// Accessors
		// ---------------------------------------------------------------------- //
		
		/**
		 * @inheritDoc
		 */
		public function get defaultLanguage():String 
		{
			return _defaultLang;
		}
		
		/**
		 * @private
		 */
		public function set defaultLanguage(defaultLang:String):void 
		{
			if (defaultLang) 
			{
				this._defaultLang = defaultLang;
			}
		}
	
		/**
		 * @inheritDoc
		 */
		public function get language():String 
		{
			return _currentLang;
		}
		
		/**
		 * @private
		 */
		public function set language(lang:String):void 
		{
			if (!lang || lang == _currentLang) 
			{
				return;
			}
			
			var prevLang:String = _currentLang;
			this._targetLang = lang;
			
			if (hasEventListener(LocalizerEvent.LANGUAGE_CHANGING)) 
			{
				dispatchEvent(new LocalizerEvent(LocalizerEvent.LANGUAGE_CHANGING,
					lang, prevLang));
			}
			
			if (!_languages[lang])
			{
				_loadLang(lang);
				return 
			}							
		}			
		
		/**
		 * @inheritDoc
		 */
		public function get availableLanguages():Array 
		{
			return DictionaryUtil.getKeys(_languages);
		}				
		
		/**
		 * @inheritDoc
		 */
		public function getText(keyText:String, params:Object = null):String 
		{						
			var language:Object = _languages[this._currentLang];
			if (language) 
			{
				keyText = language[keyText] || keyText;									
			}			
			
			if (params)
			{
				for (var key:String in params)
				{
					keyText = keyText.replace(key, params[key]);
				}
			}
			
			return keyText;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setText(lang:String, keyText:String, translatedText:String):void 
		{
			lang || (lang = this._defaultLang);
			
			if (!_languages[lang])
			{
				_languages[lang] = {};
			}				
			
			_languages[lang][keyText] = translatedText;
		}							
		
		private function _loadLang(lang:String):void 
		{
			// Ignore null lang.
			if (!lang) 
			{
				return;
			}						
			
			var path:String = this._langFileBasePath + "." + lang + LANG_FILE_EXT;
			
			// Begin loading the xml data
			try 
			{				 
				var loader:IResourceLoader = ResourceProvider.getDefault().load(
					new URLRequest(path), 
					ResourceType.TEXT
				);				
				loader.addEventListener(Event.COMPLETE, handleLoadComplete, false, 0, true);
				loader.addEventListener(ResourceErrorEvent.RESOURCE_ERROR, handleLoadError, false, 0, true);				
			} 
			catch (er:Error) 
			{
				Kernel.getInstance().reportWarning(
					"Could not load XML data for localization: " + er.message, 
					Common.LOGCAT_TRIAL); 							
				
				this._onLoadedOrError();
			}
		}
		
		/**
		 * Handle a complete load by trying to parse the strings.
		 * 
		 * @param e
		 *				used to retrieve the data.
		 */
		private function handleLoadComplete(e:Event):void 
		{
			var loader:IResourceLoader = IResourceLoader(e.target);
			
			try 
			{				
				var xml:XML = new XML(loader.data);
				var id:String = xml.@id;
				
				if (id != this._targetLang)
				{
					Kernel.getInstance().reportWarning(
						"Wrong localization file loaded. Expected Id: " + this._targetLang + " Actual Id: " + id, 
						Common.LOGCAT_TRIAL);					
					
					return;
				}
				
				var langstrings:XMLList = xml.elements("item");
				if (langstrings.length() > 0) 
				{					
					for each (var node:XML in langstrings) 
					{
						setText(id, 
							String(node.@text),
							node.toString());
					}					
				}								
			} 
			catch (err:Error) 
			{
				Kernel.getInstance().reportWarning(
					"Invalid localization data: " + err.message, 
					Common.LOGCAT_TRIAL);				
			}
			
			_onLoadedOrError();
			
			loader.detachAndClean();
		}
		
		/**
		 * Handle a load error.
		 * 
		 * @param e
		 *				used to retrieve the url and error type.
		 */
		private function handleLoadError(e:ErrorEvent):void 
		{
			Kernel.getInstance().reportWarning(
				"Could not load XML data for localization: " + e.text, 
				Common.LOGCAT_TRIAL);							
			
			_onLoadedOrError();
			
			IResourceLoader(e.target).detachAndClean();
		}
		
		/**
		 * Check if all queued language loads are done.
		 */
		private function _onLoadedOrError():void 
		{
			var prevLang:String = this._currentLang;
			this._currentLang = this._targetLang;
			
			if (hasEventListener(LocalizerEvent.LANGUAGE_CHANGED)) 
			{
				dispatchEvent(new LocalizerEvent(LocalizerEvent.LANGUAGE_CHANGED,
					this._currentLang, prevLang));
			}			
		}					
	}
}