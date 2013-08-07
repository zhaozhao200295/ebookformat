package
{
	public class Embed
	{
		[Embed(source="assets/toolBarBg.png")]
		public var icon_toolBarBg:Class;
		
		[Embed(source="assets/icons/icon.png")]
		public var icon_icon:Class;
		
		[Embed(source="assets/icons/icon_over.png")]
		public var icon_icon_over:Class;
		
		private static var _instance:Embed;

		public function Embed()
		{
			if(_instance)
			{
				throw new Error("Embed单例,不能实例化!", 99);
			}
		}

		public static function get instance():Embed
		{
			if(!_instance) _instance = new Embed();
			return _instance;
		}
	}
}