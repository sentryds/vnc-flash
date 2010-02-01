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
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import mx.events.PropertyChangeEvent;
	
	public class VNCSettings extends EventDispatcher {
		[Bindable] public var host:String = "localhost";
		[Bindable] public var port:int = 5900;
		[Bindable] public var useSecurity:Boolean = true;
		[Bindable] public var securityPort:int = 1234;
		[Bindable] public var encoding:int = VNCConst.ENCODING_TIGHT;
		[Bindable] public var colorDepth:int = 24;
		[Bindable] public var jpegCompression:int = 6;
		[Bindable] public var viewOnly:Boolean = false;
		[Bindable] public var shared:Boolean = true;
		[Bindable] public var scale:Boolean = true;
		
		private var so:SharedObject;
		
		public function bindToSharedObject():void {
			so = SharedObject.getLocal("settings");
			if (so != null && so.data != null) {
				if (so.data.host) {
					host = so.data.host;
					port = so.data.port;
					useSecurity = so.data.useSecurity;
					securityPort = so.data.securityPort;
					encoding = so.data.encoding;
					colorDepth = so.data.colorDepth;
					jpegCompression = so.data.jpegCompression;
					viewOnly = so.data.viewOnly;
					shared = so.data.shared;
					scale = so.data.scale;
				}
				
				addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
			}
		}
		
		private function onPropertyChange(event:PropertyChangeEvent):void {
			
			if (so != null && so.data != null) {
				so.data.host = host;
				so.data.port = port;
				so.data.useSecurity = useSecurity;
				so.data.securityPort = securityPort;
				so.data.encoding = encoding;
				so.data.colorDepth = colorDepth;
				so.data.jpegCompression = jpegCompression;
				so.data.viewOnly = viewOnly;
				so.data.shared = shared;
				so.data.scale = scale;
				
				so.flush();
			}
		}

	}
}