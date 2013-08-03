/**
 * @date 2012-10-16 上午9:31:40
 * @author Jeff
 *
 */

package com.dtedu.trial.utils
{

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	

	public class DisplayObjectUtil
	{
		public function DisplayObjectUtil()
		{
		}
		
		/**
		 * 给显示对象着色 
		 * @param obj
		 * @param _color
		 * @param _alpha
		 * 
		 */		
		public static function setColor(obj:DisplayObject, _color:uint = 0xdddddd, _alpha:Number = 1):void 
		{
			if(obj)
			{
				//var color:Color = new Color();
				//color.setTint(_color, _alpha);
				//obj.transform.colorTransform = color;

			}
			
		}
		/**
		 * 设置显示对象是否可用  
		 * @param obj
		 * @param value
		 * @param _alpha
		 * 
		 */		
		public static function setEnabled(obj:DisplayObjectContainer,value:Boolean,_alpha:Number=1):void
		{
			if(obj)
			{
				obj.mouseEnabled = value;
				obj.mouseChildren = value;
				obj.alpha = _alpha;
			}
			
		}
		
		/**
		 * 播放影片，包括播放影片里的声音和字幕 
		 * @param obj
		 * 
		 */		
		public static function playMovie(obj:DisplayObjectContainer):void
		{
			if(obj)
			{
				if(obj is MovieClip)
				{
					(obj as MovieClip).play();
				}
				var count:int = obj.numChildren;
				var i:int;
				var child:DisplayObject;
				for(i=0;i<count;i++)
				{
					child = obj.getChildAt(i) as DisplayObject;
					if(child is MovieClip && StrUtil.isContainStr(child.name,"s_","subtitle_"))
					{
						(child as MovieClip).play();
					}
				}
			}
		}
		
		/**
		 * 从某帧开始播放影片，包括影片的字幕  
		 * @param obj
		 * @param frame
		 * 
		 */		
		public static function playMovieAt(obj:DisplayObjectContainer,frame:int=1):void
		{
			if(obj)
			{
				if(obj is MovieClip)
				{
					(obj as MovieClip).gotoAndPlay(frame);
				}
				var count:int = obj.numChildren;
				var i:int;
				var child:DisplayObject;
				for(i=0;i<count;i++)
				{
					child = obj.getChildAt(i) as DisplayObject;
					if(child is MovieClip && StrUtil.isContainStr(child.name,"s_","subtitle_"))
					{
						(child as MovieClip).gotoAndPlay(frame);
					}
				}
			}
		}
		
		/**
		 * 停止影片，包括停止影片里的声音和字幕 
		 * @param obj
		 * 
		 */		
		public static function stopMovie(obj:DisplayObjectContainer):void
		{
			if(obj)
			{
				if(obj is MovieClip)
				{
					(obj as MovieClip).stop();
				}
				var count:int = obj.numChildren;
				var i:int;
				var child:DisplayObject;
				for(i=0;i<count;i++)
				{
					child = obj.getChildAt(i) as DisplayObject;
					if(child is MovieClip && StrUtil.isContainStr(child.name,"s_","subtitle_"))
					{
						(child as MovieClip).stop();
					}
				}
			}
		}
	
		/**
		 * 把影片停在某帧，包括影片的声音和字幕 
		 * @param obj 影片
		 * @param int 停的帧
		 * 
		 */		
		public static function stopMovieAt(obj:DisplayObjectContainer,frame:int=1):void
		{
			if(obj)
			{
				if(obj is MovieClip)
				{
					(obj as MovieClip).gotoAndStop(frame);
				}
				var count:int = obj.numChildren;
				var i:int;
				var child:DisplayObject;
				for(i=0;i<count;i++)
				{
					child = obj.getChildAt(i) as DisplayObject;
					if(child is MovieClip && StrUtil.isContainStr(child.name,"subtitle_"))
					{
						(child as MovieClip).gotoAndStop(frame);
					}
				}
			}
		}
		
		public static function stopDisplayObjectContainer(obj:DisplayObjectContainer):void
		{
			if(obj)
			{
				
				if(obj is MovieClip)
				{
					(obj as MovieClip).stop();
				}
				var count:int = obj.numChildren;
				var i:int;
				var child:DisplayObject;
				for(i=0;i<count;i++)
				{
					child = obj.getChildAt(i) as DisplayObject;
					if(child is DisplayObjectContainer)
					{
						stopDisplayObjectContainer(child as DisplayObjectContainer);
					}
				}
			}
		}
	}
}