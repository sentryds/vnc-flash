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

var f;
var objs = document.getElementsByTagName('object');
for (var objIndex in objs) {
    var obj = objs[objIndex];
    if (obj[identifier]) {
    	f = obj;
    	break;
    }
}

if (f.addEventListener) {
	var fc = f.parentNode;
	fc.addEventListener('mousedown', onMouseDown, true);
	fc.addEventListener('mouseup', onMouseUp, true);
} else if (f.attachEvent) {
	var fc = f.parentNode;
	fc.attachEvent('onmousedown', onMouseDown);
	fc.attachEvent('onmouseup', onMouseUp);
	document.oncontextmenu = function(){return window.event.srcElement != f; }
} else {
	f.onmousedown = onMouseDown;
	f.onmouseup = onMouseUp;
}

function onMouseDown(e) {
	if (!e) e = window.event;
	if (e.target && e.target != f) return;
	if (e.srcElement && e.srcElement != f) return;
	var c = false;
	if (e.which) c = (e.which == 3);
	else if (e.button) c = (e.button == 2);
	if (c) {
		f.sendRightClickEvent(true, e.ctrlKey, e.shiftKey, e.altKey);
		killEvent(e);
		if (!e.target) f.parentNode.setCapture();
	}
}

function onMouseUp(e) {
	if (!e) e = window.event;
	if (e.target && e.target != f) return;
	if (e.srcElement && e.srcElement != f) return;
	var c = false;
	if (e.which) c = (e.which == 3);
	else if (e.button) c = (e.button == 2);
	if (c) {
		f.sendRightClickEvent(false, e.ctrlKey, e.shiftKey, e.altKey);
		killEvent(e);
		if (!e.target) f.parentNode.releaseCapture();
	}
}

function killEvent(event) {
	if (event.preventDefault) {
		event.preventDefault();
	} else {
   		event.returnValue = false;
	}
	if (event.stopPropagation) {
		event.stopPropagation();
	} else {
		event.cancelBubble = true;
   	}
}