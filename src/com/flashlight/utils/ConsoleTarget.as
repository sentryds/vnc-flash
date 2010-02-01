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
	import mx.controls.Text;
	import mx.logging.targets.LineFormattedTarget;
	import mx.core.mx_internal;
	
	use namespace mx_internal;

	public class ConsoleTarget extends LineFormattedTarget {
		private var output:Text;
		
		public function ConsoleTarget(output:Text) {
			super();
			this.output = output;
			includeCategory = true;
			includeDate = true;
			includeLevel = true;
			includeTime = true;
		}
		
		override mx_internal function internalLog(message:String):void {
			if (output.text.length > 5000) output.text = "";
			output.text += message +"\n";
		}
		
	}
}