package com.dtedu.digipub.dib
{
	
	/**
	 * 常量定义
	 */
	public class DIBCommon
	{
		//type
		public static const DIB_TYPE:String = "DIB";
		public static const DIBX_TYPE:String = "DIBX";
		
		//extension
		public static const INDEX_EXT:String = ".xml";
		public static const PAGE_EXT:String = ".xml";
		public static const TOOL_EXT:String = ".xml";
		public static const MANIFEST:String = ".xml";
		public static const THUMB_EXT:String = ".png";
		
		//file name
		public static const DINDEX:String = "content" + INDEX_EXT;
		public static const DCOVER:String = "cover" + THUMB_EXT;
		
		//defaule folder
		public static const DIB_PATHS:Object = {
			images: "images",
			pages: "pages",
			thumbs: "thubms",
			contents: "contents", 
			libs: "libs", 
			plugins: "plugins"
		};	
		
		public static var dibNamespace:Namespace = new Namespace("http://ns.dtedu.com/digipub/dib");
		
		public static var pageItemTemplate:XML = <item id="PAGE_ID"/>;
		public static var tocNodeTemplate:XML = <node name="TOC_NAME" page="PAGE_ID" />;
		public static var metaTemplate:XML = <meta name="META_NAME" content="META_CONTENT"/>;
		public static var libraryTemplate:XML = <library sort="SORT" key="KEY" src="SRC"/>;
		
		public static var DIBITemplate:XML = <book version="1.0" uuid="EBOOK_UUID" xmlns="http://ns.dtedu.com/digipub/dib">      			
	<head>										        
		<meta name="title" content="EBOOK_TITLE"/>
		<meta name="authors" content="EBOOK_AUTHORS"/>
		<meta name="code" content="EBOOK_CODE"/>
		<meta name="uuid" content="EBOOK_UUID"/>
		<meta name="creation-date" content="CREATION_DATE"/>
		<meta name="modification-date" content="MODIFICATION_DATE"/>
		<style>
			<![CDATA[
			]]>
		</style>
	</head>
	<librarys/>
	<spine/>
	<toc/>
</book>;			
		
		public static var lectureTemplate:XML = <lecture id="" label="新教学步骤" title="新教学步骤"/>;
		
		public static var DIBPTemplate:XML = <page version="1.0" xmlns="http://ns.dtedu.com/digipub/dib">
	<head>										        
		<meta name="title" content="EBOOK_TITLE"/>
		<meta name="creation-date" content="CREATION_DATE"/>
		<meta name="modification-date" content="MODIFICATION_DATE"/>
		<style>
			<![CDATA[
			]]>
		</style>
	</head>
	<body width="1024" height="768" backgroundColor="0xffffff" backgroundImage="BG_IMAGE" />
	<lectures/>
</page>;
		
		public static var textTemplate:XML = <text width="400" height="120">
	<TextFlow paddingBottom="0" paddingLeft="0" paddingRight="0" paddingTop="0" whiteSpaceCollapse="preserve" version="2.0.0" 
xmlns="http://ns.adobe.com/textLayout/2008"><p><span fontFamily="微软雅黑" fontSize="32">请输入文本</span></p></TextFlow>
</text>;
		
	}
}