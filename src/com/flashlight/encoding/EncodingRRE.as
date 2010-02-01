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
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.IDataInput;
	
	public class EncodingRRE implements Encoding {
		
		public function getReader(inputStream:IDataInput, listener:RFBReaderListener, rectangle:Rectangle, pixelFormat:RFBPixelFormat):Object {
					
			return {
				name: 'EncodingRRE',
				bytesNeeded: 4 + pixelFormat.getPixelDataSize(),
				read: function():Object {
					var rectanglesNumber:int = inputStream.readUnsignedInt();
					var backgroundColor:uint = pixelFormat.readPixel(inputStream);
					var bitmapData:BitmapData = new BitmapData(rectangle.width, rectangle.height,false,backgroundColor);
					
					return {
						bytesNeeded: (pixelFormat.getPixelDataSize() + 8) * rectanglesNumber,
						read: function():Object {
							for (var i:int = 0;i<rectanglesNumber;i++) {
								var color:uint = pixelFormat.readPixel(inputStream);
								var subRect:Rectangle = new Rectangle(
									inputStream.readUnsignedShort(),
									inputStream.readUnsignedShort(),
									inputStream.readUnsignedShort(),
									inputStream.readUnsignedShort()
								);
								bitmapData.fillRect(subRect,color);
							}
							
							listener.onUpdateRectangleBitmapData(new Point(rectangle.x,rectangle.y),bitmapData);
							
							return null;
						}
					}
				}
			}
		}
	}
}