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
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBPixelFormat24bpp extends RFBPixelFormat {
		private static var logger:ILogger = Log.getLogger("RFBPixelFormat24bpp");
		
		public function RFBPixelFormat24bpp() {
			super({
				bitsPerPixel: 24,
			    depth: 24,
			    bigEndian: true,
			    trueColour: true,
			    maxRed: 255,
			    maxGreen: 255,
			    maxBlue: 255,
			    shiftRed: 16,
			    shiftGreen: 8,
			    shiftBlue: 0
			});
		}
		
		override public function getPixelDataSize():uint {
			return 3;
		}
		
		override public function getPixelsDataSize(height:uint,width:uint):uint {
			return height*width*3;
		}
		
		private var rectBitmapData1:BitmapData = new BitmapData(3,1000,false);
		private var rectBitmapData2:BitmapData = new BitmapData(3,1000,false);
		private var rectBitmapData3:BitmapData = new BitmapData(3,1000,false);
		private var rectBitmapData4:BitmapData = new BitmapData(3,1000,false);
		private var rectBitmapData:BitmapData = new BitmapData(4,1000,false);
		
		override public function readPixels(height:uint,width:uint,inputStream:IDataInput):ByteArray {
			var data:ByteArray = new ByteArray();
			var pixels:ByteArray = new ByteArray();
			var i:int;
			
			data.length = height*width*3 + 19;
			inputStream.readBytes(data, 1, height*width*3);
			data.position = height*width*3 + 1;
			data.writeInt(0);
			data.writeInt(0);
			data.writeInt(0);
			data.writeInt(0);
			data.writeShort(0);
			
			var pixelsTotal:int = height*width;
			pixels.length = pixelsTotal * 4;
			
			var pos:int = 0;
			while (pixelsTotal > pos/3) {
				var h:int = Math.min(1000,Math.ceil((pixelsTotal - pos/3)/4));
				
				var line1:Rectangle = new Rectangle(0,0,1,h);
				var line2:Rectangle = new Rectangle(1,0,1,h);
				var line3:Rectangle = new Rectangle(2,0,1,h);
				var line4:Rectangle = new Rectangle(3,0,1,h);
				var rect:Rectangle = new Rectangle(0,0,3,h);
				var rectF:Rectangle = new Rectangle(0,0,4,h);
				
				//logger.info(h+' '+pos+' '+data.length+' '+pixelsTotal);
				
				data.position = pos;
				rectBitmapData1.setPixels(rect,data);
				data.position = pos + 3;
				rectBitmapData2.setPixels(rect,data);
				data.position = pos + 6;
				rectBitmapData3.setPixels(rect,data);
				data.position = pos + 9;
				rectBitmapData4.setPixels(rect,data);
				
				var line1Pixels:ByteArray = rectBitmapData1.getPixels(line1);
				var line2Pixels:ByteArray = rectBitmapData2.getPixels(line1);
				var line3Pixels:ByteArray = rectBitmapData3.getPixels(line1);
				var line4Pixels:ByteArray = rectBitmapData4.getPixels(line1);
				line1Pixels.position = 0;
				line2Pixels.position = 0;
				line3Pixels.position = 0;
				line4Pixels.position = 0;
				
				/*logger.info(h+' '+line2Pixels.length);
				logger.info(h+' '+line3Pixels.length);*/
				
				rectBitmapData.setPixels(line1, line1Pixels);
				rectBitmapData.setPixels(line2, line2Pixels);
				rectBitmapData.setPixels(line3, line3Pixels);
				rectBitmapData.setPixels(line4, line4Pixels);
					
				pixels.writeBytes(rectBitmapData.getPixels(rectF));
				
				pos += 12*h;
			}
			
			pixels.position = 0;
			
			return pixels;
		}
		
		override public function readPixel(inputStream:IDataInput):uint {
			return 0xFF000000
				| (inputStream.readUnsignedByte() << 16)
				| (inputStream.readUnsignedByte() << 8)
				| (inputStream.readUnsignedByte());
		}
	}
}