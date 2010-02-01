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

package com.flashlight.zlib
{
	import flash.utils.ByteArray;
	
	public class Inflater {
		private var lastDeflate:ByteArray;
		
		public function uncompress(compressedData:ByteArray):ByteArray {
			var uncompressedData:ByteArray = new ByteArray();
			var dataOffset:int = lastDeflate ? 0 : 2;
			
			if (lastDeflate) {
				var dictionarySize:int = lastDeflate.length > 32768 ? 32768 : lastDeflate.length;
				uncompressedData.writeByte(0x00);
				uncompressedData.writeByte(dictionarySize );
				uncompressedData.writeByte(dictionarySize >> 8);
				uncompressedData.writeByte(~dictionarySize);
				uncompressedData.writeByte((~dictionarySize) >> 8 );
				uncompressedData.writeBytes(lastDeflate,lastDeflate.length - dictionarySize, dictionarySize);
			}
			
			uncompressedData.writeBytes(compressedData,dataOffset,compressedData.length-dataOffset);
			uncompressedData.writeByte(0x01);
			uncompressedData.writeUnsignedInt(0x0000FFFF);
			
			uncompressedData.inflate();
			
			lastDeflate = uncompressedData;
			uncompressedData.position = dictionarySize;
			
			return uncompressedData;
		}

	}
}