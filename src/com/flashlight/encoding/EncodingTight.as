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
	import com.flashlight.pixelformats.RFBPixelFormat1bpp;
	import com.flashlight.pixelformats.RFBPixelFormat24bpp;
	import com.flashlight.pixelformats.RFBPixelFormat8bpp;
	import com.flashlight.pixelformats.RFBPixelFormatGradient;
	import com.flashlight.rfb.RFBReaderListener;
	import com.flashlight.zlib.Inflater;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.JPEGLoaderContext;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class EncodingTight implements Encoding {
		private static var logger:ILogger = Log.getLogger("EncodingTight");					
		
		public static const MIN_ZLIB_COMPRESSED:int  	= 12;
		public static const MAX_SUBENCODING:int 		= 0x09;
		
		public static const SUB_ENC_FILTER:int 			= 0x04;
		public static const SUB_ENC_FILL:int			= 0x08;
		public static const SUB_ENC_JPEG:int			= 0x09;
		
		public static const FILTER_COPY:int				= 0x00;
		public static const FILTER_PALETTE:int			= 0x01;
		public static const FILTER_GRADIENT:int			= 0x02;
						
		private static function readCompactLen(inputStream:IDataInput):uint {
			var len:uint = inputStream.readUnsignedByte();
			if ((len & 0x80) != 0) len = (len & 0x7F) | (inputStream.readUnsignedByte() << 7);
			if ((len & 0x4000) != 0) len = (len & 0x3FFF) | (inputStream.readUnsignedByte() << 14);
			return len;
		}
		
		private static const pixelFormat24bpp:RFBPixelFormat = new RFBPixelFormat24bpp();
		
		private var jpegLoaderContext:LoaderContext = null;
		
		private var inflaters:Array = [];
		
		private	var jpegLoaders:Array = new Array();
		private	var jpegLoaderIndex:int = 0;
		
		public function EncodingTight() {
			jpegLoaderContext = new JPEGLoaderContext(1,false,Application.application.loaderInfo.applicationDomain,null);
		}
		
		public function getReader(inputStream:IDataInput, listener:RFBReaderListener, rectangle:Rectangle, pixelFormat:RFBPixelFormat):Object {
			pixelFormat = pixelFormat.bitsPerPixel == 32 ? pixelFormat24bpp : pixelFormat;
			
			var zlibStreamId:int;
			
			var readTightHeader:Object = {
				name:'readTightHeader',
				bytesNeeded: 1,
				read: function():Object {
					var subEncodingCode:uint = inputStream.readUnsignedByte();
					
					for (var i:int = 0; i<4; i++) {
						if (subEncodingCode & 1) inflaters[i] = null;
						subEncodingCode >>= 1;
					}
					
					//logger.info('subEncodingCode '+subEncodingCode);
					
					if (subEncodingCode == SUB_ENC_JPEG) return readTightJpeg;
					if (subEncodingCode == SUB_ENC_FILL) return readTightFill;
					
					zlibStreamId = subEncodingCode & 0x03;
					
					if (subEncodingCode & SUB_ENC_FILTER) return readTightExplicitFilter;
					
					return uncompressTightData;
				}
			}
			
			var readTightFill:Object = {
				name: 'readTightFill',
				bytesNeeded: pixelFormat.getPixelDataSize(),
				read: function():Object {
					var color:uint = pixelFormat.readPixel(inputStream);
					listener.onUpdateFillRectangle(rectangle,color);
					return null;
				}
			}
			
			
			var readTightExplicitFilter:Object = {
				name: 'readTightExplicitFilter',
				bytesNeeded: 1,
				read: function():Object {
					var filterCode:uint = inputStream.readUnsignedByte();
					
					switch (filterCode) {
						case FILTER_PALETTE :
							return readTightPalette;
						break;
						case FILTER_GRADIENT :
							pixelFormat = new RFBPixelFormatGradient(pixelFormat);
						break;
						case FILTER_COPY :
						break;
						default :
							throw new Error("Incorrect Tight filter id : "+ filterCode);
					}
					
					return uncompressTightData;
				}
			}
			
			var readTightPalette:Object = {
				name: 'readTightPalette',
				bytesNeeded: 1,
				read: function():Object {
					var paletteSize:uint = inputStream.readUnsignedByte()+1;
					
					return {
						name: 'readTightPaletteColors',
						bytesNeeded: pixelFormat.getPixelDataSize()*paletteSize,
						read: function():Object {
							var palette:Array = [];
							for (var i:int=0;i<paletteSize;i++) {
								palette[i] = pixelFormat.readPixel(inputStream);
							}
							
							if (paletteSize == 2) {
								pixelFormat = new RFBPixelFormat1bpp(palette);
							} else {
								pixelFormat = new RFBPixelFormat8bpp(palette);
							}
							
							return uncompressTightData;
						}
					}
				}
			}
			
			var uncompressTightData:Object = {
				name: 'uncompressTightData',
				bytesNeeded: 0,
				read: function():Object {
					var dataSize:uint = pixelFormat.getPixelsDataSize(rectangle.width,rectangle.height);
					
					//logger.info("dataSize "+dataSize);
					
					if (dataSize < MIN_ZLIB_COMPRESSED) return getReadTightData();
					
					return {
						name: 'readTightZlibLen',
						bytesNeeded: 3,
						read: function():Object {
							var zlibDataLen:uint = readCompactLen(inputStream);
							
							//logger.info('zlibDataLen '+zlibDataLen);
							
							return {
								name: 'readTightZlibData',
								bytesNeeded: zlibDataLen,
								read: function():Object {
									var compressedData:ByteArray = new ByteArray();
									inputStream.readBytes(compressedData,0,zlibDataLen);
									
									
									
									var inflater:Inflater = inflaters[zlibStreamId];
									if (!inflater) {
										inflater = new Inflater();
										inflaters[zlibStreamId] = inflater;
									}
									
									var data:ByteArray = inflater.uncompress(compressedData);
									var pixels:ByteArray = pixelFormat.readPixels(rectangle.width,rectangle.height,data);
									listener.onUpdateRectangle(rectangle,pixels);
						
									return null;
								}
							}
						}
					};
				}
			}
			
			function getReadTightData():Object {
				return {
					name: 'readTightData',
					bytesNeeded: pixelFormat.getPixelsDataSize(rectangle.width, rectangle.height),
					read: function():Object {
						var pixels:ByteArray = pixelFormat.readPixel(inputStream);
						listener.onUpdateRectangle(rectangle,pixels);
						return null;
					}
				}
			}
			
			var readTightJpeg:Object = {
				name: 'readTightJpeg',
				bytesNeeded: 3,
				read: function():Object {
					var jpegDataLength:uint = readCompactLen(inputStream);
					
					return {
						name: 'readTightJpegData',
						bytesNeeded: jpegDataLength,
						read: function():Object {
							var jpegData:ByteArray = new ByteArray();
							var loader:Loader = new Loader();
							
							inputStream.readBytes(jpegData,0,jpegDataLength);
							loader.loadBytes(jpegData,jpegLoaderContext);
							loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
								var jpegImage:Bitmap = loader.content as Bitmap;
								var point:Point = new Point(rectangle.x, rectangle.y);
								listener.onUpdateRectangleBitmapData(point, jpegImage.bitmapData);
								loader.unload();
							});
							
							return null;
						}
					}
				}
			}
			
			return readTightHeader;
		}
	}
}