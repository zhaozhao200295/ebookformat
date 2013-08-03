/*
 * Copyright (c) 2009-2010 Florian Nuecke
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

package com.dtedu.trial.lang {

import com.dtedu.trial.utils.StringUtil;

import flash.geom.Point;
import flash.geom.Rectangle;


/**
 * Parses a string defining a position.
 * 
 * <p>
 * A position can be given either through absolute coordinates, where the
 * first number is interpreted as the x value and the second one as the y
 * value, or as a relative position, expressed through the names
 * <code>left, center, right</code> for the horizontal alignment and
 * <code>top, middle, bottom</code> for the vertical alignment.
 * </p>
 * 
 * <p>
 * Note that realitve alignment will be ignored unless sizes of container
 * and object are given.
 * </p>
 * 
 * <p>
 * When a relative definition is found before a number, the number is
 * assumed to stand for the other axis. If both axis are set (either through
 * relative or absolute coordinates) further numbers are ignored. Alignments
 * will be used, though, so the last alignment for a axis will be the one
 * actually used.
 * </p>
 * 
 * @param position
 *				the position string to parse.
 * @param defPos
 *				the default position to use, if no valid definition is
 *				found. Defaults to (0, 0).
 * @param container
 *				the sizes of container the object is in. Only the width and
 *				height is used.
 * @param object
 *				the sizes of the object itself. Only the width and height is
 *				used.
 * @return a point being the position for the element described in the
 *				position string.
 */
public function parsePosition(position:String, defPos:Point = null,
		container:Rectangle = null, object:Rectangle = null):Point
{
	var result:Point = new Point(0, 0);
	if (defPos) {
		result.x = defPos.x;
		result.y = defPos.y;
	}
	if (!position) {
		return result;
	}
	var positions:Array = position.split(" ");
	// Found entries.
	var xSet:Boolean = false;
	var ySet:Boolean = false;
	for each (var pos:String in positions) {
		// Trim.
		pos = StringUtil.trim(pos);
		// Skip blank ones.
		if (!pos) {
			continue;
		}
		switch (pos) {
			case "left":
				if (!container || !object) {
					continue;
				}
				result.x = 0;
				xSet = true;
				break;
			case "center":
				if (!container || !object) {
					continue;
				}
				result.x = (container.width - object.width) * 0.5;
				xSet = true;
				break;
			case "right":
				if (!container || !object) {
					continue;
				}
				result.x = container.width - object.width;
				xSet = true;
				break;
			case "top":
				if (!container || !object) {
					continue;
				}
				result.y = 0;
				ySet = true;
				break;
			case "middle":
				if (!container || !object) {
					continue;
				}
				result.y = (container.height - object.height) * 0.5;
				ySet = true;
				break;
			case "bottom":
				if (!container || !object) {
					continue;
				}
				result.y = container.height - object.height;
				ySet = true;
				break;
			default:
				// A number?
				if (pos != "0" && Number(pos) == 0) {
					// Invalid entry.
					continue;
				}
				if (!xSet) {
					result.x = Number(pos);
				} else if (!ySet) {
					result.y = Number(pos);
				}
				break;
		}
	}
	return result;
}

}