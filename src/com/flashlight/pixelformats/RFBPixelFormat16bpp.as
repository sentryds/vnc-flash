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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.getTimer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBPixelFormat16bpp extends RFBPixelFormat {
		
		private static var logger:ILogger = Log.getLogger("RFBPixelFormat16bpp");
		private var palette1:Array = new Array();
		private var palette2:Array = new Array();
		private var palette3:Array = new Array();	
		
		private var rectBitmapData:BitmapData = new BitmapData(2,1000,false);
		
		public function RFBPixelFormat16bpp() {
			super({
				bitsPerPixel: 16,
			    depth: 16,
			    bigEndian: true,
			    trueColour: true,
			    maxRed: 31,
			    maxGreen: 31,
			    maxBlue: 63,
			    shiftRed: 11,
			    shiftGreen: 6,
			    shiftBlue: 0
			});
			
		 	for (var i:int=0;i<256;i++) {
		 		var redComp:int = i & 0xF8;
		 		var greenComp1:int = i & 0x07;
		 		var greenComp2:int = i & 0xA0;
		 		var blueComp:int = i & 0x3F;
		 		
		 		palette1[i] = ((redComp | (redComp >> 5)) << 16) | ((greenComp1 << 5 | greenComp1) << 8);
		 		palette2[i] = (greenComp2 >> 3) | (blueComp << 2 | blueComp >> 4);
		 	}
		}
		
		override public function getPixelDataSize():uint {
			return 2;
		}
		
		override public function getPixelsDataSize(width:uint,height:uint):uint {
			return height*width*2;
		}
		
		override public function readPixels(width:uint,height:uint,inputStream:IDataInput):ByteArray {
			var data:ByteArray = new ByteArray();
			var pixels:ByteArray = new ByteArray();
			var i:int;
			
			data.length = height*width*2 + 6;
			inputStream.readBytes(data, 2, height*width*2);
			data.position = height*width*2 + 2;
			data.writeInt(0);
			
			var pixelsSize:int = height*width*4;
			pixels.length = pixelsSize;
			
			var pos:int = 2;
			while (pixelsSize > 2*pos) {
				var h:int = Math.min(1000,1+(pixelsSize-2*pos)/8);
				
				var line1:Rectangle = new Rectangle(0,0,1,h);
				var line2:Rectangle = new Rectangle(1,0,1,h);
				var rect:Rectangle = new Rectangle(0,0,2,h);
				data.position = pos-2;
				rectBitmapData.setPixels(line1,data);
				data.position = pos;
				rectBitmapData.setPixels(line2,data);
				
				rectBitmapData.paletteMap(rectBitmapData,rect,new Point(0,0),palette3,palette1,palette2);
				
				pixels.writeBytes(rectBitmapData.getPixels(rect));
				
				pos += 4*h;
			}
			
			pixels.position = 0;
			
			return pixels;
		}
		
		override public function readPixel(inputStream:IDataInput):uint {
			return palette1[inputStream.readUnsignedByte()] + palette2[inputStream.readUnsignedByte()];
		}
	}
}