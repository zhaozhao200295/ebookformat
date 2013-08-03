package
{
	import com.dtedu.digipub.BookViewer;
	import com.dtedu.digipub.interfaces.IBookViewer;
	import com.dtedu.trial.core.Kernel;
	import com.dtedu.trial.interfaces.IKernel;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	
	[SWF(heightPercent=100, widthPercent=100, width=1024, height=768)]
	public class BookMaker extends Sprite
	{
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
			_bookViewer.loadBook("template");
		}
	}
}