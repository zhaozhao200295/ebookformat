/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.interfaces
{

    /**
     * 配置存取接口。
     */
    public interface ISettings extends IDisposable
    {
        /**
         * 初始化配置。
         *
         * @param useLocalCache 是否优先使用本地缓存，如果本地缓存有该配置。
         */
        function setup(sharedObjectName:String = null, useLocalCache:Boolean = true):void;
		
		/**
		 * 注册默认配置。
		 *
		 * @param name 配置的名称。
		 * @param defaultValue 配置的默认值。
		 * @param localCache 该配置是否保存到本地缓存。
		 * @param readonly 该配置是否只读。
		 * @param changedHandler 值改变时调用的方法，形如   function xxx(value:*):Boolean，返回否恢复默认值 。
		 */
		function register(name:String, defaultValue:* = null,
						  localCache:Boolean = true, readonly:Boolean = false, changedHandler:Function = null):void;

        /**
         * 获取配置值。
         *
         * @param name 配置的名称。
         * @return 配置的值。
         * @throws AssertError 如果配置没有预先注册。
         */
        function getSetting(name:String):*;        

        /**
         * 改变配置。
         *
         * @param name 配置的名称。
         * @param value 配置的值。
         * @throws AssertError 如果配置没有预先注册。
         */
        function setSetting(name:String, value:*):void;

        /**
         * 恢复默认。
         */
        function restoreDefault():void;

        /**
         * 克隆配置。
         */
        function cloneSettings():ISettings;
    }
}
