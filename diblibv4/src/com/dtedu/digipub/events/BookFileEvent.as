package com.dtedu.digipub.events
{
	import com.dtedu.digipub.miscs.BookData;
	
	import flash.events.Event;
	
	public class BookFileEvent extends Event
	{
		public static const SAVE_INDEX:String = "saveIndex";
		public static const SAVE_PAGE:String = "savePage";
		
		public var bookData:BookData;
		
		public function BookFileEvent(type:String, bookData:BookData = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			if(bookData) this.bookData = bookData;
			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new BookFileEvent(type, bookData, bubbles, cancelable);
		}
	}
}