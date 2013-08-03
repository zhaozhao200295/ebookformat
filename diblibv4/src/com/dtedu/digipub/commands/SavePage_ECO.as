package com.dtedu.digipub.commands
{
	import com.dtedu.digipub.events.BookFileEvent;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.digipub.miscs.BookData;
	import com.dtedu.trial.commands.RemoteCommand;
	import com.dtedu.trial.interfaces.IDataBag;
	import com.dtedu.trial.interfaces.IKernel;
	
	public class SavePage_ECO extends RemoteCommand
	{
		private var _ebookPath:Object;
		private var _viewer:IBookViewer;
		
		public function SavePage_ECO(kernel:IKernel=null, dataBag:IDataBag=null)
		{
			_ebookPath = kernel.localData.getData("ebookPath");
			_viewer = kernel.localData.getData("bookViewer") as IBookViewer;
			
			super(kernel, dataBag);
		}
		
		override public function execute(data:Object = null):void
		{
			/**
			 * 保存电子课本页面（dibp）
			 *
			 * @param uuid EBookID 电子课本编号
			 * @param array DIBP
			 *  - string name dibp文件名，不包含扩展名
			 *  - xml content dibp内容，创建课件时可以为空
			 *  - bytearray thumb dibp截图
			 *  - bool cover 可选，标识页面是否是首页，设置为true，且传递thumb属性，则thumb将会被保存为课件封面图片（若content为null，则只保存封面图片）
			 * @return array
			 *  - uuid id 电子课本编号
			 *  - string url 电子课本地址
			 */
			if(_ebookPath)
			{
				data.pages.name = "pages/" + data.pages.name + ".dibp";
				_viewer.dispatchEvent(new BookFileEvent(BookFileEvent.SAVE_PAGE, BookData(data.pages)));
			}
			else
			{
				this.getService("App.EBookService").savePage(data.coursewareID, data.pages);	
			}
		}
	}
}