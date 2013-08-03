package com.dtedu.digipub
{
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.loading.EmbeddedBundle;
	
	import flash.display.LoaderInfo;

	public class EmbeddedAsset
	{
		[Embed(source="/assets/i18n/com.dtedu.dcl.zh_CN.xml", mimeType="application/octet-stream")]
		private static const I18N_COM_DTEDU_DCL_ZH_CN:Class;
		
		[Embed(source="/assets/i18n/com.dtedu.digipub.zh_CN.xml", mimeType="application/octet-stream")]
		private static const I18N_COM_DTEDU_DIGIPUB_ZH_CN:Class;
		
		public static function init(kernel:IKernel, loaderinfo:LoaderInfo):void 
		{
			var embedded:EmbeddedBundle = new EmbeddedBundle(loaderinfo);
			
			embedded.addResource("assets/i18n/com.dtedu.dcl.zh_CN.xml", I18N_COM_DTEDU_DCL_ZH_CN);
			embedded.addResource("assets/i18n/com.dtedu.digipub.zh_CN.xml", I18N_COM_DTEDU_DIGIPUB_ZH_CN);
			
			kernel.resourceProvider.registerBundle(embedded, 10);
		}
	}
}