package com.dtedu.trial.interfaces
{
	import flash.display.DisplayObject;

	public interface IKernelProvider
	{
		function createKernel(any:DisplayObject):IKernel;
	}
}