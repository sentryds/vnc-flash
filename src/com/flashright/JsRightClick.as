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

package com.flashright {
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.ByteArrayAsset;
	import mx.logging.ILogger;
	import mx.logging.Log;
			
	public class JsRightClick {
		private var logger:ILogger = Log.getLogger("JSRightClick");
			
		[Embed(source="JsRightClick.js", mimeType="application/octet-stream")]
 		private var rightClickScriptClass:Class;

		private var altShiftClickEnabled:Boolean = false; 			
		private var downPoint:Point;
			
		public function JsRightClick() {
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			 				
			if (ExternalInterface.available) {
				var rightClickScriptAsset:ByteArrayAsset = ByteArrayAsset(new rightClickScriptClass());
 				var rightClickScript:String = rightClickScriptAsset.readUTFBytes(rightClickScriptAsset.length);
 				
 				var ref:String = (Math.random()).toString();
		        ExternalInterface.addCallback(ref,new Function());
				ExternalInterface.call("(function(identifier) {"+rightClickScript+"})", ref);
				ExternalInterface.addCallback('sendRightClickEvent',sendRightClickEvent);
				
				var infoItem:ContextMenuItem = new ContextMenuItem("Right-click not supported on your browser");
				infoItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onInfoItemSelected);
				contextMenu.customItems.push(infoItem);
			}
			
			var altShiftClickItem:ContextMenuItem = new ContextMenuItem("Enable Alt+Shift+Click for right-click");
			altShiftClickItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onAltShiftClickItem);
			contextMenu.customItems.push(altShiftClickItem);
			
			Application.application.contextMenu = contextMenu;
		}
		
		private function onInfoItemSelected(event:ContextMenuEvent):void {
			Alert.show("Right-click integration is not supported on Safari Mac due to a Safari bug");
		}
		
		private function onAltShiftClickItem(event:ContextMenuEvent):void {
			var altShiftClickItem:ContextMenuItem = ContextMenuItem(event.target);
			if (!altShiftClickEnabled) {
				altShiftClickEnabled = true;
				altShiftClickItem.caption = "Disable Alt+Shift+Click for right-click";
				Application.application.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, true);
				Application.application.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
				Application.application.addEventListener(MouseEvent.CLICK, onMouseClick, true);
			} else {
				altShiftClickEnabled = false;
				altShiftClickItem.caption = "Enable Alt+Shift+Click for right-click";
				Application.application.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, true);
				Application.application.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
				Application.application.removeEventListener(MouseEvent.CLICK, onMouseClick, true);
			}
		}
		
		private function onMouseDown(event:MouseEvent):void {
			if (event.altKey && event.shiftKey) {
				sendEvent(RightMouseEvent.RIGHT_MOUSE_DOWN,new Point(event.stageX,event.stageY),event.ctrlKey,event.altKey,event.shiftKey,event.buttonDown);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if (event.altKey && event.shiftKey) {
				sendEvent(RightMouseEvent.RIGHT_MOUSE_UP,new Point(event.stageX,event.stageY),event.ctrlKey,event.altKey,event.shiftKey,event.buttonDown);
			}
		}
		
		private function onMouseClick(event:MouseEvent):void {
			if (event.altKey && event.shiftKey) {
				sendEvent(RightMouseEvent.RIGHT_CLICK,new Point(event.stageX,event.stageY),event.ctrlKey,event.altKey,event.shiftKey,event.buttonDown);
			}
		}
		
		private function getRelatedObject(location:Point):InteractiveObject {
			var objects:Array = Application.application.getObjectsUnderPoint(location);
		    for (var i:int = objects.length - 1; i >= 0; i--) {
		        if (objects[i] is InteractiveObject) {
		            return objects[i] as InteractiveObject;
		        } else {
		        	if (objects[i].parent && objects[i].parent is InteractiveObject) {
		        		return objects[i].parent;
		        	}
		        }
		    }
		    return null;
		}
		
		private function sendRightClickEvent(down:Boolean,ctrlKey:Boolean,shiftKey:Boolean,altKey:Boolean):void {

			var eventPoint:Point = new Point(Application.application.mouseX, Application.application.mouseY);
	
			if (down) {
				sendEvent(RightMouseEvent.RIGHT_MOUSE_DOWN,eventPoint,ctrlKey,altKey,shiftKey,true);
				downPoint = eventPoint;
			} else {
				sendEvent(RightMouseEvent.RIGHT_MOUSE_UP,eventPoint,ctrlKey,altKey,shiftKey,false);
				if (downPoint && downPoint.x == eventPoint.x && downPoint.y == eventPoint.y) {
					sendEvent(RightMouseEvent.RIGHT_CLICK,eventPoint,ctrlKey,altKey,shiftKey,false);
				}
			}
		}
		
		private function sendEvent(type:String, location:Point, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean, buttonDown:Boolean):void {
			var obj:InteractiveObject = getRelatedObject(location);
			
			if (obj) {
				var localLocation:Point = obj.globalToLocal(location);
				var event:RightMouseEvent = new RightMouseEvent(type,true,false,localLocation.x,localLocation.y,obj,ctrlKey,altKey,shiftKey,buttonDown);
				obj.dispatchEvent(event);
			}
		}
	}
}