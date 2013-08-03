package com.dtedu.digipub.miscs
{
	import com.dtedu.digipub.dib.DIBCommon;
	import com.dtedu.digipub.interfaces.ITOCNode;
	import com.dtedu.trial.utils.URLUtil;
	
	public class PageEntry
	{
		public var id:String;
		
		public var url:String;
		
		public var thumb:String;
		
		public function PageEntry(id:String = null)
		{		
			this.id = id;
			this.url = URLUtil.combine(DIBCommon.DIB_PATHS.pages, this.id) + DIBCommon.PAGE_EXT;
			this.thumb = URLUtil.combine(DIBCommon.DIB_PATHS.thumbs, this.id) + DIBCommon.THUMB_EXT;	
		}
		
		public function save():XML
		{
			var pageItem:XML = DIBCommon.pageItemTemplate.copy();
			pageItem.@id = this.id;
			return pageItem;
		}	
	}
}