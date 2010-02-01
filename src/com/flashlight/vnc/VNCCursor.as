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

package com.flashlight.vnc
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class VNCCursor extends Bitmap {
		private static var logger:ILogger = Log.getLogger("VNCCursor");
		
		private var hotSpot:Point;
		
		public function VNCCursor() {
			smoothing = true;
			visible = false;
			hotSpot = new Point(0,0);
		}
		
		public function moveTo(newX:int,newY:int):void {
			x = newX - hotSpot.x;
			y = newY - hotSpot.y;
		}
		
		public function changeShape(bitmapData:BitmapData, hotSpot:Point):void {
			this.bitmapData = bitmapData;
			x = x + this.hotSpot.x - hotSpot.x;
			y = y + this.hotSpot.y - hotSpot.y;
			this.hotSpot = hotSpot;
			visible = true;
			smoothing = true;
		}

	}
}