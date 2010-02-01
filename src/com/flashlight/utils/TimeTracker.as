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

package com.flashlight.utils
{
	import flash.utils.getTimer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class TimeTracker {
		private static var logger:ILogger = Log.getLogger("TimeTracker");
		
		private static var timers:Object = new Object();
		private static var timersStart:Object = new Object();
		
		private static function startTimer(name:String):void {
			timersStart[name] = getTimer();
		}
		
		private static function stopTimer(name:String):void {
			if (!(timers[name])) timers[name] = 0;
			
			timers[name] += (getTimer()-timersStart[name]);
		}
		
		private static function logTimers():void {
			for (var n:String in timers) {
				logger.info(n+': '+timers[n]);
			}
		}
	}
}