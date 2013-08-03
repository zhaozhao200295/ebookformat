package com.dtedu.digipub.interfaces
{
	import com.dtedu.dcl.interfaces.IDCLStyleSheet;
	import com.dtedu.digipub.miscs.PageEntry;
	import com.dtedu.trial.interfaces.IChangeTarget;
	
	public interface IBookFile extends IChangeTarget, IBookEditor, IView
	{	
		function get version():String;
		function set version(version:String):void;
		
		function get code():String;
		function set code(value:String):void;
			
		function get uuid():String;
		
		function get authors():String;
		
		function get creationDate():Date;
		
		function get modificationDate():Date;
		
		function get metadata():IMetadata;
		
		function set style(style:String):void;
		function get style():String;
		
		function get bookStyle():IDCLStyleSheet;
		
		function get title():String;
		
		function set librarys(libs:Array):void;
		function get librarys():Array;
		
		function get pageCount():int;	
		
		function get bookTocPage():String;
		
		function get tocTree():XMLList;
		
		function get manifest():IManifest;
		
		function get toolbar():XML;
		
		function insertPage(index:int, id:String):String;
		
		function deletePage(id:String):int;
		
		function changePageIndexToID(index:int):String;
		function changePageIDToIndex(id:String):int;
		
		function getPageIndexByID(id:String):int;
		
		function getPageEntryByID(id:String):PageEntry;
		
		function getPageEntryByIndex(index:int):PageEntry;
	}
}