/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.helpers
{       
    import com.dtedu.trial.interfaces.IDisposable;
    import com.dtedu.trial.interfaces.IKernel;
    import com.dtedu.trial.interfaces.ILogger;
    import com.dtedu.trial.interfaces.ILoggingChannel;
    import com.dtedu.trial.interfaces.IResourceLoader;
    import com.dtedu.trial.loading.ResourceType;
    import com.dtedu.trial.miscs.Common;
    
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.net.URLRequest;

    public class Logger implements ILogger, IDisposable
    {        
		private static const MAX_LOG_ENTRY:int = 256;        
		
		private static const DEFAULT_CATEGORY:String = 'TRACE';
		
		private static const UNKNOWN_LEVEL:String = "UNKNOWN";
        
		private static var levelText:Vector.<String> /* of String */ = Vector.<String>(
			[ 
				"ALL", //0
				"FATAL", //1
				"CRITICAL", //2
				"ERROR", //3
				"WARNING", //4
				"INFO", //5				
				"DEBUG" //6				
            ]);
		
		private var _logEnabled:Boolean = true;
		
		private var _logLevel:int = Common.LOG_ERROR;				
		
		private var _channels:Vector.<ILoggingChannel>;
		
		private var _buffer:Array = [];
		
		public function Logger()
		{				
		}				
        
        public function reset(kernel:IKernel, params:Object = null):void
        {
			if (!params)
			{
				return;
			}
			
			var debuggingCfg:XML = XML(params);
			
			if (!debuggingCfg)
			{
				throw new IllegalOperationError("XML parameters expected!");
			}			
			
			_logEnabled = debuggingCfg.@enabled == "true";
			_logLevel = int(debuggingCfg.@logLevel);
			
            if (_logEnabled)
            {              											                
                for each (var debugger:XML in debuggingCfg.channels.channel.(@enabled == "true"))
                {
					var params:Object = {};
					
					for each (var param:XML in debugger.param)
					{
						params[String(param.@name)] = String(param.@value);
					}
					
					var loader:IResourceLoader = kernel.resourceProvider.load(new URLRequest(debugger.@url), ResourceType.IMAGE);														
					loader.addEventListener(
						Event.COMPLETE,						
						function (e:Event):void
						{																				
							var logger:ILoggingChannel = ILoggingChannel(loader.data);					
							logger.init(kernel, params);														
							
							_channels ||= new Vector.<ILoggingChannel>();	
							_channels.push(logger);
							
							info("Logging channel [" + debugger.@name + "] is loaded.", Common.LOGCAT_TRIAL);
							
							loader.detachAndClean();	
						}
					);							
				}                    
            }
            else
            {
				dispose();
            }
        }       
		
		public function getLevelLabel(level:int):String
		{
			return level >= 0 && level <= Common.LOG_DEBUG ? levelText[level] : UNKNOWN_LEVEL;			
		}
        
		public function log(level:int, content:Object, category:Object = null):void
        {					
            if (_logEnabled && level <= _logLevel)
            {
				category ||= DEFAULT_CATEGORY;
				
                var plainMessage:String = "[" + String(category) + "] " + levelText[level] + ": " + String(content);

                trace(plainMessage);											

                if (_channels && _channels.length > 0)
                {
					var logger:ILoggingChannel;
					
					if (_buffer.length > 0)
					{
						for each (var logEntry:Array in _buffer)
						{							 
							for each (logger in _channels)
							{
								logger.log(logEntry[0], logEntry[1], logEntry[2]);
							}
						}
						
						_buffer = [];
					}
					
                    for each (logger in _channels)
                    {
						logger.log(category, level, content);
                    }
                }
				else
				{
					if (_buffer.length > MAX_LOG_ENTRY)
					{
						_buffer.shift();
					}
					
					_buffer.push([category, level, content]);
				}
            }			
        }		
		
		public function fatal(content:Object, category:Object = null):void
		{
			log(Common.LOG_FATAL, content, category);
		}
		
		public function crit(content:Object, category:Object = null):void
		{
			log(Common.LOG_CRITICAL, content, category);
		}
		
		public function error(content:Object, category:Object = null):void
		{
			log(Common.LOG_ERROR, content, category);
		}
		
		public function warn(content:Object, category:Object = null):void
		{
			log(Common.LOG_WARNING, content, category);
		}		
		
		public function info(content:Object, category:Object = null):void
		{
			log(Common.LOG_INFO, content, category);
		}
		
		public function debug(content:Object, category:Object = null):void
		{
			log(Common.LOG_DEBUG, content, category);
		}
		
		public function dispose():void
		{
			if (_channels && _channels.length > 0)
			{										
				for each (var logger:ILoggingChannel in _channels)
				{
					logger.dispose();
				}               
				
				_channels = null;
			}
		}
    }
}
