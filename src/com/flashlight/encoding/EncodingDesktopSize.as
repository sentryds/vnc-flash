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
	import flash.utils.IDataInput;
	
	public class EncodingDesktopSize implements Encoding {
		
		public function getReader(inputStream:IDataInput, listener:RFBReaderListener, rectangle:Rectangle, pixelFormat:RFBPixelFormat):Object {			
			return {
				name:'EncodingDesktopSize',
				bytesNeeded: 0,
				read: function():Object {
					listener.onChangeDesktopSize(rectangle.width, rectangle.height);
					return null;
				}
			}
		}
	}
}