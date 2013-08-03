package com.dtedu.digipub.commands.page
{
	import com.dtedu.digipub.interfaces.IPageView;

	public class DCLCommand extends UndoCommand
	{
		protected var focusPage:IPageView;
		
		public function DCLCommand()
		{
			super();
		}
	}
}