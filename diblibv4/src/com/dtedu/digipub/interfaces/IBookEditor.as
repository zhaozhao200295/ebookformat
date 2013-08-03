package com.dtedu.digipub.interfaces
{	
	public interface IBookEditor extends IEditor
	{
		function appendPage(page:IPageFile):IPageView;
		function removePage(page:IPageFile):IPageView;
	}
}