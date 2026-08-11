package com.sulake.habbo.window.utils.bobba
{
   import com.sulake.core.window.IWindowModel;
   import com.sulake.core.window.components.IFrameController;
   import com.sulake.core.window.events.WindowEvent;
   import com.sulake.habbo.window.HabboWindowManagerComponent;
   import flash.geom.Rectangle;
   
   public class BobbaGroupLeaveConfirmEditor
   {
      
      private static const MOUSE_BLOCK_KEY:String = "bobba_group_leave_confirm";
      
      private var _windowManager:HabboWindowManagerComponent;
      
      private var _controller:BobbaGroupChatController;
      
      private var _window:IFrameController;
      
      private var _groupId:String = "";
      
      public function BobbaGroupLeaveConfirmEditor(windowManager:HabboWindowManagerComponent, controller:BobbaGroupChatController)
      {
         super();
         _windowManager = windowManager;
         _controller = controller;
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
         }
         else if(_window != null)
         {
            _window.visible = false;
            removeRoomMouseBlockRect();
         }
      }
      
      public function setLeave(groupId:String, groupName:String) : void
      {
         _groupId = groupId != null ? groupId : "";
         if(_window == null)
         {
            createWindow();
         }
         if(_window == null)
         {
            return;
         }
         try
         {
            _window.caption = BobbaI18n.t("group.leave.title");
            if(_window.findChildByName("request_title") != null)
            {
               _window.findChildByName("request_title").caption = BobbaI18n.t("group.leave.question");
            }
            if(_window.findChildByName("request_type") != null)
            {
               _window.findChildByName("request_type").caption = groupName != null && groupName.length > 0 ? groupName : BobbaI18n.t("group.chat.default_title");
            }
            if(_window.findChildByName("request_description") != null)
            {
               _window.findChildByName("request_description").caption = BobbaI18n.format("group.leave.description",groupName != null ? groupName : "");
            }
            if(_window.findChildByName("skip_link") != null)
            {
               _window.findChildByName("skip_link").caption = BobbaI18n.t("group.leave.cancel");
            }
            if(_window.findChildByName("accept_button") != null)
            {
               _window.findChildByName("accept_button").caption = BobbaI18n.t("group.leave.confirm");
            }
            if(_window.findChildByName("countdown") != null)
            {
               _window.findChildByName("countdown").visible = false;
               if(_window.findChildByName("countdown").parent != null)
               {
                  _window.findChildByName("countdown").parent.visible = false;
               }
            }
         }
         catch(err:Error)
         {
         }
      }
      
      public function dispose() : void
      {
         removeRoomMouseBlockRect();
         if(_window != null)
         {
            _window.dispose();
            _window = null;
         }
         _windowManager = null;
         _controller = null;
      }
      
      private function createWindow() : void
      {
         try
         {
            _window = BobbaHabboXml.getXmlWindow(_windowManager,"guide_accept") as IFrameController;
            if(_window == null)
            {
               return;
            }
            _window.procedure = windowProcedure;
            _window.center();
            _window.visible = true;
            _window.activate();
            updateRoomMouseBlockRect();
         }
         catch(e:Error)
         {
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
            if(target.name == "header_button_close" || target.name == "skip_link")
            {
               visible = false;
               return;
            }
            if(target.name == "accept_button")
            {
               if(_controller != null)
               {
                  _controller.leaveGroup(_groupId);
               }
               visible = false;
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
