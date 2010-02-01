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

package com.flashlight.pixelformats {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBPixelFormat1bpp extends RFBPixelFormat {
		
		private static var logger:ILogger = Log.getLogger("RFBPixelFormat1bpp");
		private var palette:Array = new Array();	
		
		public function RFBPixelFormat1bpp(palette:Array = null) {
			super({
				bitsPerPixel: 1,
			    depth: 24,
			    bigEndian: true,
			    trueColour: false,
			    maxRed: 255,
			    maxGreen: 255,
			    maxBlue: 255,
			    shiftRed: 16,
			    shiftGreen: 8,
			    shiftBlue: 0
			});
			if (palette) updatePalette(palette);
		}
		
		override public function getPixelDataSize():uint {
			throw new Error("Cannot read just one pixel");
		}
		
		override public function getPixelsDataSize(width:uint,height:uint):uint {
			return height*Math.ceil(width / 8);
		}
		
		override public function readPixels(width:uint,height:uint,inputStream:IDataInput):ByteArray {
			var data:ByteArray = new ByteArray();
			var pixels:ByteArray = new ByteArray();
			
			pixels.length = height*width*4;
			inputStream.readBytes(data, 0, height*Math.ceil(width / 8));
			
			var dataPos:int = 0;
			for (var y:int=0; y<height; y++) {
				var bitMask:int = 128;
				var byte:int = data[dataPos++];
				for (var x:int=0; x<width; x++) {
					if (bitMask == 0) {
						bitMask = 128;
						byte = data[dataPos++];
					}
					pixels.writeUnsignedInt(palette[byte & bitMask ? 1 : 0]);
					bitMask = bitMask >> 1
				}
			}
			
			pixels.position = 0;
			
			return pixels;
		}
		
		override public function readPixel(inputStream:IDataInput):uint {
			throw new Error("Cannot read just one pixel");
		}
		
		override public function updatePalette(paletteUpdate:Array):void {
			for (var i:String in paletteUpdate) {
				palette[i] = paletteUpdate[i];
			}
		}
	}
}