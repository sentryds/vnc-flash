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

package com.flashlight.rfb
{
	import com.flashlight.pixelformats.RFBPixelFormat;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public interface RFBReaderListener {
		function onRFBVersion(rfbMajorVersion:Number, rfbMinorVersion:Number):void;
		function onSecurityTypes(securityTypes:Array):void;
		function onSecurityVNCAuthChallenge(challenge:ByteArray):void;
		function onSecurityOk():void;
		function onServerInit(framebufferWidth:uint,framebufferHeight:uint,serverPixelFormat:RFBPixelFormat,serverName:String):void;
		function onServerBell():void;
		function onServerCutText(text:String):void;
		function onUpdateRectangle(rectangle:Rectangle, pixels:ByteArray):void;
		function onUpdateRectangleBitmapData(point:Point, bitmapData:BitmapData):void;
		function onUpdateFillRectangle(rectangle:Rectangle, color:uint):void;
		function onCopyRectangle(rectangle:Rectangle, source:Point):void;
		function onUpdateFramebufferBegin():void;
		function onUpdateFramebufferEnd():void;
		function onChangeCursorPos(position:Point):void;
		function onChangeCursorShape(cursorShape:BitmapData, hotSpot:Point):void;
		function onChangeDesktopSize(width:int,height:int):void;
	}
}