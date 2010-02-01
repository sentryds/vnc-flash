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
	public class VNCConst {
		public static const STATUS_NOT_CONNECTED:String = "Not connected";
		public static const STATUS_CONNECTING:String = "Connecting";
		public static const STATUS_WAITING_SERVER:String = "Waiting server";
		public static const STATUS_INITIATING:String = "Initiating";
		public static const STATUS_AUTHENTICATING:String = "Authenticating";
		public static const STATUS_CONNECTED:String = "Connected";
		
		public static const RFB_VERSION_MAJOR:uint = 3;
		public static const RFB_VERSION_MINOR:uint = 8;
		
		public static const SECURITY_TYPE_INVALID:uint = 0;
		public static const SECURITY_TYPE_NONE:uint = 1; 
		public static const SECURITY_TYPE_VNC_AUTH:uint = 2;
		public static const SECURITY_TYPE_RA2:uint = 5;
		public static const SECURITY_TYPE_RA2NE:uint = 6;
		public static const SECURITY_TYPE_TIGHT:uint = 16;
		public static const SECURITY_TYPE_ULTRA:uint = 17;
		public static const SECURITY_TYPE_TLS:uint = 18;
		public static const SECURITY_TYPE_VNECRYPT:uint = 19;
		public static const SECURITY_TYPE_GTK_SASL:uint = 20;
		public static const SECURITY_TYPE_PREFERRED_ORDER:Array = [SECURITY_TYPE_VNC_AUTH, SECURITY_TYPE_NONE];
		
		public static const SECURITY_RESULT_OK:uint = 0;
		public static const SECURITY_RESULT_FAILED:uint = 1;
		
		public static const CLIENT_SET_PIXELFORMAT:uint = 0;
		public static const CLIENT_SET_ENCODINGS:uint = 2;
		public static const CLIENT_FRAMEBUFFER_UPDATE:uint = 3;
		public static const CLIENT_KEY_EVENT:uint = 4;
		public static const CLIENT_POINTER_EVENT:uint = 5;
		public static const CLIENT_CUT_BUFFER:uint = 6;
		
		public static const SERVER_FRAMEBUFFER_UPDATE:uint 	= 0;
		public static const SERVER_SET_COLORMAP:uint 		= 1;
		public static const SERVER_BELL:uint 				= 2;
		public static const SERVER_CUT_TEXT:uint 			= 3;
		
		public static const MASK_MOUSE_BUTTON_LEFT:uint 	= 1;
		public static const MASK_MOUSE_BUTTON_MIDDLE:uint 	= 1 << 1;
		public static const MASK_MOUSE_BUTTON_RIGHT:uint 	= 1 << 2;
		public static const MASK_MOUSE_WHEEL_UP:uint 		= 1 << 3;
		public static const MASK_MOUSE_WHEEL_DOWN:uint 		= 1 << 4;
		
		public static const ENCODING_RAW:int 			= 0; 
		public static const ENCODING_COPYRECT:int 		= 1; 
		public static const ENCODING_RRE:int 			= 2;
		public static const ENCODING_HEXTILE:int 		= 5;
		public static const ENCODING_TIGHT:int			= 7;
		public static const ENCODING_ZRLE:int 			= 16;
		
   		public static const ENCODING_TIGHT_ZLIB_LEVEL:int	= -256;
   		public static const ENCODING_TIGHT_JPEG_QUALITY:int	= -32;
		public static const ENCODING_CURSOR:int 			= -239;
		public static const ENCODING_DESKTOPSIZE:int 		= -223;
   		public static const ENCODING_CURSOR_POS:int			= -232;
	}
}