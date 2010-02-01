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
	
	public class RFBPixelFormat {
		
		public var bitsPerPixel:uint;
		public var depth:uint;
		public var bigEndian:Boolean;
		public var trueColour:Boolean;
		public var maxRed:uint;
		public var maxGreen:uint;
		public var maxBlue:uint;
		public var shiftRed:uint;
		public var shiftGreen:uint;
		public var shiftBlue:uint;
		public var bytesPerPixel:uint;
		
		public function RFBPixelFormat(param:Object) {	
			this.bitsPerPixel = param.bitsPerPixel;
			this.bytesPerPixel = bitsPerPixel/8;
			this.depth = param.depth;
			this.bigEndian = param.bigEndian;
			this.trueColour = param.trueColour;
			this.maxRed = param.maxRed;
			this.maxGreen = param.maxGreen;
			this.maxBlue = param.maxBlue;
			this.shiftRed = param.shiftRed;
			this.shiftGreen = param.shiftGreen;
			this.shiftBlue = param.shiftBlue;
		}
		
		public function getPixelDataSize():uint {
			throw new Error("Not implemented");
		}
		
		public function getPixelsDataSize(width:uint,height:uint):uint {
			throw new Error("Not implemented");
		}
		
		public function readPixels(width:uint,height:uint,inputStream:IDataInput):ByteArray {
			throw new Error("Not implemented");
		}
		
		public function readPixel(inputStream:IDataInput):uint {
			throw new Error("Not implemented");
		}
		
		public function updatePalette(colorMap:Array):void {
			throw new Error("Not implemented");
		}

	}
}