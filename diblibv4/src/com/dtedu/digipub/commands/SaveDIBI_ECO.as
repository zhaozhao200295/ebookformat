package com.dtedu.digipub.commands
{
	import com.dtedu.trial.commands.RemoteCommand;
	import com.dtedu.trial.interfaces.IDataBag;
	import com.dtedu.trial.interfaces.IKernel;
	
	public class SaveDIBI_ECO extends RemoteCommand
	{
		public function SaveDIBI_ECO(kernel:IKernel=null, dataBag:IDataBag=null)
		{
			super(kernel, dataBag);
		}
		
		override public function execute(data:Object = null):void
		{
			/**
			 * 根据传递的参数更新电子课本的索引文件（content.dibi）
			 *
			 * @param uuid EBookID 电子课本编号
			 * @param array DIBI
			 *  - string name dibi文件名，不包含扩展名
			 *  - xml content dibi内容，创建电子课本时可以为空
			 * @param int pageCount 页面总数
			 * @return array
			 *  - uuid id 电子课本编号
			 *  - string url 电子课本地址
			 */
			this.getService("App.EBookService").saveDibi(data.coursewareID, data.dibi, data.pageCount);
		}
	}
}