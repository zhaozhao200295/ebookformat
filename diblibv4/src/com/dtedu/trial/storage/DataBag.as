package com.dtedu.trial.storage
{
	import com.dtedu.trial.interfaces.IDataBag;

	public class DataBag implements IDataBag
	{
		private var _bag:Object = {};
		
		public function DataBag()
		{			
		}
		
		public function getData(key:String):Object
		{
			return this._bag[key];
		}
		
		public function setData(key:String, data:*):void
		{
			this._bag[key] = data;
		}
		
		public function eraseKey(key:String):void
		{
			delete this._bag[key];
		}
	}
}