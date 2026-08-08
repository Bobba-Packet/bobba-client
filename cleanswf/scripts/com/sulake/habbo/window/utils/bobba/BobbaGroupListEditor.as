package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IBitmapWrapperController;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.core.window.utils.MouseCursorControl;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   
   public class BobbaGroupListEditor
   {
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_list";
      
      private static const ART_PATH:String = "group-chat.png";
      
      private static const ART_UNREAD_PATH:String = "group-chat-unread.png";
      
      private static const BUTTON_W:int = 120;
      
      private static const BUTTON_H:int = 43;
      
      private static const BUTTON_Y:int = 409;
      
      private static const BUTTON_MARGIN:int = 12;
      
      // bully_report row: icon ends ~x36, stock labels start at x37 (~1px gap).
      private static const ROW_TEXT_X:int = 52;
      
      private static const ROW_TEXT_RIGHT:int = 255;
      
      // Stock user_avatar widget is 33x34 at (3,4); art is 33x33.
      private static const ICON_SIZE:int = 33;
      
      private static const ICON_SLOT_X:int = 3;
      
      private static const ICON_SLOT_Y:int = 4;
      
      private static const ICON_SLOT_H:int = 34;
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _template:IWindowController_1;
      
      private var _groups:Array;
      
      private var _pendingCount:int = 0;
      
      private var _invitesButton:IWindowModel;
      
      private var _groupIconData:BitmapData;
      
      private var _groupUnreadIconData:BitmapData;
      
      private var _artLoader:Loader;
      
      private var _unreadArtLoader:Loader;
      
      public function BobbaGroupListEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
         _groups = [];
      }
      
      public function get visible() : Boolean
      {
         return _window != null && Boolean(_window.visible);
      }
      
      public function set visible(value:Boolean) : void
      {
         if(value)
         {
            if(_window == null)
            {
               createWindow();
            }
            else
            {
               _window.visible = true;
               _window.activate();
               updateRoomMouseBlockRect();
            }
            refreshPendingCaption();
            populateGroups();
         }
         else if(_window != null)
         {
            _window.visible = false;
            removeRoomMouseBlockRect();
         }
      }
      
      public function setGroups(groups:Array) : void
      {
         _groups = groups != null ? groups : [];
         populateGroups();
      }
      
      public function setPendingCount(count:int) : void
      {
         _pendingCount = count;
         refreshPendingCaption();
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         disposeArtLoader();
         disposeUnreadArtLoader();
         if(_groupIconData != null)
         {
            _groupIconData.dispose();
            _groupIconData = null;
         }
         if(_groupUnreadIconData != null)
         {
            _groupUnreadIconData.dispose();
            _groupUnreadIconData = null;
         }
         _invitesButton = null;
         if(_template != null)
         {
            _template.dispose();
            _template = null;
         }
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
         _controller = null;
         _groups = null;
      }
      
      private function createWindow() : void
      {
         var list:IItemListWindow = null;
         var first:IWindowController_1 = null;
         var createBtn:IWindowModel = null;
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"bully_report") as IFrameController;
            if(_window == null)
            {
               if(_windowManager != null)
               {
                  _windowManager.simpleAlert(BobbaI18n.t("group.title"),BobbaI18n.t("group.alert.error"),BobbaI18n.t("group.error.layout_bully_report"));
               }
               return;
            }
            _window.caption = BobbaI18n.t("group.list.title");
            createBtn = _window.findChildByName("submit_button");
            if(createBtn != null)
            {
               createBtn.caption = BobbaI18n.t("group.list.create");
               createBtn.width = BUTTON_W;
               createBtn.height = BUTTON_H;
            }
            ensureInvitesButton(createBtn);
            layoutBottomButtons();
            list = _window.findChildByName("user_list") as IItemListWindow;
            if(list != null)
            {
               list.spacing = 4;
               if(list.numListItems > 0)
               {
                  first = list.getListItemAt(0) as IWindowController_1;
                  if(first != null)
                  {
                     _template = first.clone() as IWindowController_1;
                  }
                  list.removeListItems();
               }
            }
            setPanelText(BobbaI18n.t("group.list.hint"));
            refreshPendingCaption();
            loadGroupIcon();
            _window.procedure = windowProcedure;
            _window.center();
            layoutBottomButtons();
            _window.visible = true;
            _window.activate();
            populateGroups();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
            Logger.log("[BobbaGroupChat] list createWindow failed #" + e.errorID + " " + e.message);
            try
            {
               if(_window != null)
               {
                  _window.dispose();
               }
            }
            catch(disposeErr:Error)
            {
            }
            _window = null;
            _invitesButton = null;
            _template = null;
            if(_windowManager != null)
            {
               _windowManager.simpleAlert(BobbaI18n.t("group.title"),BobbaI18n.t("group.alert.error"),e.message);
            }
         }
      }
      
      private function ensureInvitesButton(createBtn:IWindowModel) : void
      {
         var layout:XML = null;
         var built:IWindowModel = null;
         if(_invitesButton != null)
         {
            return;
         }
         try
         {
            if(createBtn is IWindowController_1)
            {
               _invitesButton = (createBtn as IWindowController_1).clone();
            }
         }
         catch(cloneErr:Error)
         {
            _invitesButton = null;
         }
         if(_invitesButton == null)
         {
            layout = <layout name="bobba_invites_button" width="120" height="43" version="0.1">
                  <window>
                     <button x="0" y="0" width="120" height="43" params="131281" style="101" name="invites_button" caption="Invites" color="0x0bbbbbb"/>
                  </window>
               </layout>;
            built = _windowManager.buildFromXML(layout,1);
            _invitesButton = built;
            if(_invitesButton != null && _invitesButton.name != "invites_button" && built.findChildByName("invites_button") != null)
            {
               _invitesButton = built.findChildByName("invites_button");
            }
         }
         if(_invitesButton != null)
         {
            _invitesButton.name = "invites_button";
            _invitesButton.caption = BobbaI18n.t("group.list.invites");
         }
      }
      
      private function layoutBottomButtons() : void
      {
         var createBtn:IWindowModel = null;
         var host:IWindowController_1 = null;
         var hostW:int = 0;
         if(_window == null)
         {
            return;
         }
         try
         {
            createBtn = _window.findChildByName("submit_button");
            if(createBtn != null && createBtn.parent is IWindowController_1)
            {
               host = createBtn.parent as IWindowController_1;
            }
            else if(_window.content != null)
            {
               host = _window.content;
            }
            else
            {
               host = _window as IWindowController_1;
            }
            if(host == null)
            {
               return;
            }
            hostW = host.width > 0 ? int(host.width) : int(_window.width);
            if(_invitesButton != null)
            {
               if(_invitesButton.parent != host)
               {
                  try
                  {
                     if(_invitesButton.parent != null)
                     {
                        IWindowController_1(_invitesButton.parent).removeChild(_invitesButton);
                     }
                  }
                  catch(remErr:Error)
                  {
                  }
                  host.addChild(_invitesButton);
               }
               _invitesButton.name = "invites_button";
               _invitesButton.width = BUTTON_W;
               _invitesButton.height = BUTTON_H;
               _invitesButton.x = BUTTON_MARGIN;
               _invitesButton.y = BUTTON_Y;
            }
            if(createBtn != null)
            {
               createBtn.width = BUTTON_W;
               createBtn.height = BUTTON_H;
               createBtn.x = hostW - BUTTON_MARGIN - BUTTON_W;
               createBtn.y = BUTTON_Y;
            }
            if(_invitesButton != null && createBtn != null)
            {
               _invitesButton.y = createBtn.y;
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] layoutBottomButtons failed",err.message);
         }
      }
      
      private function setPanelText(value:String) : void
      {
         var panel:IItemListWindow = null;
         var child:IWindowModel = null;
         try
         {
            if(_window == null)
            {
               return;
            }
            panel = _window.findChildByName("user_panel") as IItemListWindow;
            if(panel != null && panel.numListItems > 1)
            {
               child = panel.getListItemAt(1);
               if(child != null)
               {
                  child.caption = value;
               }
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function refreshPendingCaption() : void
      {
         var panel:IItemListWindow = null;
         try
         {
            if(_window == null)
            {
               return;
            }
            panel = _window.findChildByName("user_panel") as IItemListWindow;
            if(panel != null && panel.numListItems > 0)
            {
               panel.getListItemAt(0).caption = BobbaI18n.t("group.list.your_groups");
            }
            if(_invitesButton != null)
            {
               _invitesButton.caption = _pendingCount > 0 ? BobbaI18n.format("group.list.invites_count",_pendingCount) : BobbaI18n.t("group.list.invites");
            }
            if(_pendingCount > 0)
            {
               setPanelText(BobbaI18n.t("group.list.pending_hint"));
            }
            else
            {
               setPanelText(BobbaI18n.t("group.list.hint"));
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function populateGroups() : void
      {
         var list:IItemListWindow = null;
         var i:int = 0;
         var row:IWindowController_1 = null;
         var g:Object = null;
         var count:int = 0;
         var unread:int = 0;
         var caption:String = null;
         var nameField:IWindowModel = null;
         var roomField:IWindowModel = null;
         if(_window == null || _template == null)
         {
            return;
         }
         try
         {
            list = _window.findChildByName("user_list") as IItemListWindow;
            if(list == null)
            {
               return;
            }
            list.spacing = 4;
            list.removeListItems();
            for(i = 0; i < _groups.length; i++)
            {
               g = _groups[i];
               if(g == null)
               {
                  continue;
               }
               count = int(g.memberCount);
               unread = int(g.unreadCount);
               row = _template.clone() as IWindowController_1;
               if(row == null)
               {
                  continue;
               }
               row.name = String(g.id);
               row.blend = 1;
               row.procedure = onGroupRowEvent;
               nameField = row.findChildByName("user_name");
               if(nameField != null)
               {
                  nameField.x = ROW_TEXT_X;
                  nameField.width = ROW_TEXT_RIGHT - ROW_TEXT_X;
                  nameField.caption = String(g.name);
               }
               roomField = row.findChildByName("room_name");
               if(roomField != null)
               {
                  roomField.x = ROW_TEXT_X;
                  roomField.width = ROW_TEXT_RIGHT - ROW_TEXT_X;
                  caption = count == 1 ? BobbaI18n.format("group.list.member_one",count) : BobbaI18n.format("group.list.member_many",count);
                  if(unread > 0)
                  {
                     caption += " · " + (unread == 1 ? BobbaI18n.format("group.list.unread_one",unread) : BobbaI18n.format("group.list.unread_many",unread));
                  }
                  else
                  {
                     caption += BobbaI18n.t("group.list.click_to_open");
                  }
                  roomField.caption = caption;
               }
               applyGroupIcon(row,unread > 0);
               list.addListItem(row);
            }
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] populateGroups failed #" + err.errorID + " " + err.message);
         }
      }
      
      private function applyGroupIcon(row:IWindowController_1, unread:Boolean = false) : void
      {
         var avatar:IWindowModel = null;
         var icon:IBitmapWrapperController = null;
         var existing:IWindowModel = null;
         var layout:XML = null;
         var built:IWindowModel = null;
         var src:BitmapData = null;
         if(row == null)
         {
            return;
         }
         try
         {
            avatar = row.findChildByName("user_avatar");
            if(avatar != null)
            {
               avatar.visible = false;
            }
            src = unread && _groupUnreadIconData != null ? _groupUnreadIconData : _groupIconData;
            if(src == null || _windowManager == null)
            {
               return;
            }
            existing = row.findChildByName("bobba_group_row_icon");
            if(existing != null)
            {
               icon = existing as IBitmapWrapperController;
               if(icon != null)
               {
                  icon.bitmap = src.clone();
                  icon.visible = true;
                  alignGroupIcon(icon,avatar);
               }
               return;
            }
            layout = <layout name="bobba_group_row_icon" width="33" height="33" version="0.1">
                  <window>
                     <bitmap x="0" y="0" width="33" height="33" params="17" style="100" name="bobba_group_row_icon">
                        <variables>
                           <var key="stretched_x" value="false" type="Boolean"/>
                           <var key="stretched_y" value="false" type="Boolean"/>
                           <var key="fit_size_to_contents" value="true" type="Boolean"/>
                        </variables>
                     </bitmap>
                  </window>
               </layout>;
            built = _windowManager.buildFromXML(layout,1);
            icon = built as IBitmapWrapperController;
            if(icon == null && built != null)
            {
               icon = built.findChildByName("bobba_group_row_icon") as IBitmapWrapperController;
            }
            if(icon == null)
            {
               return;
            }
            icon.name = "bobba_group_row_icon";
            icon.procedure = onGroupRowEvent;
            icon.bitmap = src.clone();
            icon.visible = true;
            alignGroupIcon(icon,avatar);
            row.addChild(icon);
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] applyGroupIcon failed #" + err.errorID + " " + err.message);
         }
      }
      
      private function alignGroupIcon(icon:IWindowModel, avatar:IWindowModel) : void
      {
         var slotX:int = ICON_SLOT_X;
         var slotY:int = ICON_SLOT_Y;
         var slotW:int = ICON_SIZE;
         var slotH:int = ICON_SLOT_H;
         if(icon == null)
         {
            return;
         }
         if(avatar != null)
         {
            slotX = avatar.x;
            slotY = avatar.y;
            if(avatar.width > 0)
            {
               slotW = avatar.width;
            }
            if(avatar.height > 0)
            {
               slotH = avatar.height;
            }
         }
         icon.x = slotX + int((slotW - ICON_SIZE) / 2) + 8;
         icon.y = slotY + int((slotH - ICON_SIZE) / 2);
      }
      
      private function findGroupRow(target:IWindowModel) : IWindowModel
      {
         var row:IWindowModel = target;
         var i:int = 0;
         var g:Object = null;
         while(row != null)
         {
            for(i = 0; i < _groups.length; i++)
            {
               g = _groups[i];
               if(g != null && String(g.id) == row.name)
               {
                  return row;
               }
            }
            row = row.parent;
         }
         return null;
      }
      
      private function loadGroupIcon() : void
      {
         var url:String = null;
         disposeArtLoader();
         try
         {
            url = BobbaPack.resolveUrl(ART_PATH);
            if(url == null || url.length == 0)
            {
               return;
            }
            _artLoader = new Loader();
            _artLoader.contentLoaderInfo.addEventListener("complete",onGroupIconLoaded);
            _artLoader.contentLoaderInfo.addEventListener("ioError",onGroupIconError);
            _artLoader.load(new URLRequest(url));
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] group icon load start failed #" + err.errorID + " " + err.message);
         }
         loadUnreadGroupIcon();
      }
      
      private function loadUnreadGroupIcon() : void
      {
         var url:String = null;
         disposeUnreadArtLoader();
         try
         {
            url = BobbaPack.resolveUrl(ART_UNREAD_PATH);
            if(url == null || url.length == 0)
            {
               return;
            }
            _unreadArtLoader = new Loader();
            _unreadArtLoader.contentLoaderInfo.addEventListener("complete",onUnreadGroupIconLoaded);
            _unreadArtLoader.contentLoaderInfo.addEventListener("ioError",onUnreadGroupIconError);
            _unreadArtLoader.load(new URLRequest(url));
         }
         catch(err:Error)
         {
         }
      }
      
      private function onGroupIconLoaded(evt:Event) : void
      {
         var bmp:Bitmap = null;
         try
         {
            if(_artLoader == null)
            {
               return;
            }
            bmp = _artLoader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            if(_groupIconData != null)
            {
               _groupIconData.dispose();
            }
            _groupIconData = bmp.bitmapData.clone();
            populateGroups();
         }
         catch(err:Error)
         {
            Logger.log("[BobbaGroupChat] group icon loaded failed #" + err.errorID + " " + err.message);
         }
         disposeArtLoader();
      }
      
      private function onGroupIconError(evt:Event) : void
      {
         Logger.log("[BobbaGroupChat] group icon load error");
         disposeArtLoader();
      }
      
      private function disposeArtLoader() : void
      {
         if(_artLoader != null)
         {
            try
            {
               _artLoader.contentLoaderInfo.removeEventListener("complete",onGroupIconLoaded);
               _artLoader.contentLoaderInfo.removeEventListener("ioError",onGroupIconError);
               _artLoader.unload();
            }
            catch(err:Error)
            {
            }
            _artLoader = null;
         }
      }
      
      private function onUnreadGroupIconLoaded(evt:Event) : void
      {
         var bmp:Bitmap = null;
         try
         {
            if(_unreadArtLoader == null)
            {
               return;
            }
            bmp = _unreadArtLoader.content as Bitmap;
            if(bmp == null || bmp.bitmapData == null)
            {
               return;
            }
            if(_groupUnreadIconData != null)
            {
               _groupUnreadIconData.dispose();
            }
            _groupUnreadIconData = bmp.bitmapData.clone();
            populateGroups();
         }
         catch(err:Error)
         {
         }
         disposeUnreadArtLoader();
      }
      
      private function onUnreadGroupIconError(evt:Event) : void
      {
         disposeUnreadArtLoader();
      }
      
      private function disposeUnreadArtLoader() : void
      {
         if(_unreadArtLoader != null)
         {
            try
            {
               _unreadArtLoader.contentLoaderInfo.removeEventListener("complete",onUnreadGroupIconLoaded);
               _unreadArtLoader.contentLoaderInfo.removeEventListener("ioError",onUnreadGroupIconError);
               _unreadArtLoader.unload();
            }
            catch(err:Error)
            {
            }
            _unreadArtLoader = null;
         }
      }
      
      private function onGroupRowEvent(event:WindowEvent, target:IWindowModel) : void
      {
         var row:IWindowModel = null;
         var g:Object = null;
         var i:int = 0;
         if(event == null || _controller == null)
         {
            return;
         }
         if(event.type == "WME_OVER")
         {
            MouseCursorControl.type = 2;
            return;
         }
         if(event.type == "WME_OUT")
         {
            MouseCursorControl.type = 0;
            return;
         }
         if(event.type != "WME_CLICK")
         {
            return;
         }
         row = findGroupRow(target);
         if(row == null)
         {
            return;
         }
         for(i = 0; i < _groups.length; i++)
         {
            g = _groups[i];
            if(g != null && String(g.id) == row.name)
            {
               _controller.openGroup(String(g.id),String(g.name));
               return;
            }
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK")
         {
            if(target.name == "header_button_close")
            {
               visible = false;
               return;
            }
            if(target.name == "submit_button")
            {
               if(_controller != null)
               {
                  _controller.openCreate();
               }
               return;
            }
            if(target.name == "invites_button")
            {
               if(_controller != null)
               {
                  _controller.showPendingInvites();
               }
               return;
            }
         }
         if(event.type == "WE_RELOCATED" || event.type == "WE_RESIZED" || event.type == "WME_UP")
         {
            updateRoomMouseBlockRect();
         }
      }
      
      private function updateRoomMouseBlockRect() : void
      {
         var rect:Rectangle = null;
         try
         {
            if(_window == null || !_window.visible || _windowManager == null || _windowManager.roomEngine == null)
            {
               removeRoomMouseBlockRect();
               return;
            }
            rect = new Rectangle();
            _window.getGlobalRectangle(rect);
            _windowManager.roomEngine.setMouseEventsDisabledRect(MOUSE_BLOCK_KEY,rect);
         }
         catch(errBlock:Error)
         {
         }
      }
      
      private function removeRoomMouseBlockRect() : void
      {
         try
         {
            if(_windowManager != null && _windowManager.roomEngine != null)
            {
               _windowManager.roomEngine.removeMouseEventsDisabledRect(MOUSE_BLOCK_KEY);
            }
         }
         catch(errRemove:Error)
         {
         }
      }
   }
}
