package com.dtedu.trial.data
{
	public class DataDictionary
	{
		private var _table:Object; 
		
		public function DataDictionary(dataRecord:Array)
		{
			this._table = {};
			
			for each (var row:Array in dataRecord)
			{
				this._table[row[0]] =row[1];
			}
		}
		
		public function getValue(key:Object):Object
		{
			return this._table[key];
		}
	}
}