/*

	Copyright (C) 2009 Marco Fucci

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation;
	either version 2 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License along with this program;
	if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

	Contact : mfucci@gmail.com
	
*/

package com.flashlight.encoding
{
	import com.flashlight.pixelformats.RFBPixelFormat;
	import com.flashlight.rfb.RFBReaderListener;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class EncodingCursor implements Encoding {
		private var logger:ILogger = Log.getLogger("EncodingCursor");
		
		public function getReader(inputStream:IDataInput, listener:RFBReaderListener, rectangle:Rectangle, pixelFormat:RFBPixelFormat):Object {
			var maskDataSize:int = Math.floor((rectangle.width + 7)/8)*rectangle.height;		
			return {
				name:'EncodingCursor',
				bytesNeeded: pixelFormat.getPixelsDataSize(rectangle.width, rectangle.height) + maskDataSize,
				read: function():Object {
					var pixels:ByteArray = pixelFormat.readPixels(rectangle.width, rectangle.height, inputStream);
					var cursorShape:BitmapData = new BitmapData(rectangle.width, rectangle.height, true);
					var hotSpot:Point = new Point(rectangle.x,rectangle.y);
					
					var maskData:ByteArray = new ByteArray();
					inputStream.readBytes(maskData,0,maskDataSize);
					
					var pixelsPos:int = 0;
					var maskDataPos:int = 0;
					
					for (var y:int=0; y<rectangle.height; y++) {
						var bitMask:int = 128;
						var byte:int = maskData[maskDataPos++];
						for (var x:int=0; x<rectangle.width; x++) {
							if (bitMask == 0) {
								bitMask = 128;
								byte = maskData[maskDataPos++];
							}
							if (pixelFormat.bitsPerPixel == 32) {
								if ((byte & bitMask) != 0) {
									if (pixels[pixelsPos]==0) pixels[pixelsPos] = 0xFF;
								}
							} else {
								pixels[pixelsPos] = (byte & bitMask) != 0 ? 0xFF : 0;
							}
							pixelsPos += 4;
							bitMask = bitMask >> 1
						}
					}
					
					cursorShape.setPixels(cursorShape.rect,pixels);
					
					listener.onChangeCursorShape(cursorShape,hotSpot);
					
					return null;
				}
			}
		}

	}
}