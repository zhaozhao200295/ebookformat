package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IChangeTarget;

	public interface IManifest extends IChangeTarget
	{	
		/**
		 * 获取版本
		 */
		function get version():String;
		
		/**
		 * 设置版本
		 */
		function set version(version:String):void;
		
		/**
		 * 加载XML信息
		 */
		function load(data:*):void;		
		
		/**
		 * 保存manifest信息
		 */
		function save():*;
		
		/**
		 * 请<刘臻>再加入其他的接口方法
		 */
	}
}