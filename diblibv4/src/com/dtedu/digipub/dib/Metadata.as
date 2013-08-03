package com.dtedu.digipub.dib
{
	import com.dtedu.digipub.interfaces.IMetadata;
	import com.dtedu.trial.interfaces.IChangeObserver;
	import com.dtedu.trial.interfaces.IDisposable;

	public class Metadata implements IMetadata, IDisposable
	{
		private var _metaObj:Object;
		private var _metaBindingTable:Object;
		private var _observer:IChangeObserver;

		public function Metadata(observer:IChangeObserver)
		{
			_observer=observer;
			_metaObj={};
			_metaBindingTable={};
		}

		public function bind(key:String, functor:Function):void
		{
			_metaBindingTable[key]=functor;
		}

		public function getItem(key:String):String
		{
			return _metaObj[key];
		}

		public function setItem(key:String, value:String):void
		{
			if (value != _metaObj[key])
			{
				_metaObj[key]=value;

				if (_metaBindingTable[key])
				{
					_metaBindingTable[key](value);
				}

				_observer.notifyChange(this);
			}
		}

		public function dispose():void
		{
			_metaBindingTable=null;
			_observer=null;
		}
	}
}
