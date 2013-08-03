package
{
	public function cufDetail(log:Object,value:Object):void
	{
		for (var key:String in value) 
		{
			if(value[key] is String)
			{
				log.o += key + " = " + value[key] + "\n";
				trace(log.i++ + ".",key," = ",value[key]);
			}
			else
			{
				cufDetail(log,value[key]);
			}
		}
	}
}