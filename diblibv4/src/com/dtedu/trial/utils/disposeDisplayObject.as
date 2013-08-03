/*
 * Copyright (c) 2007-2010 Florian Nuecke
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

package com.dtedu.trial.utils 
{

import com.dtedu.trial.interfaces.IDisposable;

import com.dtedu.bytearray.display.ScaleBitmap;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.Shape;




/**
 * Clean up a display object to make it ready for garbage collection.
 * 
 * <p>
 * If the display object is a container, disposeDisplayObjectContainer is called
 * on the object automatically, meaning this will trigger a recursive disposal
 * of a whole branch of the scene graph, starting with the given node.
 * </p>
 * 
 * @param object
 *				the object to clean up.
 * @param disposeBitmapData
 *				whether to dispose bitmap data of found Bitmap objects. This
 *				should not be used when having Bitmaps in the scene graph that
 *				share their bitmap data with other bitmaps.
 * @param disposeObject
 *				whether to call the dispose() method on the object if it
 *				implements the IDisposable interface. Can be called with false
 *				by classes extending DisplayObject which use this function to
 *				clean themselves up without causing infinite recursion.
 */
public function disposeDisplayObject(displayObject:Object,
		disposeBitmapData:Boolean = false, disposeObject:Boolean = true):void
{
	if (!displayObject || !(displayObject is DisplayObject)) {
		return;
	}
	
	// Cast once.
	var object:DisplayObject = DisplayObject(displayObject);
	
	// Remove from parent.
	if (object.parent && // has parent?
			!(object.parent is Loader) && // cannot remove from loaders.
			object.parent.contains(object)) // parent may have overrides.
	{ 
		object.parent.removeChild(object);
	}
	
	// Basics.
	object.accessibilityProperties = null;
	object.cacheAsBitmap = false;
	object.filters = null;
	object.opaqueBackground = null;
	object.scale9Grid = null;
	object.scrollRect = null;
	
	// Kill mask. This needs special behavior, as interestingly, setting a mask
	// to an object tells the masking object to return the object it masks via
	// its .mask property... so this would lead to endless loops here.
	var mask:DisplayObject = object.mask;
	object.mask = null;
	disposeDisplayObject(mask);
	
	// Tweens.
	//TODO:
	//stopTweensFor(object);
	
	// Interactive object?
	if (object is InteractiveObject) {
		try {
			InteractiveObject(object).accessibilityImplementation = null;
			InteractiveObject(object).contextMenu = null;
			InteractiveObject(object).focusRect = null;
		} catch (er:Error) {}
	}
	
	// Shape?
	if (object is Shape) {
		Shape(object).graphics.clear();
	}
	
	// Bitmap?
	if (disposeBitmapData && object is Bitmap){
		Bitmap(object).bitmapData && Bitmap(object).bitmapData.dispose();
		if (object is ScaleBitmap) {
			ScaleBitmap(object).getOriginalBitmapData().dispose();
		} else {
			Bitmap(object).bitmapData = null;
		}
	}
	
	// Loader or Container?
	if (object is Loader) {
		// Try to use the unloadAndStop function if available (FP10).
		if (object.hasOwnProperty("unloadAndStop") &&
				object["unloadAndStop"] is Function)
		{
			object["unloadAndStop"]();
		} else {
			Loader(object).unload();
		}
	} else if (object is DisplayObjectContainer && !(object is Loader)){
		// Not a Loader.
		while (DisplayObjectContainer(object).numChildren > 0) {
			disposeDisplayObject(DisplayObjectContainer(object).
					removeChildAt(0), disposeBitmapData);
		}
	}
	
	// Disposable?
	if (disposeObject && (object is IDisposable)) {
		IDisposable(object).dispose();
	}
}
}
