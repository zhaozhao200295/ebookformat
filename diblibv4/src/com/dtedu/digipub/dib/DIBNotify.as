package com.dtedu.digipub.dib
{
	import com.dtedu.trial.interfaces.IChangeObserver;
	import com.dtedu.trial.interfaces.IChangeTarget;
	
	import flash.display.Sprite;
	
	public class DIBNotify implements IChangeObserver, IChangeTarget
	{				
		private var _hasPendingChanges:Boolean;
		
		protected var _enableChangeTracking:Boolean;
		
		protected var _isNew:Boolean;
		
		public function DIBNotify()
		{
		}
		
		public function get hasPendingChanges():Boolean
		{
			return _hasPendingChanges;
		}
		
		public function resetChanges():void
		{
			_hasPendingChanges = false;
			_isNew = false;
		}
		
		public function notifyChange(source:* = null):void
		{
			_enableChangeTracking && (_hasPendingChanges = true);
		}
	}
}