package com.dtedu.trial.utils
{	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

    public class SerializationUtil
    {
        public static function serialize(value:*):IDataInput
        {
            if (value == null)
            {
                return null;
            }
			
            var bytes:ByteArray = new ByteArray();
            bytes.writeObject(value);
			bytes.position = 0;
            
            return bytes;
        }

        public static function deserialize(value:IDataInput):*
        {            
			if (value == null)
			{
				return null;
			}			
			
            return value.readObject();
        }
    }
}
