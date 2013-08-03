package com.dtedu.digipub.editors
{
	import com.dtedu.dcl.interfaces.IDCLComponent;
	import com.dtedu.digipub.commands.page.AddDCLCommand;
	import com.dtedu.digipub.dib.DIBCommon;
	import com.dtedu.digipub.interfaces.IBookView;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.interfaces.IPageEditor;
	import com.dtedu.digipub.interfaces.IPageFile;
	import com.dtedu.digipub.interfaces.IPageView;
	import com.dtedu.trial.interfaces.ICommand;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class PageEditor implements IPageEditor
	{
		private var _bookView:IBookView;
		
		private var OFF_X:Number = 10;
		private var OFF_Y:Number = 10;
		
		private var OFF_XT:Number = 0;
		private var OFF_YT:Number = 0;
		
		public function PageEditor(bookView:IBookView)
		{
			_bookView = bookView;
		}
			
		
		public function undo():void
		{
		}
		
		public function redo():void
		{
		}
		
		public function addElement(element:IDCLComponent):void
		{
			if(!_bookView.focusPage || !element) return;
			var addDCLCommand:ICommand = new com.dtedu.digipub.commands.page.AddDCLCommand
			addDCLCommand.execute();
		}
		
		public function removeElement(element:IDCLComponent):void
		{
			if(!_bookView.focusPage || !element) return;
		}
		
		public function dispose():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function load(value:XML):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function save():XML
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function set backgroundColor(color:uint):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function set backgroundImage(image:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
	}
}
