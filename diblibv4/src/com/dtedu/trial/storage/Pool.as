/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.storage
{       
    import com.dtedu.trial.utils.Debug;
    
    import flash.utils.Dictionary;
    
    public class Pool 
    {
    	protected var _weakKeys:Boolean;
        protected var _pool: Dictionary;
        
        public function Pool(weakKeys:Boolean = false)
        {
        	this._weakKeys = weakKeys;
            this._pool = new Dictionary(weakKeys);
        }
        
        public function count(key:*):int
        {            
            var slot:Array = this._pool[key] as Array;
            return (slot != null) ? slot.length : 0;
        }                
        
        public function pushOne(key:*, value:*):void
        {            
            var slot:Array = this._pool[key] as Array;
            if (slot != null)
            {
            	Debug.assert(slot.indexOf(value) == -1, "Object already in pool!");
                slot.push(value);               
            }
            else
            {
                slot = [value]; 
                this._pool[key] = slot;
            }
        }    
        
        public function popOne(key:*):*
        {            
            var slot:Array = this._pool[key] as Array;
            if (slot != null && slot.length > 0)
            {
                return slot.pop();
            }
            return null;
        }   
        
        public function getSlot(key:*):Array
        {
        	return this._pool[key];
        }
        
        public function shrinkAll(numRemain:int):void
        {                
            for each (var slot:Array in this._pool)
            {
	            if (slot != null && slot.length > numRemain)
	            {
	                slot.splice(numRemain, slot.length-numRemain);
	            }    
	        }       
        }                    
        
        public function shrink(key:*, numRemain:int):Array
        {                
            var slot:Array = this._pool[key] as Array;
            if (slot != null && slot.length > numRemain)
            {
                return slot.splice(numRemain, slot.length-numRemain);
            }           
			return null;
        }
        
        public function clearAll(pop:Boolean = false):Array
        {
			var result:Array = null;
			
			if (pop)
			{
				result = [];
					
				for each (var slot:Array in this._pool)
				{
					for each (var value:* in slot)
					{
						result.push(value);
					}
				}
			}
			
            this._pool = new Dictionary(this._weakKeys);
			
			return result;
        }
        
        public function clear(key:*):void
        {            
            delete this._pool[key];
        }              
        
        public function remove(value:*):void
        {
        	for each (var slot:Array in this._pool)
            {
	            if (slot != null)
	            {
	            	var pos:int = slot.indexOf(value);
	            	if (pos >= 0) slot.splice(pos, 1);
	            }    
	        }      
        }
    }
}