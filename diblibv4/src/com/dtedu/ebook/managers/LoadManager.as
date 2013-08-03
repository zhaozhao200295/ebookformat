package com.dtedu.ebook.managers 
{
	import com.dtedu.ebook.interfaces.ILoadManager;
	import com.dtedu.trial.utils.URLUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	
	/**
	 * ...
	 * @author Jeff
	 */
	public class LoadManager implements ILoadManager
	{
		private var _loader:Loader = new Loader();
		private var _urlLoader:URLLoader = new URLLoader();
		private var _isLoading:Boolean;
		private var _loadList:Array = [];
		private static var _instance:LoadManager;
		public function LoadManager() 
		{
			if( _instance != null )
			{
				throw new Error("LoadManager 单例");
			}
			initLoader();
		}
		

		public static function get instance():LoadManager
		{
			if( _instance == null )
			{
				_instance = new LoadManager();
			}
			return _instance;
		}
		
		private function initLoader():void
		{
			_loader = new Loader();
			_urlLoader = new URLLoader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, displayLoadCompleteHandler);
			
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_urlLoader.addEventListener(Event.COMPLETE, dataLoadCompleteHandler);
		}
		
		/**
		 * 添加加载到加载队列 
		 * @param _url 加载路径
		 * @param _completeFunction 加载完成调用方法
		 * @param _container 父容器
		 * @param _context LoaderContext
		 * 
		 */		
		public function load(_url:String,_completeFunction:Function=null,_container:DisplayObjectContainer=null,_context:LoaderContext=null):void
		{
			
			_loadList.push( { url:_url, completeFunction:_completeFunction, container:_container,context:_context } );
			if (!isLoading)
			{
				loadNext();
			}
			
		}
		
		/**
		 * 停止当前所有加载,清空加载队列 
		 * 
		 */		
		public function stopAll():void
		{
			stopLoading();
			_loadList = [];
		}
		
		/**
		 * 取消加载队列中指定加载路径;
		 * @param value 指定加载路径
		 * 
		 */		
		public function cancelLoad(value:String):void
		{
			if(value)
			{
				var index:int = _loadList.indexOf(value);
				if(index>-1)
				{
					if(_loadList[0].url == value)
					{
						if(_isLoading)
						{
							stopLoading();
							_loadList[0] = null;
							_loadList.shift();
							loadNext();
						}
					}else
					{
						_loadList[index] = null;
						_loadList.splice(index,1);
					}
				}
			}
		}
		
		/**
		 * 返回是否加载中 
		 * @return 
		 * 
		 */		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		
		/**
		 * 进行一个队列中下一个加载 
		 * 
		 */		
		private function loadNext():void
		{
			if (_loadList.length)
			{
				_isLoading = true;
				switch(getFileType(_loadList[0].url))
				{
					case "swf":
					case "png":
					case "jpg":
						loadDisplayObject();
						break;
					case "xml":
					case "txt":
						loadDataObject();
						break;
				}
				
			}else
			{
				_isLoading = false;
			}
			
		}
		
		/**
		 * 停止当前加载,不清空加载列表
		 * @param value
		 * 
		 */		
		private function stopLoading():void
		{
			if(_isLoading&&_loadList.length)
			{
				switch(getFileType(_loadList[0].url))
				{
					case "swf":
					case "png":
					case "jpg":
						_loader.close();
						break;
					case "xml":
					case "txt":
						_urlLoader.close();
						break;
				}
			}
			_isLoading = false;
		}
		
		/**
		 * 加载图片,动画等可是元素 
		 * 
		 */		
		private function loadDisplayObject():void
		{
			_loader.load(new URLRequest(_loadList[0].url),_loadList[0].context);
		}
		
		/**
		 * 加载xml等文本元素 
		 * 
		 */		
		private function loadDataObject():void
		{
			_urlLoader.load(new URLRequest(_loadList[0].url));
		}
		
		/**
		 * 可是元素加载完成方法 
		 * @param e
		 * 
		 */		
		private function displayLoadCompleteHandler(e:Event):void
		{
			if(_loadList[0].completeFunction!=null)
			{
				_loadList[0].completeFunction.call(null,e.target.content);
			}
			
			if (_loadList[0].container != null)
			{
				_loadList[0].container.addChild(e.target.content);
			}
			_loadList[0] = null;
			_loadList.shift();
			
			loadNext();
		}	
		
		/**
		 * 文本元素加载完成处理 
		 * @param e
		 * 
		 */		
		private function dataLoadCompleteHandler(e:Event):void
		{
			if(_loadList[0].completeFunction!=null)
			{
				_loadList[0].completeFunction.call(null,e.target.data);
			}
			
			_loadList[0] = null;
			_loadList.shift();
			
			loadNext();
		}	
		
		private function getFileType(value:String):String
		{
			value = URLUtil.getBaseUri(value);
			return value.substring(value.lastIndexOf(".") + 1, value.length);
		}
		
		private function loadErrorHandler(e:IOErrorEvent):void
		{
			//Alert.show(e.toString());
			_isLoading = false;
			_loadList.shift();
			loadNext();
			
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			//TODO: implement function
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			//TODO: implement function
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			//TODO: implement function
			return false;
		}
		
		public function dispose():void
		{
			//TODO: implement function
		}
	}

}