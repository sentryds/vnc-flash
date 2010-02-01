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
	import com.flashlight.encoding.EncodingCopyRect;
	import com.flashlight.encoding.EncodingCursor;
	import com.flashlight.encoding.EncodingCursorPos;
	import com.flashlight.encoding.EncodingDesktopSize;
	import com.flashlight.encoding.EncodingHextile;
	import com.flashlight.encoding.EncodingRRE;
	import com.flashlight.encoding.EncodingRaw;
	import com.flashlight.encoding.EncodingTight;
	import com.flashlight.pixelformats.RFBPixelFormat;
	import com.flashlight.vnc.VNCConst;
	
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class RFBReader {
		private static var logger:ILogger = Log.getLogger("RFBReader");
		
		private var inputStream:IDataInput;
		private var listener:RFBReaderListener;
		
		private var rfbMajorVersion:Number;
		private var rfbMinorVersion:Number;
		private var readerStack:Array = [];
		
		private var encodings:Object = new Object();
		
		private var pixelFormat:RFBPixelFormat;
		
		private var readVNCAuthChallenge:Object;
		
		public function RFBReader(inputStream:IDataInput, listener:RFBReaderListener) {
			this.listener = listener;
			this.inputStream = inputStream;
			
			var readVersion:Object = {
				name: 'readVersion',
				bytesNeeded: 12,
				read: function():Object {
					var regExp:RegExp = new RegExp(/RFB (\d{3})\.(\d{3})\n/);
					
					var version:String = inputStream.readUTFBytes(12);
					
					if (!regExp.test(version)) throw new Error("Cannot parse server version: " +version);
					
					var result:Object = regExp.exec(version);
					var serverRfbMajorVersion:Number = result[1];
					var serverRfbMinorVersion:Number = result[2];
					
					listener.onRFBVersion(serverRfbMajorVersion, serverRfbMinorVersion);
					
					return null;
				}
			};
				
			var readSecurity:Object = {
				name: 'readSecurity',
				bytesNeeded: 0,
				read: function():Object {
					if (rfbMajorVersion >= 3 && rfbMinorVersion >= 7) {
						return readSecurityTypesList;
					} else {
						return readSecurityType;
					}
				}
			};
				
			var readSecurityType:Object =  {
				name: 'readSecurityType',
				bytesNeeded: 4,
				read: function():Object {
					var securityType:uint = inputStream.readInt();
					
					if (securityType == VNCConst.SECURITY_TYPE_INVALID) return readErrorMessage;
										
					setSecurityType(securityType);
					
					return null;
				}
			};
				
			var readSecurityTypesList:Object = {
				name: 'readSecurityTypesList',
				bytesNeeded: 1,
				read: function():Object {
					var typesListLength:uint = inputStream.readUnsignedByte();
					
					if (typesListLength == 0)  return readErrorMessage;
					
					return {
						name: 'readSecurityTypesListData',
						bytesNeeded: typesListLength,
						read: function():Object {
							var securityTypes:Array = new Array();
							while (typesListLength > 0) {
								securityTypes.push(inputStream.readUnsignedByte());
								typesListLength--;
							}
							
							listener.onSecurityTypes(securityTypes);
							
							return null;
						}
					}
				}
			};
				
			var readSecurityResult:Object = {
				name: 'readSecurityResult',
				bytesNeeded: 4,
				read: function():Object {
					var securityResult:uint = inputStream.readInt();
					
					if (securityResult == VNCConst.SECURITY_RESULT_FAILED) return readErrorMessage;
					
					if (securityResult != VNCConst.SECURITY_RESULT_OK) throw new Error("Unsupported security result: "+securityResult);
	
					listener.onSecurityOk();
					
					return null;
				}
			};
				
			readVNCAuthChallenge = {
				name: 'readVNCAuthChallenge',
				bytesNeeded: 16,
				read: function():Object {
					var challenge:ByteArray = new ByteArray();
					inputStream.readBytes(challenge,0,16);
					
					listener.onSecurityVNCAuthChallenge(challenge);
					
					return null;
				}
			};
				
			var readServerInit:Object = {
				name: 'readServerInit',
				bytesNeeded: 24,
				read: function():Object {
					var framebufferWidth:uint = inputStream.readUnsignedShort();
					var framebufferHeight:uint = inputStream.readUnsignedShort();
					var serverPixelFormat:RFBPixelFormat = new RFBPixelFormat({
						bitsPerPixel: inputStream.readUnsignedByte(),
						depth: inputStream.readUnsignedByte(),
						bigEndian: inputStream.readBoolean(),
						trueColor: inputStream.readBoolean(),
						maxRed: inputStream.readUnsignedShort(),
						maxGreen: inputStream.readUnsignedShort(),
						maxBlue: inputStream.readUnsignedShort(),
						shiftRed: inputStream.readUnsignedByte(),
						shiftGreen: inputStream.readUnsignedByte(),
						shiftBlue: inputStream.readUnsignedByte()
					});
					
					// padding
					inputStream.readByte();
					inputStream.readByte();
					inputStream.readByte();
					
					var nameLength:uint = inputStream.readUnsignedInt();
	
					return {
						name: 'readServerName',
						bytesNeeded: nameLength,
						read: function():Object {
							var serverName:String = inputStream.readUTFBytes(nameLength);
							
							logger.debug(serverName);
							
							listener.onServerInit(framebufferWidth,framebufferHeight,serverPixelFormat,serverName);
					
							return null;
						}
					}
				}
			};
				
			var readMessage:Object = {
				name: 'readMessage',
				bytesNeeded: 1,
				read: function():Object {
					var messageType:uint = inputStream.readByte();
					
					readerStack.push(readMessage);
					
					//logger.info('message '+messageType);
					
					switch (messageType) {
						case VNCConst.SERVER_FRAMEBUFFER_UPDATE:
							readerStack.push(readFramebufferUpdate);
							break;
						case VNCConst.SERVER_SET_COLORMAP:
							readerStack.push(readColormap);
							break;
						case VNCConst.SERVER_CUT_TEXT:
							readerStack.push(readCutText);
							break;
						case VNCConst.SERVER_BELL:
							listener.onServerBell();
							break;
						default:
							throw new Error("Unknown server message type: "+messageType);
					}
					
					return null;
				}
			};
				
			var readFramebufferUpdate:Object = {
				name: 'readFramebufferUpdate',
				bytesNeeded: 3,
				read: function():Object {
					// padding
					inputStream.readByte();
					
					listener.onUpdateFramebufferBegin();
					
					readerStack.push(readFramebufferUpdateEnd);
					
					var numberOfRectangle:uint = inputStream.readUnsignedShort();
					
					// logger.info('numberOfRectangle '+numberOfRectangle);
					
					if (numberOfRectangle == 0) return null;
					
					var readRectangleUpdate:Object = {
						name: 'readRectangleUpdate',
						bytesNeeded: 12,
						read: function():Object {
							
							numberOfRectangle--;
							if (numberOfRectangle > 0) {
								readerStack.push(readRectangleUpdate);
							}
							
							var rectangle:Rectangle = new Rectangle(
								inputStream.readUnsignedShort(),
								inputStream.readUnsignedShort(),
								inputStream.readUnsignedShort(),
								inputStream.readUnsignedShort());
								
								
					//logger.info('rectangle '+rectangle);
							
							var encodingType:uint = inputStream.readInt();
							
							if (encodings[encodingType] == undefined) throw new Error("Unknown encoding type: "+encodingType.toString(16));
														
							logger.debug('encodingType ' +encodingType);
	
							return encodings[encodingType].getReader(inputStream, listener, rectangle,pixelFormat);
						}
					}
					
					return readRectangleUpdate;
				}
			};
				
			var readFramebufferUpdateEnd:Object = {
				name: 'readFramebufferUpdateEnd',
				bytesNeeded: 0,
				read: function():Object {
					listener.onUpdateFramebufferEnd();
					return null;
				}
			};
				
			var readColormap:Object = {
				name: 'readColormap',
				bytesNeeded: 5,
				read: function():Object {
					// padding
					inputStream.readByte();
					
					var firstColor:uint = inputStream.readUnsignedShort();
					var numberOfEntries:uint = inputStream.readUnsignedShort();
					//logger.info('firstColor '+firstColor);
					//logger.info('numberOfEntries '+numberOfEntries);
					
					return {
						name: 'readColormapData',
						bytesNeeded: numberOfEntries*6,
						read: function():Object {
							var colorMap:Array = new Array();
							
							for (var i:int=firstColor; i<numberOfEntries+firstColor; i++) {
								var red:uint = inputStream.readUnsignedShort() >>> 8;
								var blue:uint = inputStream.readUnsignedShort() >>> 8;
								var green:uint = inputStream.readUnsignedShort() >>> 8;
								
								colorMap[i] = (red << 16) | (blue << 8) | green;
							}
							
							pixelFormat.updatePalette(colorMap);
							
							return null;
						}
					}
				}
			};
				
			var readCutText:Object = {
				name: 'readCutText',
				bytesNeeded: 7,
				read: function():Object {
					// padding
					inputStream.readByte();
					inputStream.readByte();
					inputStream.readByte();
					
					var textLength:uint = inputStream.readUnsignedInt();
					
					return {
						name: 'readCutTextData',
						bytesNeeded: textLength,
						read: function():Object {
							var cutText:String = inputStream.readUTFBytes(textLength);
							listener.onServerCutText(cutText);
							return null;
						}
					}
				}
			};
				
			var readErrorMessage:Object = {
				name: 'readErrorMessage',
				bytesNeeded: 4,
				read: function():Object {
					var messageLength:uint = inputStream.readUnsignedInt();
					
					return {
						name: 'readErrorMessageData',
						bytesNeeded: messageLength,
						read: function():Object {
							var errorMessage:String = inputStream.readUTFBytes(messageLength);
							throw new Error("Connection refused: "+errorMessage);
						}
					}
				}
			};
			
			readerStack.unshift(readVersion);
			readerStack.unshift(readSecurity);
			readerStack.unshift(readSecurityResult);
			readerStack.unshift(readServerInit);
			readerStack.unshift(readMessage);
			
			encodings[VNCConst.ENCODING_TIGHT] = new EncodingTight();
			encodings[VNCConst.ENCODING_HEXTILE] = new EncodingHextile();
			encodings[VNCConst.ENCODING_RRE] = new EncodingRRE();
			encodings[VNCConst.ENCODING_RAW] = new EncodingRaw();
			encodings[VNCConst.ENCODING_COPYRECT] = new EncodingCopyRect();
			encodings[VNCConst.ENCODING_CURSOR] = new EncodingCursor();
			encodings[VNCConst.ENCODING_DESKTOPSIZE] = new EncodingDesktopSize();
			encodings[VNCConst.ENCODING_CURSOR_POS] = new EncodingCursorPos();
		}
		
		public function readData():void {
			var nextReader:Object = readerStack.pop();
			
			while (nextReader.bytesNeeded <= inputStream.bytesAvailable) {
				try {
					logger.debug(">> "+nextReader.name);
					var newNextReader:Object = nextReader.read();
					logger.debug("<< "+nextReader.name);
					if (newNextReader is Array) {
						while (newNextReader.length > 0) {
							readerStack.push(newNextReader.pop());
						}
						nextReader = null;
					} else {
						nextReader = newNextReader;
					}
				} catch (e:Error) {
					throw new RFBReaderError(nextReader ? nextReader.name : 'null' , e);
				}
				
				if (!nextReader) nextReader = readerStack.pop();
			}
			
			logger.debug(nextReader.name+' '+nextReader.bytesNeeded+' '+inputStream.bytesAvailable);
				
			readerStack.push(nextReader);
		}
		
		public function setRFBVersion(rfbMajorVersion:Number, rfbMinorVersion:Number):void {
			this.rfbMajorVersion = rfbMajorVersion;
			this.rfbMinorVersion = rfbMinorVersion;
		}
		
		public function setSecurityType(securityType:uint):void {
			switch (securityType) {
				case VNCConst.SECURITY_TYPE_NONE:
					// Skip security result if auth==NONE and version < 3.8 
					if (!(rfbMajorVersion >= 3 && rfbMinorVersion >= 8)) readerStack.pop();
					break;
				case VNCConst.SECURITY_TYPE_VNC_AUTH:
					readerStack.push(readVNCAuthChallenge);
					break;
				default:
					throw new Error("Unhandled security Type: "+securityType);
			}
		}
		
		public function setPixelFormat(pixelFormat:RFBPixelFormat):void {
			this.pixelFormat = pixelFormat;
		}

	}
}