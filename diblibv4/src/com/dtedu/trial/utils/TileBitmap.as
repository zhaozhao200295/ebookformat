/*
 * Copyright (c) 2010 Florian Nuecke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.dtedu.trial.utils {
import com.dtedu.trial.interfaces.IDisposable;

import flash.display.BitmapData;
import flash.display.Shape;

/**
 * Utility Bitmap wrapper that takes another bitmap and renders it in either
 * tiled or normal (stretched) mode).
 * 
 * @author fnuecke
 */
public class TileBitmap extends Shape implements IDisposable {
	/**
	 * The underlying bitmapdata this element should paint.
	 */
	private var bitmapData_:BitmapData;
	
	/**
	 * Smooth when painting bitmapdata?
	 */
	private var smoothing_:Boolean;
	
	/**
	 * Tile the image?
	 */
	private var tile_:Boolean;
	
	/**
	 * Creates a new tile bitmap, based on the given BitmapData.
	 * 
	 * @param bitmapData
	 *				the BitmapData to draw through this object.
	 * @param tile
	 *				whether to tile the BitmapData.
	 * @param smoothing
	 *				whether to smooth the output.
	 */
	public function TileBitmap(bitmapData:BitmapData, tile:Boolean = false,
			smoothing:Boolean = false)
	{
		this.bitmapData_ = bitmapData.clone();
		this.tile_ = tile;
		this.smoothing_ = smoothing;
		redraw();
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose():void {
		if (bitmapData_) {
			bitmapData_.dispose();
			bitmapData_ = null;
		}
	}
	
	/**
	 * Whether to smooth the output.
	 */
	public function get smoothing():Boolean {
		return smoothing_;
	}
	
	/**
	 * @private
	 */
	public function set smoothing(newValue:Boolean):void {
		if (newValue != smoothing_) {
			smoothing_ = newValue;
			if (tile_) {
				resize(width, height);
			} else {
				redraw();
			}
		}
	}
	
	/**
	 * Whether to tile the output.
	 */
	public function get tile():Boolean {
		return tile_;
	}
	
	/**
	 * @private
	 */
	public function set tile(newValue:Boolean):void {
		if (newValue != tile_) {
			tile_ = newValue;
			var w:Number = width;
			var h:Number = height;
			super.scaleX = 1;
			super.scaleY = 1;
			if (tile_) {
				resize(w, h);
			} else {
				redraw();
				super.width = w;
				super.height = h;
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override public function set width(value:Number):void {
		if (value != width) {
			resize(value, height);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override public function set height(value:Number):void {
		if (value != height) {
			resize(width, value);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override public function get scaleX():Number {
		return width / bitmapData_.width;
	}
	
	/**
	 * @private
	 */
	override public function set scaleX(value:Number):void {
		if (value != scaleX) {
			resize(bitmapData_.width * value, height);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override public function get scaleY():Number {
		return height / bitmapData_.height;
	}
	
	/**
	 * @private
	 */
	override public function set scaleY(value:Number):void {
		if (value != scaleY) {
			resize(width, bitmapData_.height * value);
		}
	}
	
	/**
	 * Update tiled image data.
	 */
	private function resize(width:Number, height:Number):void {
		if (tile_) {
			graphics.clear();
			graphics.beginBitmapFill(bitmapData_, null, true, smoothing_);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		} else {
			super.width = width;
			super.height = height;
		}
	}
	
	/**
	 * Simply paint bitmapdata at original size.
	 */
	private function redraw():void {
		graphics.clear();
		graphics.beginBitmapFill(bitmapData_, null, false, smoothing_);
		graphics.drawRect(0, 0, bitmapData_.width, bitmapData_.height);
		graphics.endFill();
	}
	
}
}
