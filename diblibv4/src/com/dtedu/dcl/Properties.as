/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.dcl
{
    import com.dtedu.trial.interfaces.IDisposable;
    import com.dtedu.trial.utils.Debug;
    import com.dtedu.trial.utils.DictionaryUtil;
    
    import flash.utils.Dictionary;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
    
	use namespace flash_proxy;

    /**
     * 配置存取对象。
     */
    public dynamic class Properties extends Proxy implements IDisposable
    {				
        private var _properties:Dictionary;
		private var _updateHandler:Function;

        public function Properties(updateHandler:Function = null)
        {			
			_properties = new Dictionary();
			_updateHandler = updateHandler;
        }				
		
		public function isRegistered(name:String):Boolean 
		{
			return this._properties[name] != null;
		}				

        /**
         * @inheritDoc
         */
        public function register(name:String,
                                 defaultValue:* = null,
								 validator:Function = null):void
        {
			var setting:PropertyNode = this._properties[name];
			if (setting) setting.dispose();
			
            setting = new PropertyNode(defaultValue, validator);            
            this._properties[name] = setting;
        }
		
		public function applyDefault(name:String):void
		{
			var setting:PropertyNode = this._properties[name];
			setting.useDefault();
			
			if (_updateHandler != null)
			{
				_updateHandler(String(name), PropertyNode(this._properties[name]).currentValue);				
			}
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return this._properties[name] != null && PropertyNode(this._properties[name]).isSet;
		}				
		
		override flash_proxy function getProperty(name:*):* 
		{
			var setting:PropertyNode = this._properties[name];
			
			return setting && setting.currentValue;
		}		
		
		override flash_proxy function setProperty(name:*, value:*):void 
		{
			var setting:PropertyNode = this._properties[name];
			
			if (setting)
			{			
				if (setting.currentValue != value)
				{	            				
					if (setting.validator != null)
					{
						value = setting.validator(value, setting.defaultValue);					
					}
					
					if (_updateHandler != null)
					{
						if (_updateHandler(String(name), value))
						{
							setting.currentValue = value;
							setting.isSet = true;
						}
					}
					else
					{
						setting.currentValue = value;
						setting.isSet = true;
					}															
				}
			}
		}	
		
		public function getAllPropertyNames():Array
		{
			return DictionaryUtil.getKeys(this._properties);
		}
		
		public function getAllValidValues():Object
		{
			var result:Object = {};
			
			var node:PropertyNode;
			
			for (var k:* in _properties)
			{
				node = PropertyNode(_properties[k]);
								
				if (node.currentValue != null && node.isSet)
				{
					result[k] = node.currentValue;
				}
			}
			
			return result;
		}
		
		public function validate(name:*, value:*):*
		{
			var setting:PropertyNode = this._properties[name];
			
			if (setting)
			{			
				if (name.validator != null)
				{
					value = setting.validator(value, setting.defaultValue);					
				}
			}
			
			return value;
		}
        
        public function restoreDefault():void
        {
            for (var k:* in _properties)
            {
                PropertyNode(_properties[k]).useDefault();
            }
        }   
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_updateHandler = null;
			
			if (_properties)
			{
				for (var k:String in _properties)
				{
					PropertyNode(_properties[k]).dispose();
					delete _properties[k];
				}
			}
			
			_properties = null;
		}
    }
}

import com.dtedu.trial.interfaces.IDisposable;

internal class PropertyNode implements IDisposable
{		
	public var currentValue:*;

    public var defaultValue:*;
	
	public var isSet:Boolean;
	
	public var validator:Function;

    public function PropertyNode(defaultValue:*, validator:Function)
    {
        this.currentValue = defaultValue;
        this.defaultValue = defaultValue;
		this.isSet = false;
		this.validator = validator;
    }	

    public function useDefault():void
    {
        this.currentValue = this.defaultValue;
    }

    public function dispose():void
    {
        currentValue = null;
        defaultValue = null;
		validator = null;
    }
}