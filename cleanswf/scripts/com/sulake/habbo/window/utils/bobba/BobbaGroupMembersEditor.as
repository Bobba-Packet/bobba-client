package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowController_1;
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.components.IItemListWindow;
   import com.sulake.core.window.components.IWidgetWindowController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import com.sulake.habbo.window.widgets.IAvatarImageWidget;
   import flash.geom.Rectangle;
   
   public class BobbaGroupMembersEditor
   {
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_members";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _template:IWindowController_1;
      
      private var _members:Array;
      
      public function BobbaGroupMembersEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
         _members = [];
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
            populateMembers();
         }
         else if(_window != null)
         {
            _window.visible = false;
            removeRoomMouseBlockRect();
         }
      }
      
      public function setMembers(members:Array, groupName:String) : void
      {
         _members = members != null ? members : [];
         if(_window != null)
         {
            _window.caption = "Membros" + (groupName != null && groupName.length > 0 ? " - " + groupName : "");
         }
         populateMembers();
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
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
         _members = null;
      }
      
      private function createWindow() : void
      {
         var list:IItemListWindow = null;
         var first:IWindowController_1 = null;
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"bully_report") as IFrameController;
            if(_window == null)
            {
               return;
            }
            _window.caption = "Membros";
            if(_window.findChildByName("submit_button") != null)
            {
               _window.findChildByName("submit_button").visible = false;
            }
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
            setPanelText("Integrantes deste chat em grupo.");
            setTitle("Membros do grupo");
            _window.procedure = windowProcedure;
            _window.center();
            _window.visible = true;
            _window.activate();
            populateMembers();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
         }
      }
      
      private function setTitle(value:String) : void
      {
         var panel:IItemListWindow = null;
         try
         {
            panel = _window.findChildByName("user_panel") as IItemListWindow;
            if(panel != null && panel.numListItems > 0)
            {
               panel.getListItemAt(0).caption = value;
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function setPanelText(value:String) : void
      {
         var panel:IItemListWindow = null;
         var child:IWindowModel = null;
         try
         {
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
      
      private function populateMembers() : void
      {
         var list:IItemListWindow = null;
         var i:int = 0;
         var row:IWindowController_1 = null;
         var m:Object = null;
         var roleLabel:String = null;
         if(_window == null || _template == null)
         {
            return;
         }
         list = _window.findChildByName("user_list") as IItemListWindow;
         if(list == null)
         {
            return;
         }
         list.spacing = 4;
         list.removeListItems();
         for(i = 0; i < _members.length; i++)
         {
            m = _members[i];
            row = _template.clone() as IWindowController_1;
            row.name = "member_" + i;
            row.blend = 1;
            roleLabel = String(m.role) == "owner" ? "dono" : "membro";
            row.findChildByName("user_name").caption = String(m.nickname);
            row.findChildByName("room_name").caption = roleLabel;
            try
            {
               IAvatarImageWidget(IWidgetWindowController(row.findChildByName("user_avatar")).widget).figure = m.figure != null ? String(m.figure) : "";
            }
            catch(figErr:Error)
            {
            }
            list.addListItem(row);
         }
      }
      
      private function windowProcedure(event:WindowEvent, target:IWindowModel) : void
      {
         if(event == null || target == null)
         {
            return;
         }
         if(event.type == "WME_CLICK" && target.name == "header_button_close")
         {
            visible = false;
            return;
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
