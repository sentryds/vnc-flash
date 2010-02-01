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
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBPixelFormatGradient extends RFBPixelFormat {
		
		private static var logger:ILogger = Log.getLogger("RFBPixelFormatGradient");
		
		private var pixelFormat:RFBPixelFormat;
		
		public function RFBPixelFormatGradient(pixelFormat:RFBPixelFormat) {
			super({
				bitsPerPixel: pixelFormat.bitsPerPixel,
			    depth: pixelFormat.depth,
			    bigEndian: pixelFormat.bigEndian,
			    trueColour: pixelFormat.trueColour,
			    maxRed: pixelFormat.maxRed,
			    maxGreen: pixelFormat.maxGreen,
			    maxBlue: pixelFormat.maxBlue,
			    shiftRed: pixelFormat.shiftRed,
			    shiftGreen: pixelFormat.shiftGreen,
			    shiftBlue: pixelFormat.shiftBlue
			});
			
			this.pixelFormat = pixelFormat;
		}
		
		override public function getPixelDataSize():uint {
			return pixelFormat.getPixelDataSize();
		}
		
		override public function getPixelsDataSize(width:uint,height:uint):uint {
			return pixelFormat.getPixelsDataSize(width,height);
		}
		
		override public function readPixels(width:uint,height:uint,inputStream:IDataInput):ByteArray {
			var pixels:ByteArray = pixelFormat.readPixels(width,height,inputStream);
			
			var pos:int = 0;
			var rowSize:int = width*4;
			
			for (var y:int=0;y<height;y++) {
				for (var x:int=0;x<width;x++) {
					pos++;
					for (var c:int=0;c<3;c++) {
						var est:int = (y-1 < 0 ? 0 : pixels[pos-rowSize]) - ((y-1 < 0 || x-1 < 0) ? 0 : pixels[pos-rowSize-4]) + (x-1 < 0 ? 0 : pixels[pos-4]);
						if (est<0) est=0;
						if (est>255) est=255;
						pixels[pos] += est;
						pos++;
					}
				}
			}
			
			return pixels;
		}
		
		override public function readPixel(inputStream:IDataInput):uint {
			return pixelFormat.readPixel(inputStream);
		}
	}
}