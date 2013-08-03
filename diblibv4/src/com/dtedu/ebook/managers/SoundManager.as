package com.dtedu.ebook.managers
{
	//import dt.common.util.Alert;
	import com.dtedu.ebook.interfaces.ISoundManager;
	import com.dtedu.ebook.model.SoundInfo;
	import com.dtedu.trial.utils.URLUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	
	
	public class SoundManager implements ISoundManager
	{
		private static var _instance:ISoundManager;
		private var _bookPath:String = "";
		private var _snd:Sound;
		private var _sch:SoundChannel;
		private var _position:Number = 0;
		private var _timer:Timer;
		private var _info:SoundInfo;
		
		
		public static function get instance():ISoundManager
		{
			if (_instance == null)
			{
				_instance = new SoundManager();
			}
			
			return _instance;
		}
		
		public function SoundManager()
		{
			if(_instance != null )
			{
				throw new Error("SoundManager 单例");
			}
			
			_sch = new SoundChannel();
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER,timerEventHandler);
			
		}
		
		
		public function play(info:Object):void
		{
			//if(!_bookPath) return;
			stop();
		
			_snd = new Sound();
			_info = null;
			if (info is SoundInfo) {
				_info = info as SoundInfo;
				_snd.load(new URLRequest(URLUtil.combine(_bookPath, String(info.url))));
				_snd.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				_sch = _snd.play();
				
				if(_info.progressFunction!=null)
				{
					_timer.start();
					_info.progressFunction.call(null,{position:_sch.position,length:_snd.length});
					//					Dispatcher.dispatchEvent(new GEvent(EventName.SoundPlay_Progress, {position:_sch.position,length:_snd.length}));
				}
				
				
				if (_info.completeFunction!=null)
				{
					_sch.addEventListener(Event.SOUND_COMPLETE, mySoundCompleteHandler);
					function mySoundCompleteHandler(e:Event):void
					{
						_info.completeFunction.call(null,_info.data);
					}
				}
			}
			else
			{
				_snd.load(new URLRequest(URLUtil.combine(_bookPath, String(info))));
				_sch = _snd.play();
			}
			
			_sch.addEventListener(Event.SOUND_COMPLETE,soundCompleteHandler);
		}
		
		public function stop(channel:Object=null):void
		{
			if(_sch)
			{
				_sch.stop();
				_position = _sch.position;
				_sch.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			}
			_timer.stop();
		}
		
		public function set bookPath(value:String):void
		{
			this._bookPath = value;
		}
		
		private function soundCompleteHandler(e:Event):void
		{
			_timer.stop();
			_sch.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		}
		
		private function timerEventHandler(e:TimerEvent):void
		{
			_info.progressFunction.call(null,{position:_sch.position,length:_snd.length});
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			//Alert.show("loadSoundError:"+e.toString());
		}
		
		
		//=====================================================
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			return false;
		}
		
		public function dispose():void
		{
		}
	}
}