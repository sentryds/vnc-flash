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

package com.flashlight.components
{
	import mx.containers.Box;

	public class ScaleBox extends Box {
		override protected function measure():void {
			// Fix Flex bug.
			// Box should not measure content if clipContent = true ...
	        measuredMinWidth = 0;
	        measuredMinHeight = 0;
	        measuredWidth = 0;
	        measuredHeight = 0;
	    }
	}
}