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
	import mx.controls.Menu;
	import mx.controls.PopUpMenuButton;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
		
	use namespace mx_internal;

	public class BetterPopUpMenuButton extends PopUpMenuButton {
		
		private var _selectedItem:*;
		
		public function BetterPopUpMenuButton() {
			addEventListener(MenuEvent.ITEM_CLICK, onChangeItem);
		}
		
		private function onChangeItem(event:MenuEvent):void {
			var oldValue:* = _selectedItem;
			_selectedItem = event.item;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE,false,false,PropertyChangeEventKind.UPDATE,"selectedItem",oldValue,_selectedItem,this));
		}
		
		[Bindable]
		public function get selectedItem():* {
			return _selectedItem;
		}
		
		public function set selectedItem(item:*):void {
			var oldValue:* = _selectedItem;
			_selectedItem = item
			var popUpMenu:Menu = Menu(getPopUp());
			popUpMenu.selectedItem = item;
			popUpMenu.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE,false,false,PropertyChangeEventKind.UPDATE,"selectedItem",oldValue,_selectedItem,this));
		}
	}
}