package com.dtedu.digipub.interfaces
{
	import com.dtedu.trial.interfaces.IListener;

	public interface IPageViewController extends IViewerController
	{
		function resolvePath(path:String):String;	
		
		function loadPageAsync(index:int):IListener;
		function savePageAsync(index:int):IListener;
		
		function createPageView(ownerView:IBookView, bookPage:IPageFile):IPageView;
	}
}