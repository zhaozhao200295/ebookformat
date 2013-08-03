package
{
	public function printf(value:Object):String
	{			
		var log:Object = {i:1,o:""};		
		if(value is String)
		{
			trace(value);
			log.o = value;
		}
		else
		{
			cufDetail(log,value);
		}
		return log.o;
	}
}