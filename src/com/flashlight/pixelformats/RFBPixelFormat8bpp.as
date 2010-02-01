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
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBPixelFormat8bpp extends RFBPixelFormat {
		
		private static var logger:ILogger = Log.getLogger("RFBPixelFormat8bpp");
		private var palette:Array = new Array();	
		private var paletteNull:Array = new Array();
		
		private var rectBitmapData:BitmapData = new BitmapData(4,1000,false);
		
		public function RFBPixelFormat8bpp(palette:Array = null) {
			super({
				bitsPerPixel: 8,
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
			return 1;
		}
		
		override public function getPixelsDataSize(width:uint,height:uint):uint {
			return height*width;
		}
		
		override public function readPixels(width:uint,height:uint,inputStream:IDataInput):ByteArray {
			var data:ByteArray = new ByteArray();
			var pixels:ByteArray = new ByteArray();
			var i:int;
			
			
			data.length = height*width + 9;
			inputStream.readBytes(data, 1, width*height);
			data.position = height*width + 1;
			data.writeInt(0);
			data.writeInt(0);
			
			var pos:int = 1;
			while (width*height > pos) {
				var h:int = Math.min(1000,1+(width*height-pos)/4);
				
				var line1:Rectangle = new Rectangle(0,0,1,h);
				var line2:Rectangle = new Rectangle(1,0,1,h);
				var line3:Rectangle = new Rectangle(2,0,1,h);
				var line4:Rectangle = new Rectangle(3,0,1,h);
				var rect:Rectangle = new Rectangle(0,0,4,h);
				data.position = pos-1;
				rectBitmapData.setPixels(line1,data);
				data.position = pos;
				rectBitmapData.setPixels(line2,data);
				data.position = pos+1;
				rectBitmapData.setPixels(line3,data);
				data.position = pos+2;
				rectBitmapData.setPixels(line4,data);
				
				rectBitmapData.paletteMap(rectBitmapData,rect,new Point(0,0),palette,paletteNull,paletteNull);
				
				pixels.writeBytes(rectBitmapData.getPixels(rect));
				
				pos += 4*h;
			}
			
			pixels.position = 0;
			
			return pixels;
		}
		
		override public function readPixel(inputStream:IDataInput):uint {
			return palette[inputStream.readUnsignedByte()];
		}
		
		override public function updatePalette(paletteUpdate:Array):void {
			for (var i:String in paletteUpdate) {
				palette[i] = paletteUpdate[i];
			}
		}
	}
}