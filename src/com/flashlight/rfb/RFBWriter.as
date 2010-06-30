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
	import mx.core.FlexGlobals
	import mx.utils.StringUtil;
	
	public class RFBWriter {
		private static var logger:ILogger = Log.getLogger("RFBWriter");
		
		private var rfbMajorVersion:Number;
		private var rfbMinorVersion:Number;
		private var useWS:Boolean;
		private var rawOutputStream:IDataBufferedOutput;
		private var outputStream:ByteArray;

		private var wsHandshake:String = 'GET / HTTP/1.1\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\nHost: {0}\r\nOrigin: {1}\r\nSec-WebSocket-Key1: {2}\r\nSec-WebSocket-Key2: {3}\r\n\r\n';
		
		public function RFBWriter(outputStream:IDataBufferedOutput, useWS:Boolean) {
			this.rawOutputStream = outputStream;
			this.outputStream = new ByteArray();
			this.useWS = useWS;
		}

		private function flush():void {
			var a:uint;	
			outputStream.position = 0;
			if (useWS) {
				rawOutputStream.writeByte(0);
				while (outputStream.bytesAvailable) {
					a = outputStream.readUnsignedByte();
					if (a < 128) {
						if (a == 0) {
							rawOutputStream.writeByte(196);
							rawOutputStream.writeByte(128);
						} else {
							rawOutputStream.writeByte(a);
						}
					} else {
						if (a < 192) {
							rawOutputStream.writeByte(194);
							rawOutputStream.writeByte(a);
						} else {
							rawOutputStream.writeByte(195);
							rawOutputStream.writeByte(a - 64);
						}
					}
				}
				rawOutputStream.writeByte(255);
			} else {
				rawOutputStream.writeBytes(outputStream);
			}

			rawOutputStream.flush();
			outputStream = new ByteArray();
		}
		
		public function writeWebSocketsHandshake(hostport:String, key1:String, key2:String, key3:String):void {
			var i:uint, url:String = FlexGlobals.topLevelApplication.loaderInfo.url;
			rawOutputStream.writeUTFBytes(StringUtil.substitute(wsHandshake, hostport, url.slice(0, url.indexOf("/", 10)+1), key1, key2));
			for (i=0; i<key3.length; i++) {
				rawOutputStream.writeByte(key3.charCodeAt(i));
			}
			rawOutputStream.flush();
		}

		public function writeRFBVersion(rfbMajorVersion:Number, rfbMinorVersion:Number):void {
			this.rfbMajorVersion = rfbMajorVersion;
			this.rfbMinorVersion = rfbMinorVersion;
			var majorS:String = (rfbMajorVersion < 100 ? '0' : '') + (rfbMajorVersion < 10 ? '0' : '') + rfbMajorVersion;
			var minorS:String = (rfbMinorVersion < 100 ? '0' : '') + (rfbMinorVersion < 10 ? '0' : '') + rfbMinorVersion;
			outputStream.writeUTFBytes("RFB "+majorS+"."+minorS+"\n");

			flush();
		}
		
		public function writeSecurityType(securityType:uint):void {
			outputStream.writeByte(securityType);
			flush();
		}
		
		public function writeSecurityVNCAuthChallenge(challenge:ByteArray):void {
			outputStream.writeBytes(challenge,0,16);
			flush();
		}
		
		public function writeClientInit(shareConnection:Boolean):void {
			outputStream.writeByte(shareConnection ? 1 : 0);
			flush();
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
			flush();
		}
		
		public function writeSetEncodings(encodings:Array):void {
			outputStream.writeByte(VNCConst.CLIENT_SET_ENCODINGS);
			outputStream.writeByte(0);
			
			outputStream.writeShort(encodings.length);
			for each (var encoding:uint in encodings) {
				outputStream.writeUnsignedInt(encoding);
			}
			flush();
		}
		
		public function writeFramebufferUpdateRequest(incremental:Boolean, rectangle:Rectangle):void {
			outputStream.writeByte(VNCConst.CLIENT_FRAMEBUFFER_UPDATE);
			
			outputStream.writeByte(incremental ? 1 : 0);
			outputStream.writeShort(rectangle.x);
			outputStream.writeShort(rectangle.y);
			outputStream.writeShort(rectangle.width);
			outputStream.writeShort(rectangle.height);
			
			flush();
		}
		
		public function writeKeyEvent(keyDown:Boolean, keyCode:uint, flush:Boolean = true):void {
			outputStream.writeByte(VNCConst.CLIENT_KEY_EVENT);
			
			outputStream.writeByte(keyDown ? 1 : 0);
			outputStream.writeByte(0);
			outputStream.writeByte(0);
			outputStream.writeUnsignedInt(keyCode);
			
			if (flush) this.flush();
		}
		
		public function writePointerEvent(buttonMask:uint, position:Point):void {
			outputStream.writeByte(VNCConst.CLIENT_POINTER_EVENT);
			
			outputStream.writeByte(buttonMask);
			outputStream.writeShort(position.x);
			outputStream.writeShort(position.y);
			
			flush();
		}

	}
}
