/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.storage
{       
    import com.dtedu.trial.interfaces.ISettings;
    import com.dtedu.trial.utils.Debug;
    
    import flash.net.SharedObject;
    import flash.utils.Dictionary;

    /**
     * 配置存取对象。
     */
    public class Settings implements ISettings
    {				
        private var _settings:Dictionary;

        private var _sharedObject:SharedObject;

        private var _useLocalCache:Boolean;

        public function Settings()
        {			
        }

        /**
         * @inheritDoc
         */
        public function setup(sharedObjectName:String = null, useLocalCache:Boolean = true):void
        {
            this._settings = new Dictionary();

            if (sharedObjectName != null)
            {
                this._sharedObject = SharedObject.getLocal(sharedObjectName);
                this._useLocalCache = useLocalCache;
            }
            else
            {
                this._useLocalCache = false;	
            }
        }

        /**
         * @inheritDoc
         */
        public function dispose():void
        {
            if (_settings)
            {
                for (var k:* in _settings)
                {
                    SettingsNode(_settings[k]).dispose();
                    delete _settings[k];
                }
            }

            _settings = null;
            _sharedObject = null;
        }
		
		public function isRegistered(name:String):Boolean 
		{
			return this._settings[name] != null;
		}

        /**
         * @inheritDoc
         */
        public function register(name:String,
                                 defaultValue:* = null,
                                 localCache:Boolean = false,
								 readonly:Boolean = false, 
								 changedHandler:Function = null):void
        {
            var setting:SettingsNode = new SettingsNode(defaultValue, localCache, readonly, changedHandler);

            if (localCache)
            {
                if (this._useLocalCache && this._sharedObject && this._sharedObject.data[name])
                {
                    setting.currentValue = this._sharedObject.data[name];
                }
                else if (this._sharedObject)
                {
                    this._sharedObject.data[name] = setting.currentValue;
                }
            }

            this._settings[name] = setting;
        }
		
		/**
		 * @inheritDoc
		 */
		public function getSetting(name:String):*
		{
			var setting:SettingsNode = this._settings[name]; 
			Debug.assertNotNull(setting, "Setting [" + name + "] not registered!");
			
			return setting.currentValue;
		}

        /**
         * @inheritDoc
         */
        public function setSetting(name:String, value:*):void
        {
            var setting:SettingsNode = this._settings[name];
            Debug.assertNotNull(setting, "Setting [" + name + "] not registered!"); 
			
			if (setting.readonly)
			{
				Debug.unexpectedPath("Setting [" + name + "] is readonly!");
				return;
			}

			if (setting.currentValue != value)
			{	            				
				if (setting.changedHandler != null)
				{
					value = setting.changedHandler(value, setting.defaultValue)					
				}
				
				setting.currentValue = value;
	
	            if (setting.localCache && this._sharedObject)
	            {
	                this._sharedObject.data[name] = setting.currentValue;
	            }						
			}
        }        

        /**
         * @inheritDoc
         */
        public function restoreDefault():void
        {
            for (var k:* in _settings)
            {
                SettingsNode(_settings[k]).useDefault();
            }
        }

        public function cloneSettings():ISettings
        {
            Debug.notImplemented();
			
            return null;
        }
    }
}

import com.dtedu.trial.interfaces.IDisposable;

internal class SettingsNode implements com.dtedu.trial.interfaces.IDisposable
{
    public var currentValue:*;

    public var defaultValue:*;

    public var localCache:Boolean;
	
	public var readonly:Boolean;
	
	public var changedHandler:Function;

    public function SettingsNode(defaultValue:*, localCache:Boolean, readonly:Boolean, changedHandler:Function)
    {
        this.currentValue = defaultValue;
        this.defaultValue = defaultValue;
        this.localCache = localCache;
		this.readonly = readonly;
		this.changedHandler = changedHandler;
    }

    public function useDefault():void
    {
        this.currentValue = this.defaultValue;
    }

    public function dispose():void
    {
        currentValue = null;
        defaultValue = null;
		changedHandler = null;
    }
}