/**
 * Trial Rich Information Application Library (TRIAL)
 * Online Education Technology Group (OETG) @ DT Education & Technology
 */
package com.dtedu.trial.utils
{
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;

    public function createContextMenuEntry(contextMenu:ContextMenu, title:String, handler:Function = null, separator:Boolean = false):void
    {
        if (contextMenu.hasOwnProperty("customItems"))
        {
            if (contextMenu["customItems"] == null)
            {
                contextMenu["customItems"] = new Array();
            }
            var cmi:ContextMenuItem = new ContextMenuItem(title, separator);
            if (handler != null)
            {
                cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handler, false, 0, true); 
            }
            contextMenu["customItems"]["push"](cmi);
        }
        else
        {
            // TODO implementation for Air
        }
    }
}