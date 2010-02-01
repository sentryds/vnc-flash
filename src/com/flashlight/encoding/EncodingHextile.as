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
	
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class EncodingHextile implements Encoding {
		private static var logger:ILogger = Log.getLogger("EncodingHextile");
		
		private static const MASK_SUBENCTYPE_RAW:int = 1;
		private static const MASK_SUBENCTYPE_BACKGROUND:int = 2;
		private static const MASK_SUBENCTYPE_FOREGROUND:int = 4;
		private static const MASK_SUBENCTYPE_HASSUBRECT:int = 8;
		private static const MASK_SUBENCTYPE_SUBCOLORED:int = 16;
		
		public function getReader(inputStream:IDataInput, listener:RFBReaderListener, bigRectangle:Rectangle, pixelFormat:RFBPixelFormat):Object {
			
			var subRectColored:Boolean;
			var colorBackground:uint = 0;
			var colorForeground:uint = 0;
			
			var x:uint = bigRectangle.x;
			var y:uint = bigRectangle.y;
			var maxX:uint = bigRectangle.x + bigRectangle.width;
			var maxY:uint = bigRectangle.y + bigRectangle.height;
			var w:uint;
			var h:uint;
			
			var rectangle:Rectangle;
			
			var readBackgroundColor:Object = {
				name: 'readBackgroundColor',
				bytesNeeded: pixelFormat.getPixelDataSize(),
				read: function():Object {
					colorBackground = pixelFormat.readPixel(inputStream);
					//logger.info('colorBackground '+colorBackground.toString(16));
					return null;
				}
			}
			
			var readForegroundColor:Object = {
				name: 'readForegroundColor',
				bytesNeeded: pixelFormat.getPixelDataSize(),
				read: function():Object {
					colorForeground = pixelFormat.readPixel(inputStream);
					//logger.info('colorForeground '+colorBackground.toString(16));
					return null;
				}
			}
			
			var readSubRectNumber:Object = {
				name: 'readSubRectNumber',
				bytesNeeded: 1,
				read: function():Object {
					var subRectNumber:uint = inputStream.readUnsignedByte();
					
					//logger.info('subRectNumber '+subRectNumber);
					
					if (subRectNumber == 0) throw new Error("Subrect number can't be 0");
					
					return {
							name: 'readSubRectData',
							bytesNeeded: subRectNumber*(subRectColored ? pixelFormat.getPixelDataSize() + 2 : 2),
							read: function():Object {
								var stack:Array = new Array();
								for (var i:int = 0 ; i < subRectNumber; i++) {
									var color:uint = subRectColored ? pixelFormat.readPixel(inputStream) : colorForeground;
									var position:int = inputStream.readUnsignedByte();
									var size:int = inputStream.readUnsignedByte();
									
									var positionX:uint = (position >> 4) + rectangle.x;
									var positionY:uint = (position & 0xF) + rectangle.y;
									var sizeX:uint = (size >> 4) + 1;
									var sizeY:uint = (size & 0xF) + 1;
									
									//logger.info(positionX+' '+positionY+' '+sizeX+' '+sizeY+' '+color.toString(16));
									
									var subRect:Rectangle = new Rectangle(positionX,positionY,sizeX,sizeY);
									
									listener.onUpdateFillRectangle(subRect,color);
								}
								
								return null;
							}
						};
				}
			}
			
			var drawRectBackground:Object = {
				name: 'drawRectBackground',
				bytesNeeded: 0,
				read: function():Object {
					listener.onUpdateFillRectangle(rectangle,colorBackground);
					return null;
				}
			}
			
			var nextSubRect:Object = {
				name: 'nextSubRect',
				bytesNeeded: 0,
				read: function():Object {
					x += 16;
					if (x >= maxX) {
						y += 16;
						if (y >= maxY) return null;
						
						x = bigRectangle.x;
					}
					
					return readTileHeader;
				}
			}
			
			var readTileHeader:Object = {
				name: 'readTileHeader',
				bytesNeeded: 1,
				read: function():Object {
					
					w = Math.min(16,maxX - x);
					h = Math.min(16,maxY - y);
					rectangle = new Rectangle(x,y,w,h);
					
					var subencodingType:int = inputStream.readUnsignedByte();
					
					
					//logger.info(rectangle.x+' '+rectangle.y+' '+rectangle.width+' '+rectangle.height+' '+subencodingType.toString(16));
					
					if (subencodingType & MASK_SUBENCTYPE_RAW) {
						return {
							name: 'readRawTile',
							bytesNeeded: pixelFormat.getPixelsDataSize(rectangle.height,rectangle.width),
							read: function():Object {
								var pixels:ByteArray = pixelFormat.readPixels(rectangle.width, rectangle.height, inputStream);
								listener.onUpdateRectangle(rectangle,pixels);
								return nextSubRect;
							}
						}
					}
					
					var readerStack:Array = new Array();
					
					if (subencodingType & MASK_SUBENCTYPE_BACKGROUND) readerStack.push(readBackgroundColor);
					if (subencodingType & MASK_SUBENCTYPE_FOREGROUND) readerStack.push(readForegroundColor);
					readerStack.push(drawRectBackground);
					if (subencodingType & MASK_SUBENCTYPE_HASSUBRECT) readerStack.push(readSubRectNumber);
					subRectColored = (subencodingType & MASK_SUBENCTYPE_SUBCOLORED) != 0;
					readerStack.push(nextSubRect);
					
					return readerStack;
				}
			}
			
			return readTileHeader;
		}
	}
}