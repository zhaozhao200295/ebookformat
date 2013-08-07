package
{
	import com.dtedu.dcl.DCLFactory;
	import com.dtedu.digipub.BookViewer;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.ebook.interfaces.IPlugin;
	import com.dtedu.ebook.utils.ObjectCreate;
	import com.dtedu.trial.core.Kernel;
	import com.dtedu.trial.interfaces.IKernel;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	[SWF(width=1024, height=768)]
	public class BookMaker extends Sprite
	{
		protected var skin:Sprite;
		private var _kernel:IKernel;
		private var _bookViewer:IBookViewer;
		
		public function BookMaker()
		{
			_kernel = Kernel.getInstance(this);
						
			_kernel.configuration = <app>
    <navigation useSWFAddress="false">
    </navigation>
    
	<logging enabled="true" logLevel="7">
    	<channels>
    		<channel enabled="false" name="TrialDebugger" url="TrialDebuggerClient.swf" />						
		</channels>
	</logging>	 
	
	<services>
		<serviceGroup id="default" maxIdleConnections="2">
		    <endpoint uri="http://localhost:9331/api/amf.php" />
		</serviceGroup>
	</services>
</app>;
			_bookViewer = new BookViewer();
			addChild(Sprite(_bookViewer));
			
			
			skin = ObjectCreate.fullSprite(Embed.instance.icon_toolBarBg);
			addChild(skin);
			ObjectCreate.createIconButton(Embed.instance.icon_icon, Embed.instance.icon_icon_over, Embed.instance.icon_icon, this);
			
			var plugin:IPlugin;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(evn:Event):void{
				loader.removeEventListener(Event.COMPLETE, arguments.callee);
				plugin = IPlugin(loader.content);
				
				plugin.graphics.clear();
				plugin.graphics.beginFill(0xff0000);
				plugin.graphics.drawCircle(0, 0, 100);
				plugin.graphics.beginFill(0xffffff);
				plugin.graphics.drawCircle(0, 0, 95);
				plugin.graphics.beginFill(0x0000ff);
				plugin.graphics.drawCircle(0, 0, 90);
				plugin.graphics.endFill();
				
				plugin.instance.x = 100;
				plugin.instance.y = 100;
				addChild(plugin.instance);
				
				_bookViewer.loadBook("template");
			});
			loader.load(new URLRequest("demo.swf"));
		}
	}
}