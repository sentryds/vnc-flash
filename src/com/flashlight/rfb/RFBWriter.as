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

package com.flashlight.rfb
{
	import com.flashlight.pixelformats.RFBPixelFormat;
	import com.flashlight.utils.IDataBufferedOutput;
	import com.flashlight.vnc.VNCConst;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBWriter {
		private static var logger:ILogger = Log.getLogger("RFBWriter");
		
		private var rfbMajorVersion:Number;
		private var rfbMinorVersion:Number;
		private var outputStream:IDataBufferedOutput;
		
		public function RFBWriter(outputStream:IDataBufferedOutput, rfbMajorVersion:Number, rfbMinorVersion:Number) {
			this.outputStream = outputStream;
			this.rfbMajorVersion = rfbMajorVersion;
			this.rfbMinorVersion = rfbMinorVersion;
		}
		
		public function writeRFBVersion(rfbMajorVersion:Number, rfbMinorVersion:Number):void {
			var majorS:String = (rfbMajorVersion < 100 ? '0' : '') + (rfbMajorVersion < 10 ? '0' : '') + rfbMajorVersion;
			var minorS:String = (rfbMinorVersion < 100 ? '0' : '') + (rfbMinorVersion < 10 ? '0' : '') + rfbMinorVersion;
			outputStream.writeUTFBytes("RFB "+majorS+"."+minorS+"\n");
			
			outputStream.flush();
		}
		
		public function writeSecurityType(securityType:uint):void {
			outputStream.writeByte(securityType);
			outputStream.flush();
		}
		
		public function writeSecurityVNCAuthChallenge(challenge:ByteArray):void {
			outputStream.writeBytes(challenge,0,16);
			outputStream.flush();
		}
		
		public function writeClientInit(shareConnection:Boolean):void {
			outputStream.writeByte(shareConnection ? 1 : 0);
			outputStream.flush();
		}
		
		public function writeSetPixelFormat(pixelFormat:RFBPixelFormat):void {
			outputStream.writeByte(VNCConst.CLIENT_SET_PIXELFORMAT);
			outputStream.writeByte(0);
			outputStream.writeByte(0);
			outputStream.writeByte(0);
			
			outputStream.writeByte(pixelFormat.bitsPerPixel);
			outputStream.writeByte(pixelFormat.depth);
			outputStream.writeByte(pixelFormat.bigEndian ? 1 : 0);
			outputStream.writeByte(pixelFormat.trueColour ? 1 : 0);
			outputStream.writeShort(pixelFormat.maxRed);
			outputStream.writeShort(pixelFormat.maxGreen);
			outputStream.writeShort(pixelFormat.maxBlue);
			outputStream.writeByte(pixelFormat.shiftRed);
			outputStream.writeByte(pixelFormat.shiftGreen);
			outputStream.writeByte(pixelFormat.shiftBlue);
			outputStream.writeByte(0);
			outputStream.writeByte(0);
			outputStream.writeByte(0);
			
			outputStream.flush();
		}
		
		public function writeSetEncodings(encodings:Array):void {
			outputStream.writeByte(VNCConst.CLIENT_SET_ENCODINGS);
			outputStream.writeByte(0);
			
			outputStream.writeShort(encodings.length);
			for each (var encoding:uint in encodings) {
				outputStream.writeUnsignedInt(encoding);
			}
			
			outputStream.flush();
		}
		
		public function writeFramebufferUpdateRequest(incremental:Boolean, rectangle:Rectangle):void {
			outputStream.writeByte(VNCConst.CLIENT_FRAMEBUFFER_UPDATE);
			
			outputStream.writeByte(incremental ? 1 : 0);
			outputStream.writeShort(rectangle.x);
			outputStream.writeShort(rectangle.y);
			outputStream.writeShort(rectangle.width);
			outputStream.writeShort(rectangle.height);
			
			outputStream.flush();
		}
		
		public function writeKeyEvent(keyDown:Boolean, keyCode:uint, flush:Boolean = true):void {
			outputStream.writeByte(VNCConst.CLIENT_KEY_EVENT);
			
			outputStream.writeByte(keyDown ? 1 : 0);
			outputStream.writeByte(0);
			outputStream.writeByte(0);
			outputStream.writeUnsignedInt(keyCode);
			
			if (flush) outputStream.flush();
		}
		
		public function writePointerEvent(buttonMask:uint, position:Point):void {
			outputStream.writeByte(VNCConst.CLIENT_POINTER_EVENT);
			
			outputStream.writeByte(buttonMask);
			outputStream.writeShort(position.x);
			outputStream.writeShort(position.y);
			
			outputStream.flush();
		}

	}
}