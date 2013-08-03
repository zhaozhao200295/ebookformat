/**
 *	ScaleBitmap
 *	
 * 	@version	1.1
 * 	@author 	Didier BRUN	-  http://www.bytearray.org
 * 	
 * 	@version	1.2.1
 * 	@author		Alexandre LEGOUT - http://blog.lalex.com
 *
 * 	@version	1.2.2
 * 	@author		Pleh
 *  
 * 	@version	1.2.3
 * 	@author		Vaclav Vancura - http://vaclav.vancura.org
 *  
 * 	@version	1.2.4
 * 	@author		Joel Stransky - http://stranskydesign.com
 * 	
 * 	@version	1.3
 * 	@author		Vaclav Vancura - http://vaclav.vancura.org
 *  
 * 	Project page : http://www.bytearray.org/?p=118
 */

package com.dtedu.bytearray.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;	

	
	
	public class ScaleBitmap extends Bitmap {

		
		
		protected var _originalBitmap:BitmapData;
		protected var _scale9Grid:Rectangle = null;
		protected var _originalWidth:Number;
		protected var _originalHeight:Number;
		protected var _scaleX:Number = 1;
		protected var _scaleY:Number = 1;

		
		
		/**
		 * Constructor.
		 * @param bmpData Source BitmapData
		 * @param pixelSnapping Pixel snapping (default 'auto')
		 * @param smoothing Smoothing
		 */
		function ScaleBitmap(bmpData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false) {
			super(bmpData, pixelSnapping, smoothing);
		
			if(bmpData != null) {
				_originalBitmap = bmpData.clone();
				_originalWidth = bmpData.width;
				_originalHeight = bmpData.height;
			}
		}

		
		
		/**
		 * Set ScaleBitmap position.
		 * @param w Width
		 * @param h Height
		 */
		public function setSize(w:Number, h:Number):void {
			if(_scale9Grid == null) {
				super.width = w;
				super.height = h;
			}
			else {
				w = Math.max(w, _originalBitmap.width - _scale9Grid.width);
				h = Math.max(h, _originalBitmap.height - _scale9Grid.height);
				
				resizeBitmap(w, h);
			}
		}

		
		
		/**
		 * Get original BitmapData.
		 * @return Original BitmapData
		 */
		public function getOriginalBitmapData():BitmapData {
			return _originalBitmap;
		}

		
		
		/**
		 * Set bitmapData.
		 * @param bmpData BitmapData
		 */
		override public function set bitmapData(bmpData:BitmapData):void {
			_originalBitmap = bmpData.clone();
			
			if(_scale9Grid != null) {
				if(!validGrid(_scale9Grid)) {
					_scale9Grid = null;
				}
				
				setSize(bmpData.width, bmpData.height);
			}
			else {
				assignBitmapData(_originalBitmap.clone());
			}
		} 

		
		
		/**
		 * Set width.
		 * @param w Width
		 */
		override public function set width(w:Number):void {
			if(w != width) {
				setSize(w, height);
			}
		}

		
		
		/**
		 * Set height.
		 * @param h Height
		 */
		override public function set height(h:Number):void {
			if(h != height) {
				setSize(width, h);
			}
		}

		
		
		/**
		 * Get scale9Grid.
		 * @return Scale9 grid Rectangle
		 */
		override public function get scale9Grid():Rectangle {
			return _scale9Grid;
		}

		
		
		/**
		 * Set scale9 grid.
		 * @param r Scale9 grid Rectangle
		 */
		override public function set scale9Grid(r:Rectangle):void {
			// Check if the given grid is different from the current one
			if((_scale9Grid == null && r != null) || (_scale9Grid != null && !_scale9Grid.equals(r))) {
				if(r == null) {
					// If deleting scalee9Grid, restore the original bitmap
					// then resize it (streched) to the previously set dimensions
					var currentWidth:Number = width;
					var currentHeight:Number = height;
					
					_scale9Grid = null;
					
					assignBitmapData(_originalBitmap.clone());
					setSize(currentWidth, currentHeight);
				}
				else {
					if(!validGrid(r)) {
						throw (new Error("#001 - The _scale9Grid does not match the original BitmapData"));
						return;
					}
					
					_scale9Grid = r.clone();
					resizeBitmap(width, height);
					
					scaleX = 1;
					scaleY = 1;
				}
			}
		}

		
		
		/**
		 * Get scaleX value.
		 * @return scaleX
		 */
		override public function get scaleX():Number {
			return _scaleX;
		}

		
		
		/**
		 * Set scaleX value.
		 * @param value scaleX value
		 */
		override public function set scaleX(value:Number):void {
			if(value != _scaleX) {
				_scaleX = value;
				setSize(_originalWidth * value, height);
			}
		}

		
		
		/**
		 * Get scaleY value.
		 * @return scaleY
		 */
		override public function get scaleY():Number { 
			return _scaleY;
		}

		
		
		/**
		 * Set scaleY value.
		 * @param value scaleY value
		 */
		override public function set scaleY(value:Number):void {
			if(value != scaleY) {
				_scaleY = value;
				setSize(width, _originalHeight * value);
			}
		}

		
		
		/**
		 * Resize bitmap.
		 * @param w Width
		 * @param h Height
		 */
		protected function resizeBitmap(w:Number, h:Number):void {
			var bmpData:BitmapData = new BitmapData(w, h, true, 0x00000000);
			
			var rows:Array = [0, _scale9Grid.top, _scale9Grid.bottom, _originalBitmap.height];
			var cols:Array = [0, _scale9Grid.left, _scale9Grid.right, _originalBitmap.width];
			
			var dRows:Array = [0, _scale9Grid.top, h - (_originalBitmap.height - _scale9Grid.bottom), h];
			var dCols:Array = [0, _scale9Grid.left, w - (_originalBitmap.width - _scale9Grid.right), w];

			var origin:Rectangle;
			var draw:Rectangle;
			var mat:Matrix = new Matrix();

			for(var cx:int = 0; cx < 3;cx++) {
				for(var cy:int = 0; cy < 3;cy++) {
					origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
					draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
					
					mat.identity();
					
					mat.a = draw.width / origin.width;
					mat.d = draw.height / origin.height;
					mat.tx = draw.x - origin.x * mat.a;
					mat.ty = draw.y - origin.y * mat.d;
					
					bmpData.draw(_originalBitmap, mat, null, null, draw, smoothing);
				}
			}
			
			assignBitmapData(bmpData);
		}
		
		
		
		private function assignBitmapData(bmp:BitmapData):void {
			if(super.bitmapData != null) {
				super.bitmapData.dispose();
			}
			
			super.bitmapData = bmp;
		}

		
		
		private function validGrid(r:Rectangle):Boolean {
			return r.right <= _originalBitmap.width && r.bottom <= _originalBitmap.height;
		}
	}
}