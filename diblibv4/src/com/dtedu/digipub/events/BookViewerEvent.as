package com.dtedu.digipub.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class BookViewerEvent extends Event
	{
		public static const PAGE_THUMBNAIL_UPDATED:String = "pageThumbnailUpdated";
		public static const CURRENT_PAGE_CHANGED:String = "currentPageChanged";		
		public static const BOOK_SAVED:String = "bookSaved";
		public static const BOOK_CONTENT_CHANGED:String = "bookContentChanged";
		public static const PAGES_CHANGE_EVENT:String = "pageIndexChanged";
		
		public static const PAGE_TURN_START:String = "pageTurnStart";
		public static const PAGE_TURN_END:String = "pageTurnEnd";
		
		public var actionType:String;
		public var relatedPages:Array
		public var relatedPageIndex:int;
		public var relatedPageID:String;
		public var pageThumb:ByteArray;
		public function BookViewerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		override public function clone():Event
		{
			return new BookViewerEvent(type,bubbles,cancelable);
		}
	}
}