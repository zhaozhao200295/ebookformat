package com.dtedu.ebook.utils
{
	import com.dtedu.bytearray.display.ScaleBitmap;
	import com.dtedu.speak.controls.GButton;
	import com.dtedu.speak.core.ClassFactory;
	import com.dtedu.speak.interfaces.ISkin;
	import com.dtedu.speak.miscs.FilterConst;
	import com.dtedu.speak.miscs.GlobalStyle;
	import com.dtedu.speak.miscs.ResouceConst;
	import com.dtedu.speak.skins.Skin;
	import com.dtedu.trial.utils.Globals;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class ObjectCreate
	{
		public function ObjectCreate(){}
		
		/**
		 * 获取一个图片 
		 * @param cls Embed类嵌入的图片类
		 * @param x
		 * @param y
		 * @param parent
		 * @return 
		 * 
		 */		
		public static function createBitmap(cls:Class, x:int = 0,y:int = 0, parent:DisplayObjectContainer = null):Bitmap
		{
			var bitmap:Bitmap
			if(!cls)
			{
				bitmap = new Bitmap();
				bitmap.bitmapData = new BitmapData(10,10,false,0xffffff);
				return bitmap;
			}
			bitmap = ClassFactory.getBitmap(cls);
			bitmap.x = x;
			bitmap.y = y;
			bitmap.smoothing = true;
			if(parent)
			{
				parent.addChild(bitmap);
			}
			return bitmap;
		}
		
		
		/**
		 * 获取一个 ScaleBitmap
		 * @param cls Embed类嵌入的图片类
		 * @param x 
		 * @param y
		 * @param width
		 * @param height
		 * @param parent
		 * @param rect  当需要特殊区域时使用，否则请先在ResouceConst里面定义好，以免重复定义区域
		 * @return 
		 * 
		 */		
		public static function createScaleBitmap(cls:Class, x:int = 0, y:int = 0, width:int = 100,
											  height:int = 100, parent:DisplayObjectContainer = null,rect:Rectangle = null):ScaleBitmap
		{
			var bitmap:ScaleBitmap = ResouceConst.getScaleBitmap(cls,rect);
			bitmap.x = x;
			bitmap.y = y;
			bitmap.setSize(width,height);
			if(parent)
			{
				parent.addChild(bitmap);
			}
			return bitmap;
		}
		
		
		/**
		 * 创建一个textField 
		 * @param text
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param parent
		 * @param textFormat
		 * @return 
		 * 
		 */		
		public static function createTextField(text:String,width:int = 220,height:int = 20,textFormat:TextFormat = null,parent:DisplayObjectContainer = null,x:int = 0,y:int = 0):TextField
		{
			var textField:TextField = new TextField();
			textField.defaultTextFormat = textFormat?textFormat:GlobalStyle.textFormat_left;
			textField.x = x;
			textField.y = y;
			textField.text = text;
			textField.height = height;
			textField.width = width;
			textField.selectable = false;
			textField.filters = [FilterConst.textFilter];
			if(parent)
			{
				parent.addChild(textField);
			}
			
			return textField;
		}
		
		public static function fullSprite(value:Class):Sprite
		{
			var sp:Sprite = new Sprite();
			var bmp:Bitmap = ClassFactory.getBitmap(value);
			sp.graphics.beginBitmapFill(bmp.bitmapData);
			
			sp.graphics.clear();
			sp.graphics.beginBitmapFill(bmp.bitmapData, null, false, true);
			sp.graphics.drawRect(0, 0, bmp.width, bmp.height);
			sp.graphics.endFill();
			
			return sp;
		}
		
		public static function createIconButton(up:Class, over:Class, down:Class, parent:DisplayObjectContainer = null, x:int = 0, y:int = 0):GButton
		{
			var skin:ISkin = new Skin(fullSprite(up), fullSprite(over), fullSprite(down));
			return createSimpleButton(skin, parent, x, y);
		}
		
		public static function createSimpleButton(skinClass:ISkin, parent:DisplayObjectContainer = null, x:int = 0, y:int = 0):GButton
		{
			var btn:GButton = new GButton();
			btn.skinClass = skinClass;
			
			btn.hitTestState = btn.overState;
			
			btn.x = x;
			btn.y = y;
			
			if(parent)
			{
				parent.addChild(btn);
			}
			
			return btn;
		}
		
		/**
		 * 创建填充的矩形 
		 * @param color
		 * @param width
		 * @param height
		 * @param alpha
		 * @param parent
		 * @return 
		 * 
		 */		
		public static function createRect(_fillColor:uint = 0xCCFF00,_width:uint = 1,_height:uint = 1,_alpha:Number = 1,_parent:DisplayObjectContainer = null,_x:Number=0,_y:Number=0):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(_fillColor);
			sprite.graphics.drawRect(0,0,_width,_height);
			sprite.graphics.endFill();
			if(_parent)
			{
				_parent.addChild(sprite);
			}
			sprite.x = _x;
			sprite.y = _y;
			sprite.alpha = _alpha;
			sprite.cacheAsBitmap = true;
			return sprite;
		}
		
		
		
		/**
		 * 创建填充的圆形
		 * @param _fillColor
		 * @param _alpha
		 * @param _radius
		 * @param _parent
		 * @param _x
		 * @param _y
		 * @return 
		 * 
		 */		
		public static function createCircle(_fillColor:uint = 0xCCFF00,_alpha:Number = 1,_radius:int = 1,_parent:DisplayObjectContainer = null,_x:Number=0,_y:Number=0):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(_fillColor);
			sprite.graphics.drawCircle(0,0,_radius);
			sprite.graphics.endFill();
			if(_parent)
			{
				_parent.addChild(sprite);
			}
			sprite.x = _x;
			sprite.y = _y;
			sprite.alpha = _alpha;
			sprite.cacheAsBitmap = true;
			return sprite;
		}
		
		/**
		 * 2013.5.9 allen
		 * 创建填充三角形 
		 * @param _fillColor
		 * @param p1
		 * @param p2
		 * @param _radius
		 * @param _parent
		 * @param _x
		 * @param _y
		 * @return 
		 * 
		 */		
		public static function createTriangle(_fillColor:uint = 0xCCFF00,_alpha:Number = 1,p1:uint = 1,p2:uint = 1,_parent:DisplayObjectContainer = null,_x:Number=0,_y:Number=0):Sprite
		{
			var sprite :Sprite = new Sprite();
			sprite.graphics.beginFill(_fillColor);
			sprite.graphics.moveTo(p1,p2);
			sprite.graphics.lineTo(p1,500);
			sprite.graphics.lineTo(500,500);
			sprite.graphics.lineTo(p1,p2);
			if(_parent)
			{
				_parent.addChild(sprite);
			}
			sprite.x = _x;
			sprite.y = _y;
			sprite.alpha = _alpha;
			sprite.cacheAsBitmap = true;
			return sprite;
		}
	}
}