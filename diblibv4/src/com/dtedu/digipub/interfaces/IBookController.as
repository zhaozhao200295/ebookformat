package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IChangeObserver;
	import com.dtedu.trial.interfaces.IChangeTarget;
	import com.dtedu.trial.interfaces.IDisposable;
	import com.dtedu.trial.interfaces.IListener;
	
	public interface IBookController extends IViewerController, IChangeObserver, IChangeTarget, IDisposable
	{		
		function get bookFile():IBookFile;
		
		function resolvePath(path:String):String;
		
		function loadPageAsync(index:int):IListener;
		
		function loadAsync(bookPath:String):IListener;
		function saveAsync():IListener;
		
		function addPage(page:IPageFile):IPageView;
		function removePage(page:IPageFile):IPageView;
		
		function addPageAt(index:int, page:IPageFile):IPageView;
		function removePageAt(index:int):IPageView;
		
		function removePageCacheAt(index:int):void;
				
		function swapPage(page1Index:int, page2Index:int):void;
		
		function createPageView(ownerView:IBookView, bookPage:IPageFile):IPageView;
		function tryGetPageViewFromCache(index:int):IPageView;
	}
}